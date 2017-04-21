require "../../spec_helper"

module Lua::StackMixin
  describe Type do
    describe "#type_at" do
      it "can return TNIL type" do
        Stack.new.tap(&.<< nil).type_at(1).should eq TYPE::TNIL
      end

      it "can return TBOOLEAN type" do
        Stack.new.tap(&.<< false).type_at(1).should eq TYPE::TBOOLEAN
      end

      it "can return TNUMBER type" do
        Stack.new.tap(&.<< 3).type_at(1).should eq TYPE::TNUMBER
      end

      it "can return TSTRING type" do
        Stack.new.tap(&.<< "s").type_at(1).should eq TYPE::TSTRING
      end
    end

    describe "#typename" do
      it "can return name of nil type" do
        Stack.new.tap(&.<< nil).typename(1).should eq "nil"
      end

      it "can return name of boolean type" do
        Stack.new.tap(&.<< false).typename(1).should eq "boolean"
      end

      it "can return name of number type" do
        Stack.new.tap(&.<< 3).typename(1).should eq "number"
      end

      it "can return name of string type" do
        Stack.new.tap(&.<< "s").typename(1).should eq "string"
      end

      it "can return name of no value" do
        Stack.new.typename(1).should eq "no value"
      end

      it "can return name of TYPE" do
        Stack.new.typename(TYPE::TSTRING).should eq "string"
      end
    end
  end
end
