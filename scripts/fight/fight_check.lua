local function CheckEnvironmentArgs(env)
    local wea = {'sunny', 'rain', 'cloudy', 'snow', 'fog'}
    local geo = {'plain', 'mountain', 'forest', 'lake', 'coastal', 'cave', 'wasteland', 'citadel'}
    
    local t_wea = {}
    for _,v in pairs(wea) do
        t_wea[v] = true
    end
    
    local t_geo = {}
    for _,v in pairs(geo) do
        t_geo[v] = true
    end
    
    assert(env)
    assert(env.type)
    assert(env.weather)
    assert(env.terrain)
    assert(t_wea[env.weather])
    assert(t_geo[env.terrain])
    
    assert(env.group_a)
    assert(env.group_b)
    
    if env.round_limit then assert(env.win_condition) end
    
    for _,v in pairs({env.group_a,env.group_b}) do
        if not v.is_monster then
            assert(v.name)
            assert(v.array)
        end
        
        if not env.group_a.is_monster and not env.group_b.is_monster and env.type~=6 then
            assert(v.sex)
            assert(v.level)
        end
    end
end

local function CheckGroupArgs(group)
    local count = 0
    for _,hero in pairs(group) do
        count = count + 1
        assert(hero.level)
        assert(hero.id)
    end
    assert(count>0 and count<=5)
end

local function CheckFightArgs(group_a, group_b, env)
    CheckGroupArgs(group_a)
    CheckGroupArgs(group_b)
    CheckEnvironmentArgs(env)
end

return CheckFightArgs