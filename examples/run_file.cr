require "../src/lua"

# Runs a Lua file and returns the result
p Lua.run File.new("./examples/sample.lua") # => 42.0
