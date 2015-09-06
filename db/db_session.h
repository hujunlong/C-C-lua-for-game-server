#pragma once
#include <mysql++.h>
#include "../protocol/db.h"
#include "../protocol/game_def.h"
#include "../protocol/town.h"
#include "../protocol/internal.h"
//#include "../protocol/db_game.h"

class DbSession
{
public:
	bool Init(const char* cfg_file);
public:
	//interact
	bool GetUserInfo(_User& info, const UserID uid);
	bool GetUserInfo(_User& info, const Nickname& name);

	bool DecideHosRelation( UserID uid, UserID other_uid, bool& bHosRelation);

	bool GetAssociatedUsers(const UserID uid, p::AssociatedUsersListResult& ass_users, const UsersListType type);

	bool AddFriend(const db::AddFriend& add);

	bool RemoveFriend(const db::RemoveFriend& remove);

	bool AddFoe(const db::AddFoe& add);

	bool RemoveFoe(const db::RemoveFoe& remove);

	bool DeleteExpiredMail(UserID uid);
	bool SendMail(UserID uid,db::PlayerSendMail& send_mail,db::SendMailResult& result);
	bool GetMailsList(UserID uid, p::MailsListResult& mails_list, p::GetMailsList& get_list);
	bool GetMailNums(UserID uid, p::MailNumsResult& nums);
	bool GetMail(UserID uid, p::MailResult& mail, const p::GetMail& get_mail);
	bool GetMailAttachments(UserID uid, MailAttachments& mas, const p::ExtractAttachment& ea);
	bool DeleteMail(UserID uid, const p::DeleteMail& del_mail);
//general
	bool Excute(UserID player, const ExcuteSqlDirectly& sql_query);
	bool Excute(UserID player, const InsertRow& insert_row);
	bool Excute(const InsertRow2& insert_row2);
	bool Excute(UserID player, const UpdateField& update_field);
	bool Excute(const UpdateField2& update_field2);
	bool Excute(UserID player, const UpdateFieldConditionally& update);
	bool Excute(const UpdateDeltaField& update_delta_field);
	bool Excute(UserID player, const DeleteRow& delete_row);
	bool Excute(UserID player, const UpdateStringField& update_string_filed);
	bool Excute(const UpdateStringField2& update_string_filed2);
	bool Excute(const UpdateBinaryStringField& update_binary_string_filed);
	bool Excute(const UpdateMultiFeilds2Value& update);
	bool Excute(const ReplaceIconBin& replace_icon_bin);
	bool Excute(const GuildApplication& update);
	bool Excute(const  GuildWarFiles& update); 
	bool Excute(UserID player, const UpdateFieldWithSubIndex& update);
	bool Excute(UserID player, const UpdateDeltaFieldWithSubIndex& update);
	bool Excute(const InsertBattleRecord& battle_record );

	bool InsertGuildInfo(const InsertGuild& guild);
	bool DeleteGuildInfo(const DeleteGuild& guild);
	bool InsertNewGuildGradeInfo(const InsertNewGuildGrade& guild_grade);
	bool LeaveGuild(const MemberLeaveGuild& leave_guild);
	bool JoinGuild(const MemberJoinGuild& join_guild);
	bool UpdateWarFieldGuildInfo(const UpdateWarFieldGuild& guild);

//main line
	bool GetPlayerBossKillingTimes(UserID player, BossesKillingTimes& times);

// escort
	bool GetPlayerEscortInfo(UserID player, EscortInfo& info);
	bool GetPlayerEscortReward(UserID player, EscortRewardList& reward);
	bool GetPlayerEscortRobbed(UserID player, EscortRobbedList& robbed);
	//bool GetPlayerEscortRoad(UserID player, EscortRoad& road);

//arena
	bool GetPlayerArenaInfo(UserID player, ArenaInfo& info);
	bool GetPlayerArenaHistory(UserID player, ArenaHistoryList& history);
	bool GetPlayerArenaChallenge(UserID player, ArenaChallengeList& challenge);

//rune
	bool GetPlayerRuneStatus(UserID player, RuneStatus& status);
	bool GetPlayerRuneInfoStove(UserID player, RuneInfoStoveList& info);
	bool GetPlayerRuneInfoBag(UserID player, RuneInfoBagList& info);
	bool GetPlayerRuneInfoHero(UserID player, RuneInfoHeroList& info);
//grade
	bool GetPlayerGradeInfo(UserID player, GradeInfo& info);
//msic

