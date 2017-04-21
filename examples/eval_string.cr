require "../src/lua"

# Run a chunk of Lua code
Lua.run %q{
  local hello_message = table.concat({ 'Hello', 'from', 'Lua!' }, ' ')
  print(hello_message)
} # => prints 'Hello from Lua!'
