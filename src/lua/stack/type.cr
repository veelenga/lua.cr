module Lua
  module StackMixin::Type
    # Returns type at `pos` in the stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << "hello"
    # stack.type_at(1) # => TSTRING
    # ```
    def type_at(pos : Int)
      TYPE.new LibLua.type(@state, pos)
    end

    # Returns name of the type at `pos` in the stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << "my_super_string"
    # stack << 42
    # stack.typename(1) # => "string"
    # stack.typename(2) # => "number"
    # ```
    def typename(pos : Int)
      typename type_at(pos)
    end

    # Returns name of the `type`.
    #
    # ```
    # stack = Lub::Stack.new
    # stack.typename(TYPE::TBOOLEAN) # => "boolean"
    # ```
    def typename(type : TYPE)
      String.new LibLua.typename(@state, type.value)
    end
  end
end
