#include "msg_process.h"
#include "db_session.h"
#include "../tools/msg_helper.h"
#include "../protocol/game_def.h"
#include "../protocol/common.h"
#include "../protocol/town.h"
#include <boost/progress.hpp>



namespace
{
	DbSession g_db;
	MQNode g_mq_world;
	MQNode g_mq_interact;
}

MQNode& CreateMQ4World( const char* apAddress )
{
	g_mq_world.Init(NodeType::kServer, apAddress);
	return g_mq_world;
}

MQNode& CreateMQ4Interact( const char* apAddress )
{
	g_mq_interact.Init(NodeType::kServer, apAddress);
	return g_mq_interact;
}

bool InitProcessor()
{
	return g_db.Init("db_cfg.lua");
}


bool DoUserEnterInteract( MqHead& head )
{
	#define If if
	UserID uid = head.aid;
	p::AssociatedUsersListResult associates;
	db::UserInfo userinfo;
	If (g_db.GetUserInfo(userinfo.user, uid))
	{
		userinfo.user.role.online = Role::OnlineStatus::kOnline;
		g_mq_interact.Send(head, userinfo);
	}
	If (g_db.GetAssociatedUsers(uid, associates, UsersListType::kFriend))
	{
		g_mq_interact.Send(head, associates);
	}

	If (g_db.GetAssociatedUsers(uid, associates, UsersListType::kFoe))
	{
		g_mq_interact.Send(head, associates);
	}
// 	If (g_db.GetAssociatedUsers(uid, associates, UsersListType::kAlly))
// 	{
// 		g_mq_interact.Send(head, associates);
// 	}
	return true;
}
bool DoGetUserInfo(MqHead& head, p::GetUserInfoByName& get)
{
	db::UserInfoResult info;
	info.type = get.type;
	If( g_db.GetUserInfo( info.user, get.name) )
	{
		info.user.role.online = Role::OnlineStatus::kOffline;
	}else
	{
		info.user.role.uid = 0;
	}
	g_mq_interact.Send(head, info);
	return true;
}

bool DoAddFriend(MqHead& head, const db::AddFriend& add )
{
	db::AddFriendInfo info;
	If( add.uid == 0 )
	{
		g_db.GetUserInfo(info.user, add.friend_id);
		info.user.role.online = Role::OnlineStatus::kOffline;
		g_mq_interact.Send(head, info);
	}else
	{
		g_db.AddFriend(add);
	}
	return true;
}

bool DoRemoveFriend( const db::RemoveFriend& remove )
{
	return g_db.RemoveFriend(remove);
}

bool DoAddFoe(MqHead& head, const db::AddFoe& add )
{
	db::AddFoeInfo info;
	If( add.uid == 0 )
	{
		g_db.GetUserInfo(info.user, add.foe_id);
		info.user.role.online = Role::OnlineStatus::kOffline;
		g_mq_interact.Send(head, info);
	}else
	{
		g_db.AddFoe(add);
	}
	return true;
}

bool DoRemoveFoe( const db::RemoveFoe& remove )
{
	return g_db.RemoveFoe(remove);
}

bool DoSendMail(MqHead& head, db::PlayerSendMail& send_mail)
{
	db::SendMailResult result;
	UserID rec_uid = send_mail.receiver.role.uid;
	If( rec_uid == 0 || send_mail.bHosRelUnknow )
	{
		If( rec_uid == 0)
			g_db.GetUserInfo( send_mail.receiver, send_mail.mail.receiver_uid);
		If( send_mail.receiver.role.uid != 0)
		{
			If( send_mail.bHosRelUnknow )
			{
				send_mail.bHosRelUnknow = false;
				g_db.DecideHosRelation( rec_uid, head.aid, send_mail.bIsFoe );
			}
		}
		g_mq_interact.Send(head, send_mail);
	}else
	{
		g_db.SendMail(head.aid, send_mail, result);
		g_mq_interact.Send(head, result);
	}
	return true;
}

