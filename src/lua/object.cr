module Lua
  abstract class Object
    getter! ref

    def initialize(@stack : Stack = stack, @ref : Int32? = ref)
    end

    # Loads Lua object onto the stack from registry, yields it's
    # position (stack top) and removes object from the stack again.
    # Used internally to ensure the Lua object is always accessible.
    protected def preload
      copy_to_stack if ref
      yield @stack.size
    ensure
      @stack.remove if ref
    end

    protected def copy_to_stack
      @stack.rawgeti(ref) if ref
    end

    # Removes a reference to this Lua object. It is not be possible
    # to retrieve the object after it is being released.
    def release
      return if @stack.closed? || !ref
      @stack.unref(ref)
      @ref = nil
    end
  end
end
