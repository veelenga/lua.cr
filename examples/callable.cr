require "../src/lua"

stack = Lua.load

abstract class Animal
  include LuaCallable
  getter mood = 0
  getter hungry = 0
  getter energy = 100
  property liked = false
  getter name

  def initialize(@name : String)
  end

  def sleep
    @energy += 1
    @hungry += 1
  end

  def play
    @mood += 1
    @energy -= 1 if @energy > 0
    say_hi
  end

  def feed
    @hungry -= 1 if @hungry > 0
    @mood += 1
    say_hi
  end

  abstract def say_hi
end

class Cat < Animal
  def meow
    puts "meow"
  end

  def say_hi
    meow; meow
  end
end

class Cow < Animal
  def moo
    puts "moo"
  end

  def say_hi
    moo; moo
  end

  def milk
    @energy -= 1
    @hungry += 1
    moo
  end
end

class MyLuaModule
  include LuaCallable
  @animals = [] of Animal

  def new_cow(name : String)
    Cow.new(name).tap { |c| @animals << c }
  end

  def new_cat(name : String)
    Cat.new(name).tap { |c| @animals << c }
  end

  def hello_farm
    "Hello from farm!"
  end

  def hungry?
    String.build do |io|
      @animals.each do |a|
        if a.hungry > 0
          io << a.name << ": " << a.hungry << "\n"
        end
      end
    end
  end

  def feed_all
    @animals.each &.feed
  end
end

# single farm company
stack.set_global("farm", MyLuaModule.new)
stack.run %q{
  print(farm.hello_farm())
  rose = farm.new_cow("Rose")
  rose.milk()
  flower = farm.new_cow("Flower")
  flower.play()
  assert(flower.mood > rose.mood)
  rose.liked = true
  assert(rose.liked)
  tiger = farm.new_cat("tiger")
  tiger.play()
  assert(tiger.energy < 100)
  tiger.sleep()
  assert(tiger.energy == 100)
  assert(tiger.hungry > 0)
  print("hungry animals:\n" .. farm["hungry?"]())
  farm.feed_all()
  print("hungry animals:\n" .. farm["hungry?"]())
  assert(tiger.hungry == 0)
  assert(rose.hungry == 0)
  assert(flower.hungry == 0)
}

# multi farm company
stack.set_global("Farm", MyLuaModule)
stack.run %q{
  europe_farm = Farm.new()
  us_farm = Farm.new()
  rose = us_farm.new_cow("Rose")
  rose.milk()
  brunhilde = europe_farm.new_cow("Brunhilde")
  brunhilde.milk()
  assert(rose.hungry == brunhilde.hungry, "Do Cows Moo in Different Accents?")
}
