require "../src/lua"

stack = Lua.load nil,   # => 1  : TNIL(nil)
  10,                   # => 2  : TNUMBER(number) 10.0
  42.0,                 # => 3  : TNUMBER(number) 42.0
  true,                 # => 4  : TBOOLEAN(boolean) true
  false,                # => 5  : TBOOLEAN(boolean) false
  'x',                  # => 6  : TSTRING(string) x
  "hello",              # => 7  : TSTRING(string) hello
  :bro,                 # => 8  : TSTRING(string) bro
  [:one, :two, :three], # => 9  : TTABLE(table) size:3, {1.0 => "one", 2.0 => "two", 3.0 => "three"}
  {one: '1', two: '2'}, # => 10 : TTABLE(table) size:2, {"two" => "2", "one" => "1"}
  {:one, :two, :three}  # => 11 : TTABLE(table) size:3, {1.0 => "one", 2.0 => "two", 3.0 => "three"}

puts stack

stack.close
