@[Link("lua")]
lib LibLua
  type State = Void*

  alias Alloc = (Void*, Void*, LibC::SizeT, LibC::SizeT -> Void*)
  alias CFunction = (State -> LibC::Int)
  alias Number = LibC::Double
  alias PtrdiffT = LibC::Long
  alias Integer = PtrdiffT
  alias Unsigned = LibC::UInt
  alias Reader = (State, Void*, LibC::SizeT* -> LibC::Char*)
  alias Writer = (State, Void*, LibC::SizeT, Void* -> LibC::Int)
  alias Hook = (State, Debug* -> Void)

  struct Debug
    event : LibC::Int
    name : LibC::Char*
    namewhat : LibC::Char*
    what : LibC::Char*
    source : LibC::Char*
    srclen : LibC::SizeT
    currentline : LibC::Int
    linedefined : LibC::Int
    lastlinedefined : LibC::Int
    nups : UInt8
    nparams : UInt8
    isvararg : LibC::Char
    istailcall : LibC::Char
    ftransfer : LibC::UShort
    ntransfer : LibC::UShort
    short_src : LibC::Char[60]
    i_ci : Void*
  end

  fun l_newstate = luaL_newstate : State
  fun l_openlibs = luaL_openlibs(l : State)
  fun l_ref = luaL_ref(l : State, t : LibC::Int) : LibC::Int
  fun l_unref = luaL_unref(l : State, t : LibC::Int, ref : LibC::Int)
  fun l_loadstring = luaL_loadstring(l : State, s : LibC::Char*) : LibC::Int
  fun l_loadfilex = luaL_loadfilex(l : State, filename : LibC::Char*, mode : LibC::Char*) : LibC::Int
  fun l_loadbufferx = luaL_loadbufferx(l : State, buff : LibC::Char*, sz : LibC::SizeT, name : LibC::Char*, mode : LibC::Char*) : LibC::Int
  fun l_requiref = luaL_requiref(l : State, modname : LibC::Char*, openf : CFunction, glb : LibC::Int)
  fun l_newmetatable = luaL_newmetatable(l : State, tname : LibC::Char*) : LibC::Int
  fun l_getmetatable = luaL_getmetatable(l : State, tname : LibC::Char*) : LibC::Int
  fun l_checkudata = luaL_checkudata(l : State, ud : LibC::Int, tname : LibC::Char*) : Void*

  fun open_base = luaopen_base(l : State) : LibC::Int
  fun open_package = luaopen_package(l : State) : LibC::Int
  fun open_coroutine = luaopen_coroutine(l : State) : LibC::Int
  fun open_table = luaopen_table(l : State) : LibC::Int
  fun open_io = luaopen_io(l : State) : LibC::Int
  fun open_os = luaopen_os(l : State) : LibC::Int
  fun open_string = luaopen_string(l : State) : LibC::Int
  fun open_math = luaopen_math(l : State) : LibC::Int
  fun open_utf8 = luaopen_utf8(l : State) : LibC::Int
  fun open_debug = luaopen_debug(l : State) : LibC::Int

  fun pushnil = lua_pushnil(l : State)
  fun pushnumber = lua_pushnumber(l : State, n : Number)
  fun pushinteger = lua_pushinteger(l : State, n : Integer)
  fun pushunsigned = lua_pushunsigned(l : State, n : Unsigned)
  fun pushlstring = lua_pushlstring(l : State, s : LibC::Char*, len : LibC::SizeT) : LibC::Char*
  fun pushstring = lua_pushstring(l : State, s : LibC::Char*) : LibC::Char*
  fun pushfstring = lua_pushfstring(l : State, fmt : LibC::Char*, ...) : LibC::Char*
  fun pushcclosure = lua_pushcclosure(l : State, fn : CFunction, n : LibC::Int)
  fun pushboolean = lua_pushboolean(l : State, b : LibC::Int)
  fun pushlightuserdata = lua_pushlightuserdata(l : State, p : Void*)
  fun pushthread = lua_pushthread(l : State) : LibC::Int
  fun pushvalue = lua_pushvalue(l : State, idx : LibC::Int)

  fun isnumber = lua_isnumber(l : State, idx : LibC::Int) : LibC::Int
  fun isstring = lua_isstring(l : State, idx : LibC::Int) : LibC::Int
  fun iscfunction = lua_iscfunction(l : State, idx : LibC::Int) : LibC::Int
  fun isuserdata = lua_isuserdata(l : State, idx : LibC::Int) : LibC::Int
  fun isyieldable = lua_isyieldable(l : State) : LibC::Int

  fun close = lua_close(l : State)
  fun newthread = lua_newthread(l : State) : State
  fun atpanic = lua_atpanic(l : State, panicf : CFunction) : CFunction
  fun version = lua_version(l : State) : Number
  fun absindex = lua_absindex(l : State, idx : LibC::Int) : LibC::Int
  fun gettop = lua_gettop(l : State) : LibC::Int
  fun settop = lua_settop(l : State, idx : LibC::Int)
  fun remove = lua_remove(l : State, idx : LibC::Int)
  fun insert = lua_insert(l : State, idx : LibC::Int)
  fun replace = lua_replace(l : State, idx : LibC::Int)
  fun copy = lua_copy(l : State, fromidx : LibC::Int, toidx : LibC::Int)
  fun checkstack = lua_checkstack(l : State, sz : LibC::Int) : LibC::Int
  fun xmove = lua_xmove(from : State, to : State, n : LibC::Int)
  fun type = lua_type(l : State, idx : LibC::Int) : LibC::Int
  fun typename = lua_typename(l : State, tp : LibC::Int) : LibC::Char*
  fun tonumberx = lua_tonumberx(l : State, idx : LibC::Int, isnum : LibC::Int*) : Number
  fun tointegerx = lua_tointegerx(l : State, idx : LibC::Int, isnum : LibC::Int*) : Integer
  fun tounsignedx = lua_tounsignedx(l : State, idx : LibC::Int, isnum : LibC::Int*) : Unsigned
  fun toboolean = lua_toboolean(l : State, idx : LibC::Int) : LibC::Int
  fun tolstring = lua_tolstring(l : State, idx : LibC::Int, len : LibC::SizeT*) : LibC::Char*
  fun rawlen = lua_rawlen(l : State, idx : LibC::Int) : LibC::SizeT
  fun tocfunction = lua_tocfunction(l : State, idx : LibC::Int) : CFunction
  fun touserdata = lua_touserdata(l : State, idx : LibC::Int) : Void*
  fun tothread = lua_tothread(l : State, idx : LibC::Int) : State
  fun topointer = lua_topointer(l : State, idx : LibC::Int) : Void*
  fun arith = lua_arith(l : State, op : LibC::Int)
  fun rawequal = lua_rawequal(l : State, idx1 : LibC::Int, idx2 : LibC::Int) : LibC::Int
  fun compare = lua_compare(l : State, idx1 : LibC::Int, idx2 : LibC::Int, op : LibC::Int) : LibC::Int

  fun getglobal = lua_getglobal(l : State, var : LibC::Char*)
  fun gettable = lua_gettable(l : State, idx : LibC::Int)
  fun getfield = lua_getfield(l : State, idx : LibC::Int, k : LibC::Char*)
  fun rawget = lua_rawget(l : State, idx : LibC::Int)
  fun rawgeti = lua_rawgeti(l : State, idx : LibC::Int, n : LibC::Int) : LibC::Int
  fun rawgetp = lua_rawgetp(l : State, idx : LibC::Int, p : Void*)
  fun createtable = lua_createtable(l : State, narr : LibC::Int, nrec : LibC::Int)
  fun newuserdatauv = lua_newuserdatauv(l : State, sz : LibC::SizeT, nuvalue : LibC::Int) : Void*
  fun getmetatable = lua_getmetatable(l : State, objindex : LibC::Int) : LibC::Int
  fun getiuservalue = lua_getiuservalue(l : State, idx : LibC::Int, n : LibC::Int) : LibC::Int
  fun setglobal = lua_setglobal(l : State, var : LibC::Char*)
  fun settable = lua_settable(l : State, idx : LibC::Int)
  fun setfield = lua_setfield(l : State, idx : LibC::Int, k : LibC::Char*)
  fun rawset = lua_rawset(l : State, idx : LibC::Int)
  fun rawseti = lua_rawseti(l : State, idx : LibC::Int, n : LibC::Int)
  fun rawsetp = lua_rawsetp(l : State, idx : LibC::Int, p : Void*)
  fun setmetatable = lua_setmetatable(l : State, objindex : LibC::Int) : LibC::Int
  fun setiuservalue = lua_setiuservalue(l : State, idx : LibC::Int, n : LibC::Int) : LibC::Int
  fun callk = lua_callk(l : State, nargs : LibC::Int, nresults : LibC::Int, ctx : LibC::Int, k : CFunction)
  fun getctx = lua_getctx(l : State, ctx : LibC::Int*) : LibC::Int
  fun pcallk = lua_pcallk(l : State, nargs : LibC::Int, nresults : LibC::Int, errfunc : LibC::Int, ctx : LibC::Int, k : CFunction) : LibC::Int
  fun load = lua_load(l : State, reader : Reader, dt : Void*, chunkname : LibC::Char*, mode : LibC::Char*) : LibC::Int
  fun yieldk = lua_yieldk(l : State, nresults : LibC::Int, ctx : LibC::Int, k : CFunction) : LibC::Int
  fun resume = lua_resume(l : State, from : State, narg : LibC::Int, nresults : LibC::Int*) : LibC::Int
  fun status = lua_status(l : State) : LibC::Int
  fun gc = lua_gc(l : State, what : LibC::Int, data : LibC::Int) : LibC::Int
  fun error = lua_error(l : State) : LibC::Int
  fun next = lua_next(l : State, idx : LibC::Int) : LibC::Int
  fun concat = lua_concat(l : State, n : LibC::Int)
  fun len = lua_len(l : State, idx : LibC::Int)
  fun getallocf = lua_getallocf(l : State, ud : Void**) : Alloc
  fun setallocf = lua_setallocf(l : State, f : Alloc, ud : Void*)
  fun getstack = lua_getstack(l : State, level : LibC::Int, ar : Debug*) : LibC::Int
  fun getinfo = lua_getinfo(l : State, what : LibC::Char*, ar : Debug*) : LibC::Int
  fun getlocal = lua_getlocal(l : State, ar : Debug*, n : LibC::Int) : LibC::Char*
  fun setlocal = lua_setlocal(l : State, ar : Debug*, n : LibC::Int) : LibC::Char*
  fun getupvalue = lua_getupvalue(l : State, funcindex : LibC::Int, n : LibC::Int) : LibC::Char*
  fun setupvalue = lua_setupvalue(l : State, funcindex : LibC::Int, n : LibC::Int) : LibC::Char*
  fun upvalueid = lua_upvalueid(l : State, fidx : LibC::Int, n : LibC::Int) : Void*
  fun upvaluejoin = lua_upvaluejoin(l : State, fidx1 : LibC::Int, n1 : LibC::Int, fidx2 : LibC::Int, n2 : LibC::Int)
  fun sethook = lua_sethook(l : State, func : Hook, mask : LibC::Int, count : LibC::Int) : LibC::Int
  fun gethook = lua_gethook(l : State) : Hook
  fun gethookmask = lua_gethookmask(l : State) : LibC::Int
  fun gethookcount = lua_gethookcount(l : State) : LibC::Int

  fun seti = lua_seti(l : State, idx : LibC::Int, n : Integer)
  fun geti = lua_geti(l : State, idx : LibC::Int, n : Integer) : LibC::Int
  fun dump = lua_dump(l : State, writer : Writer, data : Void*, strip : LibC::Int) : LibC::Int
  fun rotate = lua_rotate(l : State, idx : LibC::Int, n : LibC::Int)
  fun stringtonumber = lua_stringtonumber(l : State, s : LibC::Char*) : LibC::SizeT
end
