require "../../spec_helper"

module Lua::StackMixin
  describe Registry do
    describe "#reference" do
      it "creates a reference in a registry" do
        s = Stack.new.tap(&.<< 1.0)
        s.reference(1).should be > 0
        s.size.should eq 1
      end

      it "returns -1 if it can't create a reference" do
        Stack.new.reference(1).should eq -1
      end
    end

    describe "#rawgeti" do
      it "retrieves an object referred by reference" do
        Stack.new.tap do |s|
          s << 1.0
          ref = s.reference(1)
          s.rawgeti(ref).should eq TYPE::TNUMBER
          s.size.should eq 2
          s.top.should eq 1.0
        end
      end
    end

    describe "#unref" do
      it "frees a reference and its associated object" do
        Stack.new.tap do |s|
          s << 10
          ref = s.reference(1)
          s.unref(ref).should be nil
          s.rawgeti(ref).should eq TYPE::TNIL
        end
      end
    end
  end
end
