require "../spec_helper"

module Lua
  describe Object do
    describe "#initialize" do
      it "creates new object by reference" do
        MyObj.new(Stack.new, 10).ref.should eq 10
      end
    end

    describe "#release" do
      it "frees lua object" do
        Stack.new.tap(&.<< 100).tap do |s|
          ref = s.reference(1)
          MyObj.new(s, ref).release
          s.rawgeti(ref).should eq TYPE::TNIL
        end.close
      end
    end
  end

  private class MyObj < Object
  end
end
