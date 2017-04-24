module Lua::StackMixin
  module ErrorHandling
    getter error_handler : Function?

    # Sets the Lua error handler by lua chunk. The chunk
    # should return a function that accepts error object.
    #
    # ```
    # stack.set_error_handler %q{
    #   return function(e)
    #     print("error happened: " .. e)
    #   end
    # }
    # ```
    def set_error_handler(chunk : String)
      if (res = run chunk).is_a?(Function)
        @error_handler = res
      else
        raise ArgumentError.new("lua chunk need to return a function:\n #{chunk}")
      end
    end

    protected def error(type : CALL, message = self.pop.as(String))
      case type
      when CALL::ERRRUN  then RuntimeError.new message
      when CALL::ERRMEM  then MemoryError.new message
      when CALL::ERRGCMM then GCError.new message
      when CALL::ERRERR  then ErrorHandlerError.new message
      else
        LuaError.new message
      end
    end

    # Loads handler onto the stack at the given position.
    # Returns 0 if handler not loaded.
    #
    # ```
    # stack.set_error_handler %q{
    #   return function(e)
    #     print("error happened: " .. e)
    #   end
    # }
    # stack.load_error_handler(stack.size - 1) # => loads handler at top - 1 position
    # ```
    protected def load_error_handler(pos : Int)
      if error_handler = @error_handler
        error_handler.copy_to_stack   # place it at top
        LibLua.rotate @state, pos, -1 # place it at pos
        return pos
      end
      0
    end
  end
end
