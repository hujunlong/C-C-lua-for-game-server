--拍卖行数据

local config = require('config.global')
local prop_cfgs = require('config.props')

local ffi = require('ffi')
local C = ffi.C
local new = ffi.new
local sizeof = ffi.sizeof
local cast = ffi.cast
local copy = ffi.copy

require('data')
require('global_data')

--通知队列
local auction_wait = {}

function CreateAuctionData(this)
    local obj = {}

    --索引
    local index_type = {"value","price","time"}      --竞拍价（默认），一口价，剩余时间
    local index = {}
    local uuids = {}
    
    --对索引排序
    local function Sort()
        for i=1,#index_type do
            table.sort(index[i], function(a,b) return a[index_type[i]]<b[index_type[i]] end)
        end
    end
    
    --初始化
    local function Init()
        for i=1,#index_type do index[i] = {} end
        for k,v in ipairs(this) do
            --
            uuids[v.uuid] = k
            
            v.Delete = function()
                obj.Delete(v.uuid)
            end
            
            v.GetPrice = function()
                return obj.GetPrice(v.uuid)
            end
            
            v.GetLastPrice = function()
                return obj.GetLastPrice(v.uuid)
            end
            
            v.AddPrice = function()
                obj.AddPrice(v.uuid)
            end
            
            --当前竞拍价
            v.value = v.start
            for _=1,v.count do
                v.value = v.value + math.ceil(v.start * config.auction.rise)
            end
            
            --创建索引
            for i=1,#index_type do
                table.insert(index[i], {index=k, [index_type[i]]=v[index_type[i]]})
            end
        end
        
        Sort()
    end
    
    --根据uuid获取位置
    local function GetPosition(uuid)
        return uuids[uuid]
    end
    
    --获取物品总数
    function obj.GetCount()
        return #this
    end
    
    --获取物品对象
    function obj.GetAuction(uuid)
        if uuids[uuid] then
            return this[ uuids[uuid] ]
        end
    end
    
    --添加数据
    function obj.Insert(auction)
        auction.value = auction.start
        auction.Delete = function()
            obj.Delete(auction.uuid)
        end
        
        auction.GetPrice = function()
            return obj.GetPrice(auction.uuid)
        end
        
        auction.GetLastPrice = function()
            return obj.GetLastPrice(auction.uuid)
        end
        
        auction.AddPrice = function()
            obj.AddPrice(auction.uuid)
        end
        
        data.ReadMoreProperty(auction)
        
        for i=1,#index_type do
            if #this==0 then
                table.insert(index[i], 1, {index=1, [index_type[i]]=auction[index_type[i]]})
            else
                if index[i][1][index_type[i]]>=auction[index_type[i]] then
                    table.insert(index[i], 1, {index=#this + 1, [index_type[i]]=auction[index_type[i]]})
                else
                    for k=#this,1,-1 do
                        if index[i][k][index_type[i]]<=auction[index_type[i]] then
                            table.insert(index[i], k + 1, {index=#this + 1, [index_type[i]]=auction[index_type[i]]})
                            break
                        end
                    end
                end
            end
        end
        
        table.insert(this, auction)
        GlobalInsertRow(C.ktAuction, {C.kfUUID, auction.uuid}, {C.kfSeller, auction.seller}, {C.kfStart, auction.start}, {C.kfPrice, auction.price}, {C.kfTime, auction.time})
        uuids[auction.uuid] = #this
        
        --推送添加物品
        local result = new('AuctionAppend')
        result.prop.id = auction.uuid
        result.prop.kind = auction.kind
        result.prop.start = auction.start
        result.prop.current = auction.value
        result.prop.price = auction.price
        result.prop.time = auction.time
        for player_id,_ in pairs(auction_wait) do
            if _.ready then GlobalSend2Gate(player_id, result, sizeof(result)) end
        end
    end
    
    --删除数据
    function obj.Delete(uuid)
        local position = GetPosition(uuid)
        if this[position] then
            --删除索引
            for i=1,#index_type do 
                local position_ = nil
                for k=1,#this do
                    if index[i][k].index==position then
                        position_ = k
                    elseif index[i][k].index>position then
                        index[i][k].index = index[i][k].index - 1
                    end
                end
                
                if position_ then
                    table.remove(index[i], position_)
                end
            end
            
            table.remove(this, position)
            data.DeleteAuction(uuid)
            
            --重建
            uuids = {}
            for k,v in ipairs(this) do
                uuids[v.uuid] = k
            end
            
            --推送物品删除
            local result = new('AuctionDelete')
            result.id = uuid
            for player_id,_ in pairs(auction_wait) do
                if _.ready then GlobalSend2Gate(player_id, result, sizeof(result)) end
            end
        end
    end
    
    --获取竞拍价
    function obj.GetPrice(uuid)
        local position = GetPosition(uuid)
        if this[position] then
            return this[position].value
        end
        return 0
    end
    
    --获取上次成交价格
    function obj.GetLastPrice(uuid)
        local position = GetPosition(uuid)
        if this[position] then
            local last_price = this[position].start
            for _=2,this[position].count do
                last_price = last_price + math.ceil(this[position].start * config.auction.rise)
            end
            return last_price
        end
        return 0
    end
    
    --增加竞拍价
    function obj.AddPrice(uuid)
        local position = GetPosition(uuid)
        if this[position] then
            this[position].value = this[position].value + math.ceil(this[position].start * config.auction.rise)
            this[position].count = this[position].count + 1
            this[position].time = this[position].time + config.auction.delay

            --竞拍价索引
            for i=1,#this do
                if index[1][i].index==position then
                    index[1][i].value = this[position].value
                    table.sort(index[1], function(a,b) return a.value<b.value end)
                    break
                end
            end
            
            --时间索引
            for i=1,#this do
                if index[3][i].index==position then
                    index[3][i].time = this[position].time
                    table.sort(index[3], function(a,b) return a.time<b.time end)
                    break
                end
            end
            
            --推送价格改变
            local result = new('AuctionPriceChange')
            result.id = uuid
            result.current = this[position].GetPrice()
            result.time = this[position].time
            for player_id,_ in pairs(auction_wait) do
                if _.ready then GlobalSend2Gate(player_id, result, sizeof(result)) end
            end
        end
    end

    --获取数据
    function obj.GetList(sort, order, begin, ending)
        local result = {}
        
        ending = math.min(ending, #this)
        
        for i=begin,ending do
            if order==1 then
                result[#result + 1] = this[index[sort][i].index]
            else
                result[#result + 1] = this[index[sort][#this - i + 1].index]
            end
        end

        return result
    end

    --创建过滤器
    function obj.CreateFilter(kind, type, level, quality, additions)
        local filter = {}
        
        for _,v in ipairs(this) do
            --物品种类 kind
            if prop_cfgs[v.kind].type==kind then
                --类型
                if type==0 or prop_cfgs[v.kind].sub_type==type then
                    --等级
                    if level==0 or prop_cfgs[v.kind].required_level==level then
                        --品质
                        if quality==0 or prop_cfgs[v.kind].quality==quality then
                            --装备属性
                            if not next(additions) or (kind==1 and (not additions[1] or v.strength~=0) and (not additions[2] or v.agility~=0) and (not additions[3] or v.intelligence~=0) and (not additions[4] or prop_cfgs[v.kind].additional_property["crit"]) ) then
                                table.insert(filter, v)
                            end
                        end
                    end
                end
            end
        end

        return CreateAuctionData(filter)
    end

    --初始化
    Init()

    return obj
end

function GetAuctionWait()
    return auction_wait
end