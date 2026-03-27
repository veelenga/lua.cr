require "../../spec_helper"

module Lua::StackMixin
  describe Registry do
    describe "#reference" do
      it "creates a reference in a registry" do
        stack = Stack.new.tap(&.<< 1.0)
        stack.reference(1).should be > 0
        stack.size.should eq 1
      end

      it "returns -1 if it can't create a reference" do
        Stack.new.reference(1).should eq -1
      end
    end

    describe "#rawgeti" do
      it "retrieves an object referred by reference" do
        Stack.new.tap do |stack|
          stack << 1.0
          ref = stack.reference(1)
          stack.rawgeti(ref).should eq TYPE::TNUMBER
          stack.size.should eq 2
          stack.top.should eq 1.0
        end
      end
    end

    describe "#unref" do
      it "frees a reference and its associated object" do
        Stack.new.tap do |stack|
          stack << 10
          ref = stack.reference(1)
          stack.unref(ref).should be nil
          # after unref, the slot can be reused by the next reference
          stack << 20
          new_ref = stack.reference(stack.size)
          new_ref.should eq ref
        end
      end
    end
  end
end
