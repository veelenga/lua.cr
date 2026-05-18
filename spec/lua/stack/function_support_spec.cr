require "../../spec_helper"

private def greet(name : String)
  "Hi, #{name}"
end

module Lua::StackMixin
  describe FunctionSupport do
    describe "#function" do
      it "registers a proc taking no arguments" do
        s = Stack.new
        s.function "answer", -> { 42.0 }
        s.run("return answer()").should eq 42.0
      end

      it "registers a proc with typed numeric arguments" do
        s = Stack.new
        s.function "add", ->(x : Float64, y : Float64) { x + y }
        s.run("return add(3, 4)").should eq 7.0
      end

      it "converts integer-typed arguments" do
        s = Stack.new
        s.function "mul", ->(x : Int32, y : Int32) { x * y }
        s.run("return mul(6, 7)").should eq 42.0
      end

      it "accepts string arguments and returns a string" do
        s = Stack.new
        s.function "shout", ->(text : String) { text.upcase }
        s.run("return shout('hello')").should eq "HELLO"
      end

      it "captures local Crystal state via closure" do
        s = Stack.new
        counter = 0
        s.function "tick", -> { counter += 1; nil }
        s.run "tick(); tick(); tick()"
        counter.should eq 3
      end

      it "registers a method pointer" do
        s = Stack.new
        s.function "greet", ->greet(String)
        s.run("return greet('Lua')").should eq "Hi, Lua"
      end

      it "returns no Lua value when the proc returns Nil" do
        s = Stack.new
        s.function "noop", -> { nil }
        s.run("return noop()").should be_nil
      end

      it "is callable inside larger Lua expressions" do
        s = Stack.new
        s.function "double", ->(x : Float64) { x * 2 }
        s.run("return 100 * double(3)").should eq 600.0
      end

      it "raises when Lua passes fewer arguments than expected" do
        s = Stack.new
        s.function "add", ->(x : Float64, y : Float64) { x + y }
        expect_raises(ArgumentError, /add.*expects 2/) do
          s.run "return add(1)"
        end
      end

      it "supports several mixed-type arguments" do
        s = Stack.new
        s.function "join", ->(prefix : String, count : Int32, ok : Bool) do
          "#{prefix}:#{count}:#{ok}"
        end
        s.run("return join('n', 5, true)").should eq "n:5:true"
      end
    end
  end
end
