local prop_cfgs = require('config.props')
local welcome_mail = require('config.welcome')

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

check_welcome_mail()