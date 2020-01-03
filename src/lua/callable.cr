module LuaCallable
  def to_lua(stack : Lua::Stack)
    stack.pushobject(self)
  end

  struct LuaConvert(T)
    def self.convert(val : Lua::Type) : T
      {% begin %}
            {% type = @type.type_vars[0].resolve %}
            {% if type <= Nil %}
            return nil
            {% elsif type <= String %}
            return val.as(String)
            {% elsif type <= Bool %}
            return val.as(Bool)
            {% elsif type <= Int8 %}
            return val.as(Float64).to_i8
            {% elsif type <= Int16 %}
            return val.as(Float64).to_i16
            {% elsif type <= Int32 %}
            return val.as(Float64).to_i32
            {% elsif type <= Int64 %}
            return val.as(Float64).to_i64
            {% elsif type <= UInt8 %}
            return val.as(Float64).to_u8
            {% elsif type <= UInt16 %}
            return val.as(Float64).to_u16
            {% elsif type <= UInt32 %}
            return val.as(Float64).to_u32
            {% elsif type <= UInt64 %}
            return val.as(Float64).to_u64
            {% elsif type <= Float32 %}
            return val.as(Float64).to_f32
            {% elsif type <= Float64 %}
            return val.as(Float64)
            {% elsif type <= LuaCallable %}
            return val.as(Lua::Callable).to_crystal.as(T)
            {% else %}
            return val.as(T)
            {% end %}
        {% end %}
    end
  end

  macro _lua_new_instance
    {% verbatim do %}
      {% if !@type.abstract? %}
      def self.__new(state : LibLua::State) : Int32
        stack = Lua::Stack.new(state, :all)
        instance = {{@type.name}}.allocate
        instance.initialize
        stack << instance
        return 1
      end
      {% end %}
      macro inherited
        _lua_new_instance
      end
    {% end %}
  end

  def _call(key)
  end

  macro _lua_call
    def _call(key)
      {% verbatim do %}
      {% begin %}
      {% method_map = {} of StringLiteral => Def %}
      {% for m in @type.methods %}
        {% if m.visibility == :public %}
          {% method_map[m.name] = m %}
        {% end %}
      {% end %}
      {% for a in @type.ancestors %}
        {% if a < LuaCallable %}
          {% for m in a.methods %}
            {% if !method_map[m.name] && m.visibility == :public %}
              {% method_map[m.name] = m %}
            {% end %}
          {% end %}
        {% end %}
      {% end %}
      {% for k, m in method_map %}
          {% if !m.name.ends_with?("=") && !m.name.starts_with?("_") %}
          if key == "{{m.name}}"
              proc = ->(state : LibLua::State) {
                stack = Lua::Stack.new(state, :all)
                {% reverse_args = [] of Arg %}
                {% for a in m.args %}
                  {% reverse_args = reverse_args.unshift(a) %}
                {% end %}
                {% for a, index in reverse_args %}
                    {% if a.restriction.is_a?(Nop) %}
                        {{a.name}} = stack[-{{index + 1}}]
                    {% else %}
                        {{a.name}} = LuaConvert({{a.restriction}}).convert(stack[-{{index + 1}}])
                    {% end %}
                {% end %}
                {% if m.args.empty? %}
                res = self.{{m.name}}()
                {% else %}
                res = self.{{m.name}}({{(m.args.map &.name).join(",").id}})
                {% end %}
                stack << res
                return 1
              }
              return proc
          end
          {% end %}
      {% end %}
      super
      {% end %}
      {% end %}
    end
  end

  macro included
    _lua_new_instance

    macro finished
      _lua_call
    end
  end

  def _index(key : String)
    {% for m in @type.instance_vars %}
        {% if @type.has_method?(m.name) %} #only expose public fields
        if key == "{{m.name}}"
            return self.{{m.name}}
        end
        {% end %}
    {% end %}
    self._call(key)
  end

  def _newindex(key, val)
    {% for m in @type.instance_vars %}
        {% if @type.has_method?(m.name + "=") %} #only expose public fields
        if key == "{{m.name}}"
            self.{{m.name}} = val.as({{m.type}})
        end
        {% end %}
    {% end %}
  end

  def self.__index(state : LibLua::State) : Int32 # __index(t,k)
    stack = Lua::Stack.new(state, :all)
    key = String.new LibLua.tolstring(state, -1, nil)
    data = LibLua.touserdata(state, -2).as(LuaCallable*)
    pointer = data.value
    val = pointer._index(key)
    stack << val
    1
  end

  def self.__newindex(state : LibLua::State) : Int32
    stack = Lua::Stack.new(state, :all)
    data = LibLua.touserdata(state, -3).as(LuaCallable*)
    val = stack[-1]
    key = stack[-2]
    pointer = data.value
    pointer._newindex(key, val)
    0
  end

  def self.__gc(state : LibLua::State) : Int32
    0
  end

  def self.__call(state : LibLua::State) : Int32
    data = LibLua.topointer(state, Lua::REGISTRYINDEX - 1) # lua_upvalueindex(1)
    ptr = LibLua.topointer(state, Lua::REGISTRYINDEX - 2)  # lua_upvalueindex(2)
    proc = Proc(LibLua::State, Int32).new(ptr, data)
    proc.call(state)
  end
end
