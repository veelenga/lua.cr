require "./lua/*"
require "./lua/object/*"

module Lua
  alias Option = LibLua::Option

  def self.load(*objects)
    Stack.new.tap do |s|
      objects.each { |o| s << o }
    end
  end
end
