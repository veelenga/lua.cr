require "./lua/*"
require "./lua/object/*"

module Lua
  extend self

  def load(*objects)
    Stack.new.tap do |s|
      objects.each { |o| s << o }
    end
  end
end
