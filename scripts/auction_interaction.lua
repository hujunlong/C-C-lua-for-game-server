--拍卖行交互【客户端、数据库】

local config = require('config.global')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local cast = ffi.cast
local copy = ffi.copy

require('auction')

local auction_wait = GetAuctionWait()

function AuctionInteraction(player)
    local obj = {}
    
    local uid = player.GetUID()
    
    --数据保存
    local this = {}
    this.activate = false --player.GetVIPLevel()>=4
    this.info = {}
    
    --status 0 未卖出，1 2 已卖出，3 正在出售，4 竞拍成功，5 一口价购买，6 参与竞拍
    this.GetAuctionSpace = function()
        local count = 0
        
        for _,v in ipairs(this.info) do
            if v.status==3 then
                count = count + 1
            end
        end
        return config.auction.space - count
    end
    
    function obj.open()
        this.activate = true
    end
    
    local instance = CreateAuction(player, this, auction_wait)
    
    --数据库消息处理
    local db_processor_ = {}
    
    db_processor_[C.kAuctionInfo] = function(msg)
        local AuctionInfoList = cast('const AuctionInfoList&', msg)
        for i=0,AuctionInfoList.count-1 do
            local info = {}
            info.uuid = AuctionInfoList.list[i].uuid
            info.status = AuctionInfoList.list[i].status
            info.price = AuctionInfoList.list[i].price
            info.kind = AuctionInfoList.list[i].kind
            info.amount = AuctionInfoList.list[i].amount
            info.time = AuctionInfoList.list[i].time
            
            this.info[#this.info + 1] = info
        end
        
        auction_wait[uid] = obj
    end
    
    db_processor_[C.kAuctionOffline] = function(msg)
        local AuctionOfflineList = cast('const AuctionOfflineList&', msg)
        for i=0,AuctionOfflineList.count-1 do
            local info = {}
            info.kind = AuctionOfflineList.list[i].kind
            info.gold = AuctionOfflineList.list[i].gold
            
            
            local result = new('AuctionFailed')
            result.kind = info.kind
            player.Send2Gate(result, sizeof(result))
            --print(info.kind, info.gold)
        end
    end
    
    --客户端消息处理
    local processor_ = {}
    
    --打开拍卖行
    processor_[C.kOpenAuctionHouse] = function(msg)
        local result = new('OpenAuctionHouseResult', C.AUCTION_NOT_ACTIVATE)
        if this.activate then
            result.result = C.AUCTION_SUCCESS
            result.space = this.GetAuctionSpace()
            
            obj.ready = true --打开拍卖行面板，接受推送
        end
        return result
    end
    
    --关闭拍卖行
    processor_[C.kCloseAuctionHouse] = function(msg)
        local result = new('CloseAuctionHouseResult', C.AUCTION_NOT_ACTIVATE)
        if this.activate then
            result.result = C.AUCTION_SUCCESS
            obj.ready = nil
        end
        return result
    end
    
    --出售物品
    processor_[C.kSaleAuctionProps] = function(msg)
        local ForSaleAuctionProps =  cast('const SaleAuctionProps&', msg)
        local result = new('SaleAuctionPropsResult', C.AUCTION_NOT_ACTIVATE)
        if this.activate then
            result.result = instance.SaleAuctionProps(ForSaleAuctionProps.id, ForSaleAuctionProps.amount, ForSaleAuctionProps.day, ForSaleAuctionProps.start, ForSaleAuctionProps.price)
        end
        return result
    end
    
    --购买物品
    processor_[C.kBuyAuctionProps] = function(msg)
        local BuyProps =  cast('const BuyAuctionProps&', msg)
        local result = new('BuyAuctionPropsResult', C.AUCTION_NOT_ACTIVATE)
        if this.activate then
            result.result = instance.BuyAuctionProps(BuyProps.id, BuyProps.type)
        end
        return result
    end
    
    --查看拍卖行物品列表
    processor_[C.kViewAuctionProps] = function(msg)
        local ViewProps =  cast('const ViewAuctionProps&', msg)
        local result = new('ViewAuctionPropsResult', C.AUCTION_NOT_ACTIVATE)
        if this.activate then
            local inner_result, inner_info = instance.ViewAuctionProps(ViewProps.page, ViewProps.sort, ViewProps.order)
            result.result = inner_result
            if result.result==C.AUCTION_SUCCESS then
                result.page = inner_info[1]
                result.count = 0
                for i,v in ipairs(inner_info[2]) do
                    result.list[result.count].id = v.uuid
                    result.list[result.count].kind = v.kind
                    result.list[result.count].amount = v.amount
                    result.list[result.count].start = v.start
                    result.list[result.count].current = v.GetPrice()
                    result.list[result.count].price = v.price
                    result.list[result.count].time = v.time
                    result.count = i
                end
                
                return result, 8 + result.count * sizeof(result.list[0])
            end
        end
        return result
    end
    
    --搜索拍卖行物品
    processor_[C.kSearchAuctionProps] = function(msg)
        local result = new('SearchAuctionPropsResult', C.AUCTION_NOT_ACTIVATE)
        if this.activate then
            local inner_result, inner_info = instance.SearchAuctionProps(cast('const SearchAuctionProps&', msg))
            result.result = inner_result
            if result.result==C.AUCTION_SUCCESS then
                result.page = inner_info[1]
                result.count = 0
                for i,v in ipairs(inner_info[2]) do
                    result.list[result.count].id = v.uuid
                    result.list[result.count].kind = v.kind
                    result.list[result.count].amount = v.amount
                    result.list[result.count].start = v.start
                    result.list[result.count].current = v.GetPrice()
                    result.list[result.count].price = v.price
                    result.list[result.count].time = v.time
                    result.count = i
                end
                
                return result, 8 + result.count * sizeof(result.list[0])
            end
        end
        return result
    end

    --玩家拍卖行记录
    processor_[C.kAuctionRecord] = function(msg)
        local type = cast('const AuctionRecord&', msg).type
        local result = new('AuctionRecordResult', C.AUCTION_NOT_ACTIVATE)
        if this.activate then
            result.result = instance.AuctionRecord()
            if result.result==C.AUCTION_SUCCESS then
                result.count = 0
                for _,v in ipairs(this.info) do
                    if v.status==3 or v.status==6 then
                        if type==1 then
                            result.list[result.count].kind = v.kind
                            
                            local auction = instance.GetAuction(v.uuid)
                            local status = {[3]=0, [6]=auction.start}
                            
                            result.list[result.count].price = auction.price
                            result.list[result.count].amount = auction.amount
                            result.list[result.count].time = auction.time
                            result.list[result.count].status = status[v.status]
                            
                            result.count = result.count + 1
                        end
                    else
                        if type==2 then
                            result.list[result.count].kind = v.kind
                            
                            local status = {[0]=0, [1]=1, [2]=1, [4]=2, [5]=3}
                            
                            result.list[result.count].price = v.price
                            result.list[result.count].amount = v.amount
                            result.list[result.count].time = v.time
                            result.list[result.count].status = status[v.status]
                            
                            result.count = result.count + 1
                        end
                    end
                    
                    if result.count>=256 then break end
                end
                
                return result, 8 + result.count * sizeof(result.list[0])
            end
        end
        return result
    end
    
    --获取物品详细信息
    processor_[C.kAuctionPropsDetail] = function(msg)
        local result = new('AuctionPropsDetailResult', C.AUCTION_NOT_ACTIVATE)
        if this.activate then
            local inner_result, inner_info = instance.AuctionPropsDetail(cast('const ViewAuctionProps&', msg).id)
            result.result = inner_result
            if result.result==C.AUCTION_SUCCESS then
                --TODO
            end
        end
        return result
    end
    
    
    --外部自动调用的接口
    function obj.ProcessMsgFromDb(type, msg)
        local func = db_processor_[type]
        if func then func(msg) end
    end
    function obj.ProcessMsg(type, msg)
        local func = processor_[type]
        if func then
            local result, result_length = func(msg)
            if result then
                if result.result==C.AUCTION_SUCCESS then
                    result.result = 0
                else
                    result_length = 4
                end
                return result, result_length
            end
        end
    end
    
    --玩家退出
    function obj.Destroy()
        auction_wait[uid] = nil
    end
    
    --卖出物品
    function obj.Sale(uuid, price, time)
        for _,v in ipairs(this.info) do
            if v.uuid==uuid and v.status==3 then
                v.status = 1
                v.price = price
                v.time = time
                break
            end
        end
    end
    
    --未卖出物品
    function obj.NotSale(uuid)
        for _,v in ipairs(this.info) do
            if v.uuid==uuid and v.status==3 then
                v.status = 0
                break
            end
        end
    end
    
    --买到物品
    function obj.Buy(uuid)
        for _,v in ipairs(this.info) do
            if v.uuid==uuid and v.status==6 then
                v.status = 4
                break
            end
        end
    end
    
    --竞拍失败
    function obj.Failed(uuid)
        for _,v in ipairs(this.info) do
            if v.uuid==uuid and v.status==6 then
                table.remove(this.info, _)
                break
            end
        end
    end
    
    return obj
end
