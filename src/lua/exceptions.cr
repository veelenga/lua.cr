module Lua
  class LuaError < Exception
    getter traceback : String?

    def initialize(@message, @traceback = nil)
    end
  end

  class RuntimeError < LuaError; end

  class SyntaxError < LuaError; end

  class MemoryError < LuaError; end

  class ErrorHandlerError < LuaError; end

  class FileError < LuaError; end
end
