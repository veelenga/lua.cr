module Lua::StackMixin
  module ErrorHandling
    @error_handler : Function?

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
    protected def set_error_handler(chunk : String)
      if (res = run chunk).is_a?(Function)
        @error_handler = res
      else
        raise ArgumentError.new("lua chunk need to return a function:\n #{chunk}")
      end
    end

    # Instantiates and returns a Lua error object based on
    # provided error type. The second parameter represents an
    # error object (hash), which holds message and backtrace from Lua.
    #
    # ```
    # stack.error CALL::ERRRUN # => returns new RuntimeError object
    # ```
    protected def error(type, err)
      message = err["message"]?.try &.as(String)
      traceback = err["traceback"]?.try &.as(String)
      case type
      when CALL::ERRRUN  then RuntimeError.new message, traceback
      when CALL::ERRMEM  then MemoryError.new message, traceback
      when CALL::ERRGCMM then GCError.new message, traceback
      when CALL::ERRERR  then ErrorHandlerError.new message, traceback
      else
        LuaError.new message, traceback
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
        error_handler.copy_to_stack   # places it at top
        LibLua.rotate @state, pos, -1 # places it at pos
        return pos
      end
      0
    end
  end
end
