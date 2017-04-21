require "./lua/*"
require "./lua/object/*"

module Lua
  extend self

  def load(*objects)
    Stack.new.tap do |s|
      objects.each { |o| s << o }
    end
  end

  def run(chunk)
    stack = Stack.new
    stack.run(chunk)
  ensure
    stack.try &.close
  end
end
