module Lua
  alias Type = Nil | Bool | Float64 | String | Lua::Object | Lua::Reference

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

  enum CALL
    OK        = 0
    YIELD     = 1
    ERRRUN    = 2
    ERRSYNTAX = 3
    ERRMEM    = 4
    ERRERR    = 5
    ERRFILE   = 6
  end

  REFNIL        =         -1
  NOREF         =         -2
  REGISTRYINDEX = -1_001_000

  MULTRET = -1

  CRYSTAL_BASE_TYPE_METAKEY = "__crystal_base_type"
  NEW_OBJECT_METAKEY        = "new"
  TYPE_NAME_METAKEY         = "__name"
  NEW_INDEX_METAMETHOD      = "__newindex"
  INDEX_METAMETHOD          = "__index"
  GC_METAMETHOD             = "__gc"
end
