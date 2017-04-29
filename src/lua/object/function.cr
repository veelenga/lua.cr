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

    # String representation of the function.
    # Contains number of args and function Lua source.
    def to_s(io)
      copy_to_stack
      info = @stack.getinfo(">Su")
      source = String.new info.source
      chunk = source.gsub(/^return /, "")[0, 20].rstrip
      chunk = "#{chunk}..." if chunk.size < source.size
      io << "argsize:#{info.nparams}, #{chunk}"
    end
  end
end
