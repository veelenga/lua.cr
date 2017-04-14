require "../spec_helper"

def check_maps_value(v, entry)
  Lua::Type.new(v).should eq entry
end

module Lua
  describe Type do
    it "maps -1 to TNONE" do
      check_maps_value -1, Type::TNONE
    end

    it "maps 0 to TNIL" do
      check_maps_value 0, Type::TNIL
    end

    it "maps 1 to TBOOLEAN" do
      check_maps_value 1, Type::TBOOLEAN
    end

    it "maps 2 to TLIGHTUSERDATA" do
      check_maps_value 2, Type::TLIGHTUSERDATA
    end

    it "maps 3 to TNUMBER" do
      check_maps_value 3, Type::TNUMBER
    end

    it "maps 4 to TSTRING" do
      check_maps_value 4, Type::TSTRING
    end

    it "maps 5 to TTABLE" do
      check_maps_value 5, Type::TTABLE
    end

    it "maps 6 to TFUNCTION" do
      check_maps_value 6, Type::TFUNCTION
    end

    it "maps 7 to TUSERDATA" do
      check_maps_value 7, Type::TUSERDATA
    end

    it "maps 8 to TTHREAD" do
      check_maps_value 8, Type::TTHREAD
    end
  end
end
