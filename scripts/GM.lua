--玩家离线或者全服通知时GM消息处理
module('GM', package.seeall)

local ffi = require('ffi')

local sizeof = ffi.sizeof
local new = ffi.new
local C = ffi.C
local cast = ffi.cast
local copy = ffi.copy

require('global_data')
require('db')
local prop_cfgs = require('config.props')


local gm_processors_ = {}

gm_processors_[C.kModifyPlayerResource] = function(uid, msg)
    return {result=C.kGMOffline}
end

gm_processors_[C.kGMKickUser] = function(uid)
	local result = {result=C.kGMSucceced}
	local kick = ffi.new('KickUser', uid)
	GlobalSend2Gate(uid, kick)
	return result
end

gm_processors_[C.kGMSendMail] = function(uid, msg, player)
	local result = {result=C.kGMSucceced}
	local ret = false
	
	local b_notify = false
	if player then b_notify=true end
	
	if uid<1 or not msg.subject or not msg.content then
		result.result = C.kGMInvalid
		return result
	end
	
	local ma = nil
	if not msg.attach_amount or msg.attach_amount==0 then
		ma = nil
	elseif msg.attach_amount>0 and msg.attach_amount<=8 then
		local prop = nil
		ma = new("MailAttachments")
		ma.amount = msg.attach_amount
		for i=1,msg.attach_amount do
			prop = msg.attachs[i]
			if not prop or not prop.kind or not prop.amount or not prop_cfgs[prop.kind] or prop.amount<1 then
				result.result = C.kGMInvalid
				return result
			end
			ma.attach[i-1].attach_id = i
			ma.attach[i-1].extracted = 0
			ma.attach[i-1].type = C.kPropRsc
			ma.attach[i-1].kind = prop.kind
			ma.attach[i-1].amount = prop.amount
			ma.attach[i-1].prop_id = 0
		end
	else
		result.result = C.kGMInvalid
		return result
	end

	ret=db.SendMail(uid, os.time(), msg.subject, msg.content, ma, b_notify)
	if not ret then result.result=C.kGMMailsOverFlow end
	return result
end

gm_processors_[C.kGMModifyProp] = function(uid, msg)
	local result = { result=C.kGMSucceced }
	if msg.amount and msg.id then
		local res = db.GetProp(uid, msg.id)
		if res then
			local cfg = prop_cfgs[res.kind]
			if cfg then
				if cfg.type==C.kPropEquipment then
					GlobalDeleteRow(C.ktEquipment, uid, msg.id)
					GlobalDeleteRow(C.ktProp, uid, msg.id)
				elseif msg.amount>=res.amount then
					GlobalDeleteRow(C.ktProp, uid, msg.id)
				else
					UpdateDeltaField(C.ktProp, C.kfUUID, res.uuid, C.kfAmount, -msg.amount, uid)
				end
				result.result = C.kGMSucceced
			else
				result.result = C.kGMInvalid
			end
		else
			result.result = C.kGMInvalid
		end
	else
		result.result = C.kGMInvalid
	end
	return result
end

function ProcessGMMsg(head,  msg, player)
    local f = gm_processors_[head.type]
    if f then
        return f(head.aid, msg, player)
    else
        --没有提供这个方法
        return {result=C.kGMUnknown}
    end
end