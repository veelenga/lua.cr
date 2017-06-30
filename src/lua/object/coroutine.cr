module Lua
  class Coroutine < Object
    # Creates new Coroutine with it's own stack
    # and a function to execute.
    #
    # ```
    # lua = Lua.load
    #
    # f = lua.run %q{
    #   return function()
    #     print("before yield")
    #
    #     coroutine.yield()
    #
    #     print("after yield")
    #   end
    # }
    #
    # co = lua.newthread(f.as Lua::Function)
    # co.resume # before yield
    # co.status # => YIELD
    # co.resume # after yield
    # co.status # => OK
    # ```
    #
    # Stack may return coroutine. In this case we do not need to
    # pass a function 'cause coroutine should already have it:
    #
    # ```
    # t = lua.run %q {
    #   function s(x)
    #     return coroutine.yield(x) * 10
    #   end
    #
    #   return coroutine.create(s)
    # }
    #
    # co = t.as(Lua::Coroutine)
    # co.resume      # => nil
    # co.resume(4.2) # => 42.0
    # ```
    def initialize(stack, @function : Function? = nil)
      super(stack, nil)
    end

    def resume(*args)
      if function = @function
        function.preload(@stack) { @stack.resume *args }
      else
        @stack.resume *args
      end
    end

    def status
      @stack.status
    end

    protected def function=(f : Function)
      @function = f
    end
  end
end
