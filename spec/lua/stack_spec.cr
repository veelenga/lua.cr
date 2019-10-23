require "../spec_helper"

module Lua
  describe Stack do
    describe ".new" do
      it "loads all modules" do
        Stack.new.libs.to_a.should eq StackMixin::StandardLibraries::MODULES
      end

      it "sets error handler" do
        expect_raises LuaError do
          Stack.new.run "wrong!"
        end
      end

      it "sets error handler if libs not loaded" do
        expect_raises LuaError do
          Stack.new(libs: nil).run "wrong again!"
        end
      end
    end

    describe "#<<" do
      it "can push nil value" do
        Stack.new.tap(&.<< nil)[1].should eq nil
      end

      it "can push int value" do
        Stack.new.tap(&.<< 10)[1].should eq 10.0
      end

      it "can push float value" do
        Stack.new.tap(&.<< 42.0)[1].should eq 42.0
      end

      it "can push bool true value" do
        Stack.new.tap(&.<< true)[1].should eq true
      end

      it "can push bool false value" do
        Stack.new.tap(&.<< false)[1].should eq false
      end

      it "can push char value" do
        Stack.new.tap(&.<< 'x')[1].should eq "x"
      end

      it "can push string value" do
        Stack.new.tap(&.<< "message")[1].should eq "message"
      end

      it "can push symbol value" do
        Stack.new.tap(&.<< :message)[1].should eq "message"
      end

      it "can push array" do
        r = Stack.new.tap(&.<< %w(lua is cool))[1].as(Table).map { |_, v| v }
        r.should eq %w(lua is cool)
      end

      it "can push hash" do
        r = Stack.new.tap(&.<< ({"one": '1', "two": '2'}))[1].as(Table).map { |k, v| {k.as(String), v} }
        r.sort_by(&.[0]).should eq [{"one", "1"}, {"two", "2"}]
      end

      it "can push tuple" do
        r = Stack.new.tap(&.<<({:one, :two, :three}))[1].as(Table).map { |_, v| v }
        r.should eq %w(one two three)
      end

      it "can push named tuple" do
        r = Stack.new.tap(&.<<({one: '1', two: '2', three: '3'}))[1].as(Table).map { |_, v| v.as(String) }
        r.sort.should eq %w(1 2 3)
      end

      it "can push inner array" do
        r = Stack.new.tap(&.<<({"inner" => [1, 2, 3]}))[1].as(Table)["inner"].as(Table).map { |_, v| v.as(Float) }
        r.sort.should eq [1, 2, 3]
      end

      it "raises error when it is a wrong object" do
        s = Stack.new
        expect_raises Exception do
          s << Exception.new
        end
      end

      it "accepts custom object that responds to :to_lua" do
        obj = LuaReporter.new("Hello lua")
        Stack.new.tap(&.<< obj)[1].should eq "Hello lua"
      end
    end

    describe "#[]" do
      it "returns first element for -1" do
        Stack.new.tap(&.<< :whew)[-1].should eq "whew"
      end

      it "returns nil for 0" do
        Stack.new[0].should eq nil
      end
    end

    describe "#to_s" do
      it "represents the stack as a string" do
        stack = Stack.new.tap do |s|
          s << 42.24
          s << false
          s << "hello!"
        end
        stack.to_s.should eq "3 : TSTRING(string) hello!\n2 : TBOOLEAN(boolean) false\n1 : TNUMBER(number) 42.24"
      end

      it "returns empty string when stack is empty" do
        Stack.new.to_s.should eq ""
      end
    end

    describe "#size" do
      it "returns the index of the top element" do
        Stack.new.tap do |s|
          s << 3
          s << :times
          s << :faster
        end.size.should eq 3
      end

      it "returns 0 when stack is empty" do
        Stack.new.size.should eq 0
      end
    end

    describe "#pop" do
      it "returns the element from the top of the stack" do
        Stack.new.tap(&.<< 10.01).pop.should eq 10.01
      end

      it "removes the element from the top of the stack" do
        Stack.new.tap(&.<< 10.01).tap(&.pop).size.should eq 0
      end

      it "returns nil when stack is empty" do
        Stack.new.pop.should eq nil
      end
    end

    describe "#remove" do
      it "removes element from the top of the stack and does not return it" do
        Stack.new.tap(&.<< 100).remove.should eq nil
      end

      it "can remove n elements" do
        stack = Stack.new.tap do |s|
          s << 1
          s << 3
          s << 5
        end
        stack.remove(2).should eq nil
        stack.size.should eq 1
      end

      it "can remove all elements from the stack" do
        stack = Stack.new.tap do |s|
          s << :"1"
          s << :"3"
          s << :"5"
        end
        stack.remove(stack.size).should eq nil
        stack.size.should eq 0
      end

      it "removes all elements from the stack if n is bigger than size" do
        stack = Stack.new.tap do |s|
          s << :"1"
          s << :"3"
        end
        stack.remove(100)
        stack.size.should eq 0
      end

      it "does not remove elements if n is less than 0" do
        stack = Stack.new.tap &.<< "a"
        stack.remove -100
        stack.size.should eq 1
      end
    end
  end

  private class LuaReporter
    def initialize(@message : String = message)
    end

    def to_lua(stack)
      stack << @message
    end
  end
end
