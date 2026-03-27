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
        Stack.new.tap(&.<< 100).tap do |stack|
          ref = stack.reference(1)
          obj = MyObj.new(stack, ref)
          obj.release
          obj.ref.should be_nil
        end
      end

      it "raises an error if object has been already released" do
        s = Stack.new.tap(&.<< [1, 2, 3])
        ref = s.reference(1)
        obj = MyObj.new(s, ref).tap(&.release)
        expect_raises RuntimeError, "object does not have a reference" do
          obj.load
        end
      end
    end
  end

  private class MyObj < Object
    def load
      copy_to_stack
    end
  end
end
