#include "db_session.h"
#include "../system/db_helper.h"
#include "../tools/string.h"
#include <chrono>
#include <cstdlib>
#include <iostream>
#include <cassert>
#include "db_table.h"

using namespace std;

namespace
{
	void Row2Role( Role &info, const mysqlpp::Row& row )
	{
		info.nickname.len = row["nickname"].length();
		memcpy(info.nickname.str, row["nickname"].c_str(), sizeof(info.nickname.str));
		info.sex = (Role::Sex)(int16_t)row["sex"];
		info.uid = row["uid"];
	}

}



bool DbSession::Init( const char* cfg_file )
{
	return InitConnection(conection_, cfg_file);
}



bool DbSession::GetAssociatedUsers( const UserID uid, p::AssociatedUsersListResult& ass_users, const UsersListType type )
{
	char sql[256];
	switch (type)
	{
	case UsersListType::kFriend:
		sprintf(sql, "call GetFriends(%d);", uid);
		break;
	case UsersListType::kFoe:
		sprintf(sql, "call GetFoes(%d);", uid);
		break;
	case UsersListType::kObserver:
		sprintf(sql, "call GetObservers(%d);", uid);//上面2个都写了sql,这个没弄
		break;
	default:
		return false;
	}
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty() && res.size()<=UsersList::kMaxPersonsCount)
	{
		ass_users.list.type = type;
		ass_users.list.len = 0;
		for (const auto& row: res)
		{
			_User& user = ass_users.list.users[ass_users.list.len];
			user.role.uid = row["player"];
			user.role.nickname.len = row["nickname"].length();
			memcpy(user.role.nickname.str, row["nickname"].c_str(), sizeof(user.role.nickname.str));
			user.role.sex = row["sex"];
			user.role.online = Role::OnlineStatus::kOffline;//默认离线
			user.level = row["level"];
			user.country = row["country"];
			user.guild_id = row["guild_id"];
			++ass_users.list.len;
		}
		return true;
	}
	return false;
}

bool DbSession::DecideHosRelation( UserID uid, UserID other_uid, bool& bHosRelation)
{
	char sql[256];
	sprintf(sql, "select player from foe where player=%d and foe=%d limit 1;",uid, other_uid);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		bHosRelation = true;
	}else
		bHosRelation = false;
	return true;
}

bool DbSession::GetUserInfo( _User& info, const UserID uid )
{
	char sql[256];
	sprintf(sql, "select nickname,sex,country,level`,guild_id from base_info where player=%d;", uid);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		info.role.uid = uid;
		info.role.nickname.len = row["nickname"].length();
		memcpy(info.role.nickname.str, row["nickname"].c_str(), sizeof(info.role.nickname.str));
		info.role.sex = (Role::Sex)(int16_t)row["sex"];
		info.country = row["country"];
		info.level = row["level"];
		info.guild_id = row["guild_id"];
		return true;
	}else
	{
		info.role.uid = 0;
	}
	return false;
}

bool DbSession::GetUserInfo( _User& info, const Nickname& name )
{
	char sql[256];
	if( name.len<1 || name.len > sizeof(name.str) )
		return false;
	char tmpname[sizeof(name.str)*2+2];
	conection_.driver()->escape_string(tmpname, name.str, name.len);
	sprintf(sql, "select player,sex,country,`level`,guild_id from base_info where nickname=\"%s\";", tmpname);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		info.role.uid = row["player"];
		memcpy(&info.role.nickname, &name, sizeof(Nickname));
		info.role.sex = (Role::Sex)(int16_t)row["sex"];
		info.country = row["country"];
		info.level = row["level"];
		info.guild_id = row["guild_id"];
		return true;
	}else
	{
		info.role.uid = 0;
	}
	return false;
}

bool DbSession::AddFriend( const db::AddFriend& add )
{
	char sql[256];
	sprintf(sql, "insert into friend (player,friend) values (%d,%d)", add.uid, add.friend_id);
	return QueryWrite(conection_, sql);
}

bool DbSession::RemoveFriend( const db::RemoveFriend& remove )
{
	char sql[256];
	sprintf(sql, "delete from friend where player=%d and friend=%d", remove.uid, remove.friend_id);
	return QueryWrite(conection_, sql);
}

bool DbSession::AddFoe( const db::AddFoe& add )
{
	char sql[256];
	sprintf(sql, "insert into foe (player,foe) values (%d,%d)", add.uid, add.foe_id);
	return QueryWrite(conection_, sql);
}

bool DbSession::RemoveFoe( const db::RemoveFoe& remove )
{
	char sql[256];
	sprintf(sql, "delete from foe where player=%d and foe=%d", remove.uid, remove.foe_id);
	return QueryWrite(conection_, sql);
}

bool DbSession::DeleteExpiredMail(UserID uid)
{
	char sql[256];
	time_t t;
	t = time(NULL);
	sprintf(sql, "delete from mail where player=%d and time<%d", uid, (int32_t)t);
	return QueryWrite(conection_, sql);
}

bool DbSession::SendMail(UserID uid, db::PlayerSendMail& send_mail, db::SendMailResult& result)
{
	result.result_db = eSucceeded;
	result.rec_uid = send_mail.mail.receiver_uid;
	if( send_mail.mail.subject.len<1 || send_mail.mail.subject.len > sizeof(send_mail.mail.subject.str) || send_mail.mail.subject.str[0]==0
		|| send_mail.sender_name.len<1 || send_mail.sender_name.len > sizeof(send_mail.sender_name.str) || send_mail.sender_name.str[0]==0
		|| send_mail.mail.content.len<1 || send_mail.mail.content.len > sizeof(send_mail.mail.content.str) || send_mail.mail.content.str[0]==0 )
	{
		result.result_db = eInvalidValue;
		return false;
	}
	time_t tt;
	tt = time(NULL);
	char sql[1000];

	char tmp_nickname[sizeof(send_mail.sender_name.str)*2+2];
	conection_.driver()->escape_string(tmp_nickname,send_mail.sender_name.str,send_mail.sender_name.len);

	char tmp_subject[sizeof(send_mail.mail.subject.str)*2+2];
	conection_.driver()->escape_string(tmp_subject,send_mail.mail.subject.str,send_mail.mail.subject.len);

	char tmp_content[sizeof(send_mail.mail.content.str)*2+2];
	conection_.driver()->escape_string(tmp_content,send_mail.mail.content.str,send_mail.mail.content.len);

	sprintf(sql, "call SendMail(%d,%d,%d,%d,%d,\"%s\",\"%s\",\"%s\",0);",send_mail.receiver.role.uid,uid,(uint32_t)tt,
					p::MailsListResult::MailType::kPlayersMail,0,
				 tmp_nickname,tmp_subject,tmp_content);
	auto res = QueryRead(conection_, sql);//我需要一个结果,所以不能用Write
	if( res && !res.empty() )
	{
		int8_t ret = res[0]["result"];
		if( !ret )
		{
			//不把它放在第一次来临数据库的原因是: 有可能会有直接写入数据库的邮件
			result.result_db = eMailsOverFlowWithAttach;
			return false;
		}
	}
	return true;
}

bool DbSession::GetMailsList(UserID uid, p::MailsListResult& mails_list, p::GetMailsList& get_list)
{
	char sql[256];
	time_t tt = time(NULL);
	sprintf(sql, "call GetMailsList51(%d,%d)",uid, (uint32_t)tt);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		uint8_t mail_index = 0;
		mails_list.len = res.size();
		for( const auto& row: res)
		{
			mails_list.mailslist[mail_index].mail_id = row["mail_id"];
			mails_list.mailslist[mail_index].read = row["read"];
			mails_list.mailslist[mail_index].type = (p::MailsListResult::MailType)(int8_t)row["type"];
			mails_list.mailslist[mail_index].has_attachment = row["has_attach"];
			uint32_t ui_time = (uint32_t)row["time"]-(uint32_t)tt;
			if( (int32_t)ui_time<=0 )
				mails_list.mailslist[mail_index].remaintime = 0;
			else
				mails_list.mailslist[mail_index].remaintime = ui_time;
			mails_list.mailslist[mail_index].sender_uid = row["uid"];
			mails_list.mailslist[mail_index].sender.len = row["nickname"].length();
			memcpy(mails_list.mailslist[mail_index].sender.str,row["nickname"].c_str(),mails_list.mailslist[mail_index].sender.len);
			mails_list.mailslist[mail_index].title.len = row["subject"].length();
			memcpy(mails_list.mailslist[mail_index].title.str,row["subject"].c_str(),mails_list.mailslist[mail_index].title.len);
			++mail_index;
		}
		return true;
	}
	mails_list.len = 0;
	return false;
}

