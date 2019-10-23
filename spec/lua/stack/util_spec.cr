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

    describe "#set_global" do
      it "returns the string concated from global strings" do
        s = Stack.new
        s.set_global("h", "Hello")
        s.set_global("w", "world")
        r = s.run "return h .. ' ' .. w"
        r.to_s.should eq "Hello world"
      end

      it "returns the string concated from global Hash" do
        s = Stack.new
        obj = {"h" => "Hello", "w" => "world"}
        s.set_global("o", obj)
        r = s.run "return o['h'] .. ' ' .. o['w']"
        r.to_s.should eq "Hello world"
      end

      it "cannot modify passed global Hash" do
        s = Stack.new
        obj = {"h" => "Hello", "w" => "Crystal"}
        s.set_global("o", obj)
        s.run "o['w']='Lua'"
        obj["w"].should eq "Crystal"
      end

      it "read global lua defined variable" do
        s = Stack.new
        s.run "g = 'Lua'"
        g = s.get_global("g")
        g.should eq "Lua"
      end

      it "read modified global string" do
        s = Stack.new
        g = "Crystal"
        s.set_global("g", g)
        r = s.run "l = g; g = 'Lua';return l"
        g.should eq "Crystal"
        r.to_s.should eq "Crystal"
        g = s.get_global("g")
        g.should eq "Lua"
      end

      it "read modified global hash" do
        s = Stack.new
        obj = {"h" => "Hello", "w" => "Crystal"}
        s.set_global("o", obj)
        s.run "o['w']='Lua'"
        obj["w"].should eq "Crystal"
        obj = s.get_global("o").as(Table).to_h
        obj["w"].should eq "Lua"
      end
    end
  end
end
