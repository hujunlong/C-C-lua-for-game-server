require('my_ffi')
require('tools.vector')
require('helper.equipment_property_generate')
require('fight_power')

local prop_cfgs = require('config.props')
local shop_cfgs = require('config.shop')
local gem_formulas = require('config.gem_compound')
local equip_upgrade_costs = require('config.equip_upgrade')
local equip_formulas = require('config.equip_compound')
local config = require('config.global')
local actions = require('define.action_id')

local gold_consume_flag = require('define.gold_consume_flag')


local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

local kMinBagGrids = 20
local kMinWarehouseGrids = 20
local kMaxBagGrids = 42
local kMaxWarehouseGrids = 54
local kSoldPropExpireSeconds = 60*60
local g_sold_props = {}
local trace_ = new("PropsAlteration")	--追踪道具改变
local head_trace = new("MqHead", 0, C.kPropsAlteration, -1)

local online_users = {}
function InitProp( g_players )
	online_users = g_players
end

local function RemoveExpiredSoldProp()
	local now = os.time()
	for uid,props in pairs(g_sold_props) do
		if not online_users[uid] then
			for id, p in pairs(props) do
				if (now-p.time) > kSoldPropExpireSeconds then 
					props[id]=nil 
				end
			end
		else
			trace_.amount = 0
			head_trace.aid = uid
			for id, p in pairs(props) do
				if (now-p.time) > kSoldPropExpireSeconds then 
					trace_.alters[trace_.amount] = { id, p.prop.kind, C.kInvalidID, C.kAreaSold, p.prop.location, p.prop.amount, p.prop.bind, C.kAlterationRemove }
					trace_.amount = trace_.amount + 1
					if trace_.amount>=250 then
						C.Send2Gate( head_trace, trace_, 4+trace_.amount*sizeof(trace_.alters[0]) )
						trace_.amount = 0
					end
					props[id]=nil
				end
			end
			if trace_.amount~=0 then
				C.Send2Gate( head_trace, trace_, 4+trace_.amount*sizeof(trace_.alters[0]) )
			end
		end
	end
end


ffi.CreateTimer(RemoveExpiredSoldProp, 30*60)

local function CompareProp(pa, pb)
	local ca,cb = prop_cfgs[pa.kind],prop_cfgs[pb.kind]
	if ca.type~=cb.type then return ca.type<cb.type
	elseif ca.sub_type~=cb.sub_type then return ca.sub_type<cb.sub_type
	else	return pa.kind<pb.kind
	end
end

function CreatePropManager(player)
	local obj = {}
	local db_processor_ = {}
	local processor_ = {}
	local prop_setting_ = new('PropSetting')
	local props_ = {}
	local equipments_ = {}  --包括了已出售的
	local formulas_ = {}
--	local equipment_names_ = {}
	local me = player
	local uid_ = me.GetUID()
	local name_ = me.GetCNickname()
	local max_id_ = 0
	
	local active_Strengthen = false
	local active_Inlay = false
	local active_CompoundGem = false
	local active_Migrate = false
	--local active_store = false

--  Inner functions
	local function PropsTraceBegin()
		trace_.amount = 0
	end
	
	local function PropsTraceEnd()
		if trace_.amount~=0 then
			head_trace.aid = uid_
			C.Send2Gate( head_trace, trace_, 4+trace_.amount*sizeof(trace_.alters[0]) )
		end
	end
	
	local function GetLocationProp(area, location)
		for id,prop in pairs(props_) do
			if  prop.location==location and prop.area==area then
				return prop,id
			end
		end
	end

	local function GetHeroEquipmentProp(hero_id, location)
		for id,equip in pairs(equipments_) do
			if props_[id] then
				if equip.hero==hero_id and props_[id].location==location then
					return props_[id],id
				end
			end
		end
	end

	local function IsLocationValid(area, location)
		if area==C.kAreaBag then return location<prop_setting_.bag_grids_count end
		if area==C.kAreaWarehouse then return location<prop_setting_.warehouse_grids_count end
		if area==C.kAreaHero then return location<10 end
		return true
	end

	local function Kind2Type(kind)
		return prop_cfgs[kind].type
	end

	local function IsMovingLegal(area)
		return area==C.kAreaBag or area==C.kAreaWarehouse or area==C.kAreaHero
	end


---------数据库相关操作
	local function UpdateEquipmentAssociateHero(id, hero)
		player.UpdateField(C.ktEquipment, id, {C.kfHero, hero})
		local prop = props_[id]
		local cfg = prop_cfgs[prop.kind]
		if cfg.binding==1 and hero~=C.kInvalidID and prop.bind==0 then
			prop.bind = 1
			player.UpdateField(C.ktProp, id, {C.kfBind, 1})
		end
	end

	local function UpdatePropPosition(id, prop, hero_id)
		if not hero_id then hero_id = C.kInvalidID end
		trace_.alters[trace_.amount] = { id, prop.kind, hero_id, prop.area, prop.location, prop.amount, prop.bind, C.kAlterationMove }
		trace_.amount = trace_.amount + 1
		me.UpdateField(C.ktProp, id, {C.kfArea,prop.area}, {C.kfLocation, prop.location} )
	end

	local function UpdatePropAmount( id, prop )
		trace_.alters[trace_.amount] = { id, prop.kind, C.kInvalidID, prop.area, prop.location, prop.amount, prop.bind, C.kAlterationUpdate }
		trace_.amount = trace_.amount + 1
		me.UpdateField(C.ktProp, id, {C.kfAmount, prop.amount})
	end
	
	local function Remove(id, hero_id)
		if not hero_id then hero_id = C.kInvalidID end
		local prop = props_[id]
		trace_.alters[trace_.amount] = { id, prop.kind, hero_id, prop.area, prop.location, prop.amount, prop.bind, C.kAlterationRemove }
		trace_.amount = trace_.amount + 1
		me.DeleteRow(C.ktProp, id)
		props_[id] = nil
		if  equipments_[id] then
--			equipments_[id] = nil  --保留以便查询
			me.DeleteRow(C.ktEquipment, id)
		end
	end

	local function InsertProps2Db(id, prop, equip, hero_id)
		if not hero_id then hero_id = C.kInvalidID end
		local cfg = prop_cfgs[prop.kind]
		if cfg.binding==0 then prop.bind=0
		elseif cfg.binding==1 and prop.area==C.kAreaHero then prop.bind=1
		elseif cfg.binding==2 then prop.bind=1
		elseif cfg.binding~=0 and prop.bind==1 then prop.bind=1	--repurchase
		else prop.bind=0
		end
		trace_.alters[trace_.amount] = { id, prop.kind, hero_id, prop.area, prop.location, prop.amount, prop.bind, C.kAlterationAdd }
		trace_.amount = trace_.amount + 1
		me.InsertRow(C.ktProp, {C.kfID, id}, {C.kfLocation,prop.location}, {C.kfAmount,prop.amount}, {C.kfKind, prop.kind}, {C.kfArea, prop.area}, {C.kfBind, prop.bind})
		if equip then
			me.InsertRow(C.ktEquipment, {C.kfID, id}, {C.kfStrength, equip.base_strength}, {C.kfAgility, equip.base_agility},
						{C.kfIntelligence, equip.base_intelligence}, {C.kfLevel, equip.level})
			me.UpdateStringField(C.ktEquipment, id, C.kfHoles, equip.holes, sizeof(equip.holes))
		end
	end

	local function ReduceProp(kind, amount)
		for id,prop in pairs(props_) do
			if prop.kind==kind and (prop.area==C.kAreaBag or prop.area==C.kAreaWarehouse or prop.area==C.kAreaGem) then
--				assert(not equipments_(id))
				if amount==0 then break end
				if amount< prop.amount then
					prop.amount = prop.amount-amount
					UpdatePropAmount(id, prop)
					break
				else
					amount = amount-prop.amount
					Remove(id)
				end
			end
		end
	end

	local function OverlapNewProps(amount, prop_overlapped,prop_overlapped_id)
		prop_overlapped.amount = prop_overlapped.amount+amount
		UpdatePropAmount(prop_overlapped_id, prop_overlapped)
	end

