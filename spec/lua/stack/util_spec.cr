require "../../spec_helper"

module Lua::StackMixin
  describe Util do
    describe "#version" do
      it "returns the lua version number stored in the lua core" do
        v = Stack.new.version
        v.should be_a Float64
        (v > 0).should be_true
      end
    end
  end
end
