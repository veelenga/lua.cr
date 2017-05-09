module Lua
  class Coroutine < Object
    # Creates new Coroutine with it's own stack
    # and a function to execute.
    #
    # ```
    # lua = Lua.load
    #
    # f = lua.run %q{
    #   function()
    #     print("before yield")
    #
    #     coroutine.yield()
    #
    #     print("after yield")
    #   end
    # }
    #
    # thread = LibLua.newthread lua.state
    #
    # co = Coroutine.new thread, f.as(Function)
    # co.resume # => before yield
    # co.status # => YIELD
    # co.resume # => after yield
    # co.status # => OK
    # ```
    def initialize(stack, @function : Function)
      super(stack, nil)
    end

    def resume(*args)
      @function.preload(@stack) { @stack.resume(args) }
    end

    def status
      CALL.new LibLua.status(@stack.state)
    end
  end
end