bool DoGetMailsList(MqHead& head, p::GetMailsList& get_list)
{
	p::MailsListResult mails_list;
	memset(&mails_list,0,sizeof(p::MailsListResult));
	g_db.GetMailsList(head.aid, mails_list, get_list);
	mails_list.result = eSucceeded;
	g_mq_interact.Send( head.aid, mails_list.kType, head.flag,mails_list,8+mails_list.len*sizeof(p::MailsListResult::MailInfo));
	return true;
}

bool DoGetMailNums(MqHead& head)
{
	p::MailNumsResult result;
	result.mailnums = 0;
	g_db.GetMailNums(head.aid, result);
	g_mq_interact.Send(head, result);
	return true;
}

bool DoGetMail(MqHead& head, p::GetMail& get_mail)
{
	p::MailResult mail;
	memset(&mail, 0, sizeof(p::MailResult));
	g_db.GetMail(head.aid, mail, get_mail);
	uint32_t s_size = (uint32_t)((char*)(&mail.content) - (char*)(&mail)) + (uint32_t)mail.len;
	g_mq_interact.Send(head.aid,mail.kType,head.flag,mail,s_size);
	return true;
}

bool DoDeleteMail(MqHead& head, p::DeleteMail& del_mails)
{
	p::DeleteMailResult result;
	If( g_db.DeleteMail(head.aid, (const p::DeleteMail&)del_mails) )
		result.result = eSucceeded;
	else
		result.result = eDeleteMailFailed;
	g_mq_interact.Send(head, result);
	return true;
}

bool DoQueryFightRecord(MqHead& head, uint32_t id)
{
	QueryFightRecordResult FightRecordResult;
	g_db.QueryFightRecord(id, FightRecordResult);

	FightRecordResult.flag = head.flag;
	g_mq_world.Send(head, FightRecordResult);
	return true;
}

namespace
{
	template<typename List>
	void SendList(MQNode& mq, MqHead& head, const List& list, size_t count)
	{
		for (const auto& item: list)
		{
			If (count--)
			{
				mq.Send(head, item);
			}
			else
			{
				break;
			}
		}
	}
}


