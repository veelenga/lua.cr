require "../src/lua"

state = LibLua.l_newstate

LibLua.l_openlibs state
LibLua.l_loadstring state, "print(table.concat({ 'Hello', 'from', 'Lua!' }, ' '))"
LibLua.pcallk state, 0, 0, -1, 0, nil
