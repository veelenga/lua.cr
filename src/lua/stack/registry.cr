module Lua
  module StackMixin::Registry
    # Creates a reference in registry to object at `pos` is a stack.
    # It copies a value to stack top, places top element to registry
    # and removes it from the stack. Returns a reference.
    def reference(pos)
      LibLua.pushvalue(@state, pos)
      LibLua.l_ref(@state, Lua::REGISTRYINDEX)
    end

    # Retrieves an object referred by reference.
    def rawgeti(ref)
      TYPE.new LibLua.rawgeti(@state, Lua::REGISTRYINDEX, ref)
    end

    # Frees a reference and its associated object.
    def unref(ref)
      LibLua.l_unref(@state, Lua::REGISTRYINDEX, ref)
    end
  end
end