-------------------------
	local function Put2Sold(id,prop, equipment)
		trace_.alters[trace_.amount] = { id, prop.kind, C.kInvalidID, C.kAreaSold, prop.location, prop.amount, prop.bind, C.kAlterationAdd }
		trace_.amount = trace_.amount + 1
		if not g_sold_props[uid_] then g_sold_props[uid_]={} end
		g_sold_props[uid_][id] = {prop=prop, equipment=equipment, time=os.time()}
	end

	local function RemoveFromSold(id)
		local my_sold_props = g_sold_props[uid_]
		if my_sold_props then
			local sold = my_sold_props[id]
			if sold then
				trace_.alters[trace_.amount] = { id, sold.prop.kind, C.kInvalidID, C.kAreaSold, sold.prop.location, sold.prop.amount, sold.prop.bind, C.kAlterationRemove }
				trace_.amount = trace_.amount + 1
				my_sold_props[id] = nil
				return sold.prop,sold.equipment
			end
		end
	end

	local function GetSoldProp(id)
		local my_sold_props = g_sold_props[uid_]
		if my_sold_props then
			local sold = my_sold_props[id]
			if sold then
				return sold.prop,sold.equipment
			end
		end
	end

	local function AllSoldProps()
		local my_sold_props = g_sold_props[uid_]
		local ret = {}
		local max_id = 0
		if my_sold_props then
			local tmp=0
			for id,p in pairs(my_sold_props) do
				table.insert(ret,{id,p.prop.kind, tmp, p.prop.amount})
				tmp=tmp+1
				if id>max_id then max_id=id end
			end
		end
		return ret,max_id
	end

	local function LoadSoldEquipment()
		local my_sold_props = g_sold_props[uid_]
		if my_sold_props  then
			for id, p in pairs(my_sold_props) do equipments_[id]=p.equipment end
		end
	end

	local function SwapLocation(id, target_area, target_location, hero)
--		assert(target_area~=C.kAreaHero)
		if not IsLocationValid(target_area, target_location) then return false end
		local prop = props_[id]
		if not prop then return false end
		for other_id,other in pairs(props_) do
			if  id~=other_id and other.location==target_location and other.area==target_area then
				if target_area~=C.kAreaHero then
					other.area,other.location = prop.area,prop.location
					UpdatePropPosition(other_id, other)
					break
				elseif target_area==C.kAreaHero and equipments_[other_id].hero==hero then
					other.area,other.location = prop.area,prop.location
					UpdatePropPosition(other_id, other)
					break
				end
			end
		end
		prop.area,prop.location = target_area,target_location
		UpdatePropPosition(id, prop, hero)
		return true
	end

	local function Is3HolesActive(holes)
		if holes then
			local count = 0
			local beginning = 1
			local ending = 3
			if holes[0] then
				beginning = 0
				ending = 2
			end
			for i=beginning,ending,1 do
				if holes[i]>=2 then count = count+1 end
			end
			return count==3
		end
	end

	local function Count3HolesEquipment()
		local count = 0
		for id,equip in pairs(equipments_) do
			if props_[id] then
				if Is3HolesActive(equip.holes)  then count = count+1 end
			end
		end
		return count
	end

	local function IsTheQuanityEquipment(quanity)
		return quanity>=4
	end
	
	local function CountTheQuanityEquipments(quanity)
		local count = 0
		for id,_ in pairs(equipments_) do
			if props_[id] then
				local kind = props_[id].kind
				local cfg = prop_cfgs[kind]
				if cfg.quanity and cfg.quanity>=quanity then count = count+1 end
			end
		end
		return count
	end

	local function PutNewEquip2Location(area, kind, location, level, strength, agility, intelligence, holes, hero_id)
		local cfg = prop_cfgs[kind]
		prop = new('Prop', kind, area)
		prop.amount = 1
		prop.location=location
		max_id_ = max_id_+1
		props_[max_id_] = prop
		local equip = nil
		if cfg.type==C.kPropEquipment then
			local tmp_holes 
			if not holes then
				tmp_holes = cfg.holes
				equip = new('Equipment',level,strength,agility,intelligence,C.kInvalidID, cfg.holes)
			else
				tmp_holes = holes
				equip = new('Equipment',level,strength,agility,intelligence,C.kInvalidID, holes)
			end
			equipments_[max_id_] = equip
			if cfg.quanity and IsTheQuanityEquipment(cfg.quanity) then player.RecordAction(actions.kEquipmentsQuality, CountTheQuanityEquipments(cfg.quanity)) end
			if Is3HolesActive(tmp_holes) then player.RecordAction(actions.kOwn3HolesEquipment, Count3HolesEquipment()) end
		end
		InsertProps2Db(max_id_, prop, equip, hero_id)
		player.RecordAction(actions.kPropGot, 1, kind)
		return max_id_
	end
	
	
	local function PutNewProp2Location(area, kind, amount, location, hero_id)
		local cfg = prop_cfgs[kind]
		prop = new('Prop', kind, area)
		prop.amount = amount
		prop.location=location
		max_id_ = max_id_+1
		props_[max_id_] = prop
		local equip = nil
		if cfg.type==C.kPropEquipment then
			local strength,agility,intelligence = 0, 0, 0
			if cfg.random_propery_region and cfg.random_propery_proportion then
				strength,agility,intelligence = EquipmentPropertyGenerate(cfg.random_propery_region, cfg.random_propery_proportion)
			end
			equip = new('Equipment',0,strength,agility,intelligence,C.kInvalidID, cfg.holes)
			equipments_[max_id_] = equip
			if cfg.quanity and IsTheQuanityEquipment(cfg.quanity) then player.RecordAction(actions.kEquipmentsQuality, CountTheQuanityEquipments(cfg.quanity)) end
			if Is3HolesActive(cfg.holes) then player.RecordAction(actions.kOwn3HolesEquipment, Count3HolesEquipment()) end
		end
		InsertProps2Db(max_id_, prop, equip, hero_id)
		player.RecordAction(actions.kPropGot, amount, kind)
		return max_id_
	end

	local function GetMaxGridsOfArea(area)
		if area==C.kAreaBag then return prop_setting_.bag_grids_count end
		if area==C.kAreaWarehouse then return prop_setting_.warehouse_grids_count end
		if area==C.kAreaHero then return 8 end
		return 128
	end

	local function CountAreaOccupied(area)
		local count = 0
		for _,prop in pairs(props_) do
			if prop.area==area then count=count+1 end
		end
		return count
	end
	
	local function GetUnoccupiedGridsOfArea(area)
		return (GetMaxGridsOfArea(area)-CountAreaOccupied(area))
	end
	
	local function AddProps2Area(area, kind, amount)
		local cfg = prop_cfgs[kind]
		if cfg.overlap then
			for id, prop in pairs(props_) do
				if prop.area==area and prop.kind==kind and prop.amount+amount<=cfg.overlap_limit then
					OverlapNewProps(amount, prop, id)
					player.RecordAction(actions.kPropGot, amount, kind)
					return id
				end
			end
		end
		for location=0,GetMaxGridsOfArea(area)-1 do
			if not GetLocationProp(area, location) then
				return PutNewProp2Location(area, kind, amount, location)
			end
		end
	end

	local function AddProp2Location(area, kind, amount, location)
		if IsLocationValid(area, location) then
			local cfg = prop_cfgs[kind]
			local prop,id = GetLocationProp(area, location)
			if not prop then
				id = PutNewProp2Location(area, kind, amount, location)
			elseif cfg.overlap and  prop.kind==kind and prop.amount+amount<=cfg.overlap_limit then
				OverlapNewProps(amount, prop, id)
				player.RecordAction(actions.kPropGot, amount, kind)
			else
				id = nil
				--print('error: prop=' .. id .. ' is at location=' .. location)
			end
			return id
		end
	end
	
	local function GetUnoccupiedGrid( area )
		for location=0,GetMaxGridsOfArea(area)-1 do
			if not GetLocationProp(area, location) then
				return location
			end
		end
		return nil
	end
	
	local function AddNewProp2Area(area, kind, amount)
		local location = GetUnoccupiedGrid(area)
		if not location then return end
		return PutNewProp2Location(area, kind, amount, location)
	end
	
	local function MoveProp2Unoccupied( area, prop_id, location )
		local prop = props_[prop_id]
		local equip
		if prop then
			if not location then
				location = GetUnoccupiedGrid( area )
			end
			if location then
				if prop.area==C.kAreaHero then
					equip = equipments_[prop_id]
					if equip and equip.hero~=C.kInvalidID then
						equipments_[prop_id].hero = C.kInvalidID
						UpdateEquipmentAssociateHero(prop_id, C.kInvalidID)
					end
				end
				prop.area = area
				prop.location = location
				UpdatePropPosition( prop_id, prop )
				return true
			end
		end
		return false
	end

	local function OverlapProps(a,b,aid,bid)
		if a.area ~= b.area then 
			if a.area~=C.kAreaBag and a.area~=C.kAreaWarehouse then
				return 
			end
			if b.area~=C.kAreaBag and b.area~=C.kAreaWarehouse then
				return 
			end
		end
		local cfg = prop_cfgs[a.kind]
		if a.amount+b.amount <= cfg.overlap_limit then
			b.amount = b.amount+a.amount
			a.amount = 0
			Remove(aid)
		else
			a.amount = b.amount+a.amount-cfg.overlap_limit
			b.amount = cfg.overlap_limit
			UpdatePropAmount(aid, a)
		end
		UpdatePropAmount(bid, b)
	end

	local function SearchAndOverlapProps( area, kind, amount )	--暂时只在购回中使用,不会ActionRecord
		local cfg = prop_cfgs[kind]
		if cfg.overlap then
			for id, prop in pairs(props_) do
				if prop.area==area and prop.kind==kind and prop.amount+amount<=cfg.overlap_limit then
					OverlapNewProps(amount, prop, id)
					return id
				end
			end
		end
	end
	
	local function OverlapNewPropsNeedGrids(area, kind, amount)
		local need_grids = 0
		local cfg = prop_cfgs[kind]
		if cfg.overlap then
			local tmp_amount = amount
			for _, prop in pairs(props_) do
				if prop.area==area and prop.kind==kind and prop.amount<cfg.overlap_limit then
					tmp_amount = tmp_amount-(cfg.overlap_limit-prop.amount)
					if tmp_amount<=0 then
						break
					end
				end
			end
			if tmp_amount>0 then
				need_grids = math.ceil(tmp_amount/cfg.overlap_limit)
			end
		else
			need_grids = amount
		end
		return need_grids
	end
	
	local function OverlapNewProps2(area, kind, amount)
		local cfg = prop_cfgs[kind]
		local tmp_amount = amount
		local tmp_value = 0
		for id, prop in pairs(props_) do
			if prop.area==area and prop.kind==kind and prop.amount<cfg.overlap_limit then
				tmp_value = cfg.overlap_limit-prop.amount
				if tmp_amount<=tmp_value then
					tmp_value = tmp_amount
					tmp_amount = 0
				else
					tmp_amount = tmp_amount - tmp_value
				end
				OverlapNewProps(tmp_value, prop, id)
				player.RecordAction(actions.kPropGot, tmp_value, kind)
				if tmp_amount<=0 then
					break
				end
			end
		end
		if tmp_amount>0 then
			AddNewProp2Area(area, kind, tmp_amount)
		end
	end
	
	
	
	--[[
		props[kind]=amount
	]]
	local function CanAddNewProp2Area(area, props)
		local prop_cfg = nil
		local unoccupied_grids = GetUnoccupiedGridsOfArea(area)
		local need_grids = 0
		local add_props = {}
		for kind, amount in pairs(props) do
			if not add_props[kind] then add_props[kind]=0 end
			add_props[kind] = add_props[kind]+amount
		end
		for kind, amount in pairs(add_props) do
			prop_cfg = prop_cfgs[kind]
			if not prop_cfg then 
				print('prop kind='..kind..' is error')
				return false 
			end
			if prop_cfg.type==C.kPropGem then
				--
			elseif not prop_cfg.overlap then
				need_grids = need_grids+amount
			else
				need_grids = need_grids+OverlapNewPropsNeedGrids(area, kind, amount)
			end
			if need_grids>unoccupied_grids then return false end
		end
		return true
	end
	
	local function AddNewProp2Area2(area, props)
		local prop_cfg = nil
		local add_props = {}
		for kind, amount in pairs(props) do
			if not add_props[kind] then add_props[kind]=0 end
			add_props[kind] = add_props[kind]+amount
		end
		local tmp_area = area
		for kind, amount in pairs(add_props) do
			tmp_area = area
			prop_cfg = prop_cfgs[kind]
			if not prop_cfg then
				print('prop kind='..kind..' is error')
				return false 
			end
			if prop_cfg.type==C.kPropGem then
				tmp_area = C.kAreaGem
			end
			if not prop_cfg.overlap then
				for i=1, amount do
					AddNewProp2Area(tmp_area, kind, 1)
				end
			else
				OverlapNewProps2(tmp_area, kind, amount)
			end
		end
		return true
	end
	
	local function AddNewProps2Area4Kinds(area, props)
		if CanAddNewProp2Area(area, props) then
			return AddNewProp2Area2(area, props)
		else
			return false
		end
	end
	
	local function AddNewProps2Area4Kind(area, kind, amount)
		local props = {}
		props[kind] = amount
		return AddNewProps2Area4Kinds(area, props)
	end
	
	local function ModifyPropById(id, amount)
		local prop = props_[id]
		if prop then
			local tmp_amount = prop.amount + amount
			if tmp_amount<=0 then
				Remove(id)
			elseif amount<0 then
				prop.amount = tmp_amount
				UpdatePropAmount(id, prop)
			else
				local cfg = prop_cfgs[prop.kind]
				if not cfg then print('prop kind='..prop.kind..' is error') return false end
				local add_prop = {}
				add_prop[prop.kind] = amount
				if not CanAddNewProp2Area(prop.area, add_prop) then
					return false
				end
				player.RecordAction(actions.kPropGot, amount, prop.kind)
				if cfg.overlap then
					if prop.amount<cfg.overlap_limit then
						tmp_amount = tmp_amount-cfg.overlap_limit
						if tmp_amount>=0 then
							prop.amount = cfg.overlap_limit
							UpdatePropAmount(id, prop)
						else
							prop.amount = tmp_amount + cfg.overlap_limit
							UpdatePropAmount(id, prop)
						end
					end
					if tmp_amount>0 then
						add_prop[prop.kind] = tmp_amount
						AddNewProp2Area2(prop.area, add_prop)
					end
				else
					AddNewProp2Area2(prop.area, add_prop)
				end
			end
			return true
		else
			return false
		end
	end
	
	local function ReducePropById(id, amount)--amount>0
		assert(amount>0)
		return ModifyPropById(id, -amount)
	end
	
	local function AddNewEquip2Area(area, kind, location, level, strength, agility, intelligence, hero_id)
		local cfg = prop_cfgs[kind]
		if cfg and cfg.type==C.kPropEquipment then
			if not location then
				location = GetUnoccupiedGrid(area)
				if not location then
					return nil
				end
			end
			if not level then
				level = 0
			end
			if not strength or not agility or not intelligence then
				strength, agility, intelligence = 0, 0 , 0
				if cfg.random_propery_region and cfg.random_propery_proportion then
					strength,agility,intelligence = EquipmentPropertyGenerate(cfg.random_propery_region, cfg.random_propery_proportion)
				end
			end
			prop = new('Prop', kind, area)
			prop.amount = 1
			prop.location=location
			max_id_ = max_id_+1
			props_[max_id_] = prop
			local equip = nil
			equip = new('Equipment',level,strength,agility,intelligence,C.kInvalidID, cfg.holes)
			equipments_[max_id_] = equip
			if cfg.quanity and IsTheQuanityEquipment(cfg.quanity) then player.RecordAction(actions.kEquipmentsQuality, CountTheQuanityEquipments(cfg.quanity)) end
			if Is3HolesActive(cfg.holes) then player.RecordAction(actions.kOwn3HolesEquipment, Count3HolesEquipment()) end
			InsertProps2Db(max_id_, prop, equip, hero_id)
			if hero_id then
				UpdateEquipmentAssociateHero(max_id_, hero_id)
			end
			player.RecordAction(actions.kPropGot, 1, kind)
			return max_id_
		else
			print('error equip kind='..kind..' in prop')
			return nil
		end
	end

