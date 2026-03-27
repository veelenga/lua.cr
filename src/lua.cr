require "./lua/*"
require "./lua/object/*"

module Lua
  extend self

  def load(*objects)
    Stack.new.tap do |stack|
      objects.each { |obj| stack << obj }
    end
  end

  def run(chunk)
    stack = Stack.new
    stack.run(chunk)
  ensure
    stack.try &.close
  end
end
