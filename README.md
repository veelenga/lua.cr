# lua.cr [![Build Status](https://travis-ci.org/veelenga/lua.cr.svg?branch=master)](https://travis-ci.org/veelenga/lua.cr)

Bindings to liblua. **UNDER CONSTRUCTION**

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  liblua:
    github: veelenga/lua.cr
```

## Usage

```crystal
require "lua"

state = LibLua.l_newstate

LibLua.l_openlibs state
LibLua.l_loadstring state, "print(table.concat({ 'Hello', 'from', 'Lua!' }, ' '))"
LibLua.pcallk state, 0, 0, -1, 0, nil #=> Hello from Lua!
LibLua.close state
```

## Contributing

1. Fork it ( https://github.com/veelenga/lua.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request
