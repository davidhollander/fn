-- tests.lua
-- Copyright (c) David Hollander 2011
-- Released under the MIT License, see LICENSE.TXT

-- Function tests for fn.lua, see: http://www.github.com/davidhollander/fn
-- If an error is found, please raise an issue on github or via gmail: dhllndr.

require 'fn'
for k,v in pairs(fn) do _G[k]=v end
local test={}

test.set = function()
  local t={}
  set(t, 'foo', 'bar')
  assert(t.foo=='bar')
end

test.tuple = function()
  local x = tuple(1,2,nil,3,nil)
  local function t(...)
    assert(select('#',...)==5)
    local t={...}
    assert(t[1]+t[2]+t[4] == 6)
  end
  t(x())
end

test.collect = function()
  local x = collect(1,2,nil,3,nil)
  x(4,5,nil)
  x(7)
  local function t(...)
    assert(select('#',...)==9)
    local t={...}
    assert(t[1]+t[2]+t[4]+t[6]+t[7]+t[9] == 22)
  end
  t(x())
end

test.call = function()
  local exp = function(x,y) return x^y end
  local fn = call(exp,2,8)
  assert(fn() == 2^8)
end

test.fill = function()
  local exp = function(x,y) return x^y end
  local x = fill(exp,2,8)
  assert(x(call)() == 2^8)
end

test.partial = function()
  local sum = partial(foldl, function(a,b) return a+b end)
  assert(sum(1,2,3,4,5) == 15)
end

test.flattenr = function()
  local function check(...)
    local n, t = select('#', ...), {...}
    assert(n==10)
    assert(t[1]+t[2]+t[3]+t[5]+t[6]+t[7]+t[8]+t[9])
  end
  check(flattenr(tuple(3,2,1,nil),1,3,tuple(3,tuple(3,1)),nil))
end

test.map = function()
  local t = {map(function(x) return x*2 end, 1,2,3,4,5)}
  assert(t[1]+t[2]+t[3]+t[4]+t[5] == 30)
end

test.mapt = function()
  local out = mapt(function(x) return x*2 end, {1,2,3})
  assert(out[1]+out[2]+out[3] == 12)
end

test.foldl = function(fn, ...)
  local v = foldl(function(a,b) return a-b end, 1,2,3,4,5)
  assert(v == -13)
end

test.foldlt = function()
  assert(foldlt(function(a,b) return a-b end,0,{1,2,3,4}) == -10)
end

test.foldr = function()
  assert(foldr(function(a,b) return a-b end,0,1,2,3,4,5)== -3)
end

test.foldrt = function()
  assert(foldrt(function(a,b) return a-b end,{1,2,3,4},0) == -2)
end

test.gen = function()
  local y = gen(function(x) return x*2 end,10)
  assert(y()+y()+y()+y() == 10+20+40+80)
end

test.genn = function()
  local z = genn(function(x,y) return x*2,y+2 end, 4, 4)
  z();z();z();z()
  local x, y = z()
  assert(x==64 and y==12)
end

test.compose = function()
  local fn = compose(
    function(x,a,b) return x*2,a,b end,
    function(y,a,b) return y*2,a,b end)
  local function test(...)
    assert(select('#',...)==3)
    local t={...}
    assert(t[1]==16)
    assert(t[2]==8)
  end
  test(fn(4,8,nil))
end

test.composen = function()
  local fn = composen(
    function(x,a,b) return x*2,a,b end,
    function(y,a,b) return y*2,a,b end,
    function(z,a,b) return z*2,a,b end)
  local x = function(...)
    assert(select('#',...)==3)
    local t={...}
    assert(t[1]==32)
    assert(t[2]==8)
  end
  x(fn(4,8,nil))
end

test.filter = function()
  local function check(...)
    local n, t = select('#', ...), {...}
    assert(n==4)
    assert(t[1]+t[2]+t[3]+t[4]==6+7+8+9)
  end
  check(filter(function(el) return el>5 end, 1,2,3,4,5,6,7,8,9))
end

test.filtert = function()
  local t = filtert(function(el) return el>5 end,{1,2,3,4,5,6,7,8,9})
  assert(#t==4)
  assert(t[1]+t[2]+t[3]+t[4]==6+7+8+9)
end

test.filterpairs = function()
  local t = filterpairs(function(k,v) if k==v then return true end end,{
    key='key', foo='bar', name='blame', game='same', baz='baz'})
  assert(t.key and t.baz and not t.name)
end

for k,fn in pairs(test) do
  print(k) fn()
end
print('\n','passed.')
