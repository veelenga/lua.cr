module Lua
  class Stack

    getter! state

    # Initializes new Lua stack running in a new, independent state.
    # Has to be closed to call the corresponding garbage-collection
    # metamethods on Lua side.
    #
    # ```
    # stack = Lua::Stack.new
    # #...
    # stack.close
    # ```
    def initialize
      @state = LibLua.l_newstate
      LibLua.l_openlibs(@state)
    end

    # Destroys all objects in the given Lua state
    #
    # ```
    # stack = Lua::Stack.new
    # #...
    # stack.close
    # ```
    def close
      LibLua.close @state
    end

    # Adds Crystal object to Lua stack.
    #
    # ```
    # Lua::Stack.new.tap do |s|
    #   stack << 10
    #   stack << "str"
    #   stack << false
    #  end
    # ```
    def <<(o)
      case o
        when Nil then LibLua.pushnil(@state)
        when Int then LibLua.pushinteger(@state, o)
        when Float then LibLua.pushnumber(@state, o)
        when Bool then LibLua.pushboolean(@state, o ? 1 : 0)
        when Char then LibLua.pushstring(@state, o.to_s)
        when String then LibLua.pushstring(@state, o)
        when Symbol then LibLua.pushstring(@state, o.to_s)
        when Array, Tuple then push(o.to_a)
        when Hash, NamedTuple then push(o.to_h)
        # TODO: Proc
        else
          o.responds_to?(:to_lua) ? o.to_lua(@state) :
            raise ArgumentError.new(
              "unable to pass Crystal object of type #{typeof(o)} to Lua"
            )
      end
    end

    # Fetches value from the stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << 10.01
    # stack << "lua"
    # stack[1] #=> 10.01
    # stack[2] #=> "lua"
    # ```
    def [](pos : Int)
      return nil if pos == 0

      case type_at(pos)
        when Type::TNIL, Type::TNONE then nil

        when Type::TBOOLEAN
          LibLua.toboolean(@state, pos) == 1

        when Type::TNUMBER
          LibLua.tonumberx(@state, pos, nil)

        when Type::TSTRING
          String.new LibLua.tolstring(@state, pos, nil)

        when Type::TTABLE
          Table.new(self, pos)

        when Type::TFUNCTION then nil      # TBD
        when Type::TUSERDATA then nil      # TBD
        when Type::TTHREAD then nil        # TBD
        when Type::TLIGHTUSERDATA then nil # TBD
        else
          raise ArgumentError.new "unable to detect type of the object to fetch"
      end
    end

    # Represents the stack as a string.
    #
    # stack = Lua::Stack.new.tap do |s|
    #   s << 42.24
    #   s << false
    #   s << "hello!"
    # end
    # stack.to_s #=>
    #
    #   # 3 : TSTRING(string) hello!
    #   # 2 : TBOOLEAN(boolean) false
    #   # 1 : TNUMBER(number) 42.24
    #
    def to_s(io : IO)
      io << String.build do |acc|
        (1..top).reverse_each do |pos|
          type = type_at(pos)
          name = typename(type)

          acc << "#{pos} : #{type}(#{name}) #{self[pos]}\n"
        end
      end
    end

    # Returns the index of the top element in the stack.
    # Because indices start at 1, this result is equal to
    # the number of elements in the stack; in particular,
    # 0 means an empty stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack.top #=> 0
    # stack << 10
    # stack.top #=> 1
    # ```
    def top : Int
      LibLua.gettop(@state)
    end

    # Removes element from the top of the stack and returns it.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << 10.01
    # stack.top    #=> 1
    # stack.pop(1) #=> 10.01
    # stack.top    #=> 0
    # ```
    def pop
      self[top].tap { LibLua.settop(@state, -2) }
    end

    # Returns type at `pos` in the stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << "hello"
    # stack.type_at(1) #=> TSTRING
    # ```
    def type_at(pos : Int)
      Type.new LibLua.type(@state, pos)
    end

    # Returns name of the type at `pos` in the stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << "my_super_string"
    # stack << 42
    # stack.typename(1) #=> "string"
    # stack.typename(2) #=> "number"
    # ```
    def typename(pos : Int)
      typename type_at(pos)
    end

    # Returns name of the `type`.
    #
    # ```
    # stack = Lub::Stack.new
    # stack.typename(Type::TBOOLEAN) #=> "boolean"
    # ```
    def typename(type : Type)
      String.new LibLua.typename(@state, type.value)
    end

    private def push(a : Array)
      LibLua.createtable(@state, a.size, 0)
      settable(a.map_with_index { |e, i| [i + 1, e] }.to_h)
    end

    private def push(a : Hash)
      LibLua.createtable(@state, 0, a.size)
      settable a
    end

    private def settable(a : Hash)
      a.each do |k, v|
        self << k
        self << v
        LibLua.settable(@state, -3)
      end
    end
  end
end
