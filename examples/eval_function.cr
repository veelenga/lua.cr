require "../src/lua"

# Evaluates Lua function with Crystal objects as arguments
lua = Lua.load
sum = lua.run %q{
  function sum(x, y)
    return x + y
  end

  return sum
}
p sum.as(Lua::Function).call(3.2, 1) # => 4.2
lua.close
