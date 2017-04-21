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
  end
end