bool DbSession::GetMailNums(UserID uid, p::MailNumsResult& nums)
{
	char sql[256];
	time_t tt = time(NULL);
	sprintf(sql, "call GetMailNums(%d,%d)",uid, (uint32_t)tt);
	auto res = QueryRead(conection_, sql);
	if( res && res.size() )
	{
		nums.mailnums = (uint8_t)res[0]["count(*)"];
		return true;
	}
	return false;
}

bool DbSession::GetMail(UserID uid, p::MailResult& mail, const p::GetMail& get_mail)
{
	char sql[256];
	time_t tt = time(NULL);
	sprintf(sql, "call GetMail(%d,%d,%d)",uid, (uint32_t)tt,get_mail.mail_id);
	auto res = QueryRead(conection_, sql);
	if( res && res.size() )
	{
		auto& row = res[0];
		if( row["has_attach"] )
		{
			int len = row["attach"].length();
			memcpy(&mail.attachments, row["attach"].data(), len);
		}else
		{
			memset(&mail.attachments,0,10);
		}
		mail.len = (StringLength)(row["content"].length());
		memcpy(mail.content,row["content"].c_str(), mail.len);
		mail.result = eSucceeded;
		return true;
	}else
	{
		mail.result = eGetMailNotExist;
	}
	return false;
}

bool DbSession::GetMailAttachments(UserID uid, MailAttachments& mas, const p::ExtractAttachment& ea)
{
	char sql[256];
	time_t tt = time(NULL);
	sprintf(sql, "call GetMailAttachments(%d,%d,%d)",uid, (uint32_t)tt,ea.mail_id);
	auto res = QueryRead(conection_, sql);
	if( res && res.size() )
	{
		auto& row = res[0];
		int len = row["attach"].length();
		memcpy(&mas, row["attach"].data(), len);
		return true;
	}
	return false;
}

bool DbSession::DeleteMail(UserID uid, const p::DeleteMail& del_mail)
{
	char sql[256];
	sprintf(sql, "delete from mail where player=%d and mail_id=%d", uid, del_mail.mail_id);
	return QueryWrite(conection_, sql);
}

//bool DbSession::GetAllTownItems( UserID uid, std::vector<FunctionBuildingStatus>& fbs, std::vector<BusinessBuildingStatus>& bbs, std::vector<DecorationStatus>&ds, std::vector<RoadStatus>& rs)
//{
//	char sql[256];
//	sprintf(sql, "call GetAllTownItems(%d);", uid);
//	auto res = QueryReadMulti(conection_, sql);
//	if (res.size() == 4)
//	{
//		fbs.reserve(res[0].size());
//		for (const auto& row: res[0] ) //function buildings
//		{
//			FunctionBuildingStatus fb;
//			fb.id = row["id"];
//			fb.kind = row["kind"];
//			fb.x = row["x"];
//			fb.y = row["y"];
//			fb.aspect = row["aspect"];
//			fb.level = row["level"];
//			fb.progress = row["progress"];
//			mysqlpp::DateTime last_reap = row["last_reap"];
//			fb.last_reap = last_reap;
//			fbs.push_back(fb);
//		}
//
//		bbs.reserve(res[1].size());
//		for (const auto& row: res[1]) //business buildings
//		{
//			BusinessBuildingStatus bb;
//			bb.id = row["id"];
//			bb.kind = row["kind"];
//			bb.x = row["x"];
//			bb.y = row["y"];
//			bb.aspect = row["aspect"];
//			bb.warehoused = row["warehoused"];
//			bb.progress = row["progress"];
//			mysqlpp::DateTime last_reap = row["last_reap"];
//			bb.last_reap = last_reap;
//			bbs.push_back(bb);
//		}
//
//		ds.reserve(res[2].size());
//		for (const auto& row: res[2])  //decorations
//		{
//			DecorationStatus d;
//			d.id = row["id"];
//			d.kind = row["kind"];
//			d.x = row["x"];
//			d.y = row["y"];
//			d.aspect = row["aspect"];
//			d.warehoused = row["warehoused"];
//			ds.push_back(d);
//		}
//
//		rs.reserve(res[3].size());
//		for (const auto& row: res[3]) //roads
//		{
//			RoadStatus r;
//			r.id = row["id"];
//			r.kind = row["kind"];
//			r.x = row["x"];
//			r.y = row["y"];
//			r.aspect = row["aspect"];
//			r.warehoused = row["warehoused"];
//			rs.push_back(r);
//		}
//
//		return true;
//	}
//	return false;
//}

bool DbSession::GetPlayerBasicInfo( UserID uid, PlayerBaseInfo& info )
{
	char sql[256];
	sprintf(sql, "call GetPlayerBasicInfo(%d);", uid);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		info.role.uid = uid;
		info.role.online = false;
		info.role.nickname.len = row["nickname"].size();
		memcpy(info.role.nickname.str, row["nickname"], sizeof(info.role.nickname.str));
		info.role.sex = row["sex"];
		info.game_info.uid = uid;
		info.game_info.energy = row["energy"];
		info.game_info.feat = row["feat"];
		info.game_info.gold = row["gold"];
		info.game_info.level = row["level"];
		info.game_info.lord_experience = row["exp"];
		info.game_info.mobility = row["mobility"];
		info.game_info.prestige = row["prestige"];
		info.game_info.silver = row["silver"];
		info.game_info.country = row["country"];
		info.game_info.array = row[GetFieldName(kfArray)];
		info.game_info.progress = row[GetFieldName(kfProgress)];
		info.game_info.recharged_gold = row[GetFieldName(kfRechargedGold)];
		info.game_info.guild_id = row[GetFieldName(kfGuildId)];
		return true;
	}

	return false;
}

//bool DbSession::Excute(UserID player, const SqlQuery& sql_query)
//{
//	char sql[256]={0}
//	memcpy(sql,sql_query.query,sql_query.len);
//	return QueryWrite(conection_, sql);
//}

bool DbSession::Excute(UserID player,  const InsertRow& insert_row )
{
	auto table = insert_row.table;
	if (table == ktBaseInfo || table==ktPropSetting)
	{
		return false;
	}

	assert(insert_row.len <= sizeof(insert_row.fields)/sizeof(PerField));
	char field_names[256] = {'\0'};
	for (size_t i=0; i<insert_row.len; ++i)
	{
		strcat(field_names, GetFieldName(insert_row.fields[i].field));
		strcat(field_names, ",");
	}
	strcat(field_names, "player");

	char field_values[256] = {'\0'};
	char tmp_val[16];
	for (size_t i=0; i<insert_row.len; ++i)
	{
		sprintf(tmp_val, "%lld", insert_row.fields[i].val);
		strcat(field_values, tmp_val);
		strcat(field_values, ",");
	}
	sprintf(tmp_val, "%d", player);
	strcat(field_values, tmp_val);

	char sql[512];
	sprintf(sql, "insert into %s (%s) values (%s);", GetTableName(insert_row.table), field_names, field_values);
	return	QueryWrite(conection_, sql);
}

bool DbSession::Excute(const InsertRow2& insert_row2 )
{
	auto table = insert_row2.table;
	if (table == ktBaseInfo || table==ktPropSetting)
	{
		return false;
	}

	assert(insert_row2.len <= sizeof(insert_row2.fields)/sizeof(PerField));
	char field_names[256] = {'\0'};
	for (size_t i=0; i<insert_row2.len; ++i)
	{
		if (i!=0)
			strcat(field_names, ",");
		strcat(field_names, GetFieldName(insert_row2.fields[i].field));
	}

	char field_values[256] = {'\0'};
	char tmp_val[16];
	for (size_t i=0; i<insert_row2.len; ++i)
	{
		if (i!=0)
			strcat(field_values, ",");
		sprintf(tmp_val, "%lld", insert_row2.fields[i].val);
		strcat(field_values, tmp_val);
	}

	char sql[512];
	sprintf(sql, "insert into %s (%s) values (%s);", GetTableName(insert_row2.table), field_names, field_values);
	return	QueryWrite(conection_, sql);
}

bool DbSession::Excute(const InsertBattleRecord& battle_record )
{
	char hex_str[kMaxFightRecordLength*3 + 20];
	Binary2HexString(battle_record.str, battle_record.len, hex_str, sizeof(hex_str));

	char sql[kMaxFightRecordLength*3 + 200];
	sprintf(sql, "insert into battle_record (`id`, `record`) values (%u, %s);", battle_record.id, hex_str);
	return QueryWrite(conection_, sql);
}

