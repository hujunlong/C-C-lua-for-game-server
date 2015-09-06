module('welcome', package.seeall)

local welcome_mail = require('config.welcome')
local prop_cfgs = require('config.props')

require('db')

local ffi = require("ffi")
local C = ffi.C
--local cast= ffi.cast
local new = ffi.new
--local sizeof = ffi.sizeof



local attachments_ = nil

local function SendMailForNewPlayer(uid)
	db.SendMail(uid, os.time(), welcome_mail.subject, welcome_mail.content, attachments_, true)
end

function WelcomeToGame(uid)
	print('welcome new player to game: '..uid)
	SendMailForNewPlayer(uid)
end











local function check_welcome_mail()
	assert(welcome_mail.subject and type(welcome_mail.subject)=='string')
	assert(welcome_mail.content and type(welcome_mail.content)=='string')
	for _, attachment in pairs(welcome_mail.attachments) do
		assert(attachment.kind)
		local prop_cfg = prop_cfgs[attachment.kind]
		assert(prop_cfg)
		assert(attachment.amount)
		if not prop_cfg.overlap then
			assert(attachment.amount==1)
		else
			assert(attachment.amount>=1)
		end
	end
end

local function GetAttachmentFromConfig()
	attachments_ = new("MailAttachments")
	attachments_.amount = 0
	for _, attachment in pairs(welcome_mail.attachments) do
		attachments_.attach[attachments_.amount].attach_id = attachments_.amount+1
		attachments_.attach[attachments_.amount].extracted = 0
		attachments_.attach[attachments_.amount].type = C.kPropRsc
		attachments_.attach[attachments_.amount].kind = attachment.kind
		attachments_.attach[attachments_.amount].amount = attachment.amount
		attachments_.attach[attachments_.amount].prop_id = 0
		attachments_.amount = attachments_.amount + 1
	end
end

check_welcome_mail()
GetAttachmentFromConfig()