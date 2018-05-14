require "../../spec_helper"

module Lua::StackMixin
  describe StandardLibraries do
    describe "MODULES" do
      it "is defined" do
        StandardLibraries::MODULES.size.should be > 0
      end
    end

    describe "#open_libs" do
      it "accepts an Array of symbols" do
        stack = Stack.new libs: nil
        stack.open_libs %i(base debug)
        stack.libs.to_a.should eq [:base, :debug]
      end

      it "accepts a Symbol" do
        stack = Stack.new libs: nil
        stack.open_libs :math
        stack.libs.to_a.should eq [:math]
      end

      it "accepts special :all Symbol and opens all libs" do
        stack = Stack.new libs: nil
        stack.open_libs :all
        stack.libs.to_a.should eq StandardLibraries::MODULES
      end

      it "accepts nil" do
        stack = Stack.new libs: nil
        stack.open_libs nil
        stack.libs.size.should eq 0
      end

      it "adds a library to the list of libs" do
        stack = Stack.new %i(base package)
        stack.open_libs :string
        stack.libs.to_a.should eq [:base, :package, :string]
      end

      StandardLibraries::MODULES.each do |mod|
        it "can open '#{mod}'" do
          stack = Stack.new nil
          stack.open_libs mod
          stack.libs.includes?(mod).should be_true
        end
      end

      it "raises ArgumentError if module is wrong" do
        expect_raises ArgumentError do
          Stack.new :no_such_module
        end
      end

      it "can open module twice" do
        stack = Stack.new %i(debug debug)
        stack.libs.to_a.should eq [:debug]
      end
    end
  end
end
