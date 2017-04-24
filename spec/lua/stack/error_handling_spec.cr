require "../../spec_helper"

module Lua::StackMixin
  describe ErrorHandling do
    describe "#set_error_handler" do
      it "sets the Lua error handler by lua chunk" do
        stack = Stack.new.tap &.set_error_handler %q{
          return function(e)
            return e
          end
        }

        expect_raises RuntimeError, "attempt to call a nil value (global 'raise')" do
          stack.run "raise('Blah!')"
        end
      end
    end
  end
end
