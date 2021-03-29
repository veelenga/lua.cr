module Lua::StackMixin
  module CoroutineSupport
    # Creates new thread and returns a coroutine that wraps
    # that state and function `f`
    def newthread(f : Function)
      LibLua.newthread(@state)
      pop.as(Coroutine).tap(&.function=(f))
    end

    # Starts and resumes a coroutine in the given thread
    protected def resume(*args)
      thread_pos = size
      args.each { |a| self.<< a }

      nres = 0
      res = CALL.new LibLua.resume(@state, nil, args.size, pointerof(nres))
      raise error(res, pop) if res > CALL::YIELD

      pick_results thread_pos
    end

    # Returns the status of the current thread.
    def status
      CALL.new LibLua.status(@state)
    end
  end
end
