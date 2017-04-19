module Lua
  module StackMixin::Table
    # Creates new Lua table from the Array.
    #
    # ```
    # stack.createtable([1, 2, 3])
    # stack.pop # => {1.0 => 1.0, 2.0 => 2.0, 3.0 => 3.0}
    # ```
    def createtable(a : Array)
      h = a.map_with_index { |e, i| [i + 1, e] }.to_h
      createtable h, a.size, 0
    end

    # Creates new Lua table from the hash.
    #
    # ```
    # stack.creattable({"one" => "1", "two" => 2})
    # stack.pop # => {"one" => "1", "two" => 2}
    # ```
    def createtable(a : Hash)
      createtable a, 0, a.size
    end

    private def createtable(a : Hash, narr : Int, nrec : Int)
      LibLua.createtable(@state, narr, nrec)
      a.each do |k, v|
        self << k
        self << v
        LibLua.settable(@state, -3)
      end
    end
  end
end
