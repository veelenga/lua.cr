module Lua
  module StackMixin::Chunk
    # Evaluates a Lua chunk and returns the result if any.
    # You can set the name of your chunk using `name` var.
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
    def run(buff : String, name : String? = nil)
      call = CALL.new LibLua.l_loadbufferx @state, buff, buff.size, name || buff.strip, nil
      raise self.error(call, pop) if call != CALL::OK
      call_and_return size
    end

    # Evaluates a Lua chunk in a file and returns the result if any.
    #
    # ```
    # Stack.new.run File.new("./sample.lua")
    # ```
    def run(lua_file : File)
      call = CALL.new LibLua.l_loadfilex @state, lua_file.path, nil
      raise self.error(call, pop) if call != CALL::OK
      call_and_return size
    end

    protected def call_and_return(chunk_pos, *args)
      # loads handler just below the chunk
      error_handler_pos = self.load_error_handler chunk_pos
      chunk_pos += 1 if error_handler_pos != 0

      args.each { |a| self.<< a }
      call = CALL.new LibLua.pcallk(@state, args.size, Lua::MULTRET, error_handler_pos, 0, nil)
      raise self.error(call, pop) if call != CALL::OK

      pick_results chunk_pos
    ensure
      self.remove if error_handler_pos != 0 # removes the handler
    end
  end
end