bool DbSession::Excute(UserID player,  const UpdateField& update_field )
{
	char kv_str[256] = {'\0'};
	for (size_t i=0; i<update_field.len; ++i)
	{
		char sz[64]={'\0'};
		int tmp_len = 0;
		if ( update_field.fields[i].field == kfLastReap && update_field.fields[i].val == 0  || update_field.fields[i].field == kfLastLogoutTime)
		{
			tmp_len = sprintf(sz, "%s=now()", GetFieldName(update_field.fields[i].field));
		}
		else if (update_field.fields[i].field == kfLastReap && update_field.fields[i].val == kInvalidID)
		{
			tmp_len = sprintf(sz, "%s=\'2010-01-01 00:00:00\'",GetFieldName(update_field.fields[i].field));
		}
		else
		{
			tmp_len = sprintf(sz, "%s=%lld", GetFieldName(update_field.fields[i].field), update_field.fields[i].val);
		}
		if(i!=update_field.len-1)
		{
			sz[tmp_len] = ',';
		}
		strcat(kv_str, sz);
	}

	char sql[512];
	if(player != -1 && update_field.id!=kInvalidID)
	{
		sprintf(sql, "update %s set %s where player=%d and id=%d;", GetTableName(update_field.table), kv_str, player, update_field.id);
	}
	else if(player != -1 && update_field.id==kInvalidID)
	{
		sprintf(sql, "update %s set %s where player=%d;", GetTableName(update_field.table), kv_str, player);
	}
	else if (player==-1 && update_field.id!=kInvalidID)
	{
		sprintf(sql, "update %s set %s where id=%d;", GetTableName(update_field.table), kv_str, update_field.id);
	}
	return QueryWrite(conection_, sql);
}

bool DbSession::Excute(const UpdateField2& update_field2)
{
	char kv_str[256] = {'\0'};
	for (size_t i=0; i<update_field2.len; ++i)
	{
		char sz[64]={'\0'};
		int tmp_len = sprintf(sz, "%s=%lld", GetFieldName(update_field2.fields[i].field), update_field2.fields[i].val);
		if(i!=update_field2.len-1)
		{
			sz[tmp_len] = ',';
		}
		strcat(kv_str, sz);
	}

	char sql[512];
	if(update_field2.sub_id!=kInvalidID)
	{
		sprintf(sql, "update %s set %s where %s=%d and %s=%d;", GetTableName(update_field2.table), kv_str, GetFieldName(update_field2.index_filed), update_field2.id, GetFieldName(update_field2.sub_index_filed), update_field2.sub_id);
	}
	else
	{
		sprintf(sql, "update %s set %s where %s=%d;", GetTableName(update_field2.table), kv_str, GetFieldName(update_field2.index_filed), update_field2.id);
	}

	return QueryWrite(conection_, sql);
}

/*
bool DbSession::Excute(UserID player, const UpdateFieldConditionally& update )
{
	char sql[512];
	if (update.sub_id!=kInvalidID)
	{
		sprintf(sql, "update %s set %s=%d where", GetTableName(update.table), GetFieldName(update.field), update.value, )
	}
	else
	{

	}
}
*/

bool DbSession::Excute(const UpdateDeltaField& update_delta_field)
{
	char sql[512];
	sprintf(sql, "update %s set %s=%s+%d where %s=%d;", GetTableName(update_delta_field.table_name),
		GetFieldName(update_delta_field.field), GetFieldName(update_delta_field.field), update_delta_field.val, GetFieldName(update_delta_field.index_name), update_delta_field.index);
	return QueryWrite(conection_, sql);
}

bool DbSession::Excute(UserID player,  const DeleteRow& delete_row )
{
	auto table = delete_row.table;
	if (table == ktBaseInfo || table==ktPropSetting)
	{
		return false;
	}
	char sql[256];
	if (player!=-1)
	{
		sprintf(sql, "delete from %s where player=%d and id=%d;", GetTableName(delete_row.table), player, delete_row.id);
	}
	return QueryWrite(conection_, sql);
}

bool DbSession::Excute( UserID player, const UpdateStringField& update )
{
	char hex_str[256];
	Binary2HexString(update.str, update.len, hex_str, sizeof(hex_str));
	char sql[512];
	sprintf(sql, "update %s set %s=%s where player=%d and id=%d;", GetTableName(update.table), GetFieldName(update.filed),
		hex_str, player, update.id);
	return QueryWrite(conection_, sql);
}

bool DbSession::Excute( const UpdateStringField2& update2 )
{
	char where_field[256] = {'\0'};
	for (size_t i=0; i<update2.where_len; ++i)
	{
		if(i==0)
		{
			sprintf(where_field, "%s=%lld", GetFieldName(update2.where_fields[i].field), update2.where_fields[i].val);
		}
		else
		{
			strcat(where_field, " and ");
			char tmp[80] = {'\0'};
			sprintf(tmp, "%s=%lld", GetFieldName(update2.where_fields[i].field), update2.where_fields[i].val);
			strcat(where_field, tmp);
		}
	}

	char set_field_val[1202]={'\0'};
	Binary2HexString(update2.set_val_str,update2.set_val_len, set_field_val, sizeof(set_field_val));
//	memcpy(set_field_val,update2.set_val_str,update2.set_val_len);

	char sql[2048];
	sprintf(sql, "update %s set %s=%s where %s;", GetTableName(update2.table), GetFieldName(update2.set_filed),set_field_val, where_field);
	return QueryWrite(conection_, sql);
}

bool DbSession::Excute( const UpdateBinaryStringField& update )
{
	if (update.set_val_len>sizeof(update.set_val_str) || update.where_len>3)
	{
		return false;
	}
	char where_field[256] = {'\0'};
	for (size_t i=0; i<update.where_len; ++i)
	{
		if(i==0)
		{
			sprintf(where_field, "%s=%lld", GetFieldName(update.where_fields[i].field), update.where_fields[i].val);
		}
		else
		{
			strcat(where_field, " and ");
			char tmp[80] = {'\0'};
			sprintf(tmp, "%s=%lld", GetFieldName(update.where_fields[i].field), update.where_fields[i].val);
			strcat(where_field, tmp);
		}
	}

	char hex_str[sizeof(update.set_val_str)*2+3] = {'\0'};
	Binary2HexString(update.set_val_str, update.set_val_len, hex_str, sizeof(hex_str));

	char sql[1024];
	sprintf(sql, "update %s set %s=%s where %s;", GetTableName(update.table), GetFieldName(update.set_filed), hex_str, where_field);
	return QueryWrite(conection_, sql);
}

bool DbSession::Excute( const ReplaceIconBin& update )
{
	//删除以前拥有的
	char sql[1024];
	sprintf(sql,"delete from guild_icon where guild_id = %d;",update.guild_id);
	QueryWrite(conection_, sql);
	string img_data;
	img_data.assign(update.icon_bin,update.icon_bin_len);
	mysqlpp::Query query = conection_.query();
	cout<<"update.icon_bin_len="<<update.icon_bin_len<<endl;
	query << "REPLACE INTO guild_icon(guild_id,icon_bin) VALUES(" << update.guild_id << ",\"" <<mysqlpp::escape<< img_data << "\");";
	return QueryWrite(conection_, query);
}

bool DbSession::Excute(const  GuildApplication& update)
{
	mysqlpp::Query query = conection_.query();
	char sql[128];
	sprintf(sql, "insert into guild_application(guild_id,player_id,time,player_name,player_level) values (%d,%d,%d,%d,%d)",update.guild_id,update.player_id,update.apply_time,update.player_name,update.player_level);
	return QueryWrite(conection_, sql);
}

bool DbSession::Excute(const  GuildWarFiles& update)
{
	mysqlpp::Query query = conection_.query();
	char sql[128];
	sprintf(sql,"update guild_war_fields set guild_id =%d ,technology_level =%d,technology_exp =%d where id = %d",update.guild_id,update.technology_level,update.technology_exp,update.id);
	return QueryWrite(conection_, sql);
}
bool DbSession::Excute( UserID player, const UpdateFieldWithSubIndex& update )
{
	char kv_str[256] = {'\0'};
	for (size_t i=0; i<update.len; ++i)
	{
		char sz[64]={'\0'};
		int tmp_len = sprintf(sz, "%s=%lld", GetFieldName(update.fields[i].field), update.fields[i].val);
		if(i!=update.len-1)
		{
			sz[tmp_len] = ',';
		}
		strcat(kv_str, sz);
	}

	char sql[512];
	sprintf(sql, "update %s set %s where player=%d and %s=%d and %s=%d;", GetTableName(update.table), kv_str, player,
		GetFieldName(update.index_filed), update.index, GetFieldName(update.sub_index_filed), update.sub_index);

	return QueryWrite(conection_, sql);
}

