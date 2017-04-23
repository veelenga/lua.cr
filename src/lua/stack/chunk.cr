module Lua
  module StackMixin::Chunk
    # Evaluates a Lua chunk and returns the result if any.
    #
    # ```
    # Stack.new.run %q{
    #   double = function (x)
    #     return x * 2
    #   end
    #
    #   return double(double(2))
    # } # => 8
    # ```
    def run(buff : String)
      LibLua.l_loadbufferx @state, buff, buff.size, "lua_code_chunk", nil
      call_and_return size
    end

    # Evaluates a Lua chunk in a file and returns the result if any.
    #
    # ```
    # Stack.new.run File.new("./sample.lua")
    # ```
    def run(lua_file : File)
      # TODO: check loadfilex result to ensure file has been loaded properly
      LibLua.l_loadfilex @state, lua_file.path, nil
      call_and_return size
    end

    protected def call_and_return(initial_size, *args)
      # set handler just below the chunk
      error_handler = self.load_error_handler initial_size

      args.each { |a| self.<< a }
      LibLua.pcallk @state, args.size, Lua::MULTRET, 1, error_handler, nil

      elements = (initial_size..size).map { pop }
      elements.size > 1 ? elements : elements.first?
    ensure
      self.pop if error_handler != 0 # remove the error handler
    end
  end
end
