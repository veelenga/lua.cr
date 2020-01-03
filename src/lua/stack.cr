require "./stack/*"

module Lua
  class Stack
    include StackMixin::Type
    include StackMixin::Util
    include StackMixin::Chunk
    include StackMixin::Registry
    include StackMixin::TableSupport
    include StackMixin::ErrorHandling
    include StackMixin::CoroutineSupport
    include StackMixin::StandardLibraries
    include StackMixin::ClassSupport

    getter state
    getter libs = Set(Symbol).new

    getter? closed : Bool = false

    # Initializes new Lua stack running in a new, independent state.
    # Has to be closed to call the corresponding garbage-collection
    # metamethods on Lua side.
    #
    # By default it loads all standard libraries. But that's possible to
    # load only a subset of them using `libs` named parameter. If you
    # pass nil as `libs` parameter, none of standard libraries will be loaded.
    #
    # ```
    # stack = Lua::Stack.new
    # # ...
    # stack.close
    # ```
    def initialize(libs = :all)
      initialize LibLua.l_newstate, libs
    end

    # Initializes new Lua stack running in an existed state.
    # Has to be closed to call the corresponding garbage-collection
    # metamethods on Lua side.
    def initialize(@state : LibLua::State, libs)
      check_lua_supported

      open_libs(libs)

      if @libs.includes?(:debug)
        set_error_handler %q{
          function(e)
            return { message = e, traceback = debug.traceback() }
          end
        }
      else
        set_error_handler "function(e) return { message = e } end"
      end
    end

    # Destroys all objects in the given Lua state.
    #
    # ```
    # stack = Lua::Stack.new
    # # ...
    # stack.close
    # ```
    def close
      LibLua.close @state
      @libs.clear
      @closed = true
    end

    # Adds Crystal object to Lua stack.
    #
    # ```
    # Lua::Stack.new.tap do |stack|
    #   stack << 10
    #   stack << "str"
    #   stack << false
    # end
    # ```
    def <<(o)
      case o
      when Nil                        then LibLua.pushnil(@state)
      when Int                        then LibLua.pushinteger(@state, o)
      when Float                      then LibLua.pushnumber(@state, o)
      when Bool                       then LibLua.pushboolean(@state, o ? 1 : 0)
      when Char                       then LibLua.pushstring(@state, o.to_s)
      when String                     then LibLua.pushstring(@state, o)
      when Symbol                     then LibLua.pushstring(@state, o.to_s)
      when Array, Tuple               then pushtable(o.to_a)
      when Hash, NamedTuple           then pushtable(o.to_h)
      when Proc(LibLua::State, Int32) then pushclosure(o.as(Proc))
      when Class
        if o < LuaCallable
          pushmetatable(o)
        else
          raise ArgumentError.new(
            "unable to pass Crystal Class of type '#{typeof(o)}' to Lua"
          )
        end
      else
        o.responds_to?(:to_lua) ? o.to_lua(self) : raise ArgumentError.new(
          "unable to pass Crystal object of type '#{typeof(o)}' to Lua"
        )
      end
    end

    # Fetches value from the stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << 10.01
    # stack << "lua"
    # stack[1] # => 10.01
    # stack[2] # => "lua"
    # ```
    def [](pos : Int)
      return nil if pos == 0

      case type_at(pos)
      when TYPE::TNIL, TYPE::TNONE then nil
      when TYPE::TBOOLEAN          then LibLua.toboolean(@state, pos) == 1
      when TYPE::TNUMBER           then LibLua.tonumberx(@state, pos, nil)
      when TYPE::TSTRING           then String.new LibLua.tolstring(@state, pos, nil)
      when TYPE::TTABLE            then Table.new self, reference(pos)
      when TYPE::TFUNCTION         then Function.new self, reference(pos)
      when TYPE::TTHREAD           then Coroutine.new Stack.new(LibLua.tothread(@state, pos), libs.to_a)
      when TYPE::TUSERDATA
        type_info = crystal_type_info_at(pos)
        if !type_info[1].nil? && type_info[0] == LuaCallable.name
          Callable.new self, LibLua.touserdata(state, pos), type_info[1]
        else
          Reference.new self, LibLua.topointer(state, pos)
        end
      when TYPE::TLIGHTUSERDATA then Reference.new self, LibLua.topointer(state, pos)
      else
        raise Exception.new "unable to map Lua type '#{type_at(pos)}'"
      end
    end

    # Represents the stack as a string.
    #
    # ```
    # stack = Lua::Stack.new.tap do |s|
    #   s << 42.24
    #   s << false
    #   s << "hello!"
    # end
    # stack.to_s # =>
    #
    # # 3 : TSTRING(string) hello!
    # # 2 : TBOOLEAN(boolean) false
    # # 1 : TNUMBER(number) 42.24
    # ```
    #
    def to_s(io : IO)
      return "" if size == 0
      io << String.build do |acc|
        l = size
        pad = Math.log10(l).to_i + 1
        (1..l).reverse_each do |pos|
          type = type_at(pos)
          name = typename(type)

          acc << "#{pos.to_s.rjust(pad)} : #{type}(#{name}) #{self[pos]}\n"
        end
      end.strip
    end

    # Returns the index of the top element in the stack.
    # Because indices start at 1, this result is equal to
    # the number of elements in the stack; in particular,
    # 0 means an empty stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack.size # => 0
    # stack << 10
    # stack.size # => 1
    # ```
    def size : Int
      LibLua.gettop(@state)
    end

    # Returns the top element and does not remove it from the stack.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << "hey"
    # stack.top  # => "hey"
    # stack.size # => 0
    # ```
    def top
      self[size]
    end

    # Removes element from the top of the stack and returns it.
    #
    # ```
    # stack = Lua::Stack.new
    # stack << 10.01
    # stack.size # => 1
    # stack.pop  # => 10.01
    # stack.size # => 0
    # ```
    def pop
      top.try &.tap { remove }
    end

    # Removes n elements from the stack.
    #
    # ```
    # stack = Lua::Stak.new
    # stack << "a"
    # stack << "b"
    # stack << "c"
    # stack.remove(2) # => nil
    # stack.size      # => 1
    # ```
    def remove(n : Int = 1)
      n = n < 0 ? 0 : [n, size].min
      LibLua.settop(@state, -n - 1)
    end
  end
end