bool DbSession::Excute( UserID player, const UpdateDeltaFieldWithSubIndex& update )
{
	char sql[512];
	sprintf(sql, "update %s set %s=%s+%d where player=%d and %s=%d and %s=%d;", GetTableName(update.table), GetFieldName(update.field),
		GetFieldName(update.field), update.delta,
		player, GetFieldName(update.index_filed), update.index, GetFieldName(update.sub_index_filed), update.sub_index);

	return QueryWrite(conection_, sql);
}

bool DbSession::Excute( UserID player, const ExcuteSqlDirectly& sql )
{
	ExcuteSqlDirectly  sql_query = sql;
	assert(sql_query.len<sizeof(sql_query.sql));
	if (sql_query.len<sizeof(sql_query.sql))
	{
		assert(strstr(sql_query.sql, "select")==nullptr && strstr(sql_query.sql, "SELECT")==nullptr);
		sql_query.sql[sql_query.len] = '\0';
		return QueryWrite(conection_, sql_query.sql);
	}
	return false;
}

bool DbSession::Excute( const UpdateMultiFeilds2Value& update )
{
	char sql[256*1024];
	sprintf(sql, "update %s set %s=%d where %s in (", GetTableName(update.table_name), GetFieldName(update.field_name), update.val, GetFieldName(update.index_name));
	for (size_t i=0; i<update.count; ++i)
	{
		char szint[64];
		itoa(update.indexs[i], szint);
		strcat(sql, szint);
		if(i<update.count-1) strcat(sql, ",");
	}
	strcat(sql, ");");
	return QueryWrite(conection_, sql);
}




bool DbSession::InsertGuildInfo(const InsertGuild& guild)
{
	char guild_name[25]={0};
	memcpy(guild_name,guild.name,guild.len);
	char grade1_name[25]={0};
	memcpy(grade1_name,guild.grade1_name,guild.grade1_name_len);
	char grade2_name[25]={0};
	memcpy(grade2_name,guild.grade2_name,guild.grade2_name_len);
	char grade100_name[25]={0};
	memcpy(grade100_name,guild.grade100_name,guild.grade100_name_len);

	char sql[256];
	sprintf(sql, "call add_guild(%d,'%s',%d,%d,'%s','%s','%s')",guild.guild_id,guild_name,guild.leader,guild.icon,grade1_name,grade2_name,grade100_name);
	return QueryWrite(conection_, sql);
}

bool DbSession::UpdateWarFieldGuildInfo(const UpdateWarFieldGuild& war_field_guild)
{
	char sql[256];
	sprintf(sql, "call update_war_field_guild(%d,%d)",war_field_guild.war_filed_id, war_field_guild.guild_id);
	return QueryWrite(conection_, sql);
}

bool DbSession::DeleteGuildInfo(const DeleteGuild& guild)
{
	char sql[256];
	sprintf(sql, "call del_guild(%d)",guild.guild_id);
	return QueryWrite(conection_, sql);
}

bool DbSession::InsertNewGuildGradeInfo(const InsertNewGuildGrade& guild_grade)
{
	char new_grade_name[25]={0};
	memcpy(new_grade_name,guild_grade.new_grade_name,guild_grade.new_grade_name_len);

	char sql[256];
	sprintf(sql, "call add_new_guild_grade(%d,%d,'%s')",guild_grade.guild_id,guild_grade.new_grade_level,new_grade_name);
	return QueryWrite(conection_, sql);
}

bool DbSession::LeaveGuild(const MemberLeaveGuild& leave_guild)
{
	char sql[256];
	sprintf(sql, "call leave_guild(%d)",leave_guild.player_id);
	return QueryWrite(conection_, sql);
}

bool DbSession::JoinGuild(const MemberJoinGuild& join_guild)
{
	char sql[256];
	sprintf(sql, "call join_guild(%d,%d)",join_guild.player_id,join_guild.guild_id);
	return QueryWrite(conection_, sql);
}

bool DbSession::GetAllHeros( UserID uid, Hero heros[], size_t& count )
{
	count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d", GetTableName(ktHero), GetFieldName(kfPlayer), uid);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		Hero hero;
		for (const auto& row: res)
		{
			hero.id = row[GetFieldName(kfID)];
			hero.level = row[GetFieldName(kfLevel)];
			hero.exp = row[GetFieldName(kfExp)];
			hero.status = row[GetFieldName(kfStatus)];
			hero.location = row[GetFieldName(kfLocation)];
			//hero.bringup_strength = row[GetFieldName(kfBringupStrength)];
			//hero.bringup_agility = row[GetFieldName(kfBringupAgility)];
			//hero.bringup_intelligence = row[GetFieldName(kfBringupIntelligence)];
			memcpy(&hero.bringup_bin,row[GetFieldName(kfBringupBin)].data(),sizeof(hero.bringup_bin));
			heros[count++] = hero;
		}
		return true;
	}
	return false;
}

bool DbSession::GetTownBlocks( UserID player, TownBlocks& town_blocks )
{
	char sql[256];
	sprintf(sql, "select blocks from town where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		memcpy(town_blocks.block_status, row["blocks"].data(), sizeof(town_blocks.block_status));
		return true;
	}
	return false;
}

bool DbSession::SaveTownBlocks( UserID player, const TownBlocks& town_blocks )
{
	char hex_str[128];
	Binary2HexString(town_blocks.block_status, sizeof(town_blocks.block_status), hex_str, sizeof(hex_str));
	char sql[256];
	sprintf(sql, "update town set blocks=%s where player=%d", hex_str, player);
	return QueryWrite(conection_, sql);
}

bool DbSession::GetAllEquipment( UserID player, EquipmentFromDb euips[], size_t& count )
{
	count = 0;
	char sql[256];
	sprintf(sql, "select * from equipment where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		EquipmentFromDb equipment;
		for (const auto& row: res)
		{
			memset(equipment.equip.holes, 0, sizeof(equipment.equip.holes));
			equipment.id = row[GetFieldName(kfID)];
			equipment.equip.level = row[GetFieldName(kfLevel)];
			equipment.equip.base_strength = row[GetFieldName(kfStrength)];
			equipment.equip.base_agility = row[GetFieldName(kfAgility)];
			equipment.equip.base_intelligence = row[GetFieldName(kfIntelligence)];
			equipment.equip.hero = row[GetFieldName(kfHero)];
			memcpy(equipment.equip.holes, row[GetFieldName(kfHoles)].data(), sizeof(equipment.equip.holes));
			memcpy(equipment.equip.gems, row[GetFieldName(kfGems)].data(), sizeof(equipment.equip.gems));
			euips[count++] = equipment;
		}
		return true;
	}
	return false;
}

bool DbSession::GetAllProps( UserID player, PropFromDb props[], size_t& count )
{
	count = 0;
	char sql[256];
	sprintf(sql, "select * from prop where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		PropFromDb prop;
		for (const auto& row: res)
		{
			prop.id = row[GetFieldName(kfID)];
			prop.prop.kind  = row[GetFieldName(kfKind)];
			prop.prop.area = row[GetFieldName(kfArea)];
			prop.prop.location = row[GetFieldName(kfLocation)];
			prop.prop.amount = row[GetFieldName(kfAmount)];
			prop.prop.bind = row[GetFieldName(kfBind)];
			props[count++] = prop;
		}
		return true;
	}
	return false;
}

bool DbSession::GetPropSetting( UserID player, PropSetting& setting )
{
	char sql[256];
	sprintf(sql, "select * from prop_setting where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		setting.bag_grids_count = row[GetFieldName(kfBagGridsCount)];
		setting.warehouse_grids_count = row[GetFieldName(kfWarehouseGridsCount)];
		return true;
	}
	return false;
}

bool DbSession::GetFormulas( UserID player, MyFormulas& formulas )
{
	formulas.count = 0;
	char sql[256];
	sprintf(sql, "select id from formula where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			formulas.kinds[formulas.count++] = row["id"];
			if (formulas.count>=formulas.MAX_COUNT)
			{
				break;
			}
		}
		return true;
	}
	return false;
}

bool DbSession::GetAllEquipmentGems( UserID player, const size_t max_count, EquipmentGemFromDb gems[] , size_t& count )
{
	count = 0;
	char sql[256];
	sprintf(sql, "select id from formula where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		EquipmentGemFromDb gem;
		for (const auto& row: res)
		{
//			gem.equipment = row[GetFieldName(kfEquipment)];
//			gem.hole_index = row[GetFieldName(kfIndex)];
			gem.kind = row[GetFieldName(kfKind)];
			gems[count++] = gem;
			if (count>=max_count)
			{
				break;
			}
		}
		return true;
	}
	return false;
}

