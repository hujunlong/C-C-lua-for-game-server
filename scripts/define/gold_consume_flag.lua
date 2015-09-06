local cfg = {
--[[
	energy=1, --购买能量
	mobility=2, --购买行动力
	building=3, --购买建筑物
	silver=4, -- 炼金术，购买银币
	auction=5, --拍卖行
	hero=6, --训练和培养系统
	dragon=7, --龙
	runner=8, --转盘
	props=9, --道具
	world_boss=10, --世界boss
	arena=11, --竞技场
	guild=12, --工会
	assistant=13, --小助手
	rune=14, --宝具
]]
	energy=1, --购买能量
	mobility=2, --购买行动力
	alchemy=3, --使用炼金术
	
	hero_evolve = 8800; --英雄进化
	hero_bringup1 = 8801;    --普通培养
	hero_bringup2 = 8802;    --加强培养
	hero_bringup3 = 8803;    --黄金培养
	hero_bringup4 = 8804;    --白金培养
	arena_clear_cd = 8900;  --清除竞技场CD
	arena_buy_count = 8901;  --购买竞技场次数
	escort_refresh = 9000;  --刷新护送交通工具
	escort_clear_cd = 9001;  --清除护送打劫CD
	rune_gold_activation = 9100;    --宝具系统直接激活赤金
	territory_clear_cd = 9200;    --领地清除CD
	tower_refresh = 9300;  --刷新试练塔
	world_boss_clear_cd = 9400;  --清除世界BOSS CD
	world_boss_phoenix_nirvana = 9401;  --世界BOSS 不死鸟复活
	world_war_clear_cd = 9500;  --清除国战CD
	branch_task_receive_series_task = 2001,  --接系列支线任务的下一个
	branch_task_refresh_task = 2002, --刷新支线任务
	boss_section_second_killing = 2101, --精英boss二次击杀
    
    gold_coins_training = 9600; --金币训练
    intensive_training = 9601;--强化训练
    buy_traing_num = 9602;--购买训练次数
    guild_war_donate = 9700; --公会战领地捐赠
    guild_war_buy_buff = 9701;--公会战购买战场buff
    guild_war_buy_harm = 9702;--公会战购买伤害
    guild_upgrade_monogram_box = 9703;--升级会标框
    guild_upgrade_icon = 9704;--上传会标
    guild_resert_talent = 9705;--重置天赋加点
    town_buy_material = 9800; --购买城建合成材料
	
	fish_gold_rod = 6000,		--使用黄金鱼杆钓鱼
	fish_torpedo = 6001,		--使用鱼雷
	assistant_retrieve = 6002,	--小助手找回任务
	explore_back_to_town_clear_cd = 6003,	--清除回城cd
	explore_replenish_stamina_clear_cd = 6004,	--清除体力恢复cd
	playground_buy_prop = 6005,	--游乐场购买道具
	rear_dragon_change_name = 6006,	--育龙改名
	rear_dragon_mate_time_reset = 6007, --育龙交配时间重置
	tree_buy_god_water = 6008,		--幸运树购买神水
	turntable_return = 6009,		--转轮重转
	prop_active_hole = 6010,		--装备开孔
	prop_compound_gem = 6011,		--宝石直接合成
	prop_compound_equip = 6012,		--装备直接合成
	prop_unlock_bag_grid = 6013,	--解锁背包格子
	prop_unlock_warehouse_grid = 6014,	--解锁仓库格子
	lucky_draw_lottery = 6015, 	--抽奖消费
}


return cfg