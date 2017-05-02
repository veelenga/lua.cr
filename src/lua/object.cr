module Lua
  abstract class Object
    getter ref

    def initialize(@stack : Stack, @ref : Int32?)
    end

    # Loads Lua object onto the stack from registry, yields it's
    # position (stack top) and removes object from the stack again.
    # Used internally to ensure the Lua object is always accessible.
    protected def preload
      check_ref_valid! @ref
      copy_to_stack
      yield @stack.size
    ensure
      @stack.remove
    end

    protected def copy_to_stack
      check_ref_valid! ref
      @stack.rawgeti ref.not_nil!
    end

    # Removes a reference to this Lua object. It is not be possible
    # to retrieve the object after it is being released.
    def release
      if !@stack.closed? && (ref = @ref)
        @stack.unref(ref)
        @ref = nil
      end
    end

    private def check_ref_valid!(ref)
      if ref.nil? || ref < 1
        raise RuntimeError.new "object does not have a reference in Lua registry."
      end
    end
  end
end
