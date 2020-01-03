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
    # stack.typename(3) # => "no value"
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

    def crystal_type_at(pos : Int)
      if LibLua.getmetatable(@state, pos) == 0
        raise "Index #{pos} is not valid, or the value does not have a metatable!"
      end
      LibLua.pushstring(@state, TYPE_NAME_METAKEY)
      LibLua.gettable(@state, -2)
      type = self[-1].as(String)
      LibLua.settop(@state, -3) # remove metatable from stack
      type
    end

    def crystal_base_type_at(pos : Int)
      if LibLua.getmetatable(@state, pos) == 0
        raise "Index #{pos} is not valid, or the value does not have a metatable!"
      end
      LibLua.pushstring(@state, CRYSTAL_BASE_TYPE_METAKEY)
      LibLua.gettable(@state, -2)
      type = self[-1].as(String?)
      LibLua.settop(@state, -3) # remove type and metatable from stack
      type
    end

    def crystal_type_info_at(pos : Int)
      if LibLua.getmetatable(@state, pos) == 0
        raise "Index #{pos} is not valid, or the value does not have a metatable!"
      end
      LibLua.pushstring(@state, TYPE_NAME_METAKEY)
      LibLua.gettable(@state, -2)
      type = self[-1].as(String)
      LibLua.pushstring(@state, CRYSTAL_BASE_TYPE_METAKEY)
      LibLua.gettable(@state, -3)
      base_type = self[-1].as(String?)
      LibLua.settop(@state, -4) # remove metatable from stack
      {base_type, type}
    end
  end
end
