-- fn.lua
-- Copyright (c) David Hollander 2011
-- Released under the MIT License, see LICENSE.TXT

-- fn.lua provides functional programming extras for Lua
-- See http://www.github.com/davidhollander/fn
-- Unlike some other functional libraries, it makes use of "select" to ensure ending nil values are preserved.
-- It aims to support the manipulation of ordered data via both Lua Tables and Lua multi arity arguments.
-- It will avoid implementing library functions in terms of each other to reduce the height of the call stack for end users.

module(... or 'fn', package.seeall)
-- set(t, k, v): functional __newindex
function set(t, k, v)
  t[k]=v
  return true
end

--get(t, k): functional __index
function get(t, k)
  return t[k]
end
---call a function k times with ..., return time taken
function clock(fn, k, ...)
  local c=os.clock()
  for i=1,k do fn(...) end
  return os.clock() -c
end

-- tuple(...): stores values, returns lambda
-- lambda(): returns all values
function tuple(...)
  local n=select('#',...)
  local t={...}
  return function() return unpack(t,1,n) end
end

-- collect(...): store args, return lambda
-- lambda(): return stored args
-- lambda(...): store new args appended to old
function collect(...)
	local n=select('#',...)
	local t={...}
	return function(...)
		local n2=select('#',...)
		if n2==0 then return unpack(t,1,n)
		else
			local t2={...}
			for i=1,n2 do t[n+i]=t2[i] end
			n=n+n2
		end
	end
end

-- call(fn, ...): store fn and args, return lambda
-- lambda(): call stored fn with stored args
function call(fn, ...)
  local n=select('#',...)
  local t={...}
  return function() return fn(unpack(t,1,n)) end
end

-- fill(...): store args, return lambda
-- lambda(fn): call fn with stored args
function fill(...)
  local n=select('#',...)
  local t={...}
  return function(fn) return fn(unpack(t,1,n)) end
end

-- filter(fn, ...): returns args where fn evaluates true
function filter(fn, ...)
  local n, t = select('#', ...), {...}
  local t2={}
  for i=1,n do
    if fn(t[i]) then table.insert(t2,t[i]) end
  end
  return unpack(t2)
end
-- filtert(fn, t): returns a copy of t containing elements where fn(t[i])==true
function filtert(fn, t)
  local t2={}
  for i=1,#t do
    if fn(t[i]) then table.insert(t2,t[i]) end
  end
  return t2
end
--filterpairs(fn, t): returns a copy of table t containing pairs where fn(k,v)==true
function filterpairs(fn, t)
  local t2={}
  for k,v in pairs(t) do
    if fn(k,v) then t2[k]=v end
  end
  return t2
end

-- partial(fn, ...): store fn and args, return lambda
-- lambda(...): call stored fn with stored args + new args
function partial(fn, ...)
  local n=select('#', ...)
  local t={...}
  return function(...)
    local n2=select('#', ...)
    local t2={...}
    for i=1,n2 do t[n+i]=t2[i] end
    return fn(unpack(t,1,n+n2))
  end
end

-- flattenr(...): sequentially and recursively flattens all functions in args, return all values in order
function flattenr(...)
  local out={}
  local k=0
  local function flat(...)
    local n, t = select('#',...), {...}
    for i=1,n do
      if type(t[i])=='function' then flat(t[i]())
      else k=k+1; out[k]=t[i] end
    end
  end
  flat(...)
  return unpack(out,1,k)
end

-- map(fn, ...): return each arg transformed by fn
function map(fn, ...)
  local n, t = select('#',...), {...}
  for i=1,n do t[i]=fn(t[i]) end
  return unpack(t,1,n)
end

-- mapt(fn, table): return a copy of table, with each element transformed by fn
function mapt(fn, t)
  local t2={}
  for i,v in ipairs(t) do t2[i]=fn(v) end
  return t2
end
-- in place map
function mapti(fn, t)
  for i,v in ipairs(t) do t[i]=fn(v) end
end

-- mapkeys(fn, table): return a list of keys from table [t] transformed by [fn]
function mapkeys(fn, t)
  local t2={}
  for k,v in pairs(t) do table.insert(t2, fn(k)) end
  return t2
end
-- foldl(fn, ...): use fn to left fold args
function foldl(fn, ...)
  local n=select('#',...)
  local t={...}
  local v=t[1]
  for i=2,n do v = fn(v,t[i]) end
  return v
end

-- foldlt(fn, v, t): use fn and an initial v to left fold table
function foldlt(fn, v, t)
	for i=1,#t do v=fn(v,t[i]) end
	return v
end

-- foldr(fn, ...): use fn to right fold args
function foldr(fn, ...)
  local n=select('#',...)
  local t={...}
  local v=t[n]
  for i=n-1,1,-1 do v=fn(t[i],v) end
  return v
end

-- foldrt(fn, t, v): use fn to right fold a table with a rightmost v
function foldrt(fn, t, v)
	for i=#t,1,-1 do v=fn(t[i], v) end
	return v
end

-- gen(fn, initial): store args, return lambda
-- lambda(): recursively call a single arity function one step after initially returning stored args
function gen(fn, initial)
  local x
  return function()
    x=x and fn(x) or initial
    return x
  end
end

-- genn(fn, ...): store args, return lambda
-- lambda(): recursively call a multi arity function one step after initially returning stored args
function genn(fn, ...)
  local initial=tuple(...)
  local z
  return function()
    z=z and tuple(fn(z())) or initial
    return z()
  end
end

-- compose(fn1, fn2): chain 2 functions together
function compose(fn1, fn2)
  return function(...) return fn1(fn2(...)) end
end

-- composen(...): chain multiple functions together
function composen(...)
  local fns={...}
  return function(...)
    local x = tuple(...)
    for i=#fns,1,-1 do
      x = tuple(fns[i](x()))
    end
    return x()
  end
end
