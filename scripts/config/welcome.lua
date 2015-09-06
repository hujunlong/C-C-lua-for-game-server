local welcome_mail = {}


--附件
welcome_mail.attachments = {}



--以下为可修改内容


--[[
邮件标题和内容,必须使用全角符号
]]

--邮件标题
welcome_mail.subject = '欢迎来到英雄领域'

--邮件内容
welcome_mail.content = '叫上朋友，大家一起来吧'



--[[
1.必须是存在于道具表里面的;
2.不可堆叠的道具,数量只能是一个
3.道具种类不能超过8个
]]

--附件1
welcome_mail.attachments[1] = {}
welcome_mail.attachments[1].kind = 10038		--道具种类为10038
welcome_mail.attachments[1].amount = 1			--道具数量为1

--附件2
welcome_mail.attachments[2] = {}
welcome_mail.attachments[2].kind = 10054		--道具种类为10054
welcome_mail.attachments[2].amount = 1			--道具数量为1


--以上为可修改内容


return welcome_mail