	bool GetPlayerAuctionInfo(UserID player, AuctionInfoList& info);

	bool QueryFightRecord(uint32_t id, QueryFightRecordResult& FightRecordResult);
	//bool GetPlayerWorldWarInfo(UserID player, WorldWarInfo& info);

	bool GetPlayerClientConfig(UserID player, ClientConfig& config);
	bool GetVIPCount(UserID player, VIPCount& vip_count);
	bool GetStageAward(UserID player, StageAward& stage_award);

//town
	bool GetAllTownItems(UserID uid, std::vector<FunctionBuildingStatus>& fbs, std::vector<BusinessBuildingStatus>& bbs, std::vector<DecorationStatus>&ds, std::vector<RoadStatus>& rs);
	bool GetAllBuildingStatus(UserID uid, FunctionBuildingStatus fbs[], size_t& count);
	bool GetAllBuildingStatus(UserID uid, BusinessBuildingStatus bbs[], size_t& count);
	bool GetAllBuildingStatus(UserID uid, DecorationStatus ds[], size_t& count);
	bool GetAllBuildingStatus(UserID uid, RoadStatus rs[], size_t& count);

	bool GetTownBlocks(UserID player, TownBlocks& town_blocks);
	bool SaveTownBlocks(UserID player, const TownBlocks& town_blocks);

	bool GetTownWarehouse(UserID player, TownWarehouse& tw);

//game common
	bool GetPlayerBasicInfo(UserID uid, PlayerBaseInfo& info);

	bool GetAllHeros(UserID uid, Hero heros[], size_t& count);

	bool GetAllProps(UserID player, PropFromDb props[], size_t& count);

	bool GetAllEquipment(UserID player, EquipmentFromDb euips[], size_t& count);

	bool GetPropSetting(UserID player, PropSetting& setting);

	bool GetFormulas(UserID player, MyFormulas& formulas);

	bool GetSectionScores(UserID player, SectionScores& scores);

	bool GetSkills(UserID player, Skills& skills);

	bool GetPlayerStatus(UserID player, PlayerStatus& status);

	bool GetAllArrays(UserID player, Arrays& arrays);

	bool GetAccomplishedAchievement(UserID player, AccomplishedAchievements& achievements);

	bool GetActions(UserID player, Actions& actions);

	bool GetAuctionOfflineList( UserID player, AuctionOfflineList& auction_offline );

	bool GetLoadBuffers(UserID player, LordBuffers& buffers);

	bool GetHeroTrainInfo(UserID player, TrainNum& buffers);

	bool GetTowerInfo(UserID player, TowerInfo& tower_info);
	
	bool GetTerritoryOffline(UserID player, TerritoryOffline& territory_offline);
//task 
	bool GetAccomplishBranchTask(UserID player, AccomplishedBranchTasks& tasks);

//playground
	bool GetFishInfo(UserID player, FishInfo& fish_info);

	bool GetPlayGroundRaceInfo( UserID player, PlayGroundRaceInfoResult& race_info);

	bool GetPlayGroundDragonInfo( UserID player, PlayGroundDragonInfoResult& dragon_info);

	bool GetTurntableInfo( UserID player, InternalTurntableInfo& info);

	bool GetPlaygroundInfo( UserID player, InternalPlaygroundInfo& pg_info);

	bool GetPlaygroundProps( UserID player, InternalPlaygroundProps& pg_props);

	bool GetAssistantInfo( UserID player, InternalAssistantInfo& ass_info);

	bool GetTreeInfo( UserID player, InternalTreeInfo& tree_info);

	bool GetRewardForDaysAgoInfo( UserID player, InternalRewardDaysAgoInfo& days_ago_info);

	bool GetSaveWebsiteInfo(UserID player, InternalSaveWebsiteInfo& sw_info);

	bool GetLuckyDrawInfo(UserID player, InternalLuckyDrawInfo& ld_info);

	bool GetCheckInEveryDayInfo(UserID player, InternalCheckInEveryDayInfo& cied_info);

	bool GetCheckInAccumulateInfo(UserID player, InternalCheckInAccumulateInfo& cia_info);
private:
	bool GetAllEquipmentGems(UserID player, const size_t max_count, EquipmentGemFromDb[], size_t& count);
private:
	mysqlpp::Connection conection_;
};

