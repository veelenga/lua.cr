module Lua::StackMixin
  module CoroutineSupport
    def newthread(f : Function)
      LibLua.newthread(@state)
      Coroutine.new pop.as(Stack), f
    end

    # Starts and resumes a coroutine in the given thread
    def resume(*args)
      args.each { |a| self.<< a }
      res = CALL.new LibLua.resume(@state, nil, args.size)
      raise error(res, pop) if res != CALL::OK
      res
    end

    def status
      # TODO:
    end
  end
end
