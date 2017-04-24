require "../../spec_helper"

module Lua::StackMixin
  describe ErrorHandling do
    it "cat catch lua syntax error" do
      expect_raises RuntimeError, "attempt to call a nil value (global 'raise')" do
        Lua.run "raise('Blah!')"
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
