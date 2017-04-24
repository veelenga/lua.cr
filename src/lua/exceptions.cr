module Lua
  class LuaError < Exception
    def initialize(@message : String = message)
    end
  end

  class RuntimeError < LuaError; end

  class MemoryError < LuaError; end

  class ErrorHandlerError < LuaError; end

  class GCError < LuaError; end
end
