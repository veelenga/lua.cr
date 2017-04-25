module Lua::StackMixin
  module StandardLibraries
    MODULES = %i(
      base
      package
      coroutine
      table
      io
      os
      string
      math
      utf8
      debug
    )

    # Opens Lua standard libraries.
    #
    # ```
    # state.open_libs %i(base debug)
    # state.open_libs :math
    # state.libs # => Set{:base, :debug, :math}
    # ```
    def open_libs(libraries)
      libraries = [libraries].flatten.compact
      if libraries.includes?(:all)
        LibLua.l_openlibs(@state)
        @libs.concat(MODULES)
      else
        libraries.each { |l| open_library(l); @libs.add(l) }
      end
    end

    macro open_library(library)
      case {{library}}
        {% for name in MODULES %}
          when {{name}}
            LibLua.l_requiref(@state, {{name}}.to_s, ->(l : LibLua::State) { LibLua.open_{{name.id}}(l) }, 1)
            remove # remove the copy of returned module
        {% end %}
      else
        raise ArgumentError.new "unable to load '#{{{library}}}' lib. Try one of the following: #{MODULES.join(", ")}"
      end
    end
  end
end
