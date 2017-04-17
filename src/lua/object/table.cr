module Lua
  class Table < Object
    include Enumerable({ LuaType, LuaType })
    include Iterable({ LuaType, LuaType })

    # Sets value to index in a table
    #
    # ```
    # t[3] = "test"
    # t[3] #=> "test"
    # ```
    def []=(index, value)
      @stack << index
      @stack << value
      LibLua.settable(@stack.state, @pos)
    end

    # Returns the value placed at index
    # or nil if there is no such value
    #
    # ```
    # t[2] = "test"
    # t[2] #=> "test"
    # ```
    def [](index)
      @stack << index
      LibLua.gettable(@stack.state, @pos)
      @stack.pop
    end

    # Traverses a table in Lua using
    # [next](http://www.lua.org/manual/5.3/manual.html#pdf-next)
    #
    # ```
    # t[1] = '1'
    # t[2] = '2'
    # t[3] = '3'
    # t.each do |k, v|
    #   k #=> 1.0, 2.0, 3.0 (represents table index)
    #   v #=> '1', '2', '3' (represents table value)
    # end
    # ```
    def each : Nil
      @stack << nil
      while(LibLua.next(@stack.state, @pos) != 0)
        yield({ @stack[-2], @stack[-1] })
        @stack.pop
      end
    end

    # Represents table as a string
    #
    # ```
    # t #=> [1.1, 2.1, 3.1]
    # t.to_s #=> { 1.0 => 1.1 } { 2.0 => 2.1 } { 3.0 => 3.1 }
    # ```
    def to_s(io : IO)
      io << String.build do |str|
        self.each do |k, v|
          str << " " unless str.empty?
          str << "{ #{k} => #{v} }"
        end
      end
    end
  end
end