-- from gate
	processor_[C.kGetMyProps] = function(msg)
		local area = cast("const GetMyProps&", msg).area
		local result = new('MyProps',0)
		if area==C.kAreaSold then
			local all = AllSoldProps()
			for i,prop4client in ipairs(all) do
				result.props[result.count] = prop4client
				result.count = result.count+1
			end
		else
			for id,prop in pairs(props_) do
				if prop.area==area then
					result.props[result.count] = {id, prop.kind, prop.location, prop.amount, prop.bind}
					result.count = result.count+1
				end
			end
			if area==C.kAreaBag then result.grids_count=prop_setting_.bag_grids_count end
			if area==C.kAreaWarehouse then result.grids_count=prop_setting_.warehouse_grids_count end
		end
		local bytes = 4 + sizeof(result.props[0])*result.count
		return result,bytes
	end

	processor_[C.kGetMyEquipment] = function(msg)
		local id = cast('const GetMyEquipment&', msg).id
		local result = new('MyEquipment')
		local equip = equipments_[id]
		if equip then
			result.equipment = {equip.level, equip.base_strength, equip.base_agility, equip.base_intelligence, equip.holes, 0, equip.gems}
		end
		return result
	end

	processor_[C.kMoveProp] = function(msg)
		PropsTraceBegin()
		local move = cast('const MoveProp&', msg)
		local result = new('MovePropResult', C.eInvalidValue)
		local prop = props_[move.id]
		if prop and IsMovingLegal(prop.area) and IsMovingLegal(move.new_area) then
			if prop.area~=C.kAreaHero and move.new_area~=C.kAreaHero and SwapLocation(move.id, move.new_area, move.new_location) then
				result.result = C.eSucceeded
			end
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kOverlapProp] = function(msg)
		PropsTraceBegin()
		local overlap = cast('const OverlapProp&', msg)
		local result = new('OverlapPropResult', C.eInvalidValue)
		local a,b = props_[overlap.a],props_[overlap.b]
		if not a  or  not b  or  a.kind~=b.kind then return result end
		if IsMovingLegal(a.area) and IsMovingLegal(b.area) then
			OverlapProps(a,b,overlap.a,overlap.b)
			result.a_amount = a.amount
			result.b_amount = b.amount
			result.result = C.eSucceeded
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kSellProp] = function(msg)
		PropsTraceBegin()
		local id = cast('const SellProp&', msg).id
		local result = new('SellPropResult', C.eInvalidValue)
		local prop = props_[id]
		if not prop or prop.area~=C.kAreaBag then return result end
		local cfg = prop_cfgs[prop.kind]
		if cfg and cfg.for_sale then
			me.ModifySilver(cfg.sale_price*prop.amount)
			Put2Sold(id,prop, equipments_[id])
			Remove(id)
			result.price = cfg.sale_price
			result.result = C.eSucceeded
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kDropProp] = function(msg)
		PropsTraceBegin()
		local id = cast('const DropProp&', msg).id
		local result = new('DropPropResult', C.eInvalidValue)
		local prop = props_[id]
		if prop and prop_cfgs[prop.kind].can_discard then
			if prop.area==C.kAreaBag or prop.area==C.kAreaWarehouse or prop.area==C.kAreaGem then
				result.result = C.eSucceeded
				Remove(id)
			end
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kRearrangeProp] = function(msg)

		local function Find2PropsCanOverlapped(props, area)
			for id,prop in pairs(props) do
				if prop.area==area then
					local cfg = prop_cfgs[prop.kind]
					if cfg.overlap and cfg.overlap_limit>prop.amount then
						for id2,prop2 in pairs(props) do
							if prop2.area==area and prop2.kind==prop.kind and id2~=id and cfg.overlap_limit>prop2.amount then
