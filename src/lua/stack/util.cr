module Lua
  module StackMixin::Util
    # Returns the lua version number stored in the Lua core.
    #
    # ```
    # state.version # => 503.0
    # ```
    def version
      LibLua.version(@state).value
    end

    protected def check_lua_supported
      if (ver = version) < 503
        raise RuntimeError.new "Lua #{ver} not supported. Try Lua 5.3 or higher."
      end
    end
  end
end
