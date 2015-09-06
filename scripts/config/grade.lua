local grade = {}

grade[1] = 
{
    prestige = 250,
    silver_ratio = 0.8,
    property = {strength = 6, agility = 6, intelligence = 6},
    stamina_max = 170,
}

grade[2] = 
{
    prestige = 500,
    silver_ratio = 0.85,
    activation1 = {19},
    activation2 = {23},
    activation3 = {16},
    property = {strength = 12, agility = 12, intelligence = 12},
    stamina_max = 175,
}

grade[3] = 
{
    prestige = 1000,
    silver_ratio = 0.9,
    property = {strength = 18, agility = 18, intelligence = 18},
    stamina_max = 180,
}

grade[4] = 
{
    prestige = 1750,
    silver_ratio = 0.95,
    property = {strength = 24, agility = 24, intelligence = 24},
    stamina_max = 185,
}

grade[5] = 
{
    prestige = 3500,
    silver_ratio = 1,
    activation1 = {18},
    activation2 = {4},
    activation3 = {3},
    property = {strength = 30, agility = 30, intelligence = 30},
    stamina_max = 190,
}

grade[6] = 
{
    prestige = 7000,
    silver_ratio = 1.025,
    property = {strength = 36, agility = 36, intelligence = 36},
    stamina_max = 195,
}

grade[7] = 
{
    prestige = 10500,
    silver_ratio = 1.05,
    property = {strength = 42, agility = 42, intelligence = 42},
    stamina_max = 200,
}

grade[8] = 
{
    prestige = 14000,
    silver_ratio = 1.075,
    property = {strength = 48, agility = 48, intelligence = 48},
    stamina_max = 205,
}

grade[9] = 
{
    prestige = 45000,
    silver_ratio = 1.1,
    property = {strength = 54, agility = 54, intelligence = 54},
    stamina_max = 210,
}

grade[10] = 
{
    prestige = 45000,
    silver_ratio = 1.125,
    property = {strength = 60, agility = 60, intelligence = 60},
    stamina_max = 215,
}

grade[11] = 
{
    prestige = 45000,
    silver_ratio = 1.15,
    property = {strength = 66, agility = 66, intelligence = 66},
    stamina_max = 220,
}

grade[12] = 
{
    prestige = 45000,
    silver_ratio = 1.175,
    property = {strength = 72, agility = 72, intelligence = 72},
    stamina_max = 225,
}

grade[13] = 
{
    silver_ratio = 1.2,
    property = {strength = 78, agility = 78, intelligence = 78},
    stamina_max = 230,
}

grade[14] = 
{
    silver_ratio = 1.225,
    property = {strength = 84, agility = 84, intelligence = 84},
    stamina_max = 240,
}

grade[15] = 
{
    silver_ratio = 1.25,
    property = {strength = 90, agility = 90, intelligence = 90},
    stamina_max = 250,
}

grade[16] = 
{
    silver_ratio = 1.275,
    property = {strength = 96, agility = 96, intelligence = 96},
    stamina_max = 260,
}

local heros_order = {{},{},{}}
for _,v in pairs(grade) do
    v.activation = {}
    v.activation[1] = v.activation1
    v.activation[2] = v.activation2
    v.activation[3] = v.activation3
    
    for k,heros in pairs(v.activation) do
        for _,hero in pairs(heros) do
            table.insert(heros_order[k],hero)
        end
    end
    
    v.activation1 = nil
    v.activation2 = nil
    v.activation3 = nil
end

if true then return {grade, heros_order} end

return grade