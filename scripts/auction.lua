--拍卖行逻辑

local config = require('config.global')
local prop_cfgs = require('config.props')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local cast = ffi.cast
local copy = ffi.copy

require('data')
require('db')
require('auction_data')

local auction_wait = GetAuctionWait()
local auction_info = data.GetAuctionInfo()

local auctions = CreateAuctionData(auction_info)

--返还金币
local function GiveBack(auction, buyer)
    buyer = buyer or auction.buyer
    if buyer~=-1 then
        local buyer_ = data.GetOnlinePlayer(buyer)
        if buyer_ then
            --在线玩家
            buyer_.AddGold(auction.GetLastPrice())
            
            --更改物品所有者记录
            if auction_wait[buyer] then
                auction_wait[buyer].Failed(auction.uuid)
            end
            
            --推送
            local result = new('AuctionFailed')
            result.kind = auction.kind
            GlobalSend2Gate(buyer, result, sizeof(result))
        else
            --离线玩家
            AddGoldByUID(buyer, auction.GetLastPrice())
            
            --插入离线消息
            GlobalInsertRow(C.ktAuctionOffline, {C.kfPlayer, buyer}, {C.kfGold, auction.value})
        end
    end
end

local function SendMailProp(auction, to_uid)
    local new_id = data.ChangePropOwner(auction.seller, to_uid, auction.id)
    
    if not new_id then
        --交易失败
        GiveBack(auction, to_uid)
        return false
    else
        --这里只改变在线买家状态，这是因为在线卖家的物品即使在内存也无法使用，无需要特殊处理
        
        local buyer_ = data.GetOnlinePlayer(to_uid)
        if buyer_ then
            --改变在线玩家状态
            buyer_.AddAttach(new_id, auction.kind, auction.amount)
        end
    end
    
    local ma = new("MailAttachments")
    ma.amount=1
    ma.attach[0].attach_id = 1
    ma.attach[0].extracted = 0
    ma.attach[0].type = C.kPropRsc
    ma.attach[0].prop_id = new_id
    ma.attach[0].kind = auction.kind
    ma.attach[0].amount = auction.amount
    db.SendMail(to_uid, os.time(), "拍卖行邮件", "恭喜您成功获取了物品", ma, true)
    return true
end

local function SendMailGold(uid, gold)
    local ma = new("MailAttachments")
    ma.amount=1
    ma.attach[0].attach_id = 1
    ma.attach[0].extracted = 0
    ma.attach[0].type = C.kGoldRsc
    ma.attach[0].amount = gold
    db.SendMail(uid, os.time(), "拍卖行邮件", "恭喜您成功售出了物品", ma, true)
end

--返回值，判断执行结果
local RESULT = table.enum(14500, {"SUCCESS", "NOT_YET_ACTIVATE", "INVALID_ARGUMENT", "NOT_ENOUGH_SPACE", "NOT_FOR_AUCTION", "NOT_ENOUGH_GOLD", "INVALID_ID", "NOT_SET_PRICE", "INVALID_PAGE"})

