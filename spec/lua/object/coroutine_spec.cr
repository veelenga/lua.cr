require "../../spec_helper"

module Lua
  describe Coroutine do
    describe "#resume" do
      it "starts and resumes coroutine" do
        lua = Lua.load
        f = lua.run %q{
          return function()
            coroutine.yield()
          end
        }
        co = lua.newthread(f.as Lua::Function)
        co.status.should eq CALL::OK
        co.resume
        co.status.should eq CALL::YIELD
        co.resume
        co.status.should eq CALL::OK
        lua.close
      end

      it "can yield arguments" do
        lua = Lua.load
        f = lua.run %q{
          return function(x)
            return coroutine.yield()
          end
        }
        co = lua.newthread(f.as Lua::Function)
        co.resume.should eq nil
        co.resume(42).should eq 42.0
        lua.close
      end

      it "resumes coroutine created with coroutine.create" do
        lua = Lua.load
        t = lua.run %q{
          function s(x)
            return coroutine.yield(x)
          end
          return coroutine.create(s)
        }

        co = t.as(Lua::Coroutine)
        co.resume.should eq nil
        co.status.should eq CALL::YIELD
        co.resume("test").should eq "test"
        co.status.should eq CALL::OK
        lua.close
      end

      it "can return an error" do
        lua = Lua.load
        t = lua.run %q{
          function s(x)
            return x * 20
          end
          return coroutine.create(s)
        }

        co = t.as(Lua::Coroutine)
        expect_raises RuntimeError do
          co.resume("hello")
        end
        co.status.should eq CALL::ERRRUN
        lua.close
      end
    end
  end
end
