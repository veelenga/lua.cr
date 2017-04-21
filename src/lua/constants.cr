module Lua
  alias LuaType = Nil | Bool | Float64 | String | Table

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

  enum OPTION
    REFNIL        =       -1
    NOREF         =       -2
    REGISTRYINDEX = -1001000
  end

  MULTRET = -1
end
