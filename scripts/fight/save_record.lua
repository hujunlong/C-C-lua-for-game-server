--保存战报
local ffi = require('ffi')
local C = ffi.C
local sizeof = ffi.sizeof
local new = ffi.new
local cast = ffi.cast
local copy = ffi.copy

require('data')
require('global_data')

local battle_sequence = data.GetBattleSequence()

function SaveBattleRecord(record, record_len)
    battle_sequence = battle_sequence + 1
    local BattleRecord = new('InsertBattleRecord', battle_sequence, record_len)
    copy(BattleRecord.str, record, record_len)
    GlobalSend2Db( BattleRecord, 8 + record_len )
    return battle_sequence
end
