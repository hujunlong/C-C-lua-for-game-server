function ErrorHandle(err_str)
	print(err_str)
	print(debug.traceback())
	for i=2,4 do 
		local info = debug.getinfo(i)
		if not info then break end
--		if not info.name then break end
--[[		print('stack '..i)
		print('name:', info.name)
		print('namewhat:', info.namewhat)
		print('source:', info.source)
		print('short_src:', info.short_src)
		print('lastlinedefined:', info.lastlinedefined)
		print('what:', info.what)
		print('nups:', info.nups)
		print('activelines:', info.activelines)
		print('func:', info.func)
]]		
		print(info.short_src..':'..info.lastlinedefined..': in function "'..info.name or " " .. '"')
		
		for j=2,4 do 
			local name, value = debug.getlocal(i, j)
			if not name or name=='(*temporary)' or type(value)=='table' then break end
			print(name, value)
			if name=='player' then print('player id = ' .. value and value.GetUID()) end
			if name=='head' then print('head.aid='..value.aid) end
		end
		
--		print('upvalues----')
		local func = debug.getinfo(i).func
		for j=2,4 do 
			local name, value = debug.getupvalue(func, j)
			if not name then break end
			print(name, value)
		end
		
		print('')
	end
end