bool DbSession::GetSectionScores( UserID player, SectionScores& scores )
{
	memset(&scores, 0, sizeof(scores));
	char sql[256];
	sprintf(sql, "select * from section where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		static const size_t kMaxCount = sizeof(scores.scores);
		for (const auto& row: res)
		{
			uint16_t id =  row[GetFieldName(kfID)];
			if (id>sizeof(scores.scores)-1) continue;
			scores.scores[id] = row[GetFieldName(kfScore)];
//			if (scores.count>=kMaxCount) break;
		}
	}
	return res;
}

bool DbSession::GetSkills( UserID player, Skills& skills )
{
	skills.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d", GetTableName(ktSkill), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			Skills::Skill skill;
			skill.id = row[GetFieldName(kfID)];
			skill.level = row[GetFieldName(kfLevel)];
			skills.skills[skills.count++] = skill;
			if (skills.count>=skills.kMaxCount) break;
		}
	}
	return res;
}

bool DbSession::GetPlayerStatus( UserID player, PlayerStatus& status )
{
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d;", GetTableName(ktStatus), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		mysqlpp::DateTime time = row[GetFieldName(kfLastLogoutTime)];
		status.last_logout_time = time;
		status.last_active_time = row[GetFieldName(kfLastActiveTime)];
		status.army_area = row[GetFieldName(kfArmyArea)];
		status.army_location = row[GetFieldName(kfArmyLocation)];
		status.encounter_cd = row[GetFieldName(kfEncounterCD)];
		status.current_trunk_task = row[GetFieldName(kfTrunkTask)];
		status.current_branch_task = row[GetFieldName(kfBranchTask)];
		status.trunk_task_progress = row[GetFieldName(kfTrunkTaskProgress)];
		status.branch_task_progress = row[GetFieldName(kfBranchTaskProgress)];
		status.passed_section = row[GetFieldName(kfPassedSection)];
		status.passed_boss_section = row[GetFieldName(kfPassedBossSection)];
		status.boss_killing_times = row[GetFieldName(kfBossKillingTimes)];
		status.replenish_time = row[GetFieldName(kfReplenishTime)];
		status.back_time = row[GetFieldName(kfBackTime)];
		status.stamina = row[GetFieldName(kfStamina)];
		status.stamina_take = row[GetFieldName(kfStaminaTake)];
		return true;
	}
	return false;
}

bool DbSession::GetPlayerAuctionInfo(UserID player, AuctionInfoList& info)
{
	info.count = 0;
	char sql[256];

	sprintf(sql, "select * from %s where %s=%d or %s=%d LIMIT 0,256", GetTableName(ktAuctionInfo), GetFieldName(kfSeller), player, GetFieldName(kfBuyer), player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			UserID Seller = row[GetFieldName(kfSeller)];
			UserID Buyer = row[GetFieldName(kfBuyer)];
			if(Seller==player)
			{
				info.list[info.count].uuid = row[GetFieldName(kfUUID)];
				info.list[info.count].status = row[GetFieldName(kfStatus)];
				info.list[info.count].price = row[GetFieldName(kfPrice)];
				info.list[info.count].kind = row[GetFieldName(kfKind)];
				info.list[info.count].amount = row[GetFieldName(kfAmount)];
				info.list[info.count].time = row[GetFieldName(kfTime)];

				info.count++;
			}

			if(Buyer==player)
			{
				info.list[info.count].uuid = row[GetFieldName(kfUUID)];
				info.list[info.count].status = row[GetFieldName(kfStatus)] + 3;
				info.list[info.count].price = row[GetFieldName(kfPrice)];
				info.list[info.count].amount = row[GetFieldName(kfAmount)];
				info.list[info.count].kind = row[GetFieldName(kfKind)];
				info.list[info.count].time = row[GetFieldName(kfTime)];

				info.count++;
			}
		}

		if (info.count!=0)
		{
			// TODO 删除一周前记录
			//sprintf(sql, "delete from %s where %s=%d", GetTableName(ktArenaChallenge), GetFieldName(kfPlayer), player);
			//QueryWrite(conection_, sql);
		}
	}

	return res;
}

bool DbSession::GetPlayerArenaInfo(UserID player, ArenaInfo& info)
{
	//sprintf(sql, "SELECT ifnull(MAX(%s),0) FROM %s", GetFieldName(kfRank), GetTableName(ktArenaInfo));
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d", GetTableName(ktArenaInfo), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		/*
		info.rank = row[GetFieldName(kfRank)];
		info.reward = row[GetFieldName(kfReward)];
		info.reward_bak = row[GetFieldName(kfRewardBak)];
		*/
		info.time = row[GetFieldName(kfTime)];
		info.count = row[GetFieldName(kfCount)];
		info.buy_count = row[GetFieldName(kfBuyCount)];
		/*
		info.win_count = row[GetFieldName(kfWinCount)];
		info.lose_count = row[GetFieldName(kfLoseCount)];
		*/

		return true;
	}
	return false;
}

bool DbSession::GetPlayerArenaHistory(UserID player, ArenaHistoryList& history)
{
	history.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d or %s=%d ORDER BY %s DESC LIMIT 0,5", GetTableName(ktArenaHistory), GetFieldName(kfPlayer), player, GetFieldName(kfTarget), player, GetFieldName(kfTime));
	//cout<<sql<<endl;
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			UserID uid = row[GetFieldName(kfPlayer)];
			if(uid==player)
			{
				history.list[history.count].target_id = row[GetFieldName(kfTarget)];
				history.list[history.count].initiative = 1;
				history.list[history.count].winner = row[GetFieldName(kfWinner)];
				history.list[history.count].rank_change = row[GetFieldName(kfRankSelf)];
			}
			else
			{
				history.list[history.count].target_id = uid;
				history.list[history.count].initiative = 0;
				history.list[history.count].winner = 1 - row[GetFieldName(kfWinner)];
				history.list[history.count].rank_change = row[GetFieldName(kfRankTarget)];
			}
			history.list[history.count].war_id = row[GetFieldName(kfWarID)];
			history.list[history.count].time = row[GetFieldName(kfTime)];

			history.count++;
		}
	}
	return res;
}

bool DbSession::GetPlayerArenaChallenge(UserID player, ArenaChallengeList& challenge)
{
	challenge.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d ORDER BY challenge_id DESC LIMIT 0,64", GetTableName(ktArenaChallenge), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			challenge.list[challenge.count].challenger = row[GetFieldName(kfChallenger)];
			challenge.list[challenge.count].rank_change = row[GetFieldName(kfRankChange)];
			challenge.list[challenge.count].war_id = row[GetFieldName(kfWarID)];

			challenge.count++;
		}

		if (challenge.count!=0)
		{
			sprintf(sql, "delete from %s where %s=%d", GetTableName(ktArenaChallenge), GetFieldName(kfPlayer), player);
			QueryWrite(conection_, sql);
		}
	}

	return res;
}
bool DbSession::GetPlayerRuneStatus(UserID player, RuneStatus& status)
{
	status.max_id = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d", GetTableName(ktRuneStatus), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		status.status = row[GetFieldName(kfStatus)];
		status.energy = row[GetFieldName(kfEnergy)];

		sprintf(sql, "SELECT IFNULL(MAX(%s),0) FROM %s where %s=%d", GetFieldName(kfID), GetTableName(ktRuneInfo), GetFieldName(kfPlayer), player);
		auto res_id = QueryRead(conection_, sql);
		if(res_id && !res_id.empty())
		{
			status.max_id = res_id[0][0];
			return true;
		}
	}
	return false;
}

bool DbSession::GetPlayerRuneInfoStove(UserID player, RuneInfoStoveList& info)
{
	info.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d and %s=%d LIMIT 0,20", GetTableName(ktRuneInfo), GetFieldName(kfPlayer), player, GetFieldName(kfLocation), -2);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			info.list[info.count].rune_id = row[GetFieldName(kfID)];
			info.list[info.count].type = row[GetFieldName(kfType)];
			info.list[info.count].location = row[GetFieldName(kfLocation)];
			info.list[info.count].position = row[GetFieldName(kfPosition)];
			info.list[info.count].lock = row[GetFieldName(kfLocked)];
			info.list[info.count].exp = row[GetFieldName(kfExp)];

			info.count++;
		}
	}

	return res;
}


