module Lua
  module StackMixin::RegisterFunction
    macro included
      macro register_function(stack, name, proc)
        {% verbatim do %}
        proc = ->(state : LibLua::State) {
          {% for arg, index in proc.args %}
            {{ arg.name }} = LibLua.tonumberx(state, {{ index + 1 }}, nil)
          {% end %}

          # push result to stack
          LibLua.pushnumber(state, {{ proc.body }})

          1 # number of results
        }

        # push crystal proc onto the stack
        LibLua.pushcclosure({{ stack.id }}.state, proc, 0)

        # give it a name
        LibLua.setglobal({{ stack.id }}.state, {{ name }})
        {% end %}
      end
    end
  end
end
