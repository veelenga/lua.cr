module Lua
  class Callable < Reference
    getter crystal_type_name

    def initialize(stack : Stack, ref : Void*, @crystal_type_name : String)
      super stack, ref
    end

    def to_crystal
      data = @ref.as(LuaCallable*)
      data.value
    end

    def to_s(io)
      io << "pointer:#{@ref.address} to #{@crystal_type_name}"
    end
  end
end
