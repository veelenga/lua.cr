require "../../spec_helper"

module Lua::StackMixin
  describe Chunk do
    describe "#eval" do
      it "evaluates a lua chunk" do
        r = Stack.new.eval %q{
          double = function (x)
            return x * 2
          end

          return double(double(2))
        }
        r.should eq 8
      end

      it "removes a chunk and results from the stack" do
        s = Stack.new.tap(&.<< "first element")
        s.eval %q{ return 122 }
        s.size.should eq 1
        s[1].should eq "first element"
      end

      it "returns nil if there are no returnings" do
        s = Stack.new
        s.eval("a = 10").should eq nil
        s.size.should eq 0
      end

      it "can return any of LuaType" do
        s = Stack.new
        s.eval(%q{ return nil }).should eq nil
        s.eval(%q{ return "a" }).should eq "a"
        s.eval(%q{ return false }).should eq nil
        s.eval(%q{ return true }).should eq true
        s.eval(%q{ return 100 }).should eq 100
        s.eval(%q{ a = {}; a[1] = "a"; return a }).as(Lua::Table)[1].should eq "a"
        s.eval(%q{
          sum = function(x, y)
            return x + y
          end
          return sum
        }).should eq nil # function
      end
    end
  end
end
