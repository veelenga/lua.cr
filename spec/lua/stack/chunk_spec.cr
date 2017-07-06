require "../../spec_helper"

module Lua::StackMixin
  describe Chunk do
    describe "#run" do
      it "evaluates a lua chunk" do
        r = Stack.new.run %q{
          runuble = function (x)
            return x * 2
          end

          return runuble(runuble(2))
        }
        r.should eq 8
      end

      it "removes a chunk and results from the stack" do
        s = Stack.new.tap(&.<< "first element")
        s.run %q{ return 122 }
        s.size.should eq 1
        s[1].should eq "first element"
      end

      it "returns nil if there are no returnings" do
        s = Stack.new
        s.run("a = 10").should eq nil
        s.size.should eq 0
      end

      it "can return any of Lua::Type" do
        s = Stack.new
        s.run(%q{ return nil }).should eq nil
        s.run(%q{ return "a" }).should eq "a"
        s.run(%q{ return false }).should eq false
        s.run(%q{ return true }).should eq true
        s.run(%q{ return 100 }).should eq 100
        s.run(%q{ a = {}; a[1] = "a"; return a }).as(Lua::Table)[1].should eq "a"
        s.run(%q{
          sum = function(x, y)
            return x + y
          end
          return sum
        }).should be_a Function
        s.close
      end
    end

    describe "#run" do
      it "loads lua chunk from file" do
        Stack.new.run(File.new "spec/fixtures/sample.lua").should eq 23
      end

      it "removes chunk and results from the stack" do
        s = Stack.new.tap(&.<< false)
        s.run File.new("spec/fixtures/sample.lua")
        s.size.should eq 1
        s[1].should eq false
      end
    end
  end
end
