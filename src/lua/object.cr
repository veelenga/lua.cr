module Lua
  abstract class Object
    alias Option = LibLua::Option

    getter! ref

    def initialize(@stack : Stack = stack, @ref : Int32? = ref)
    end

    def preload
      LibLua.rawgeti(@stack.state, Option::REGISTRYINDEX, ref) unless ref.nil?
      yield @stack.size
    ensure
      @stack.pop unless ref.nil?
      nil
    end
  end
end
