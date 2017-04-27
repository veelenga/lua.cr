require "../../spec_helper"

module Lua::StackMixin
  describe Util do
    describe "#version" do
      it "returns the lua version number stored in the lua core" do
        v = Stack.new.version
        v.is_a?(Number).should be_true
        (v > 0).should be_true
      end
    end
  end
end
