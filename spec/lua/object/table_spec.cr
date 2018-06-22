module Lua
  def table(values)
    Stack.new.tap(&.<< values)[1].as(Table)
  end

  describe Table do
    describe "#[]" do
      it "converts int value" do
        t = table [1.0, 2.1]
        t[1].should eq 1.0
        t[2].should eq 2.1
      end

      it "converts string value" do
        t = table ["a", ""]
        t[1].should eq "a"
        t[2].should eq ""
      end

      it "converts bool" do
        t = table [true, false]
        t[1].should eq true
        t[2].should eq false
      end

      it "returns nil if there is no values" do
        table([] of String)[1].should eq nil
      end

      it "converts" do
        table([nil])[1].should eq nil
      end

      it "converts char" do
        table(['x', 'b'])[1].should eq "x"
      end

      it "converts hash values" do
        t = table({:one => "1", :two => "2", "three" => 3})
        t["one"].should eq "1"
        t["two"].should eq "2"
        t["three"].should eq 3.0
      end

      it "converts tuple values" do
        t = table({:one, "two", 'x', true, false, 3, ["a"]})
        t[1].should eq "one"
        t[2].should eq "two"
        t[3].should eq "x"
        t[4].should eq true
        t[5].should eq false
        t[6].should eq 3.0
        t[7].as(Table)[1].should eq "a"
      end

      it "converts named tuple values" do
        t = table({one: 1, "two": 2, bool: true, char: 'x', tuple: {:one}})
        t["one"].should eq 1
        t["two"].should eq 2
        t["bool"].should eq true
        t["char"].should eq "x"
        t["tuple"].as(Table)[1].should eq "one"
      end

      it "converts values if table has been removed from the stack" do
        t = Stack.new.tap(&.<< [1, "a", [true, {"key" => :value}]]).pop.as(Table)
        t[1].should eq 1
        t[2].should eq "a"
        t[3].as(Table).tap do |tb|
          tb[1].should eq true
          tb[2].as(Table)["key"].should eq "value"
        end
        t.select { |_, v| v.is_a?(String) }.should eq [{2, "a"}]
      end
    end

    describe "#[]=" do
      it "sets new value by index" do
        t = table [1.0, 2.1]
        t[2] = 200
        t[2].should eq 200
      end

      it "sets new value with string index" do
        t = table [1.0, 2.1]
        t["2"] = 200
        t["2"].should eq 200
      end

      it "updates existed value" do
        t = table %w(a b)
        t[2].should eq "b"
        t[2] = "c"
        t[2].should eq "c"
      end

      it "sets/updates value if table is removed from the stack" do
        t = Stack.new.tap(&.<< %w(a b)).pop.as(Table)
        t[1].should eq "a"
        t[1] = "aabb"
        t[1].should eq "aabb"
        t[2].should eq "b"
      end
    end

    describe "#each" do
      it "yields all elements in array" do
        t = table [1.0, 2.1, 3.2]
        t.join(",").should eq "{1.0, 1.0},{2.0, 2.1},{3.0, 3.2}"
      end

      it "yields all elements in a hash" do
        t = table({"one" => 1, "two" => 2, "three" => 3})
        t.all? { |_, v| v.as(Number) > 0 }.should be_true
      end

      it "yields all elements in a tuple" do
        t = table({:one, "true", 'x'})
        t.all? { |_, v| v.is_a?(String) }.should be_true
      end

      it "yields all elements in a named tuple" do
        t = table({one: 1.0, two: "two"})
        t.all? { |_, v| v.is_a?(String) }.should be_false
      end
    end

    describe "#to_h" do
      it "converts table to crystal hash" do
        t = table({1.0 => "a", "io" => "b", :gog => "c"})
        t.to_h.should eq({"gog" => "c", 1.0 => "a", "io" => "b"})
      end

      it "returns empty hash if table is empty" do
        t = table([] of String)
        t.to_h.should eq({} of Lua::Type => Lua::Type)
      end
    end

    describe "#to_s" do
      it "print keys and values" do
        t = Stack.new.tap(&.<< [1.0, 2.1, 3.2])[1].as(Table)
        t.to_s.should eq "size:3, {1.0 => 1.0, 2.0 => 2.1, 3.0 => 3.2}"
      end
    end
  end
end
