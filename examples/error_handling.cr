require "../src/lua"

begin
  Lua.run %q{
    function runtime_error(x, y)
      return x + y
    end

    runtime_error("blah", 10)
  }
rescue e : Lua::RuntimeError
  puts e.message
  puts e.traceback
end

# =>
# [string "lua_chunk"]:3: attempt to perform arithmetic on a string value (local 'x')
# stack traceback:
#         [string "lua_chunk"]:3: in metamethod '__add'
#         [string "lua_chunk"]:3: in function 'runtime_error'
#         [string "lua_chunk"]:6: in main chunk
