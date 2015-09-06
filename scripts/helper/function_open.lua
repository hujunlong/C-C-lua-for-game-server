module('FunctionOpen', package.seeall)

array_skills = require("config.array")
fight_skills = require("config.fight_skill")
town_skills = require("config.town_skill")


local function ActiveSkill(level, skills)
	for _,skill in pairs(skills) do 
		if skill[1].level==level then 
			
			break
		end
	end
end

function OnLevelUp(level)
	ActiveSkill(level, array_skills)
	ActiveSkill(level, fight_skills)
	ActiveSkill(level, town_skills)
end

function OnTaskComplete(task)
	
end