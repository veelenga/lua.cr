module Lua
  alias LuaType = Nil | Bool | Float64 | String | Table | Function

  enum TYPE
    TNONE          = -1
    TNIL           =  0
    TBOOLEAN       =  1
    TLIGHTUSERDATA =  2
    TNUMBER        =  3
    TSTRING        =  4
    TTABLE         =  5
    TFUNCTION      =  6
    TUSERDATA      =  7
    TTHREAD        =  8
  end

  REFNIL        =       -1
  NOREF         =       -2
  REGISTRYINDEX = -1001000

  MULTRET = -1

  enum CALL
    OK        = 0
    YIELD     = 1
    ERRRUN    = 2
    ERRSYNTAX = 3
    ERRMEM    = 4
    ERRGCMM   = 5
    ERRERR    = 6
    ERRFILE   = 7
  end
end
