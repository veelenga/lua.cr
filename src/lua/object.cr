module Lua
  abstract class Object
    getter! ref

    def initialize(@stack : Stack = stack, @ref : Int32? = ref)
    end

    def preload
      LibLua.rawgeti(@stack.state, Lua::REGISTRYINDEX, ref) unless ref.nil?
      yield @stack.size
    ensure
      @stack.pop unless ref.nil?
      nil
    end
  end
end
