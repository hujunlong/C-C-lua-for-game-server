#pragma once
#include "../protocol/db.h"
#include "../protocol/internal.h"
#include "../protocol/town.h"
#include "../system/mq_node.h"

bool InitProcessor();
MQNode& CreateMQ4World(const char* apAddress);
MQNode& CreateMQ4Interact(const char* apAddress); 

bool DoUserEnterInteract( MqHead& head);

bool DoUserEnterWorld(MqHead& head);

bool DoAddFriend(MqHead& head, const db::AddFriend& add);

bool DoRemoveFriend(const db::RemoveFriend& remove);

bool DoAddFoe(MqHead& head, const db::AddFoe& add);

bool DoRemoveFoe(const db::RemoveFoe& remove);

bool DoGetUserInfo(MqHead& head, p::GetUserInfoByName& get);

bool DoSendMail(MqHead& head, db::PlayerSendMail& send_mail);
bool DoGetMailsList(MqHead& head, p::GetMailsList& get_list);
bool DoGetMailNums(MqHead& head);
bool DoGetMail(MqHead& head, p::GetMail& get_mail);
bool DoDeleteMail(MqHead& head, p::DeleteMail& del_mails);

bool DoQueryFightRecord(MqHead& head, uint32_t id);

//bool DoSqlQuery(UserID uid, const SqlQuery& query);

bool DoInsertRow(UserID uid, const InsertRow& insert_row);

bool DoInsertRow2(const InsertRow2& insert_row2);

bool DoInsertBattleRecord(const InsertBattleRecord& battle_record);

bool DoUpdateField(UserID uid, const UpdateField& update_field);

bool DoUpdateField2(const UpdateField2& update_field2);

bool DoUpdateDeltaField(const UpdateDeltaField& update_delta_field);

bool DoUpdateMultiFeilds2Value(const UpdateMultiFeilds2Value& update);

bool DoUpdateFieldWithSubIndex( int32_t aid, const UpdateFieldWithSubIndex& update );

bool DoUpdateDeltaFieldWithSubIndex(int32_t aid, const UpdateDeltaFieldWithSubIndex& update);

bool DoDeleteRow(UserID uid, const DeleteRow& delete_row);

bool DoUpdateStringField(UserID uid, const UpdateStringField& update);

bool DoUpdateStringField2(const UpdateStringField2& update2);

bool DoUpdateBinaryStringField(const UpdateBinaryStringField& update);

bool DoReplaceIconBin(const ReplaceIconBin& update);

bool DoGuildApplication(const GuildApplication&update);

bool DoGuildWarFiles(const GuildWarFiles&update);

bool DoSaveTownBlocks(UserID uid, const TownBlocks& town_blocks);

bool DoInsertGuild(const InsertGuild& guild );

bool DoDeleteGuild(const DeleteGuild& guild );

bool DoInsertNewGuildGrade(const InsertNewGuildGrade& guild_grade);

bool DoMemberLeaveGuild(const MemberLeaveGuild& leave_guild);

bool DoMemberJoinGuild(const MemberJoinGuild& join_guild);

bool DoUpdateWarFieldGuild(const UpdateWarFieldGuild& war_field_guild);

bool DoExcuteSqlDirectly( int32_t aid, const ExcuteSqlDirectly& sql );