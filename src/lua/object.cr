module Lua
  abstract class Object
    def initialize(@stack : Stack = stack, @pos : Int32 = pos)
    end
  end
end
