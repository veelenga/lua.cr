require "spec"
require "../src/lua"

class LuaReporter
  def initialize(@message : String = message)
  end

  def to_lua(state)
    LibLua.pushstring(state, @message)
  end
end
