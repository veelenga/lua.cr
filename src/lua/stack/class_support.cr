module Lua
  class Object
    macro methods
      {{ @type.methods.map &.name.stringify }}
    end
  end

  module StackMixin::ClassSupport
    def pushmetatable(type : LuaCallable.class)
      if LibLua.l_newmetatable(@state, type.name) == 1 # returns 1 if new
        # Set __index
        proc = ->LuaCallable.__index(LibLua::State)
        self << INDEX_METAMETHOD             # push method name on stack
        pushclosure(proc)                    # pointer to function on stack
        LibLua.settable(@state, -3)
        # Set __gc
        proc = ->LuaCallable.__gc(LibLua::State)
        self << GC_METAMETHOD                # push method name on stack
        pushclosure(proc)                    # pointer to function on stack
        LibLua.settable(@state, -3)
        # set __newindex
        proc = ->LuaCallable.__newindex(LibLua::State)
        self << NEW_INDEX_METAMETHOD         # push method name on stack
        pushclosure(proc)                    # pointer to function on stack
        LibLua.settable(@state, -3)
        proc = ->type.__new(LibLua::State)
        self << NEW_OBJECT_METAKEY           # push method name on stack
        pushclosure(proc)                    # pointer to function on stack
        LibLua.settable(@state, -3)
        self << CRYSTAL_BASE_TYPE_METAKEY
        self << LuaCallable.name
        LibLua.settable(@state, -3)
      end
    end

    def pushobject(a : LuaCallable)
      # pushes onto the stack a new full userdata with the block address, and returns this address
      p = LibLua.newuserdatauv(@state, sizeof(Pointer(UInt64)), 1) # address of user data
      user_data = p.as(Pointer(UInt64))
      user_data.value = a.object_id
      pushmetatable(a.class)
      # Set metatable
      LibLua.setmetatable(@state, -2)
    end

    def pushclosure(proc : Proc)
      if proc.closure?
        ptr = proc.pointer
        data = proc.closure_data
        c = ->LuaCallable.__call(LibLua::State)
        LibLua.pushlightuserdata(@state, data)
        LibLua.pushlightuserdata(@state, ptr)
        LibLua.pushcclosure(@state, c, 2)
      else
        LibLua.pushcclosure(@state, proc, 0)
      end
    end
  end
end
