module Lua
  module StackMixin::Chunk
    # Evaluates a Lua chunk and returns the result if any.
    #
    # ```
    # Stack.new.eval %q{
    #   double = function (x)
    #     return x * 2
    #   end
    #
    #   return double(double(2))
    # } # => 8
    # ```
    def eval(buff : String) : LuaType
      LibLua.l_loadbufferx @state, buff, buff.size, "lua_code_chunk", nil
      call_and_return(size - 1).try &.first
    end

    private def call_and_return(initial_size, *args)
      args.each { |a| self.<< a }
      LibLua.pcallk @state, args.size, -1, 1, -1, nil

      elements = (initial_size...size).map { pop }
      elements.any? ? elements : nil
    end
  end
end
