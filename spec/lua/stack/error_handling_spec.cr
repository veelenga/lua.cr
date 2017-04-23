require "../../spec_helper"

module Lua::StackMixin
  describe ErrorHandling do
    describe "#set_error_handler" do
      it "sets the Lua error handler by lua chunk" do
        stack = Stack.new.tap &.set_error_handler %q{
          return function(e)
            return("something went wrong: " .. e)
          end
        }

        stack.run "raise('Blah!')"
        # TODO:
      end
    end
  end
end
