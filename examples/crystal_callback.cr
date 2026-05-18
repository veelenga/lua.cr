require "../src/lua"

# crystal run examples/crystal_callback.cr

lua = Lua.load

# 1. inline proc literal
lua.function "add", ->(x : Float64, y : Float64) { x + y }
puts lua.run "return add(3, 4)" # => 7.0

# 2. closure capturing local Crystal state
counter = 0
lua.function "tick", -> { counter += 1; nil }
lua.run "tick(); tick(); tick()"
puts "counter = #{counter}" # => counter = 3

# 3. method pointer
def greet(name : String)
  "Hi, #{name}"
end

lua.function "greet", ->greet(String)
puts lua.run "return greet('Lua')" # => Hi, Lua

# 4. mixed types, used inside a larger Lua expression
lua.function "join", ->(prefix : String, count : Int32, ok : Bool) do
  "#{prefix}:#{count}:#{ok}"
end
puts lua.run %q{
  local label = join("requests", 5, true)
  return label .. " (" .. tostring(add(10, 20)) .. ")"
} # => requests:5:true (30.0)

lua.close
