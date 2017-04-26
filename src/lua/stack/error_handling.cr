module Lua::StackMixin
  module ErrorHandling
    @error_handler : Function?

    # Sets the Lua error handler by lua chunk. The chunk
    # should return a function that accepts error object.
    #
    # ```
    # stack.set_error_handler %q{
    #   function(e)
    #     print("error happened: " .. e)
    #   end
    # }
    # ```
    protected def set_error_handler(chunk : String)
      chunk = "return " + chunk unless chunk.match /^return\s+/
      if (res = run chunk).is_a?(Function)
        @error_handler = res
      else
        raise ArgumentError.new("lua chunk need to return a function:\n #{chunk}")
      end
    end

    # The same as `ErrorHandling#error(type, err)` method
    # but accepts only string `message` instead of `err`.
    protected def error(type, message : String)
      error type, {"message" => message}
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
      when .errrun?    then RuntimeError.new message, traceback
      when .errsyntax? then SyntaxError.new message, traceback
      when .errmem?    then MemoryError.new message, traceback
      when .errgcmm?   then GCError.new message, traceback
      when .errerr?    then ErrorHandlerError.new message, traceback
      when .errfile?   then FileError.new message, traceback
      else
        LuaError.new message, traceback
      end
    end

    # Loads handler onto the stack at the given position.
    # Returns 0 if handler not loaded.
    #
    # ```
    # stack.set_error_handler %q{
    #   function(e)
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