bool DoUserEnterWorld( MqHead& head)
{
	
	boost::progress_timer pt;

	UserID uid = head.aid;

	PlayerBaseInfo base_info;
	If (!g_db.GetPlayerBasicInfo(uid, base_info)) return false;

	g_mq_world.Send(head, base_info);

	{
		size_t count = 0;
		FunctionBuildingStatus fbs[kMaxFunctionBuildings];
		If (g_db.GetAllBuildingStatus(uid, fbs, count))
		{
			SendList(g_mq_world, head, fbs, count);
		}
		BusinessBuildingStatus bbs[kMaxBusinessBuildings];
		If (g_db.GetAllBuildingStatus(uid, bbs, count))
		{
			SendList(g_mq_world, head, bbs, count);
		}
		DecorationStatus ds[kMaxDecorations];
		If (g_db.GetAllBuildingStatus(uid, ds, count))
		{
			SendList(g_mq_world, head, ds, count);
		}
		RoadStatus rs[kMaxRoads];
		If (g_db.GetAllBuildingStatus(uid, rs, count))
		{
			SendList(g_mq_world, head, rs, count);
		}
	} //防止堆栈溢出

	TownBlocks town_blocks;
	If (g_db.GetTownBlocks(uid, town_blocks))
	{
		g_mq_world.Send(head, town_blocks);
	}

	TownWarehouse tw;
	If (g_db.GetTownWarehouse(uid, tw))
	{
		g_mq_world.Send(head, tw);
	}

	PlayerStatus status;
	If (g_db.GetPlayerStatus(uid, status))
	{
		g_mq_world.Send(head, status);
	}

	Hero heros[256];
	size_t hero_count = 0;
	If (g_db.GetAllHeros(uid, heros, hero_count))
	{
		for (size_t i=0; i<hero_count; ++i)
		{
			g_mq_world.Send(head, heros[i]);
		}
	}

	PropSetting prop_setting;
	If (g_db.GetPropSetting(uid, prop_setting))
	{
		g_mq_world.Send(head, prop_setting);
	}

{
	PropFromDb props[2048];
	size_t prop_count = 0;
	If (g_db.GetAllProps(uid, props, prop_count))
	{
		for (size_t i=0; i<prop_count; ++i)
		{
			g_mq_world.Send(head, props[i]);
		}
	}

	EquipmentFromDb equips[2048];
	size_t equiq_count = 0;
	If (g_db.GetAllEquipment(uid, equips, equiq_count))
	{
		for (size_t i=0; i<equiq_count; ++i)
		{
			g_mq_world.Send(head, equips[i]);
		}
	}
}
	MyFormulas formalus;
	If (g_db.GetFormulas(uid, formalus))
	{
		g_mq_world.Send(head, formalus);
	}

	SectionScores scores;
	If (g_db.GetSectionScores(uid, scores))
	{
		g_mq_world.Send(head, scores);
	}

	Skills skills;
	If (g_db.GetSkills(uid, skills))
	{
		g_mq_world.Send(head, skills);
	}

	//已移动到GetAllHeros前面,方便算英雄离线训练经验时读取下线时间 测试期
	//PlayerStatus status;
	//If (g_db.GetPlayerStatus(uid, status))
	//{
	//	g_mq_world.Send(head, status);
	//}

	AuctionInfoList auction_info;
	If (g_db.GetPlayerAuctionInfo(uid, auction_info))
	{
		g_mq_world.Send(head, auction_info);
	}

	EscortInfo escort_info;
	If (g_db.GetPlayerEscortInfo(uid, escort_info))
	{
		g_mq_world.Send(head, escort_info);
	}
	/*
	EscortRoad escort_road;
	If (g_db.GetPlayerEscortRoad(uid, escort_road))
	{
		g_mq_world.Send(head, escort_road);
	}
	*/
	ClientConfig config;
	If (g_db.GetPlayerClientConfig(uid, config))
	{
		g_mq_world.Send(head, config);
	}

	EscortRewardList escort_reward;
	If (g_db.GetPlayerEscortReward(uid, escort_reward))
	{
		g_mq_world.Send(head, escort_reward);
	}

	EscortRobbedList escort_robbed;
	If (g_db.GetPlayerEscortRobbed(uid, escort_robbed))
	{
		g_mq_world.Send(head, escort_robbed);
	}

	ArenaInfo arena_info;
	If (g_db.GetPlayerArenaInfo(uid, arena_info))
	{
		g_mq_world.Send(head, arena_info);
	}

	ArenaHistoryList arena_history;
	If (g_db.GetPlayerArenaHistory(uid, arena_history))
	{
		g_mq_world.Send(head, arena_history);
	}

	ArenaChallengeList arena_challenge;
	If (g_db.GetPlayerArenaChallenge(uid, arena_challenge))
	{
		g_mq_world.Send(head, arena_challenge);
	}

	RuneStatus rune_status;
	If (g_db.GetPlayerRuneStatus(uid, rune_status))
	{
		g_mq_world.Send(head, rune_status);
	}

	RuneInfoStoveList rune_info_stove;
	If (g_db.GetPlayerRuneInfoStove(uid, rune_info_stove))
	{
		g_mq_world.Send(head, rune_info_stove);
	}

	RuneInfoBagList rune_info_bag;
	If (g_db.GetPlayerRuneInfoBag(uid, rune_info_bag))
	{
		g_mq_world.Send(head, rune_info_bag);
	}

	RuneInfoHeroList rune_info_list;
	If (g_db.GetPlayerRuneInfoHero(uid, rune_info_list))
	{
		g_mq_world.Send(head, rune_info_list);
	}

	GradeInfo grade_info;
	If (g_db.GetPlayerGradeInfo(uid, grade_info))
	{
		g_mq_world.Send(head, grade_info);
	}

	Arrays arrays;
	If (g_db.GetAllArrays(uid, arrays))
	{
		g_mq_world.Send(head, arrays);
	}

	FishInfo fish_info;
	If(g_db.GetFishInfo(uid, fish_info))
	{
		g_mq_world.Send(head, fish_info);
	}

	AccomplishedAchievements achivements;
	If (g_db.GetAccomplishedAchievement(uid, achivements))
	{
		g_mq_world.Send(head, achivements);
	}

	Actions actions;
	If (g_db.GetActions(uid, actions))
	{
		g_mq_world.Send(head, actions);
	}

	PlayGroundRaceInfoResult race_info;
	If (g_db.GetPlayGroundRaceInfo(uid, race_info))
	{
		g_mq_world.Send(head, race_info);
	}

	PlayGroundDragonInfoResult dragon_info;
	If (g_db.GetPlayGroundDragonInfo(uid, dragon_info))
	{
		g_mq_world.Send(head, dragon_info);
	}

	InternalTurntableInfo turntable_info;
	If( g_db.GetTurntableInfo(uid, turntable_info))
	{
		g_mq_world.Send(head, turntable_info);
	}
	
	InternalPlaygroundInfo pg_info;
	If( g_db.GetPlaygroundInfo(uid, pg_info))
	{
		g_mq_world.Send(head, pg_info);
	}

	InternalPlaygroundProps pg_props;
	If( g_db.GetPlaygroundProps(uid,pg_props) )
	{
		g_mq_world.Send(head, pg_props);
	}

	VIPCount vip_count;
	If( g_db.GetVIPCount(uid, vip_count) )
	{
		g_mq_world.Send(head, vip_count);
	}

	InternalAssistantInfo ass_info;
	If( g_db.GetAssistantInfo(uid, ass_info) )
	{
		g_mq_world.Send(head, ass_info);
	}

	InternalTreeInfo tree_info;
	If( g_db.GetTreeInfo(uid, tree_info) )
	{
		g_mq_world.Send(head, tree_info);
	}

	AuctionOfflineList auction_offline;
	If( g_db.GetAuctionOfflineList(uid, auction_offline) )
	{
		g_mq_world.Send(head, auction_offline);
	}
	/*
	WorldWarInfo world_war_info;
	If (g_db.GetPlayerWorldWarInfo(uid, world_war_info))
	{
		g_mq_world.Send(head, world_war_info);
	}
	*/

	LordBuffers lord_buffers;
	If (g_db.GetLoadBuffers(uid, lord_buffers))
	{
		g_mq_world.Send(head, lord_buffers);
	}

	AccomplishedBranchTasks branch_tasks;
	If (g_db.GetAccomplishBranchTask(uid, branch_tasks))
	{
		g_mq_world.Send(head, branch_tasks);
	}

	BossesKillingTimes bosses_killing_times;
	If (g_db.GetPlayerBossKillingTimes(uid, bosses_killing_times))
	{
		g_mq_world.Send(head, bosses_killing_times);
	}

	TrainNum train_num;
	If (g_db.GetHeroTrainInfo(uid, train_num))
	{
		g_mq_world.Send(head, train_num);
	}

	TowerInfo tower_info;
	If (g_db.GetTowerInfo(uid, tower_info))
	{
		g_mq_world.Send(head, tower_info);
	}

	TerritoryOffline territory_offline;
	If (g_db.GetTerritoryOffline(uid, territory_offline))
	{
		g_mq_world.Send(head, territory_offline);
	}

	InternalRewardDaysAgoInfo days_ago_info;
	If (g_db.GetRewardForDaysAgoInfo(uid, days_ago_info))
	{
		g_mq_world.Send(head, days_ago_info);
	}

	InternalSaveWebsiteInfo sw_info;
	If (g_db.GetSaveWebsiteInfo(uid, sw_info))
	{
		g_mq_world.Send(head, sw_info);
	}
	
	StageAward stage_award;
	If (g_db.GetStageAward(uid, stage_award))
	{
		g_mq_world.Send(head, stage_award);
	}
	
	InternalLuckyDrawInfo ld_info;
	If (g_db.GetLuckyDrawInfo(uid, ld_info))
	{
		g_mq_world.Send(head, ld_info);
	}

	InternalCheckInEveryDayInfo cied_info;
	If (g_db.GetCheckInEveryDayInfo(uid, cied_info))
	{
		g_mq_world.Send(head, cied_info);
	}

	InternalCheckInAccumulateInfo cia_info;
	If (g_db.GetCheckInAccumulateInfo(uid, cia_info))
	{
		g_mq_world.Send(head, cia_info);
	}
	g_mq_world.Send(head, UserEnterSucceeded());
	return true;
}

