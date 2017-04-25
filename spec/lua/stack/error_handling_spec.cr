require "../../spec_helper"
require "tempfile"

module Lua::StackMixin
  describe ErrorHandling do
    it "can catch lua runtime error" do
      expect_raises RuntimeError, "attempt to call a nil value (global 'raise')" do
        Lua.run "raise('Blah!')"
      end
    end

    it "can catch lua syntax error" do
      expect_raises SyntaxError, %q[unexpected symbol near '"a"'] do
        Lua.run %q{
          "a" * 3
        }
      end
    end

    it "can catch lua stack overflow" do
      expect_raises RuntimeError, "stack overflow" do
        Lua.run %q{
          function s()
            s()
          end
          s()
        }
      end
    end

    it "can catch lua file error" do
      tempfile = Tempfile.open("foo") { }
      invalid_file = File.new tempfile.path
      tempfile.unlink
      expect_raises FileError, "cannot open #{invalid_file.path}" do
        Lua.load.run invalid_file
      end
    end

    it "can give you a lua error message" do
      stack = Stack.new
      expect_raises RuntimeError, "attempt to perform arithmetic on a string value" do
        stack.run %q{
          s = "a" + 1
        }
      end
    end

    it "can give you a lua traceback" do
      stack = Stack.new
      expect_raises RuntimeError, "attempt to perform arithmetic on a string value" do
        stack.run %q{
          s = function()
            return "a" + 1
          end

          print(s())
        }
      end.traceback.should eq <<-STACK
      stack traceback:
      \t[string "lua_chunk"]:3: in metamethod '__add'
      \t[string "lua_chunk"]:3: in function 's'
      \t[string "lua_chunk"]:6: in main chunk
      STACK
    end
  end
end
