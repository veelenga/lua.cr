module Lua
  class Function < Object
    # Make a call to the Lua function.
    #
    # ```
    # s = Lua::Stack.new
    # sum = s.run(%q{
    #    function sum(x, y)
    #      return x + y
    #    end
    #
    #    return sum
    #  }).as(Lua::Function)
    #
    # sum.call(2, 3) # => 5.0
    # ```
    #
    def call(*args)
      preload do |pos|
        @stack.call_and_return pos, *args
      end
    end

    # String representation of function.
    # Contains number of arguments and function Lua source.
    def to_s(io)
      copy_to_stack
      info = @stack.getinfo(">Su")
      io << "argsize:#{info.nparams}, #{String.new info.source}"
    end
  end
end
