module Lua::StackMixin
  module CoroutineSupport
    # Creates new thread and returns a coroutine that wraps
    # that state and function `f`
    def newthread(f : Function)
      LibLua.newthread(@state)
      pop.as(Coroutine).tap { |c| c.function = f }
    end

    # Starts and resumes a coroutine in the given thread
    def resume(*args)
      args.each { |a| self.<< a }
      res = CALL.new LibLua.resume(@state, nil, args.size)
      raise error(res, pop) if res > CALL::YIELD
      res
    end

    # Returns the status of the current thread.
    def status
      CALL.new LibLua.status(@state)
    end
  end
end
