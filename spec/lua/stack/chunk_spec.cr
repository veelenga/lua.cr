require "../../spec_helper"

module Lua::StackMixin
  describe Chunk do
    describe "#run" do
      it "evaluates a lua chunk" do
        r = Stack.new.run %q(
          runuble = function (x)
            return x * 2
          end

          return runuble(runuble(2))
        )
        r.should eq 8
      end

      it "removes a chunk and results from the stack" do
        s = Stack.new.tap(&.<< "first element")
        s.run %q( return 122 )
        s.size.should eq 1
        s[1].should eq "first element"
      end

      it "returns nil if there are no returnings" do
        s = Stack.new
        s.run("a = 10").should be_nil
        s.size.should eq 0
      end

      it "can return any of Lua::Type" do
        s = Stack.new
        s.run(%q( return nil )).should be_nil
        s.run(%q( return "a" )).should eq "a"
        s.run(%q( return false )).should be_false
        s.run(%q( return true )).should be_true
        s.run(%q( return 100 )).should eq 100
        s.run(%q( a = {}; a[1] = "a"; return a )).as(Lua::Table)[1].should eq "a"
        s.run(%q(
          sum = function(x, y)
            return x + y
          end
          return sum
        )).should be_a Function
        s.close
      end

      # Regression: luaL_loadbufferx must be passed the byte length of the
      # chunk, not the codepoint count. Passing `String#size` (codepoints)
      # silently truncates the buffer for any non-ASCII byte, which then
      # surfaces as a spurious "<eof>" / "unfinished string" syntax error
      # at the *tail* of the chunk rather than at the offending character.
      context "with non-ASCII characters (multibyte UTF-8)" do
        it "keeps the full chunk when a comment contains Latin-1 supplement" do
          chunk = String.build do |io|
            io << "-- comment with é, à, ç\n"
            io << "return 42\n"
          end
          Stack.new.run(chunk).should eq 42
        end

        it "keeps the full chunk when a comment contains Thai" do
          # สวัสดี : each codepoint is 3 bytes in UTF-8
          chunk = String.build do |io|
            io << "-- สวัสดีครับ\n"
            io << "return 7\n"
          end
          Stack.new.run(chunk).should eq 7
        end

        it "keeps the full chunk when a comment contains CJK" do
          # 你好世界 : each codepoint is 3 bytes in UTF-8
          chunk = String.build do |io|
            io << "-- 你好世界\n"
            io << "return 11\n"
          end
          Stack.new.run(chunk).should eq 11
        end

        it "keeps the full chunk when a comment contains an em-dash" do
          chunk = String.build do |io|
            io << "-- an em-dash — here\n"
            io << "return 99\n"
          end
          Stack.new.run(chunk).should eq 99
        end

        it "passes non-ASCII bytes through inside string literals" do
          # `"é — สวัสดี 你好"` written via string concatenation so the Lua
          # source contains a literal double-quoted string with multibyte
          # bytes inside it.
          inner = "\u00E9 — \u0E2A\u0E27\u0E31\u0E2A\u0E14\u0E35 \u4F60\u597D"
          chunk = "return \"" + inner + "\"\n"
          Stack.new.run(chunk).should eq inner
        end

        it "loads a chunk whose entire trailing portion is multibyte" do
          # If the loader truncates by even one byte, the final `return`
          # statement gets mangled and we get a tail-side syntax error
          # instead of the intended value.
          chunk = String.build do |io|
            io << "-- 你好สวัสดีé—\n"
            io << "return 123\n"
          end
          Stack.new.run(chunk).should eq 123
        end
      end
    end

    describe "#run" do
      it "loads lua chunk from file" do
        Stack.new.run(File.new "spec/fixtures/sample.lua").should eq 23
      end

      it "removes chunk and results from the stack" do
        s = Stack.new.tap(&.<< false)
        s.run File.new("spec/fixtures/sample.lua")
        s.size.should eq 1
        s[1].should be_false
      end
    end
  end
end