--								print('Find 2 prop need overlap,id='..id..' '..id2)
								return prop,prop2,id,id2
							end
						end
					end
				end
			end
		end

		local function MergeAll(props, area)
			while true do
				local prop,prop2,id,id2 = Find2PropsCanOverlapped(props, area)
				if prop then
					OverlapProps(prop,prop2,id,id2)
				else
					break
				end
			end
		end


		PropsTraceBegin()
		local area = cast('const RearrangeProp&', msg).area
		local result = new('RearrangePropResult', C.eInvalidOperation)
		if area==C.kAreaBag or area==C.kAreaWarehouse then
			MergeAll(props_, area)
			local tmp = {}
			for id,prop in pairs(props_) do
				if prop.area==area then table.insert(tmp, {id,prop}) end
			end
			table.sort(tmp, function(a,b) return CompareProp(a[2],b[2]) end )
			for i,id_prop in ipairs(tmp) do
				local id,prop = id_prop[1],id_prop[2]
				if prop.location ~= i-1 then
					prop.location=i-1
					UpdatePropPosition(id, prop)
				end
			end
			result.result = C.eSucceeded
		end
		PropsTraceEnd()
		return result
	end
	
	processor_[C.kBuyProp] = function(msg)
		PropsTraceBegin()
		local buy = cast("const BuyProp&",msg)
		local result = new('BuyPropResult', C.eInvalidValue)
		local shop_cfg = shop_cfgs[buy.shop]
		local cfg = shop_cfg and shop_cfg[buy.prop_index]
		if not cfg then
		elseif player.GetLevel()<cfg.level then
			result.result = C.eLowLevel
		elseif cfg.coin_type==1 and not me.IsSilverEnough(cfg.price) then
			result.result=C.eLackResource
		elseif cfg.coin_type==2 and not me.IsPropEnough(cfg.coin_kind, cfg.price) then
			result.result=C.eLackResource
		elseif cfg.coin_type==1 or cfg.coin_type==2 then
			local id = 0
			if Kind2Type(cfg.prop_kind)==C.kPropGem then
				id = AddProps2Area( C.kAreaGem, cfg.prop_kind, cfg.amount )
			else
				id = AddProp2Location(C.kAreaBag, cfg.prop_kind, cfg.amount, buy.location)
				if not id then
					id = AddProps2Area( C.kAreaBag, cfg.prop_kind, cfg.amount )
				end
			end
			if id then
				result.result, result.id = C.eSucceeded, id
				if cfg.coin_type==1 then 
					me.ModifySilver(-cfg.price) 
				elseif cfg.coin_type==2 then
					ReduceProp(cfg.coin_kind, cfg.price)
				else
					me.ModifyProp(cfg.coin_kind, -cfg.price)
				end
			else
				result.result = C.eBagFull
			end
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kRepurchase] = function(msg) 
		PropsTraceBegin()
		local repurchase = cast('const Repurchase&', msg)
		local id,location = repurchase.id,repurchase.location
		local result = new('RepurchaseResult', C.eInvalidValue)
		local cfg
		local prop,equip = GetSoldProp(id)
		if prop then
			local price = prop_cfgs[prop.kind].sale_price * prop.amount
			if not IsLocationValid(C.kAreaBag, location) then
				result.result = C.eInvalidValue
			elseif not me.IsSilverEnough(price) then
				result.result = C.eLackResource
			else
				local l_prop,l_id = GetLocationProp(C.kAreaBag, location)
				if l_id then--被占用
					cfg = prop_cfgs[prop.kind]
					if cfg.overlap then--可堆叠
						if prop.kind==l_prop.kind and prop.amount+l_prop.amount<=cfg.overlap_limit then
							result.result = C.eSucceeded
							OverlapNewProps( prop.amount, l_prop, l_id )
						elseif SearchAndOverlapProps( C.kAreaBag, prop.kind, prop.amount ) then
								result.result = C.eSucceeded
						else
							if obj.IsBagFull() then--包包满了
								result.result = C.eBagFull
							else
								result.result = C.eSucceeded
								location = GetUnoccupiedGrid( C.kAreaBag )
								prop.area,prop.location = C.kAreaBag,location
								InsertProps2Db(id, prop, equip)
								props_[id] = prop
							end
						end
					else--不可堆叠,寻找一个空位
						if obj.IsBagFull() then--包包满了
							result.result = C.eBagFull
						else
							result.result = C.eSucceeded
							location = GetUnoccupiedGrid( C.kAreaBag )
							prop.area,prop.location = C.kAreaBag,location
							InsertProps2Db(id, prop, equip)
							props_[id] = prop
						end
					end
				else--位置未被占用
					result.result = C.eSucceeded
					prop.area,prop.location = C.kAreaBag,location
					InsertProps2Db(id, prop, equip)
					props_[id] = prop
				end
				if result.result == C.eSucceeded then
					RemoveFromSold(id)
					me.ModifySilver(-price, true)
				end
			end
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kUseProp] = function(msg)
		PropsTraceBegin()
		local use_prop = cast("const UseProp&", msg)
		local id = use_prop.id
		local amount = use_prop.amount
		local result = new('UsePropResult', C.eInvalidOperation)
		local prop = props_[id]
		if prop and prop.area==C.kAreaBag and amount>=1 then
			assert(prop.amount>0)
			if prop.amount<amount then
				result.result = C.eInvalidValue
				return result
			end
			local cfg = prop_cfgs[prop.kind]
			if cfg.required_level and me.GetLevel()<cfg.required_level then
				result.result = C.eLowLevel
			elseif cfg.type==C.kPropResource then  --资源类
				for i=1, amount do
					me.AddReward(cfg.resource_reward)
				end
				if prop.amount==amount then Remove(id) else
					prop.amount = prop.amount-amount
					UpdatePropAmount( id, prop )
				end
				result.result = C.eSucceeded
			elseif cfg.type==C.kPropFormula then --配方类
				player.InsertRow(C.ktFormula, {C.kfID, cfg.sub_type})
				Remove(id)
				result.result = C.eSucceeded
			elseif cfg.type==C.kPropContainer then --宝箱
				if cfg.box_rewards then
					local pro = 0
					local give_props = {}
					local occupy_grids = 0
					for i=1, amount do
						if cfg.sub_type==20 then
							for _, give_prop in pairs(cfg.box_rewards) do
								pro = math.random()
								if pro<=give_prop.probability then
									if not give_props[give_prop.kind] then give_props[give_prop.kind]={amount=0} end
									give_props[give_prop.kind].amount = give_props[give_prop.kind].amount + give_prop.amount
								end
							end
						elseif cfg.sub_type==21 then
							local all = 0
							for _, give_prop in ipairs(cfg.box_rewards) do
								all = all + give_prop.probability
							end
							local probability = math.random()
							for _, give_prop in ipairs(cfg.box_rewards) do
								pro = give_prop.probability/all
								if probability<=pro then
									if not give_props[give_prop.kind] then give_props[give_prop.kind]={amount=0} end
									give_props[give_prop.kind].amount = give_props[give_prop.kind].amount + give_prop.amount
									break
								else
									probability = probability - pro
								end
							end
						else
							print('use prop, kind='..prop.kind..',error sub_type')
						end
					end
					local t_cfg = nil
					for kind, give_prop in pairs(give_props) do
						t_cfg = prop_cfgs[kind]
						if not t_cfg then return end
						if Kind2Type(kind)~=C.kPropGem then
							if t_cfg.overlap then
								occupy_grids = occupy_grids + math.ceil(give_prop.amount/t_cfg.overlap_limit)
							else
								occupy_grids = occupy_grids + give_prop.amount
							end
						end
					end
					
					local un_grids = obj.BagUnoccupied()
					if occupy_grids<=un_grids or (prop.amount==amount and occupy_grids<=(un_grids+1) )then
						if prop.amount==amount then Remove(id) else
							prop.amount = prop.amount-amount
							UpdatePropAmount( id, prop )
						end
						local push_props = new('UseProp4Container')
						push_props.amount = 0
						for kind, give_prop in pairs(give_props) do
							push_props.props[push_props.amount].kind = kind
							push_props.props[push_props.amount].amount = give_prop.amount
							push_props.amount = push_props.amount+1
							--
							--
							local area = C.kAreaBag
							if Kind2Type(kind)==C.kPropGem then
								area=C.kAreaGem
								AddProps2Area(area, kind, give_prop.amount)
							else
								t_cfg = prop_cfgs[kind]
								if t_cfg.overlap then
									local add_amount = give_prop.amount
									repeat
										if add_amount>=t_cfg.overlap_limit then
											AddNewProp2Area(area, kind, t_cfg.overlap_limit)
											add_amount = add_amount - t_cfg.overlap_limit
										else
											AddProps2Area(area, kind, add_amount)
											add_amount = 0
										end
									until add_amount<=0
								else
									for i=1, give_prop.amount do
										AddProps2Area(area, kind, 1)
									end
								end
							end
						end
						player.Send2Gate(push_props, 4+push_props.amount*sizeof(push_props.props[0]))
						result.result = C.eSucceeded
					else
						result.result = C.eBagLeackSpace
					end
				else
					print('use prop id='..id..',box_rewards=nil')
				end
			else
				print('use prop id='..id..',type='..cfg.type)
			end
		end
		if result.result==C.eSucceeded then player.RecordAction(actions.kPropUsed, amount, prop.kind) end
		PropsTraceEnd()
		return result
	end

	processor_[C.kRenameEquipment] = function(msg)
	end

	local function CalcUnlockCost(unlocked, count2add)
		if unlocked<0 then return 0 end
		local kStartingPrice,kAdditonPrice = config.prop.unlock_block.kStartingPrice, config.prop.unlock_block.kAdditonPrice
		local price = ( (kStartingPrice+unlocked*kAdditonPrice)+(kStartingPrice+(unlocked+count2add-1)*kAdditonPrice) ) * count2add / 2
		return price
	end

	processor_[C.kUnlockPropGrid] = function(msg)
		local unlock = cast('const UnlockPropGrid&', msg)
		local result = new('UnlockPropGridResult', C.eInvalidValue)
		if unlock.area==C.kAreaBag and unlock.count>0 and unlock.count <= kMaxBagGrids-prop_setting_.bag_grids_count then
			local gold = CalcUnlockCost(prop_setting_.bag_grids_count-kMinBagGrids, unlock.count)
			if not player.IsGoldEnough(gold)	then result.result=C.eLackResource return result end
			prop_setting_.bag_grids_count = prop_setting_.bag_grids_count + unlock.count
			me.UpdateField(C.ktPropSetting, C.kInvalidID, {C.kfBagGridsCount, prop_setting_.bag_grids_count} )
			me.ConsumeGold(gold, gold_consume_flag.prop_unlock_bag_grid)
			result.result = C.eSucceeded
			player.RecordAction(actions.kBagUnlock, unlock.count)
		elseif unlock.area==C.kAreaWarehouse and unlock.count>0 and unlock.count <= kMaxWarehouseGrids-prop_setting_.warehouse_grids_count then
			local gold = CalcUnlockCost(prop_setting_.warehouse_grids_count-kMinWarehouseGrids, unlock.count)
			if not player.IsGoldEnough(gold)	then result.result=C.eLackResource return result end
			prop_setting_.warehouse_grids_count = prop_setting_.warehouse_grids_count + unlock.count
			me.UpdateField(C.ktPropSetting, C.kInvalidID, {C.kfWarehouseGridsCount, prop_setting_.warehouse_grids_count} )
			me.ConsumeGold(gold, gold_consume_flag.prop_unlock_warehouse_grid)
			result.result = C.eSucceeded
		end
		return result
	end

	processor_[C.kStrengthen] = function(msg)
		local id = cast('const Strengthen&', msg).id
		local result = new('StrengthenResult', C.eInvalidValue)
		if not active_Strengthen then
			result.result = C.eFunctionDisable
			return result
		end
		local prop,equip = props_[id],equipments_[id]
		if prop and equip then
			local cfg = prop_cfgs[prop.kind]
			local cost = equip_upgrade_costs[equip.level+1]
			assert(cfg.type==C.kPropEquipment and cost)
			local min_weapon_type = 10
			local silver_needed = (cfg.sub_type<min_weapon_type) and cost.non_weapon or cost.weapon
			if me.GetSmithyLevel() and (me.GetSmithyLevel()-1)<=equip.level then
				result.result = C.eLowLevel
			elseif not me.IsSilverEnough(silver_needed) then
				result.result=C.eLackResource
			else
				me.ModifySilver(-silver_needed)
				equip.level = equip.level+1
				me.UpdateField(C.ktEquipment, id, {C.kfLevel, equip.level})
				result.result = C.eSucceeded
				--
				if math.fmod(equip.level,10)==0 then
					local push = new('StrengthenProp')
					push.uid = uid_
					copy(push.name,name_,sizeof(name_))
					push.level = equip.level
					GlobalSend2Gate(-1, push)
				end
				
				fight_power.CheckFightPowerChange(player.GetUID())
			end
		end
		return result
	end
	--[[rdf]]
	processor_[C.kActiveHole] = function(msg)
		local act = cast('const ActiveHole&', msg)
		local result = new('ActiveHoleResult', C.eInvalidOperation)
		if not active_Inlay then
			result.result = C.eFunctionDisable
			return result
		end
		local prop,equip = props_[act.id],equipments_[act.id]
		if prop and equip and equip.holes[act.hole] and equip.holes[act.hole]==C.kHoleDisable then
			local gold_needed = config.prop.kActiveHoleCost
			if not me.IsGoldEnough(gold_needed) then
				result.result = C.eLackResource
			else
				equip.holes[act.hole] = C.kHoleEnable
				me.UpdateStringField(C.ktEquipment, act.id, C.kfHoles, equip.holes, sizeof(equip.holes))
				me.ConsumeGold(gold_needed, gold_consume_flag.prop_active_hole)
				result.result = C.eSucceeded
				if Is3HolesActive(equip.holes) then player.RecordAction(actions.kOwn3HolesEquipment, Count3HolesEquipment()) end
			end
		end
		return result
	end

	processor_[C.kCompoundGem] = function(msg)
		PropsTraceBegin()
		local result = new('CompoundGemResult', C.eInvalidValue)
		local com = cast('const CompoundGem&', msg)
		if not active_CompoundGem then
			result.result = C.eFunctionDisable
			return result
		end
		if com.b_direct==1 then
			--vip等级判定
			if player.GetVIPLevel()<config.prop.kGemDirectNeedVipLevel then
				result.result = C.eLowVipLevel
				return result
			end
		end
		local formula_kind = com.formula_kind
		local formula = gem_formulas[formula_kind]
		if formula and (vector.find(formulas_, formula_kind) or (formula.level and formula.level<=player.GetSmithyLevel())) then
			local cost_gold  = 0
			local cost_goods = {}
			for i,material in ipairs(formula.materials) do
				cost_goods[i] = {}
				cost_goods[i].kind = material.kind
				if com.b_direct==0 then
					if not player.IsPropEnough(material.kind, material.amount) then
						result.result = C.eLackResource
						break
					else
						cost_goods[i].amount = material.amount
					end
				else
					local tmp_amount = me.HavePropAmount( material.kind )
					if material.amount>tmp_amount then
						if material.cost<0 then
							cost_gold = 0
							result.result=C.eLackResource
							break
						else
							cost_goods[i].amount = tmp_amount
							cost_gold = cost_gold + material.cost * (material.amount - tmp_amount)
						end
					else
						cost_goods[i].amount = material.amount
					end
				end
			end
			if cost_gold~=0 then
				if not me.IsGoldEnough(cost_gold) then
					result.result = C.eLackResource
				end
			end
			if result.result ~= C.eLackResource then
				local r = math.random()
				if r<=formula.gems[1].probability then
					result.gem = formula.gems[1].kind
					result.amount = formula.gems[1].amount
				else --获得了变异的宝石
					result.gem = formula.gems[2].kind
					result.amount = formula.gems[2].amount
					player.RecordAction(actions.kGotVariationGem, result.amount)
				end
				if cost_gold~=0 then
					player.ConsumeGold( cost_gold, gold_consume_flag.prop_compound_gem )
				end
				for _,material in ipairs( cost_goods ) do
					ReduceProp(material.kind, material.amount)
				end
				AddProps2Area(C.kAreaGem, result.gem, result.amount)
				result.result = C.eSucceeded
			end
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kGetMyFormulas] = function()
		local result = new('MyFormulas')
		for kind, formula in pairs( gem_formulas ) do
			if formula.level and formula.level<=player.GetSmithyLevel() then
				if not vector.find(formulas_, kind) then
					table.insert( formulas_, kind )
				end
			end
		end
		result.count = table.getn(formulas_)
		result.kinds = formulas_
		return result, 2+result.count*2
	end

	local function CalcAmountOfGemsInEquip(holes)
		local gems = 0
		for i=0, 2 do
			if holes[i]==C.kHoleInlayed then
				gems = gems + 1
			end
		end
		return gems
	end
	
	processor_[C.kInlay] = function(msg)
		PropsTraceBegin()
		local inlay = cast('const Inlay&', msg)
		local result = new('InlayResult', C.eInvalidOperation)
		if not active_Inlay then
			result.result = C.eFunctionDisable
			return result
		end
		local equip = equipments_[inlay.equipment]
		local gem = nil
		local gem_kind = nil
		if equip and equip.holes[inlay.hole] then
			if inlay.b_inlay==1 then
				gem = props_[inlay.inlay_gem]
				if gem then
					local gem_cfg = prop_cfgs[gem.kind]
					if gem_cfg and gem_cfg.type==C.kPropGem and gem_cfg.sub_type and gem_cfg.sub_type==22 then
						if equip.holes[inlay.hole]==C.kHoleInlayed then
							gem_kind = equip.gems[inlay.hole]
							if gem_kind~=gem.kind then
								equip.gems[inlay.hole] = gem.kind
								player.UpdateStringField(C.ktEquipment, inlay.equipment, C.kfGems, equip.gems, sizeof(equip.gems))
								ReducePropById(inlay.inlay_gem, 1)
								
								if inlay.dis_gem==0 then
									AddProps2Area(C.kAreaGem, gem_kind, 1)
								else
									local dis_gem = props_[inlay.dis_gem]
									if not dis_gem or dis_gem.kind~=gem_kind or not ModifyPropById(inlay.dis_gem, 1) then
										AddProps2Area(C.kAreaGem, gem_kind, 1)
									end
								end
								fight_power.CheckFightPowerChange(uid_)
							end
							result.result = C.eSucceeded
						elseif equip.holes[inlay.hole]==C.kHoleEnable then
							equip.gems[inlay.hole] = gem.kind
							equip.holes[inlay.hole] = C.kHoleInlayed
							player.UpdateStringField(C.ktEquipment, inlay.equipment, C.kfGems, equip.gems, sizeof(equip.gems))
							player.UpdateStringField(C.ktEquipment, inlay.equipment, C.kfHoles, equip.holes, sizeof(equip.holes))
							ReducePropById(inlay.inlay_gem, 1)
							result.result = C.eSucceeded
							fight_power.CheckFightPowerChange(uid_)
						end
					end
				end
			else
				if equip.holes[inlay.hole]==C.kHoleInlayed then
					gem_kind = equip.gems[inlay.hole]
					equip.gems[inlay.hole] = 0
					equip.holes[inlay.hole] = C.kHoleEnable
					player.UpdateStringField(C.ktEquipment, inlay.equipment, C.kfGems, equip.gems, sizeof(equip.gems))
					player.UpdateStringField(C.ktEquipment, inlay.equipment, C.kfHoles, equip.holes, sizeof(equip.holes))
					if inlay.dis_gem==0 then
						AddProps2Area(C.kAreaGem, gem_kind, 1)
					else
						local dis_gem = props_[inlay.dis_gem]
						if not dis_gem or dis_gem.kind~=gem_kind or not ModifyPropById(inlay.dis_gem, 1) then
							AddProps2Area(C.kAreaGem, gem_kind, 1)
						end
					end
					result.result = C.eSucceeded
					fight_power.CheckFightPowerChange(uid_)
				end
			end
			if result.result==C.eSucceeded then
				player.RecordAction(actions.kEquipmentAmountOfGems, CalcAmountOfGemsInEquip(equip.holes)) 
			end
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kEquipmentPropertyMigrate] = function(msg)
		PropsTraceBegin()
		local mig = cast('const EquipmentPropertyMigrate&', msg)
		local result = new('EquipmentPropertyMigrateResult', C.eInvalidOperation)
		if not active_Migrate then
			result.result = C.eFunctionDisable
			return result
		end
		if mig.source~=mig.dest then
			local src,dest = equipments_[mig.source], equipments_[mig.dest]
			local prop_src,prop_dest = props_[mig.source], props_[mig.dest]
			if src and dest and prop_src and prop_dest and IsMovingLegal(prop_src.area) and IsMovingLegal(prop_dest.area) then
				dest.base_strength, dest.base_agility, dest.base_intelligence = src.base_strength,src.base_agility,src.base_intelligence
				player.UpdateField(C.ktEquipment, mig.dest, {C.kfStrength,dest.base_strength}, {C.kfAgility,dest.base_agility}, {C.kfIntelligence,dest.base_intelligence})
				Remove(mig.source, src.hero)
				src.hero = -1
				result.result = C.eSucceeded
				fight_power.CheckFightPowerChange(uid_)
			end
		end
		PropsTraceEnd()
		return result
	end

	processor_[C.kGetMyHeroEquipment] = function(msg)
		local hero_id = cast("const GetMyHeroEquipment&", msg).hero_id
		local result = new('MyHeroEquipment',0)
		for id,equip in pairs(equipments_) do
			local prop = props_[id]
			if equip.hero==hero_id and prop and prop.area==C.kAreaHero then
				result.equipments[result.count] = {id, prop.kind, prop.location, prop.amount, prop.bind}
				result.count = result.count+1
				if result.count>=8 then break end
			end
		end
		return result
	end

	processor_[C.kEquipCompound] = function(msg)
		PropsTraceBegin()
		local com = cast('const EquipCompound&', msg)
		local ret = new('EquipCompoundResult',C.eInvalidOperation)
		if not active_Strengthen then
			ret.result = C.eFunctionDisable
			return ret
		end
		if com.b_direct==1 then
			--vip等级判定
			if player.GetVIPLevel()<config.prop.kEquipDirectNeedVipLevel then
				ret.result = C.eLowVipLevel
				return ret
			end
		end
		local prop  = props_[com.equip_id]
		if prop then
			local formula = equip_formulas[prop.kind]
			local equip = equipments_[com.equip_id]
			if formula and equip then
				local target_cfg = prop_cfgs[formula.target_equip]
				if target_cfg and target_cfg.type==C.kPropEquipment then

				local consume_goods = {}
				local cost_gold = 0
				local holes = {0,0,0}
				local gems  = {}
				local equip_level = equip.level
				local equip_hero = -1
				--
				if com.b_reserved==1 then
					for i=1,sizeof(equip.holes),1 do
						if equip.holes[i-1]==C.kHoleEnable then
							holes[i] = C.kHoleEnable
							cost_gold = cost_gold + config.prop.kReservedOneHoleCostGold
						elseif equip.holes[i-1]==C.kHoleInlayed then
							holes[i] = C.kHoleInlayed
							gems[i] = equip.gems[i-1]
							cost_gold = cost_gold + config.prop.kReservedOneHoleCostGold
						else
							holes[i] = equip.holes[i-1]
						end
					end
				end
				if com.b_direct==0 then
					if com.b_reserved==1 and not me.IsGoldEnough( cost_gold ) then
						ret.result = C.eLackResource
					else
						for i, material in ipairs( formula.materials ) do
							if not me.IsPropEnough( material.kind, material.amount ) then
								ret.result = C.eLackResource
								break
							else
								consume_goods[i] = {}
								consume_goods[i].kind = material.kind
								consume_goods[i].amount = material.amount
							end
						end
					end
				else
					local tmp_amount = nil
					for i, material in ipairs( formula.materials ) do
						consume_goods[i] = {}
						consume_goods[i].kind = material.kind
						tmp_amount = me.HavePropAmount( material.kind )
						if tmp_amount<material.amount then
							if material.cost<0 then
								ret.result=C.eLackResource
								break
							else
								consume_goods[i].amount = material.amount - tmp_amount
								cost_gold = cost_gold + consume_goods[i].amount*material.cost
							end
						else
							consume_goods[i].amount = material.amount
						end
					end
					if ret.result==C.eLackResource or not me.IsGoldEnough( cost_gold ) then
						ret.result = C.eLackResource
					end
				end
				if ret.result~=C.eLackResource then
					local tmp_area = 0
					if prop.area==C.kAreaHero then
						equip_hero = equip.hero
						local hero_level = player.GetHeroLevel( equip_hero )
						local prop_level = target_cfg.required_level
						if hero_level and prop_level and hero_level>=prop_level then
							tmp_area = C.kAreaHero
						else
							if obj.IsBagFull() then
								ret.result = C.eBagFull
							else
								tmp_area = C.kAreaBag
							end
						end
					else
						tmp_area = C.kAreaBag
					end
					if ret.result~=C.eBagFull then
						for _, material in ipairs( consume_goods ) do
							ReduceProp( material.kind, material.amount )
						end

						
						Remove( com.equip_id, equip.hero)
						equip.hero = -1

						local new_equip_lv = 0
						if equip_level-5>0 then
							new_equip_lv = equip_level-5
						end
						
						if com.b_reserved~=1 then
							holes = nil
						end
						
						local new_equip_id = nil
						if tmp_area==C.kAreaBag then
							local location = GetUnoccupiedGrid( C.kAreaBag )
							new_equip_id = PutNewEquip2Location(C.kAreaBag, formula.target_equip, location, new_equip_lv, equip.base_strength,equip.base_agility,equip.base_intelligence, holes)
						else
							new_equip_id = PutNewEquip2Location(C.kAreaHero, formula.target_equip, prop.location, new_equip_lv, equip.base_strength,equip.base_agility,equip.base_intelligence, holes, equip_hero)
						end
						local new_equip = equipments_[max_id_]
						if tmp_area==C.kAreaHero then
							new_equip.hero = equip_hero
							UpdateEquipmentAssociateHero(max_id_, equip_hero)
						end
						if cost_gold~=0 then
							player.ConsumeGold( cost_gold, gold_consume_flag.prop_compound_equip )
							if com.b_reserved==1 then
								local b_inlayed = 0
								for i,v in pairs( holes ) do
									if v == C.kHoleInlayed then
										new_equip.gems[i-1] = gems[i]
										b_inlayed = 1
									end
								end
								if b_inlayed==1 then
									player.UpdateStringField(C.ktEquipment, max_id_, C.kfGems, new_equip.gems, sizeof(new_equip.gems))
								end
							end
						end
						ret.equip_id = max_id_
						ret.result = C.eSucceeded
						
						fight_power.CheckFightPowerChange(player.GetUID())
					end
				end
				end
			end
		end
		PropsTraceEnd()
		return ret
	end

	--提取附件
	processor_[C.kExtractAttachment] = function(msg, flag)
		PropsTraceBegin()
		local ret = new("ExtractAttachmentResult",C.eSucceeded)
		local head = new("MqHead", uid_, C.kExtractAttachmentResult, flag)
		local attachs = nil
		local attach  = nil
		local extract = cast("const ExtractAttachment&",msg)
		local db_res = nil
		db_res = db.GetMailAttachment( uid_, extract.mail_id )
		if not db_res then
			ret.result = C.eAttachmentDontExist
		else
			attachs = cast("const MailAttachments&", db_res)
			if attachs.amount>8 and attachs.amount<1 then
				ret.result = C.eExtractAttachmentFailed
				C.Send2Interact(head, ret, sizeof(ret))
				return
			end
			if extract.attach_id>attachs.amount then
				ret.result = C.eInvalidValue
				C.Send2Interact(head, ret, sizeof(ret))
				return
			end
			local ext = {}
			local prop
			local need_grid = 0
			if extract.attach_id~=-1 then
				attach = attachs.attach[extract.attach_id-1]
				if attach.extracted==1 then
					ret.result = C.eAttachmentHadExtracted
					C.Send2Interact(head, ret, sizeof(ret))
					return
				else
					table.insert( ext, attach )
					if attach.prop_id~=0 then
						prop = props_[attach.prop_id]
						if prop then
							need_grid = need_grid + 1
						end
					elseif attach.type==C.kPropRsc then
						need_grid = need_grid + 1
					end
				end
			else
				for i=1,attachs.amount do
					attach = attachs.attach[i-1]
					if attach.extracted==0 then
						table.insert( ext, attach )
						if attach.prop_id~=0 then
							prop = props_[attach.prop_id]
							if prop then
								need_grid = need_grid + 1
							end
						elseif attach.type==C.kPropRsc then
							need_grid = need_grid + 1
						end
					end
				end
			end
			if need_grid>obj.BagUnoccupied() then
				ret.result = C.eBagLeackSpace
			else
				for _, v in pairs( ext ) do
					v.extracted = 1
					if v.prop_id~=0 then
						prop = props_[v.prop_id]
						local cfg = prop_cfgs[prop.kind]
						if prop and cfg then
							MoveProp2Unoccupied( C.kAreaBag, v.prop_id )
							player.RecordAction(actions.kPropGot, prop.amount, prop.kind)
							if cfg.type==C.kPropEquipment then
								if cfg.quanity and IsTheQuanityEquipment(cfg.quanity) then player.RecordAction(actions.kEquipmentsQuality, CountTheQuanityEquipments(cfg.quanity)) end
							end
						end
					elseif v.type==C.kPropRsc then
						AddProps2Area( C.kAreaBag, v.kind, v.amount )
						player.RecordAction(actions.kPropGot, v.amount, v.kind)
					--elseif v.type==C.kGoldRsc then
						--player.ModifyGold( v.amount )
					--elseif v.type==C.kSilverRsc then
						--player.ModifySilver( v.amount )
					else
						print("don't support resource type: " .. v.type)
					end
				end
				local b_has_attach = 0
				if extract.attach_id==-1 then
					b_has_attach = 0
				else
					for i=1,attachs.amount do
						if attachs.attach[i-1].extracted==0 then
							b_has_attach = 1
							break
						end
					end
				end
				--
				--更新数据库
				db.UpdateMailAttachments(uid_, extract.mail_id, b_has_attach, attachs)
			end
		end
		C.Send2Interact(head, ret, sizeof(ret))
		PropsTraceEnd()
	end

