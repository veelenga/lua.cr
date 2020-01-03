module Lua
  class Table < Object
    include Enumerable({Type, Type})
    include Iterable({Type, Type})

    # Sets a new value at index into a table.
    #
    # ```
    # t[3] = "test"
    # t[3] # => "test"
    # ```
    def []=(index, value)
      preload do |pos|
        @stack << index
        @stack << value
        LibLua.settable(@stack.state, pos)
      end
    end

    # Returns the value at index or nil if there is no value at all.
    #
    # ```
    # t[2] = "test"
    # t[2] # => "test"
    # ```
    def [](index)
      preload do |pos|
        @stack << index
        LibLua.gettable(@stack.state, pos)
        @stack.pop
      end
    end

    # Implements Enumerable. Traverses a table in Lua stack using
    # [next](http://www.lua.org/manual/5.3/manual.html#pdf-next).
    def each : Nil
      preload do |pos|
        @stack << nil
        while (LibLua.next(@stack.state, pos) != 0)
          k, v = @stack[-2], @stack[-1]
          yield({k, v})
          @stack.remove
        end
      end
    end

    # Implements Iterator. Traverses a table in Lua stack using
    # [next](http://www.lua.org/manual/5.3/manual.html#pdf-next).
    # ```
    def next
      preload do |pos|
        @stack << nil
        if LibLua.next(@stack.state, pos) != 0
          {@stack[-2], @stack[-1]}.tap { @stack.remove }
        else
          stop
        end
      end
    end

    # Implements Iterable
    def each : Iterator
      self
    end

    # Converts this table to Crystal hash.
    #
    # ```
    # t[1] = "a"
    # t["io"] = "b"
    # t[:gog] = "c"
    # t.to_h # => {"gog" => "c", 1.0 => "a", "io" => "b"}
    # ```
    def to_h
      each_with_object({} of Type => Type) do |pair, o|
        k, v = pair
        o[k] = v
      end
    end

    # Represents table as a string.
    #
    # ```
    # t      # => [1.1, 2.1, 3.1]
    # t.to_s # => #3 {1.0 => 1.1, 2.0 => 2.1, 3.0 => 3.1}
    # ```
    def to_s(io : IO)
      n = size
      h = first(5).to_h.to_s
      h = h.gsub "}", " ...}" if n > 5
      io << "size:#{n}, #{h}"
    end
  end
end
