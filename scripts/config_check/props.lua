local props_cfg = require('config.props')
local shops_cfg = require('config.shop')
local formula_cfg = require('config.gem_compound')
local equip_up_cfg = require('config.equip_upgrade')
local equip_com_cfg = require('config.equip_compound')

local function check_prop( prop )
	assert(prop.type)
	if prop.for_sale then assert(prop.sale_price) end
	if prop.overlap then assert(prop.overlap_limit) end
end

local function check_shop( shop_prop )
	assert(shop_prop.SID)
	assert(shop_prop.prop_kind)
	assert(props_cfg[shop_prop.prop_kind])
	assert(shop_prop.coin_type)
	assert(shop_prop.price)
end

local function check_gem_compound( formula )
	assert(formula.gems)
	local total = 0
	for _, gem in pairs( formula.gems ) do
		assert(gem.kind)
		assert(props_cfg[gem.kind])
		assert(gem.probability)
		total = total + gem.probability
		assert(gem.amount)
	end
	assert( total==1 )
	assert(formula.materials)
	for _, material in pairs( formula.materials ) do
		assert(material.kind)
		assert(props_cfg[material.kind])
		assert(material.cost)
	end
	assert(formula.level)
end

local function check_equip_upgrade( up )
	assert(up.non_weapon)
	assert(up.weapon)
end

local function check_equip_compound( formula )
	assert(formula.equip)
	assert(props_cfg[formula.equip])
	assert(formula.target_equip)
	assert(props_cfg[formula.target_equip])
	assert(formula.materials)
	for _, material in pairs(formula.materials) do
		assert(material.kind)
		assert(props_cfg[material.kind])
		assert(material.amount)
		assert(material.cost)
	end
end

do
	--print('-->check props	<roughly>')
	for id, prop in pairs(props_cfg) do
		local ret, err = pcall(check_prop, prop)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check shop')
	for id1, shop in pairs(shops_cfg) do
		for id2, prop in pairs( shop ) do
			local ret, err = pcall(check_shop, prop)
			if not ret then print('id1='..id1..'id2='..id2..' has error') print(err) end
		end
	end
end

do
	--print('-->check gem compound')
	for id, formula in pairs(formula_cfg) do
		local ret, err = pcall(check_gem_compound, formula)
		if not ret then print('id='..id..' has error') print(err) end
	end
end

do
	--print('-->check equip upgrade')
	for id=1,#equip_up_cfg do
		if equip_up_cfg[id] then
			if not equip_up_cfg[id].weapon and not equip_up_cfg[id+1] then break end
			local ret, err = pcall(check_equip_upgrade, equip_up_cfg[id])
			if not ret then print('id='..id..' has error') print(err) end
		else
			print('id='..id..' has error')
		end
	end
end

do
	--print('-->check equip compound')
	for id, formula in pairs(equip_com_cfg) do
		local ret, err = pcall(check_equip_compound, formula)
		if not ret then print('id='..id..' has error') print(err) end
	end
end