bool DbSession::GetPlayerRuneInfoBag(UserID player, RuneInfoBagList& info)
{
	info.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d and %s=%d LIMIT 0,30", GetTableName(ktRuneInfo), GetFieldName(kfPlayer), player, GetFieldName(kfLocation), -1);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			info.list[info.count].rune_id = row[GetFieldName(kfID)];
			info.list[info.count].type = row[GetFieldName(kfType)];
			info.list[info.count].location = row[GetFieldName(kfLocation)];
			info.list[info.count].position = row[GetFieldName(kfPosition)];
			info.list[info.count].lock = row[GetFieldName(kfLocked)];
			info.list[info.count].exp = row[GetFieldName(kfExp)];

			info.count++;
		}
	}

	return res;
}
bool DbSession::GetPlayerRuneInfoHero(UserID player, RuneInfoHeroList& info)
{
	info.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d and %s>=%d LIMIT 0,512", GetTableName(ktRuneInfo), GetFieldName(kfPlayer), player, GetFieldName(kfLocation), 0);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			info.list[info.count].rune_id = row[GetFieldName(kfID)];
			info.list[info.count].type = row[GetFieldName(kfType)];
			info.list[info.count].location = row[GetFieldName(kfLocation)];
			info.list[info.count].position = row[GetFieldName(kfPosition)];
			info.list[info.count].lock = row[GetFieldName(kfLocked)];
			info.list[info.count].exp = row[GetFieldName(kfExp)];

			info.count++;
		}
	}

	return res;
}


bool DbSession::GetPlayerGradeInfo(UserID player, GradeInfo& info)
{
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d", GetTableName(ktGrade), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		info.level = row[GetFieldName(kfLevel)];
		info.progress = row[GetFieldName(kfProgress)];
		info.reward = row[GetFieldName(kfReward)];
		//info.reward_bak = row[GetFieldName(kfRewardBak)];
		//info.time = row[GetFieldName(kfTime)];

		return true;
	}
	return false;
}

bool DbSession::GetAllArrays( UserID player, Arrays& arrays )
{
	arrays.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d LIMIT 0,16", GetTableName(ktArray), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			arrays.arrays[arrays.count].id = row[GetFieldName(kfID)];
			memcpy(arrays.arrays[arrays.count].heros, row[GetFieldName(kfArray)].data(), sizeof(arrays.arrays[arrays.count].heros));

			arrays.count++;
		}
	}

	return res;
}


bool DbSession::GetPlayerEscortInfo(UserID player, EscortInfo& info)
{
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d", GetTableName(ktEscortInfo), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		info.count = row[GetFieldName(kfCount)];
		//info.total = row[GetFieldName(kfTotal)];
		info.intercept = row[GetFieldName(kfIntercept)];
		//info.intercept_total = row[GetFieldName(kfInterceptTotal)];
		//info.auto_accept = row[GetFieldName(kfAutoAccept)];
		info.transport = row[GetFieldName(kfTransport)];
		info.time = row[GetFieldName(kfTime)];
		info.refresh = row[GetFieldName(kfRefresh)];
		return true;
	}
	return false;
}

bool DbSession::GetPlayerEscortReward(UserID player, EscortRewardList& reward)
{
	reward.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d ORDER BY reward_id DESC LIMIT 0,128", GetTableName(ktEscortReward), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			reward.list[reward.count].transport = row[GetFieldName(kfTransport)];
			reward.list[reward.count].count = row[GetFieldName(kfCount)];
			reward.list[reward.count].help = row[GetFieldName(kfHelp)];
			reward.list[reward.count].silver = row[GetFieldName(kfSilver)];
			reward.list[reward.count].prestige = row[GetFieldName(kfPrestige)];

			reward.count++;
		}

		if (reward.count!=0)
		{
			sprintf(sql, "delete from %s where %s=%d", GetTableName(ktEscortReward), GetFieldName(kfPlayer), player);
			QueryWrite(conection_, sql);
		}

		if (reward.count==0)
		{
            return false;
		}
	}

	return res;
}

bool DbSession::GetPlayerEscortRobbed(UserID player, EscortRobbedList& robbed)
{
	robbed.count = 0;
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d ORDER BY rob_id DESC LIMIT 0,16", GetTableName(ktEscortRobbed), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			robbed.list[robbed.count].robber = row[GetFieldName(kfRobber)];
			robbed.list[robbed.count].help = row[GetFieldName(kfHelp)];
			robbed.list[robbed.count].transport = row[GetFieldName(kfTransport)];
			robbed.list[robbed.count].winner = row[GetFieldName(kfWinner)];
			robbed.list[robbed.count].silver = row[GetFieldName(kfSilver)];
			robbed.list[robbed.count].prestige = row[GetFieldName(kfPrestige)];

			robbed.count++;
		}

		if (robbed.count!=0)
		{
			sprintf(sql, "delete from %s where %s=%d", GetTableName(ktEscortRobbed), GetFieldName(kfPlayer), player);
			QueryWrite(conection_, sql);
		}

		if (robbed.count==0)
		{
            return false;
		}
	}

	return res;
}
/*
bool DbSession::GetPlayerEscortRoad(UserID player, EscortRoad& road)
{
	char sql[256];
	sprintf(sql, "select * from %s where %s=%d", GetTableName(ktEscortInfo), GetFieldName(kfPlayer), player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		const auto& row = res[0];
		road.time = row[GetFieldName(kfTime)];
		road.guardian = row[GetFieldName(kfGuardian)];
		road.transport = row[GetFieldName(kfTransport)];
		//road.count = row[GetFieldName(kfCount)];
		return true;
	}
	return false;
}
*/
bool DbSession::GetFishInfo(UserID player, FishInfo& fish_info)
{
	char sql[256];
	memset(&fish_info,0,sizeof(fish_info));
	sprintf(sql,"select * from %s where player=%d",GetTableName(ktFish), player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty())
	{
		auto& row = res[0];
		fish_info.fish_times = row[GetFieldName(kfFishFishTimes)];
		fish_info.gold_times = row[GetFieldName(kfFishGoldTimes)];
		fish_info.torpedo_times = row[GetFieldName(kfFishTorpedoTimes)];
	}else
		return false;
	sprintf(sql, "select * from %s where player=%d", GetTableName(ktFishRecord), player);
	res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		uint16_t amount = 0;
		for( auto& row: res)
		{
			fish_info.records[amount].kind = row[GetFieldName(kfFishKind)];
			fish_info.records[amount].weight = row[GetFieldName(kfFishWeight)];
			++amount;
		}
		fish_info.amount = amount;
	}
	return true;
}

bool DbSession::GetAccomplishedAchievement( UserID player, AccomplishedAchievements& achievements )
{
	achievements.count = 0;
	char sql[256];
	sprintf(sql, "select id,time from achievement where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			achievements.records[achievements.count].id = row[0];
			//achievements.ids[achievements.count++] = row[0];
			achievements.records[achievements.count].time = row[1];
			++achievements.count;
		}
	}
	return res;
}

bool DbSession::GetActions( UserID player, Actions& actions )
{
	actions.count = 0;
	char sql[256];
	sprintf(sql, "select id,max,value,kind from action where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			actions.records[actions.count].id = row[0];
			actions.records[actions.count].max = row[1];
			actions.records[actions.count].value = row[2];
			actions.records[actions.count].kind = row[3];
			++actions.count;
		}
	}
	return res;
}

bool DbSession::GetAuctionOfflineList( UserID player, AuctionOfflineList& auction_offline )
{
	auction_offline.count = 0;
	char sql[256];
	sprintf(sql, "select kind,gold from auction_offline where player=%d LIMIT 0,256", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			auction_offline.list[auction_offline.count].kind = row[0];
			auction_offline.list[auction_offline.count].gold = row[1];
			++auction_offline.count;
		}

		if (auction_offline.count!=0)
		{
			sprintf(sql, "delete from auction_offline where %s=%d", GetFieldName(kfPlayer), player);
			QueryWrite(conection_, sql);
		}
	}
	return res;
}

bool DbSession::GetPlayGroundRaceInfo( UserID player, PlayGroundRaceInfoResult& race_info)
{
	char sql[256];
	memset(&race_info,0,sizeof(race_info));
	sprintf(sql,"select player from playground_dragon where player=%d and signup=1 limit 1",player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		race_info.signup = 1;//已报名
	}else
	{
		race_info.signup = 0;
	}
	res.clear();
	//
	sprintf(sql,"select money,guess from playground_race_guess where player=%d limit 11", player);
	res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		for( const auto& row: res)
		{
			int8_t guess = row["guess"];
			int16_t money = row["money"];
			race_info.money[guess-1] = money;
		}
	}
	return true;
}

