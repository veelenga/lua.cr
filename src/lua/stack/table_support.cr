module Lua
  module StackMixin::TableSupport
    # Pushes array to the stack. Converts it to Lua table.
    #
    # ```
    # stack.pushtable([1, 2, 3])
    # stack.pop # => {1.0 => 1.0, 2.0 => 2.0, 3.0 => 3.0}
    # ```
    def pushtable(a : Array)
      h = a.map_with_index { |e, i| [i + 1, e] }.to_h
      pushtable h, a.size, 0
    end

    # Pushes hash onto the stack. Converts it to Lua table
    #
    # ```
    # stack.pushtable({"one" => "1", "two" => 2})
    # stack.pop # => {"one" => "1", "two" => 2}
    # ```
    def pushtable(a : Hash)
      pushtable a, 0, a.size
    end

    private def pushtable(a : Hash, narr : Int, nrec : Int)
      LibLua.createtable(@state, narr, nrec)
      a.each do |k, v|
        self << k
        self << v
        LibLua.settable(@state, -3)
      end
    end
  end
end
