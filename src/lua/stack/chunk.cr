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
      LibLua.l_loadbufferx @state, buff, buff.size, "lua_chunk", nil
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

    protected def call_and_return(chunk_pos, *args)
      # loads handler just below the chunk
      error_handler_pos = self.load_error_handler chunk_pos
      chunk_pos += 1 if error_handler_pos != 0

      args.each { |a| self.<< a }
      call = CALL.new LibLua.pcallk(@state, args.size, Lua::MULTRET, 1, error_handler_pos, nil)
      raise self.error(call, pop.as(Lua::Table).to_h) if call != CALL::OK

      elements = (chunk_pos..size).map { pop }
      elements.size > 1 ? elements : elements.first?
    ensure
      self.remove if error_handler_pos != 0 # removes the handler
    end
  end
end