bool DbSession::GetPlayGroundDragonInfo(UserID player, PlayGroundDragonInfoResult& dragon_info)
{
	char sql[256];
	sprintf(sql,"select * from playground_rear where player=%d limit 1", player);
	auto res = QueryRead(conection_, sql);
	dragon_info.rooms = 0;
	if( res && !res.empty() )
	{
		auto& row = res[0];
		dragon_info.rooms = row["rooms"];
	}else
	{
		return false;//未激活功能
	}
	res.clear();
	sprintf(sql,"select * from playground_dragon where player=%d limit 9", player);
	res = QueryRead(conection_, sql);
	dragon_info.len = 0;
	if( res && !res.empty() )
	{
		int32_t index = 0;
		dragon_info.len = res.size();
		for( const auto& row: res )
		{
			dragon_info.dragon[index].dragon_id = row["dragon"];
			dragon_info.dragon[index].his_rank = row["his_rank"];
			dragon_info.dragon[index].m_time   = row["m_time"];
			dragon_info.dragon[index].strength = row["strength"];
			dragon_info.dragon[index].agility = row["agility"];
			dragon_info.dragon[index].intellect = row["intellect"];
			dragon_info.dragon[index].max_str = row["max_str"];
			dragon_info.dragon[index].max_agi = row["max_agi"];
			dragon_info.dragon[index].max_int = row["max_int"];
			dragon_info.dragon[index].kind = row["kind"];
			dragon_info.dragon[index].sex = row["sex"];
			dragon_info.dragon[index].signup = row["signup"];
			dragon_info.dragon[index].ch_name = row["ch_name"];
			if( dragon_info.dragon[index].ch_name == 1)
			{
				dragon_info.dragon[index].d_name.len = row["d_name"].length();
				memcpy( dragon_info.dragon[index].d_name.str, row["d_name"].c_str(), dragon_info.dragon[index].d_name.len);
			}
			++index;
		}
	}
	return true;
}

bool DbSession::GetTurntableInfo( UserID player, InternalTurntableInfo& info)
{
	char sql[256];
	sprintf(sql,"select * from %s where player=%d limit 1", GetTableName(ktTurntable), player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		auto& row = res[0];
		info.result = row[GetFieldName(kfTurnResult)];
		info.re_times = row[GetFieldName(kfTurnReTimes)];
		info.times = row[GetFieldName(kfTurnTimes)];
		info.cur_point = row[GetFieldName(kfTurnCurPoint)];
		info.should_return = row[GetFieldName(kfTurnShouldReturn)];
	}else
	{
		return false;
	}
	return true;
}

bool DbSession::GetPlaygroundInfo( UserID player, InternalPlaygroundInfo& pg_info)
{
	char sql[256];
	sprintf(sql,"select * from playground where player=%d limit 1", player);
	auto res = QueryRead(conection_, sql);
	pg_info.tickets = 0;
	if( res && !res.empty() )
	{
		auto& row = res[0];
		pg_info.tickets = row["tickets"];
	}
	return true;
}

bool DbSession::GetPlaygroundProps( UserID player, InternalPlaygroundProps& pg_props)
{
	char sql[256];
	sprintf(sql,"select * from playground_props where player=%d", player);
	auto res = QueryRead(conection_, sql);
	pg_props.amount = 0;
	if( res && !res.empty() )
	{
		int32_t tmp_index = 0;
		pg_props.amount = res.size();
		for (const auto& row: res)
		{
			pg_props.prop[tmp_index].kind = row["kind"];
			pg_props.prop[tmp_index].amount = row["amount"];
			pg_props.prop[tmp_index].buy_count = row["buy_count"];
			++tmp_index;
		}
		return true;
	}else
		return false;
}

bool DbSession::GetAssistantInfo( UserID player, InternalAssistantInfo& ass_info)
{
	char sql[256];
	sprintf(sql,"select * from assistant where player=%d", player);
	auto res = QueryRead(conection_, sql);
	ass_info.activity = 0;
	ass_info.draw = 0;
	if( res && !res.empty() )
	{
		auto& row = res[0];
		ass_info.activity = row["activity"];
		ass_info.draw = row["draw"];
	}
	sprintf(sql, "select * from assistant_task where player=%d",player);
	res = QueryRead(conection_, sql);
	ass_info.amount = 0;
	if( res && !res.empty() )
	{
		int16_t amount = 0;
		for(auto&row: res)
		{
			ass_info.tasks[amount].task_id = row["task_id"];
			ass_info.tasks[amount].times   = row["times"];
			ass_info.tasks[amount].b_retrieve = row["b_retrieve"];
			ass_info.tasks[amount].times_back = row["times_back"];
			ass_info.tasks[amount].remain_times = row["remain_times"];
			++amount;
		}
		ass_info.amount = amount;
	}
	return true;
}

bool DbSession::GetTreeInfo( UserID player, InternalTreeInfo& tree_info)
{
	char sql[256];
	sprintf(sql,"select * from %s where player=%d", GetTableName(ktTreeWater), player);
	auto res = QueryRead(conection_, sql);
	tree_info.water_amount = 0;
	if( res && !res.empty() )
	{
		auto& row = res[0];
		tree_info.water_amount = row[GetFieldName(kfTreeWaterAmount)];
		tree_info.buy_count = row[GetFieldName(kfTreeBuyCount)];
	}else
		return false;
	sprintf(sql,"select * from %s where player=%d", GetTableName(ktTreeSeed), player);
	res = QueryRead(conection_, sql);
	tree_info.seed_amount = 0;
	if( res && !res.empty() )
	{
		for( const auto& row: res)
		{
			tree_info.seeds[tree_info.seed_amount].ripe_time = row[GetFieldName(kfTreeRipeTime)];
			tree_info.seeds[tree_info.seed_amount].last_water = row[GetFieldName(kfTreeLastWater)];
			tree_info.seeds[tree_info.seed_amount].kind = row[GetFieldName(kfTreeKind)];
			tree_info.seeds[tree_info.seed_amount].location = row[GetFieldName(kfTreeLocation)];
			tree_info.seeds[tree_info.seed_amount].watered = row[GetFieldName(kfTreeWatered)];
			tree_info.seeds[tree_info.seed_amount].status = row[GetFieldName(kfTreeStatus)];
			++tree_info.seed_amount;
		}
	}
	sprintf(sql,"select bi.nickname,log.`time`,log.`id` from tree_log as log inner join base_info as bi on bi.player=log.uid where log.player=%d order by log.`time` asc", player);
	res = QueryRead(conection_, sql);
	tree_info.log_amount = 0;
	{
		for( const auto& row: res)
		{
			tree_info.logs[tree_info.log_amount].id = row[GetFieldName(kfTreeId)];
			tree_info.logs[tree_info.log_amount].name.len = row["nickname"].length();
			memcpy(tree_info.logs[tree_info.log_amount].name.str, row["nickname"].c_str(), tree_info.logs[tree_info.log_amount].name.len);
			tree_info.logs[tree_info.log_amount].time = row[GetFieldName(kfTreeTime)];
			++tree_info.log_amount;
		}
	}
	return true;
}

bool DbSession::GetRewardForDaysAgoInfo( UserID player, InternalRewardDaysAgoInfo& days_ago_info)
{
	char sql[256];
	sprintf(sql,"select register_time,%s from account as a, %s as b where a.player=%d and b.player=%d", GetFieldName(kfGot),GetTableName(ktRewardForDaysAgo), player, player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		auto& row = res[0];
		mysqlpp::DateTime reg_time = row["register_time"];
		days_ago_info.reg_time = reg_time;
		days_ago_info.got = row[GetFieldName(kfGot)];
		return true;
	}
	return false;
}

bool DbSession::GetSaveWebsiteInfo(UserID player, InternalSaveWebsiteInfo& sw_info)
{
	char sql[256];
	sprintf(sql,"select * from %s where player=%d", GetTableName(ktSaveWebsite), player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		auto& row = res[0];
		sw_info.b_got = row[GetFieldName(kfGot)];
		return true;
	}
	return false;
}

bool DbSession::GetLuckyDrawInfo(UserID player, InternalLuckyDrawInfo& ld_info)
{
	char sql[256];
	sprintf(sql,"select * from %s where player=%d", GetTableName(ktLuckyDraw), player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		auto& row = res[0];
		ld_info.times = row[GetFieldName(kfTimes)];
		return true;
	}
	return false;
}

bool DbSession::GetCheckInEveryDayInfo(UserID player, InternalCheckInEveryDayInfo& cied_info)
{
	char sql[256];
	sprintf(sql,"select * from %s where player=%d", GetTableName(ktCheckInEveryDay), player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		auto& row = res[0];
		cied_info.time = row[GetFieldName(kfTime)];
		cied_info.days = row[GetFieldName(kfDays)];
		int len = row[GetFieldName(kfRewards)].length();
		memcpy(&cied_info.rewards, row[GetFieldName(kfRewards)].data(), len);
		return true;
	}
	return false;
}

bool DbSession::GetCheckInAccumulateInfo(UserID player, InternalCheckInAccumulateInfo& cia_info)
{
	char sql[256];
	sprintf(sql,"select * from %s where player=%d", GetTableName(ktCheckInAccumulate), player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty() )
	{
		auto& row = res[0];
		cia_info.time = row[GetFieldName(kfTime)];
		cia_info.days = row[GetFieldName(kfDays)];
		return true;
	}
	return false;
}

