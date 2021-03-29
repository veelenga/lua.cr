module Lua
  module StackMixin::Util
    # Returns the lua version number stored in the Lua core.
    #
    # ```
    # state.version # => 503.0
    # ```
    def version
      LibLua.version(@state)
    end

    # Gets information about a specific function or function invocation.
    def getinfo(what)
      ar = LibLua::Debug.new
      LibLua.getinfo @state, what, pointerof(ar)
      ar
    end

    # assign a value to a lua global variable with the name to value
    def set_global(name : String, value)
      self << value
      LibLua.setglobal(@state, name)
    end

    # gets a value of the global with the name
    def get_global(name : String)
      LibLua.getglobal(@state, name)
      pop
    end

    protected def check_lua_supported
      if (ver = version) < 504
        raise RuntimeError.new "Lua #{ver} not supported. Try Lua 5.4 or higher."
      end
    end

    protected def pick_results(start, finish = size)
      elements = (start..finish).map { pop }
      elements.size > 1 ? elements : elements.first?
    end
  end
end
