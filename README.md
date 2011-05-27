# fn.lua

Copy fn.lua into your lua module directory. On Ubuntu, this is /usr/local/share/lua/5.1/

importing

	require'fn'
	
create a new function that will call Fold Left using an addition function as the first parameter

	sum = fn.partial( fn.foldl, function(a, b) return a+b end)

call sum with a list of numbers

	x = sum(1, 2, 3, 4, 5, 6, 7, 8, 9)
	print(x)
	-- 45

see fn.lua and tests.lua for additional information.
