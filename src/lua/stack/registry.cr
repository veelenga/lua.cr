module Lua
  module StackMixin::Registry
    # Creates a reference in registry to object at `pos` is a stack.
    # It copies a value to stack top, places top element to registry
    # and removes it from the stack. Returns a reference.
    def reference(pos)
      LibLua.pushvalue(@state, pos)
      LibLua.l_ref(@state, OPTION::REGISTRYINDEX)
    end
  end
end
