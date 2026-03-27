<img src='https://github.com/veelenga/bin/blob/master/lua.cr/logo.jpg?raw=true' width='100' align='right'>

# lua.cr

[![CI](https://github.com/veelenga/lua.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/veelenga/lua.cr/actions/workflows/ci.yml)

Crystal bindings to Lua. Supports [Lua 5.4](http://www.lua.org/ftp/) and higher (including Lua 5.5).

## Installation

Lua development libraries must be installed on your system:

```bash
# macOS
brew install lua

# Ubuntu/Debian
sudo apt install liblua5.4-dev

# Arch Linux
sudo pacman -S lua

# Fedora
sudo dnf install lua-devel
```

Then add this to your application's `shard.yml`:

```yaml
dependencies:
  lua:
    github: veelenga/lua.cr
```

## Usage

First you need to `require` Lua:

```crystal
require "lua"
```

Then you can run a chunk of Lua code:

```crystal
Lua.run %q{
  local hello_message = table.concat({ 'Hello', 'from', 'Lua!' }, ' ')
  print(hello_message)
} # => prints 'Hello from Lua!'
```

Or run a Lua file and obtain results:

```crystal
p Lua.run File.new("./examples/sample.lua") # => 42.0
```

Or even evaluate a function and pass arguments in:

```crystal
lua = Lua.load
sum = lua.run %q{
  function sum(x, y)
    return x + y
  end

  return sum
}
p sum.as(Lua::Function).call(3.2, 1) # => 4.2
lua.close
```

More features coming soon. Try it, that's fun :)

## Contributing

1. Fork it https://github.com/veelenga/lua.cr/fork
1. Create a feature branch `git checkout -b my-new-feature` and implement your feature
1. Run tests `crystal spec` and format code `crystal tool format`
1. Commit your changes `git commit -am 'Add some feature'`
1. Push to the branch `git push origin my-new-feature`
1. Create a new Pull Request