function CreateAuction(player, this)
    local obj = {}
    
    local uid = player.GetUID()
    local props = player.GetProps()

    --出售物品
    function obj.SaleAuctionProps(id, amount, day, start, price)
        --检查参数是否正确
        local prop = props[id]
        if not prop or prop.area~=C.kAreaBag or (prop_cfgs[prop.kind].type~=1 and prop_cfgs[prop.kind].type~=2) then return RESULT.INVALID_ARGUMENT end
        
        if amount<0 or amount>prop.amount then return RESULT.INVALID_ARGUMENT end
        
        if not config.auction.cost[day] then return RESULT.INVALID_ARGUMENT end
        
        if start<=0 or (price~=0 and start>price) then return RESULT.INVALID_ARGUMENT end
        
        local uuid = data.GetPropUUID(uid, id)
        if not uuid then return RESULT.INVALID_ARGUMENT end
        
        --检查是否还能卖东西
        if this.GetAuctionSpace()<=0 then return RESULT.NOT_ENOUGH_SPACE end
        
        if not prop_cfgs[prop.kind].for_auction or not data.CanSellEquipment(uid, id) then return RESULT.NOT_FOR_AUCTION end
        
        --检查金币是否足够
        if not player.IsGoldEnough(config.auction.cost[day]) then return RESULT.NOT_ENOUGH_GOLD end
        
        --扣除服务费
        player.ConsumeGold(config.auction.cost[day])
        
        --把物品移动到拍卖行
        if amount==prop.amount then
            --整堆出售
            player.MoveProps(id)
            --prop.area = C.kAreaAuction
            --player.UpdateField(C.ktProp, id, {C.kfArea, prop.area})
        else
            --需要拆分
            player.ModifyProp(id, -amount)
            --prop.amount = prop.amount - amount
            --player.UpdateField(C.ktProp, id, {C.kfAmount, prop.amount})
            
            --
            local new_id = player.AddProps(C.kAreaAuction, prop.kind, amount)
            uuid = data.GetPropUUID(uid, new_id)
        end
        
        
        --插入玩家交易记录｛物品尚未卖出｝
        local info = {}
        info.uuid = uuid
        info.status = 3
        info.kind = prop.kind
        info.amount = prop.amount
        info.price = 0
        info.time = 0
        this.info[#this.info + 1] = info
        GlobalInsertRow(C.ktAuctionInfo, {C.kfUUID, uuid}, {C.kfSeller, uid}, {C.kfKind, info.kind}, {C.kfAmount, info.amount})
        
        --把物品添加到拍卖行
        local auction = {}
        auction.uuid = uuid
        auction.seller = uid
        auction.buyer = -1
        auction.count = 0
        auction.start = start
        auction.price = price
        auction.time = os.time() + day * (60*60*24)
        auctions.Insert(auction)
        
        return RESULT.SUCCESS
    end
    
    --购买物品
    function obj.BuyAuctionProps(id, type)
        local auction = auctions.GetAuction(id)
        
        --检查物品ID
        if not auction then return RESULT.INVALID_ID end
        
        --检查是否设置一口价
        if type==1 and auction.price==0 then return RESULT.NOT_SET_PRICE end
        
        if type==1 then
            --一口价直接购买

            
            --检查金币是否足够
            if not player.IsGoldEnough(auction.price) then return RESULT.NOT_ENOUGH_GOLD end
            
            --扣除金币
            player.ConsumeGold(auction.price)
            
            --返还参与竞拍玩家的钱
            GiveBack(auction)
            auction.value = auction.price
            auction.buyer = uid
            
            --插入玩家交易记录
            local info = {}
            info.uuid = id
            info.status = 5
            info.kind = auction.kind
            info.price = auction.price
            info.amount = auction.amount
            info.time = os.time()
            this.info[#this.info + 1] = info
            UpdateField2(C.ktAuctionInfo, C.kfUUID, id, 0, C.kInvalidID, {C.kfBuyer, uid}, {C.kfStatus, 2}, {C.kfPrice, info.price}, {C.kfTime, info.time})
            
            --更改物品所有者记录
            if auction_wait[auction.seller] then
                auction_wait[auction.seller].Sale(id, auction.price, info.time)
            end
            
            --发送双方邮件
            if SendMailProp(auction, uid) then
                SendMailGold(auction.seller, auction.price * (1 - config.auction.tax))
            end
            
            auction.Delete()
        else
            --参与竞拍

            --检查金币是否足够
            local gold = auction.GetPrice()
            if auction.price~=0 and gold>=auction.price then gold = auction.price end
            if not player.IsGoldEnough(gold) then return RESULT.NOT_ENOUGH_GOLD end
            
            --扣除金币
            player.ConsumeGold(gold)
            
            --返还参与竞拍玩家的钱
            GiveBack(auction)
            
            --判断是否超过一口价
            if auction.price~=0 and gold==auction.price then
                --超过了一口价，直接竞拍成功
                auction.buyer = uid
                auction.value = auction.price
                
                --插入玩家交易记录
                local info = {}
                info.uuid = id
                info.status = 4
                info.kind = auction.kind
                info.price = gold
                info.amount = auction.amount
                info.time = os.time()
                this.info[#this.info + 1] = info
                UpdateField2(C.ktAuctionInfo, C.kfUUID, id, 0, C.kInvalidID, {C.kfBuyer, uid}, {C.kfStatus, 1}, {C.kfPrice, info.price}, {C.kfTime, info.time})
                
                --更改物品所有者记录
                if auction_wait[auction.seller] then
                    auction_wait[auction.seller].Sale(id, auction.price, info.time)
                end
                
                --发送双方邮件
                if SendMailProp(auction, uid) then
                    SendMailGold(auction.seller, auction.price * (1 - config.auction.tax))
                end
            
                auction.Delete()
            else
                --参与竞拍
                auction.buyer = uid
                
                --插入玩家交易记录｛物品尚未卖出｝
                local info = {}
                info.uuid = id
                info.status = 6
                info.kind = auction.kind
                info.price = 0
                info.amount = auction.amount
                info.time = 0
                this.info[#this.info + 1] = info
                UpdateField2(C.ktAuctionInfo, C.kfUUID, id, 0, C.kInvalidID, {C.kfBuyer, uid}, {C.kfStatus, 3})
                
                auction.AddPrice()
                UpdateField2(C.ktAuction, C.kfUUID, id, 0, C.kInvalidID, {C.kfBuyer, uid}, {C.kfCount, auction.count}, {C.kfTime, auction.time})
            end
        end
        
        return RESULT.SUCCESS
    end
    
    --查看拍卖行物品列表
    function obj.ViewAuctionProps(page, sort, order)
        --检查参数是否正确
        if (sort~=1 and sort~=2 and sort~=3) then return RESULT.INVALID_ARGUMENT end
        
        --检查页数是否正确
        local page_total = math.ceil(auctions.GetCount()/11)
        if page_total==0 then return RESULT.SUCCESS, {page_total, {}} end
        
        if page<1 or page>page_total then return RESULT.INVALID_PAGE end
        
        local begin = 1+(page-1)*11
        local over = 11+(page-1)*11
        
        if over>auctions.GetCount() then over = auctions.GetCount() end
        
        return RESULT.SUCCESS, {page_total, auctions.GetList(sort, order, begin, over)}
    end
    
    --搜索拍卖行物品
    function obj.SearchAuctionProps(SearchProps)
        local page = SearchProps.page
        local sort = SearchProps.sort
        local order = SearchProps.order
        local kind = SearchProps.kind
        local additions = {}
        if SearchProps.addition==1 then
            additions[SearchProps.addition1] = true
            additions[SearchProps.addition2] = true
            additions[SearchProps.addition3] = true
        end
        
        --检查参数是否正确
        if (sort~=1 and sort~=2 and sort~=3) or (kind~=1 and kind~=2) then return RESULT.INVALID_ARGUMENT end
        
        local temp_auctions = auctions.CreateFilter(kind, SearchProps.type, SearchProps.level, SearchProps.quality, additions)
        
        --检查页数是否正确
        local page_total = math.ceil(temp_auctions.GetCount()/11)
        if page_total==0 then return RESULT.SUCCESS, {page_total, {}} end
        
        if page<1 or page>page_total then return RESULT.INVALID_PAGE end
        
        local begin = 1+(page-1)*11
        local over = 11+(page-1)*11
        
        if over>temp_auctions.GetCount() then over = temp_auctions.GetCount() end
        
        return RESULT.SUCCESS, {page_total, temp_auctions.GetList(sort, order, begin, over)}
    end
    
    --玩家拍卖行记录
    function obj.AuctionRecord()
        
        return RESULT.SUCCESS
    end
    
    --获取物品详细信息
    function obj.AuctionPropsDetail(id)
        return RESULT.SUCCESS
    end

    --
    function obj.GetAuction(id)
        return auctions.GetAuction(id)
    end
    
    return obj
end


--检查拍卖是否到期
function AuctionExpiration()
    for _,v in ipairs(auction_info) do
        if os.time()>v.time then
            local auction = auctions.GetAuction(v.uuid)
            if auction.buyer==-1 then
                --流拍
                
                --改变在线玩家记录
                if auction_wait[auction.seller] then
                    auction_wait[auction.seller].NotSale(v.uuid)
                end
                
                UpdateField2(C.ktAuctionInfo, C.kfUUID, v.uuid, 0, C.kInvalidID, {C.kfStatus, 0}, {C.kfTime, auction.time})
                SendMailProp(auction, auction.seller)
            else
                --达到时间上限，正常卖出
            
                --改变在线玩家记录
                if auction_wait[auction.buyer] then
                    auction_wait[auction.buyer].Buy(v.uuid)
                end
                if auction_wait[auction.seller] then
                    auction_wait[auction.seller].Sale(v.uuid, auction.value, v.time)
                end
                
                UpdateField2(C.ktAuctionInfo, C.kfUUID, v.uuid, 0, C.kInvalidID, {C.kfBuyer, auction.buyer}, {C.kfStatus, 1}, {C.kfPrice, auction.value}, {C.kfTime, auction.time})
                
                --发送双方邮件
                if SendMailProp(auction, auction.buyer) then
                    SendMailGold(auction.seller, auction.value * (1 - config.auction.tax))
                end
            end
            
            auction.Delete()
            break
        end
    end
end
