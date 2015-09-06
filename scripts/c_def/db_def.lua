require('ctype')

local int8 = Int8
local int16 = Int16
local int32 = Int32
local str = Str

--local DbType = DbType

local def = {}

def[DbType.kGetAllTownItems] =
{
	{int32, 'uid'},
}


function GetDbDef(type)
	return def[type]
end
  





