module Lua
  class LuaError < Exception
    getter traceback

    def initialize(@message = message, @traceback : String? = traceback)
    end
  end

  class RuntimeError < LuaError; end

  class SyntaxError < LuaError; end

  class MemoryError < LuaError; end

  class ErrorHandlerError < LuaError; end

  class GCError < LuaError; end

  class FileError < LuaError; end
end
