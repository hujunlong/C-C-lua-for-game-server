crit_probability = require('config.train_crit_probability')
buy_cost = require('config.train_buy_cost')
level_silver = require("config.train_level_silver")
train = require("config.train")
guild_frames = require('config.guild_frames')
guild_exp = require('config.guild_exp')
guild_heavensents1 = require('config.guild_heavensents1')
guild_heavensents2 = require('config.guild_heavensents2')
guild_skills = require("config.guild_skills")
guild_war_fields = require("config.guild_war_fields")
guild_war_fields_technology = require("config.guild_war_fields_technology")
guild_war_maps = require("config.guild_war_maps")

---------------------------------------------------------------------------------------
	assert(next(crit_probability))
    for _,force_p in ipairs(crit_probability) do
        assert(force_p.exp_coefficient>0)
        for _,crit_probability in pairs(force_p.crit_probability) do
            for i=1,#crit_probability do
              assert(crit_probability[i]>0)
            end
        end
    end
---------------------------------------------------------------------------------------
	assert(next(buy_cost))
    for _,_buy_cost in ipairs(buy_cost) do 
        assert(_buy_cost.buy_num>0)
        assert(_buy_cost.consumer_gold>0)
    end
---------------------------------------------------------------------------------------
	assert(next(guild_frames))
    for _,_guild_frames in ipairs(guild_frames) do 
        assert(_guild_frames.need_gold>0)
    end
---------------------------------------------------------------------------------------
	assert(next(guild_exp))
    for i=1,#guild_exp-1 do 
        assert(guild_exp[i].exp>0)
    end
---------------------------------------------------------------------------------------
	assert(next(guild_heavensents1))
    for _,_guild_heavensents1 in ipairs(guild_heavensents1) do 
        assert(_guild_heavensents1.level_max >0 )
        assert(_guild_heavensents1.active_level >0 )
        if _guild_heavensents1.need_prepare_heavensent then
            assert(_guild_heavensents1.need_prepare_heavensent.prepare >0 )
            assert(_guild_heavensents1.need_prepare_heavensent.level >0 )
        end
    end
---------------------------------------------------------------------------------------
	assert(next(guild_heavensents2))
    for _,_guild_heavensents2 in ipairs(guild_heavensents2) do 
        assert(_guild_heavensents2.id >0 )
        assert(_guild_heavensents2.level >0 )
        if _guild_heavensents2.add_sub_line_silver_per then
            assert(_guild_heavensents2.add_sub_line_silver_per >0 and _guild_heavensents2.add_sub_line_silver_per < 1)
        end
        if _guild_heavensents2.sub_town_cd_per then
            assert(_guild_heavensents2.sub_town_cd_per >0 and _guild_heavensents2.sub_town_cd_per < 1)
        end
    end
---------------------------------------------------------------------------------------
assert(next(guild_skills))
    for _,_guild_skills in ipairs(guild_skills) do 
        assert(_guild_skills.active_level >0 )
        if _guild_skills.add_guild_member then
            assert(_guild_skills.add_guild_member>0)
        end
        
        if _guild_skills.add_guild_grade then
            assert(_guild_skills.add_guild_grade>0)
        end
        
        if _guild_skills.add_rune_energy_per then
            assert(_guild_skills.add_rune_energy_per>0 and _guild_skills.add_rune_energy_per < 1)
        end
        
        if _guild_skills.add_energy_mobility_per then
            assert(_guild_skills.add_energy_mobility_per.energy>0 and _guild_skills.add_energy_mobility_per.mobility>0)
        end
        
        if _guild_skills.add_high_level_task_per then
            for i,_add_energy_mobility_per in pairs(_guild_skills.add_high_level_task_per) do
                assert(_add_energy_mobility_per)
            end
        end
    end
---------------------------------------------------------------------------------------
assert(next(guild_war_fields))
for _,_guild_war_fields in pairs(guild_war_fields) do
    assert(_guild_war_fields.map_name)
    assert(_guild_war_fields.field_map_id>0)
    assert(_guild_war_fields.field_type>0)
    assert(_guild_war_fields.move_cd>0)
    assert(_guild_war_fields.fight_box_type>0)
    assert(_guild_war_fields.fight_box_count>0)
    assert(_guild_war_fields.guild_box_type>0)
    assert(_guild_war_fields.guild_box_count>0)
    assert(_guild_war_fields.member_box_type>0)
end
---------------------------------------------------------------------------------------
assert(next(guild_war_fields_technology))
for _,_guild_war_fields in pairs(guild_war_fields_technology) do
    assert(_guild_war_fields.war_field_id>0)
    assert(_guild_war_fields.technology_level>0)
    if _guild_war_fields.exp then
        assert(_guild_war_fields.exp>0)
    end
    assert(_guild_war_fields.add_heal_hp_per>0 and _guild_war_fields.add_heal_hp_per<1)
    if _guild_war_fields.sub_hurt_per then
        assert(_guild_war_fields.sub_hurt_per>0 and _guild_war_fields.sub_hurt_per<1)
    end
    assert(_guild_war_fields.add_max_hp_per>0 and _guild_war_fields.add_max_hp_per<1)
end
---------------------------------------------------------------------------------------
assert(next(guild_war_maps))
for _,_guild_war_maps in pairs(guild_war_maps) do
    if _guild_war_maps.reborn_locations then
        assert(next(_guild_war_maps.reborn_locations))
        assert(_guild_war_maps.attack_born_location > 0)
        assert(_guild_war_maps.defense_born_location > 0)
        assert(next(_guild_war_maps.resource_locations))
    end
end
---------------------------------------------------------------------------------------
assert(next(level_silver))
for _,_level_silver in pairs(level_silver) do
    assert(_level_silver.level>0)
    assert(_level_silver.exp>0)
    assert(_level_silver.silver>0)
end
---------------------------------------------------------------------------------------
assert(next(train))
for _,_train in pairs(train) do
    assert(_train.level>=0)
    assert(_train.cost_gold>0)
    assert(_train.strength_cost_gold>=0)
    assert(_train.max_buy_count>=0)
    assert(_train.every_time_available_train_count>=0)
    assert(_train.max_available_train_count>0)
end
---------------------------------------------------------------------------------------