bool DbSession::GetAllBuildingStatus( UserID uid, FunctionBuildingStatus fbs[100], size_t& count )
{
	count = 0;
	char sql[256];
	sprintf(sql, "select * from function_building where player=%d limit %d", uid, kMaxFunctionBuildings);
	auto res = QueryRead(conection_, sql);
	for (const auto& row: res ) //function buildings
	{
		FunctionBuildingStatus fb;
		fb.id = row["id"];
		fb.kind = row["kind"];
		fb.x = row["x"];
		fb.y = row["y"];
		fb.aspect = row["aspect"];
		fb.level = row["level"];
		fb.progress = row["progress"];
		mysqlpp::DateTime last_reap = row["last_reap"];
		fb.last_reap = last_reap;
		if (fb.last_reap==-1) fb.last_reap=0;
		fbs[count++] = fb;
	}
	return res;
}

bool DbSession::GetAllBuildingStatus( UserID uid, BusinessBuildingStatus bbs[], size_t& count )
{
	count = 0;
	char sql[256];
	sprintf(sql, "select * from business_building where player=%d limit %d", uid, kMaxBusinessBuildings);
	auto res = QueryRead(conection_, sql);
	for (const auto& row: res) //business buildings
	{
		BusinessBuildingStatus bb;
		bb.id = row["id"];
		bb.kind = row["kind"];
		bb.x = row["x"];
		bb.y = row["y"];
		bb.aspect = row["aspect"];
		bb.warehoused = row["warehoused"];
		bb.progress = row["progress"];
		mysqlpp::DateTime last_reap = row["last_reap"];
		bb.last_reap = last_reap;
		bbs[count++] = bb;
	}
	return res;
}

bool DbSession::GetAllBuildingStatus( UserID uid, DecorationStatus ds[], size_t& count )
{
	count = 0;
	char sql[256];
	sprintf(sql, "select * from decoration where player=%d limit %d", uid, kMaxDecorations);
	auto res = QueryRead(conection_, sql);
	for (const auto& row: res)  //decorations
	{
		DecorationStatus d;
		d.id = row["id"];
		d.kind = row["kind"];
		d.x = row["x"];
		d.y = row["y"];
		d.aspect = row["aspect"];
		d.warehoused = row["warehoused"];
		ds[count++] = d;
	}
	return res;
}

bool DbSession::GetAllBuildingStatus( UserID uid, RoadStatus rs[], size_t& count )
{
	count = 0;
	char sql[256];
	sprintf(sql, "select * from road where player=%d limit %d", uid, kMaxRoads);
	auto res = QueryRead(conection_, sql);
	for (const auto& row: res) //roads
	{
		RoadStatus r;
		r.id = row["id"];
		r.kind = row["kind"];
		r.x = row["x"];
		r.y = row["y"];
		r.aspect = row["aspect"];
		r.warehoused = row["warehoused"];
		rs[count++] = r;
	}
	return res;
}

bool DbSession::GetPlayerClientConfig(UserID player, ClientConfig& config)
{
	char sql[256];
	sprintf(sql,"select setting,length(setting) as len from settings where player=%d",player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty())
	{
		auto& row = res[0];
		config.len = row["len"];
		if(config.len>256) config.len = 256;
		memcpy(config.config, row["setting"], config.len);
		return true;
	}
	return false;
}

bool DbSession::QueryFightRecord(uint32_t id, QueryFightRecordResult& FightRecordResult)
{
	FightRecordResult.len = 0;

	char sql[256];
	sprintf(sql,"select record,length(record) as len from  battle_record where id=%d", id);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty())
	{
		auto& row = res[0];

		FightRecordResult.len = row["len"];
		if(FightRecordResult.len>kMaxFightRecordLength) FightRecordResult.len = kMaxFightRecordLength;
		memcpy(FightRecordResult.str, row["record"], FightRecordResult.len);

		return true;
	}
	return false;
}

bool DbSession::GetVIPCount(UserID player, VIPCount& vip_count)
{
	char sql[256];
	sprintf(sql,"select * from vip_count where player=%d",player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty())
	{
		auto& row = res[0];
		vip_count.energy = row["energy"];
		vip_count.mobility = row["mobility"];
		vip_count.alchemy = row["alchemy"];
		vip_count.rune = row["rune"];
		//vip_count.arena = row["arena"];
		return true;
	}
	return false;
}
bool DbSession::GetLoadBuffers( UserID player, LordBuffers& buffers )
{
	char sql[256];
	sprintf(sql, "select kind,value,time from lord_buffer where player=%d limit 5", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		size_t count = 0;
		for (const auto& row: res)
		{
			buffers.buffers[count].kind = row["kind"];
			buffers.buffers[count].value = row["value"];
			buffers.buffers[count].time = row["time"];
			++count;
		}
	}
	return res && !res.empty();
}

bool DbSession::GetAccomplishBranchTask( UserID player, AccomplishedBranchTasks& tasks )
{
	char sql[256];
	sprintf(sql, "select id from branch_task where player=%d", player);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		size_t count = 0;
		for (const auto& row: res)
		{
			tasks.tasks[count] = row[0];
			count++;
		};
		tasks.count = count;
	}
	return res && !res.empty();
}

bool DbSession::GetPlayerBossKillingTimes( UserID player, BossesKillingTimes& times )
{
	memset(&times, 0, sizeof(times));
	char sql[256];
	sprintf(sql, "select id, times from boss_section where player=%d limit %d", player, sizeof(times.killing_times)-1);
	auto res = QueryRead(conection_, sql);
	if (res)
	{
		for (const auto& row: res)
		{
			int id = row["id"];
			if (id < sizeof(times.killing_times)) times.killing_times[id] = row["times"];
		}
	}
	return res;
}

bool DbSession::GetHeroTrainInfo(UserID player, TrainNum& buffers)
{
	char sql[256];
	sprintf(sql, "select train_num,buy_num,add_count_time from train where player = %d", player);
	auto res = QueryRead(conection_, sql);
	if (res && !res.empty())
	{
		auto& row = res[0];
		buffers.available_train_count = row[GetFieldName(kfTrainNum)];
		buffers.used_buy_count = row[GetFieldName(kfBuyNum)];
		buffers.add_count_time = row[GetFieldName(kfAddCountTime)];
		return true;
	}
	return false;
}

bool DbSession::GetTowerInfo(UserID player, TowerInfo& tower_info)
{
	char sql[256];
	sprintf(sql,"select * from tower where player=%d",player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty())
	{
		auto& row = res[0];
		tower_info.tower = row[GetFieldName(kfTower)];
		tower_info.layer = row[GetFieldName(kfLayer)];
		tower_info.refresh = row[GetFieldName(kfRefresh)];
		tower_info.status = row[GetFieldName(kfStatus)];
		tower_info.suspend = row[GetFieldName(kfSuspend)];
		tower_info.time = row[GetFieldName(kfTime)];
		return true;
	}
	return false;
}

bool DbSession::GetTownWarehouse( UserID player, TownWarehouse& tw )
{
	tw.count = 0;
	char sql[256];
	sprintf(sql,"select * from town_warehouse where player=%d",player);
	auto res = QueryRead(conection_, sql);
	if( res)
	{
		for (const auto& row: res)
		{
			tw.items[tw.count].id = row[GetFieldName(kfID)];
			tw.items[tw.count].expired_time = row[GetFieldName(kfExpireTime)];
			++tw.count;
		}
		return true;
	}
	return false;
}

bool DbSession::GetTerritoryOffline(UserID player, TerritoryOffline& territory_offline)
{
	char sql[256];
	sprintf(sql,"select time from territory_offline where player=%d",player);
	auto res = QueryRead(conection_, sql);
	if( res && !res.empty())
	{
		auto& row = res[0];
		territory_offline.time = row[GetFieldName(kfTime)];

        sprintf(sql, "delete from territory_offline where player=%d", player);
        QueryWrite(conection_, sql);

		return true;
	}
	return false;
}

bool DbSession::GetStageAward( UserID player, StageAward& stage_award )
{
	stage_award.count = 0;
	char sql[256];
	sprintf(sql,"select * from stage_award where player=%d",player);
	auto res = QueryRead(conection_, sql);
	if( res)
	{
		for (const auto& row: res)
		{
			stage_award.list[stage_award.count].stage = row[GetFieldName(kfStage)];
			stage_award.list[stage_award.count].phase = row[GetFieldName(kfPhase)];
			stage_award.count++;
		}
		return true;
	}
	return false;
}
