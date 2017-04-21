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
  end
end
