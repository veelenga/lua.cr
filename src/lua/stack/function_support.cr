module Lua
  module StackMixin::FunctionSupport
    # Registers a Crystal `Proc` as a global Lua function under the given name.
    #
    # Argument types come from the proc's signature: each Lua argument is
    # converted to the matching Crystal type before the proc is called, and
    # the proc's return value is pushed back onto the Lua stack. A proc
    # returning `Nil` produces no Lua return value.
    #
    # ```
    # lua = Lua.load
    #
    # # inline proc literal
    # lua.function "add", ->(x : Float64, y : Float64) { x + y }
    # lua.run "return add(3, 4)" # => 7.0
    #
    # # closure over local state
    # counter = 0
    # lua.function "tick", -> { counter += 1; nil }
    # lua.run "tick(); tick()"
    # counter # => 2
    #
    # # method pointer
    # def greet(name : String)
    #   "Hi, #{name}"
    # end
    #
    # lua.function "greet", ->greet(String)
    # lua.run "return greet('Lua')" # => "Hi, Lua"
    # ```
    def function(name : String, proc : Proc(*Args, R)) forall Args, R
      libs_snapshot = libs.to_a
      arity = {{ Args.type_vars.size }}
      wrapper = ->(state : LibLua::State) do
        if LibLua.gettop(state) < arity
          raise ArgumentError.new("'#{name}' expects #{arity} argument(s)")
        end
        stack = Lua::Stack.new(state, libs_snapshot)
        {% if Args.type_vars.empty? %}
          result = proc.call
        {% else %}
          result = proc.call(
            {% for type, i in Args.type_vars %}
              ::LuaCallable::LuaConvert({{type}}).convert(stack[{{i + 1}}]),
            {% end %}
          )
        {% end %}
        {% if R.resolve == Nil %}
          0
        {% else %}
          stack << result
          1
        {% end %}
      end
      set_global(name, wrapper)
    end
  end
end
