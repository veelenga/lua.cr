module Lua
  describe Table do
    describe "#[]" do
      it "returns value" do
        t = Stack.new.tap(&.<< [1.0, 2.1])[1].as(Table)
        t[1].should eq 1.0
        t[2].should eq 2.1
      end

      it "returns nil if there is not values" do
        t = Stack.new.tap(&.<< [] of String)[1].as(Table)
        t[0].should eq nil
      end
    end

    describe "#[]=" do
      it "sets new value with number index" do
        t = Stack.new.tap(&.<< [1.0, 2.1])[1].as(Table)
        t[2] = 200
        t[2].should eq 200.0
      end

      it "sets new value with string index" do
        t = Stack.new.tap(&.<< [1.0, 2.1])[1].as(Table)
        t["2"] = 200
        t["2"].should eq 200.0
      end

      it "updates existed value" do
        t = Stack.new.tap(&.<< ["a", "b"])[1].as(Table)
        t[2].should eq "b"
        t[2] = "c"
        t[2].should eq "c"
      end
    end

    describe "#each" do
      it "yields all elements in array" do
        t = Stack.new.tap(&.<< [1.0, 2.1, 3.2])[1].as(Table)
        t.join(",").should eq "{1.0, 1.0},{2.0, 2.1},{3.0, 3.2}"
      end

      it "yields all elements in a hash" do
        t = Stack.new.tap(&.<<({"one" => 1, "two" => 2, "three" => 3}))[1].as(Table)
        t.all? { |k, v| v.as(Number) > 0 }
      end
    end

    describe "#to_s" do
      it "print keys and values" do
        t = Stack.new.tap(&.<< [1.0, 2.1, 3.2])[1].as(Table)
        t.to_s.should eq "{ 1.0 => 1.0 } { 2.0 => 2.1 } { 3.0 => 3.2 }"
      end
    end
  end
end
