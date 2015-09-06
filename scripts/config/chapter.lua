local chapters = {}

chapters[1] = 
{
    head = 1,
    tail = 7,
    country = 0,
}

chapters[2] = 
{
    head = 8,
    tail = 20,
    country = 1,
}

chapters[3] = 
{
    head = 21,
    tail = 33,
    country = 2,
}

chapters[4] = 
{
    head = 34,
    tail = 46,
    country = 3,
}

chapters[5] = 
{
    head = 47,
    tail = 61,
    country = 0,
}

chapters[6] = 
{
    head = 62,
    tail = 79,
    country = 0,
}

chapters[7] = 
{
    head = 80,
    tail = 94,
    country = 0,
}

chapters[8] = 
{
    head = 95,
    tail = 112,
    country = 0,
}

chapters[9] = 
{
    head = 113,
    tail = 136,
    country = 0,
}


for _,v in pairs(chapters) do 
	if v.country==0 then v.country=nil end
end

return chapters