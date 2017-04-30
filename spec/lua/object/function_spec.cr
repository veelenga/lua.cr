require "../../spec_helper"

module Lua
  describe Function do
    describe "#call" do
      it "make a call to the Lua function" do
        sum = Lua::Stack.new.run(%q{
          function sum(x, y)
            return x + y
          end

          return sum
        }).as(Lua::Function)

        sum.call(2, 3).should eq 5
      end

      it "returns nil if function does not have returning" do
        sum = Lua::Stack.new.run(%q{
          function sum(x, y)
            a = x + y
          end

          return sum
        }).as(Lua::Function)
        sum.call(2, 3).should eq nil
      end

      it "can call a function without arguments" do
        f = Lua::Stack.new.run(%q{
          function ff()
            return "ff"
          end

          return ff
        }).as(Lua::Function)
        f.call.should eq "ff"
      end
    end

    describe "#to_s" do
      it "returns string representation of the function" do
        f = Lua::Stack.new.run(%q{
          return function(x, y)
            return x + y
          end
        })
        f.to_s.should eq "argsize:2, function(x, y)..."
      end
    end
  end
end
