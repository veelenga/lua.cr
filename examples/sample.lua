--> https://www.lua.org/pil/16.2.html

--> Account
Account = { balance = 0 }

function Account:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Account:deposit (v)
  self.balance = self.balance + v
end

function Account:withdraw (v)
  if v > self.balance then error"insufficient funds" end
  self.balance = self.balance - v
end

--> SpecialAccount
SpecialAccount = Account:new()

function SpecialAccount:withdraw (v)
  if v - self.balance >= self:getLimit() then
    error"insufficient funds"
  end
  self.balance = self.balance - v
end

function SpecialAccount:getLimit ()
  return self.limit or 0
end

--> Main
s = SpecialAccount:new{limit=1000.00}
s:deposit(100.00)
s:withdraw(58.00)

return s.balance --> 42.0