-- from db
	db_processor_[C.kPropFromDb] = function(msg)
		local prop = new('Prop')
		local prop_from_db = cast('const PropFromDb&', msg)
		copy(prop, prop_from_db.prop, sizeof(prop))
		props_[prop_from_db.id] = prop
		if prop_from_db.id>max_id_ then max_id_=prop_from_db.id end
	end

	db_processor_[C.kEquipmentFromDb] = function(msg)
		local eqdb = cast('const EquipmentFromDb&', msg)
		local equip = new("Equipment")
		copy(equip, eqdb.equip, sizeof(equip))
		equipments_[eqdb.id] = equip
	end

	db_processor_[C.kPropSetting] = function(msg)
		copy(prop_setting_, msg, sizeof(prop_setting_))
	end

	db_processor_[C.kMyFormulas] = function(msg)
		local myformulas = cast('const MyFormulas&', msg)
		for i=0,myformulas.count-1 do table.insert(formulas_, myformulas.kinds[i]) end
	end

--成员函数
	function obj.ActiveFunction( type )
		if type==1 then
			active_Strengthen = true
		elseif type==2 then
			active_Inlay = true
		elseif type==3 then
			active_CompoundGem = true
		elseif type==4 then
			active_Migrate = true
		end
	end
	
	function obj.PropsTraceBegin()
		PropsTraceBegin()
	end
	
	function obj.PropsTraceEnd()
		PropsTraceEnd()
	end

	function obj.GetProps()
        return props_
	end
    
    --把物品移动到拍卖行
    function obj.MoveProps(id)
		PropsTraceBegin()
		trace_.alters[trace_.amount] = { id, props_[id].kind, C.kInvalidID, props_[id].area, props_[id].location, props_[id].amount, props_[id].bind, C.kAlterationRemove}
		trace_.amount = trace_.amount + 1
        props_[id].area = C.kAreaAuction
        player.UpdateField(C.ktProp, id, {C.kfArea, props_[id].area})
		PropsTraceEnd()
    end

    --拆分道具
    function obj.UseProps(id, amount)
		PropsTraceBegin()
        props_[id].amount = props_[id].amount - amount
		UpdatePropAmount( id, props_[id] )
		PropsTraceEnd()
    end
    
    --添加道具<目前是拍卖行在用,非装备>
	function obj.AddProps(area, kind, amount)
		prop = new('Prop', kind, area)
		prop.amount = amount
		prop.location=0
		max_id_ = max_id_+1
		props_[max_id_] = prop
		local equip = nil
		InsertProps2Db(max_id_, prop, equip)
		return max_id_
    end
    
    --以上拍卖行专用，其它地方请勿调用，否则有安全性问题
    
    
	function obj.AddAttach(id, kind, amount)--这里不用trace
        max_id_ = id
		prop = new('Prop', kind, C.kAreaMail)
		prop.amount = amount
		prop.location = 0
		props_[max_id_] = prop
	end

	function obj.Destroy()
	end

	function obj.ModifyAmount(kind, amount)
		PropsTraceBegin()
		local prop_id = nil
		if amount>0 then
			local area = C.kAreaBag
			if Kind2Type(kind)==C.kPropGem then area=C.kAreaGem end
			prop_id = AddProps2Area(area, kind, amount)
		elseif amount<0 then
			ReduceProp(kind, -amount)
		end
		PropsTraceEnd()
		return prop_id
	end
	
	--
	--amount>0 or amount<0
	--不必调用方考虑叠加问题,包裹已满返回false
	--
	function obj.ModifyPropById(id, amount)
		PropsTraceBegin()
		local result = ModifyPropById(id, amount)
		PropsTraceEnd()
		return result
	end
	
	function obj.AddNewProps2Area4Kind(area, kind, amount)
		PropsTraceBegin()
		local result = AddNewProps2Area4Kind(area, kind, amount)
		PropsTraceEnd()
		return result
	end
	
	function obj.AddNewProps2Area4Kinds(area, props)
		PropsTraceBegin()
		local result = AddNewProps2Area4Kinds(area, props)
		PropsTraceEnd()
		return result
	end
	
	function obj.AddNewEquip2Area(area, kind, location, level, strength, agility, intelligence, hero_id)
		PropsTraceBegin()
		local equip_id =  AddNewEquip2Area(area, kind, location, level, strength, agility, intelligence, hero_id)
		PropsTraceEnd()
		return equip_id
	end
	
	function obj.DeletePropAmount(id, amount)
		PropsTraceBegin()
		local result = C.eSucceeded
		local prop = props_[id]
		local equip = nil
		if id and prop and amount>0 then
			equip = equipments_[id]
			if equip then
				Remove(id, equip.hero)
				if equip.hero~=C.kInvalidID then fight_power.CheckFightPowerChange(player.GetUID()) end
			elseif amount>=prop.amount then
				Remove(id)
			else
				prop.amount = prop.amount - amount
				UpdatePropAmount(id, prop)
			end
			result = C.eSucceeded
		else
			result = C.eInvalidValue
		end
		PropsTraceEnd()
		return result
	end
	
	--参数有test时,表示测试能否购买此物品,同时返回物品的信息
	--参数无test时,正式购买,并放到指定位置<英雄身上>
	function obj.BuyProp2Location(buy, test)
		PropsTraceBegin()
		local result = {result=C.eInvalidValue, prop_id=nil, prop_kind=nil}
		local shop_cfg = shop_cfgs[buy.shop]
		local cfg = shop_cfg and shop_cfg[buy.prop_index]
		if not cfg then
		elseif player.GetLevel()<cfg.level then
			result.result = C.eLowLevel
		elseif cfg.coin_type==1 and not me.IsSilverEnough(cfg.price) then
			result.result=C.eLackResource
		elseif cfg.coin_type==2 and not me.IsPropEnough(cfg.coin_kind, cfg.price) then
			result.result=C.eLackResource
		elseif cfg.coin_type==1 or cfg.coin_type==2 then
			local prop_cfg = prop_cfgs[cfg.prop_kind]
			if prop_cfg and prop_cfg.type==C.kPropEquipment then
				if GetHeroEquipmentProp(buy.hero_id, buy.location) then
					result.result = C.eOccupy
				elseif not test then
					local id = PutNewProp2Location(C.kAreaHero, cfg.prop_kind, 1, buy.location, buy.hero_id)
					if id then
						equipments_[id].hero = buy.hero_id
						UpdateEquipmentAssociateHero(id, buy.hero_id)
						fight_power.CheckFightPowerChange(player.GetUID())
						result.result, result.prop_id = C.eSucceeded, id
						if cfg.coin_type==1 then 
							me.ModifySilver(-cfg.price) 
						elseif cfg.coin_type==2 then
							ReduceProp(cfg.coin_kind, cfg.price)
						else
							me.ModifyProp(cfg.coin_kind, -cfg.price)
						end
					end
				else
					result.result = C.eSucceeded
					result.prop_kind = cfg.prop_kind
				end
			end
		end
		PropsTraceEnd()
		return result
	end
	
	function obj.Move2Hero(equip_hero, take_off) --装备到英雄身上
		local result = C.eInvalidValue
		local id = equip_hero.prop
		local prop = props_[id]
		--print('id='..id..',kind='..prop.kind..',location='..equip_hero.location)
		if prop and prop.area==C.kAreaBag and equipments_[id] then
			local prop_location = prop.location
			if take_off.amount==2 then		--脱掉装备
				if not MoveProp2Unoccupied(C.kAreaBag,take_off.id) then
					return C.eBagFull
				end
			end

			local target,target_id = GetHeroEquipmentProp(equip_hero.hero, equip_hero.location)
			if SwapLocation(id, C.kAreaHero, equip_hero.location, equip_hero.hero) then
				equipments_[id].hero = equip_hero.hero
				UpdateEquipmentAssociateHero(id, equip_hero.hero)
				if target then
					UpdateEquipmentAssociateHero(target_id, C.kInvalidID)
				end
				if take_off.amount==1 and take_off.id then
					MoveProp2Unoccupied(C.kAreaBag, take_off.id, prop_location)
				end
				result = C.eSucceeded
				fight_power.CheckFightPowerChange(player.GetUID())
			end
		end
		return result
	end

	function obj.MoveFromHero(take_off) --从英雄身上脱下装备
		local result = C.eInvalidValue
		local id = take_off.prop
		local prop = props_[id]
		local equip_location = -1
		if prop and prop.area==C.kAreaHero and equipments_[id] then
			equip_location = prop.location
			if GetLocationProp(C.kAreaBag, take_off.location) then
				result = C.eOccupy
			elseif SwapLocation(id, C.kAreaBag, take_off.location) then
				equipments_[id].hero = C.kInvalidID
				UpdateEquipmentAssociateHero(id, C.kInvalidID)
				result = C.eSucceeded
				fight_power.CheckFightPowerChange(player.GetUID())
			else
				print('swap failed')
			end
		end
		return result,equip_location
	end

	function obj.IsEnough(kind, amount)
		local tmp = 0
		for id,prop in pairs(props_) do
			if prop.kind==kind and (prop.area==C.kAreaBag or prop.area==C.kAreaWarehouse or prop.area==C.kAreaGem) then
				tmp = tmp+prop.amount
				if tmp>=amount then return true end
			end
		end
	end

	function obj.HavePropAmount( kind )
		local tmp = 0
		for id,prop in pairs(props_) do
			if prop.kind==kind and (prop.area==C.kAreaBag or prop.area==C.kAreaWarehouse or prop.area==C.kAreaGem) then
				tmp = tmp+prop.amount
			end
		end
		return tmp
	end

	function obj.GetEquipment(id)
		return props_[id], equipments_[id]
	end

	function obj.GetEquipment4Client(id)
		local equip = equipments_[id]
		if equip then
			local equipment = new('Equipment4Client', equip.level, equip.base_strength, equip.base_agility, equip.base_intelligence, equip.holes, 0, equip.gems)
			return equipment
		end
	end

	function obj.GetHeroEquipments(hero_id)
		local equips = {}
		for id,equip in pairs(equipments_) do
			local prop = props_[id]
			if equip.hero==hero_id and prop and prop.area==C.kAreaHero then
				equips[prop.location] = {prop, equip, id}
			end
		end
		return equips
	end
	
	function obj.TransferEquipment2Hero(hero_from, hero_to)
		for id,equip in pairs(equipments_) do
			local prop = props_[id]
			if equip.hero==hero_from and prop and prop.area==C.kAreaHero then
				equip.hero = hero_to
			end
		end
		player.UpdateField2(C.ktEquipment, C.kfPlayer, uid_, C.kfHero, hero_from, {C.kfHero, hero_to})
	end

	function obj.IsBagFull()
		return CountAreaOccupied(C.kAreaBag)>=prop_setting_.bag_grids_count
	end
	
	function obj.GetBagSpace()
		return prop_setting_.bag_grids_count - CountAreaOccupied(C.kAreaBag)
	end

	function obj.BagUnoccupied()
		return (prop_setting_.bag_grids_count-CountAreaOccupied(C.kAreaBag))
	end

	function obj.HasPropInBag()
		for _,prop in pairs(props_) do
			if prop.area == C.kAreaBag then return true end
		end
	end

	function obj.GetEquipmentStrengthenTimes()
		local times = 0
		for _,equipment in pairs(equipments_) do
			if equipment.level>0 then times=times+equipment.level end
		end
		return times
	end

	function obj.ProcessMsgFromDb(type, msg, flag)
		local func = db_processor_[type]
		if func then func(msg, flag) end
	end

	function obj.ProcessMsg(type, msg, flag)
		local func = processor_[type]
		if func then return func(msg, flag) end
	end

--初始化
	LoadSoldEquipment()
	_,max_id_ = AllSoldProps()

	return obj
end