//bool DoSqlQuery(UserID uid, const SqlQuery& query)
//{
//	return g_db.Excute(uid, query);
//}

bool DoInsertRow( UserID uid, const InsertRow& insert_row )
{
	return g_db.Excute(uid, insert_row);
}

bool DoInsertRow2(const InsertRow2& insert_row2 )
{
	return g_db.Excute(insert_row2);
}

bool DoInsertBattleRecord(const InsertBattleRecord& battle_record)
{
	return g_db.Excute(battle_record);
}


bool DoUpdateField( UserID uid, const UpdateField& update_field )
{
	return g_db.Excute(uid, update_field);
}

bool DoUpdateField2(const UpdateField2& update_field2)
{
	return g_db.Excute(update_field2);
}

bool DoUpdateDeltaField(const UpdateDeltaField& update_delta_field)
{
	return g_db.Excute(update_delta_field);
}

bool DoDeleteRow( UserID uid, const DeleteRow& delete_row )
{
	return g_db.Excute(uid, delete_row);
}

bool DoSaveTownBlocks( UserID uid, const TownBlocks& town_blocks )
{
	return g_db.SaveTownBlocks(uid, town_blocks);
}

bool DoUpdateStringField( UserID uid, const UpdateStringField& update )
{
	return g_db.Excute(uid, update);
}

