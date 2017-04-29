require "../../spec_helper"

module Lua::StackMixin
  describe TableSupport do
    describe "#pushtable" do
      it "pushes Array" do
        t = Stack.new.tap(&.pushtable([1, true, false, "a"])).pop.as(Lua::Table)
        t.size.should eq 4
        t[1].should eq 1
        t[2].should eq true
        t[4].should eq "a"
      end

      it "pushes Hash" do
        t = Stack.new.tap(&.pushtable({:one => :two})).pop.as(Lua::Table)
        t.size.should eq 1
        t["one"].should eq "two"
      end
    end
  end
end
