require "../src/lua"

lua = Lua.load
co = lua.run(%q{
  function foo (a)
    print("foo", a)
    return coroutine.yield(2*a)
  end

  return coroutine.create(function (a,b)
    print("co-body", a, b)
    local r = foo(a+1)
    print("co-body", r)
    local r, s = coroutine.yield(a+b, a-b)
    print("co-body", r, s)
    return b, "end"
  end)
}).as(Lua::Coroutine)

res = co.resume 1, 10
puts "main #{res}"

res = co.resume "r"
puts "main #{res}"

res = co.resume "x", "y"
puts "main #{res}"