bool DoUpdateStringField2( const UpdateStringField2& update2 )
{
	return g_db.Excute(update2);
}

bool DoUpdateBinaryStringField( const UpdateBinaryStringField& update )
{
	return g_db.Excute(update);
}

bool DoGuildApplication(const GuildApplication&update)
{
	return g_db.Excute(update);
}

bool DoGuildWarFiles(const GuildWarFiles&update)
{
	return g_db.Excute(update);
}

bool DoReplaceIconBin( const ReplaceIconBin& update )
{
	return g_db.Excute(update);
}

bool DoUpdateFieldWithSubIndex( int32_t aid, const UpdateFieldWithSubIndex& update )
{
	return g_db.Excute(aid, update);
}

bool DoUpdateDeltaFieldWithSubIndex( int32_t aid, const UpdateDeltaFieldWithSubIndex& update )
{
	return g_db.Excute(aid, update);
}

bool DoInsertGuild(const InsertGuild& guild )
{
	return g_db.InsertGuildInfo(guild);
}

bool DoDeleteGuild(const DeleteGuild& guild )
{
	return g_db.DeleteGuildInfo(guild);
}

bool DoInsertNewGuildGrade(const InsertNewGuildGrade& guild_grade)
{
	return g_db.InsertNewGuildGradeInfo(guild_grade);
}

bool DoMemberLeaveGuild(const MemberLeaveGuild& leave_guild)
{
	return g_db.LeaveGuild(leave_guild);
}

bool DoMemberJoinGuild(const MemberJoinGuild& join_guild)
{
	return g_db.JoinGuild(join_guild);
}

bool DoUpdateWarFieldGuild(const UpdateWarFieldGuild& war_field_guild)
{
	return g_db.UpdateWarFieldGuildInfo(war_field_guild);
}

bool DoExcuteSqlDirectly( int32_t aid, const ExcuteSqlDirectly& sql )
{
	return g_db.Excute(aid, sql);
}

bool DoUpdateMultiFeilds2Value( const UpdateMultiFeilds2Value& update )
{
	return g_db.Excute(update);
}
