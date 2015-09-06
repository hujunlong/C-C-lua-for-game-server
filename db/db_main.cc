#include "../system/mq_node.h"
#include <mysql++.h>
#include "../mq/config.h"
#include "../system/mq_helper.h"
#include <thread>
#include <chrono>
#include "db_session.h"
#include "../protocol/db.h"
#include "msg_process.h"



void ProcessMsgFromWorld( MqHead& head, uint8_t* data, int len )
{
	using namespace db;
	switch (head.type)
	{
	case UserEnter::kType:
		DoUserEnterWorld(head );
		break;
	case ExcuteSqlDirectly::kType:
		DoExcuteSqlDirectly(head.aid, (const ExcuteSqlDirectly&)*data);
		break;
	case InsertRow::kType:
		DoInsertRow(head.aid, (const InsertRow&)*data);
		break;
	case InsertRow2::kType:
		DoInsertRow2((const InsertRow2&)*data);
		break;
	case InsertBattleRecord::kType:
		DoInsertBattleRecord((const InsertBattleRecord&)*data);
		break;
	case UpdateField::kType:
		DoUpdateField(head.aid, (const UpdateField&)*data);
		break;
	case UpdateField2::kType:
		DoUpdateField2((const UpdateField2&)*data);
		break;
	case UpdateDeltaField::kType:
		DoUpdateDeltaField((const UpdateDeltaField&)*data);
		break;
	case DeleteRow::kType:
		DoDeleteRow(head.aid, (const DeleteRow&)*data);
		break;
	case TownBlocks::kType:
		DoSaveTownBlocks(head.aid, (const TownBlocks&)*data);
		break;
	case UpdateStringField::kType:
		DoUpdateStringField(head.aid, (const UpdateStringField&)*data);
		break;
	case UpdateStringField2::kType:
		DoUpdateStringField2((const UpdateStringField2&)*data);
		break;
	case UpdateBinaryStringField::kType:
		DoUpdateBinaryStringField((const UpdateBinaryStringField&)*data);
		break;
	case UpdateMultiFeilds2Value::kType:
		DoUpdateMultiFeilds2Value((const UpdateMultiFeilds2Value&)*data);
		break;
	case ReplaceIconBin::kType:
		DoReplaceIconBin((const ReplaceIconBin&)*data);
		break;
	case GuildApplication::kType:
		DoGuildApplication((const GuildApplication&)*data);
		break;
	case GuildWarFiles::kType:
		DoGuildWarFiles((const GuildWarFiles&)*data);
		break;
	case UpdateFieldWithSubIndex::kType:
		DoUpdateFieldWithSubIndex(head.aid, (const UpdateFieldWithSubIndex&)*data);
		break;
	case UpdateDeltaFieldWithSubIndex::kType:
		DoUpdateDeltaFieldWithSubIndex(head.aid, (const UpdateDeltaFieldWithSubIndex&)*data);
		break;		
	case InsertGuild::kType:
		DoInsertGuild((const InsertGuild&)*data);
		break;
	case DeleteGuild::kType:
		DoDeleteGuild((const DeleteGuild&)*data);
		break;
	case UpdateWarFieldGuild::kType:
		DoUpdateWarFieldGuild((UpdateWarFieldGuild&)*data);
		break;
	case InsertNewGuildGrade::kType:
		DoInsertNewGuildGrade((const InsertNewGuildGrade&)*data);
		break;
	case MemberLeaveGuild::kType:
		DoMemberLeaveGuild((const MemberLeaveGuild&)*data);
		break;
	case MemberJoinGuild::kType:
		DoMemberJoinGuild((const MemberJoinGuild&)*data);
		break;
	case QueryFightRecord::kType:
		DoQueryFightRecord(head, ((const QueryFightRecord&)*data).id);
	default:
		break;
	}
}

void ProcessMsgFromInteract( MqHead& head, uint8_t* data, int len )
{
	using namespace db;
	switch (head.type)
	{
	case UserEnter::kType:
		DoUserEnterInteract(head);
		break;

	case p::GetUserInfoByName::kType:
		DoGetUserInfo(head, (p::GetUserInfoByName&)*data );
		break;

	case db::PlayerSendMail::kType:
		DoSendMail(head, (db::PlayerSendMail&)*data);
		break;

	case p::GetMailsList::kType:
		DoGetMailsList(head, (p::GetMailsList&)*data );
		break;

	case p::GetMailNums::kType:
		DoGetMailNums(head);
		break;

	case p::GetMail::kType:
		DoGetMail( head, (p::GetMail&)*data );
		break;

	case p::DeleteMail::kType:
		DoDeleteMail(head, (p::DeleteMail&)*data );
		break;

	case db::AddFriend::kType:
		DoAddFriend(head, (const db::AddFriend&)*data);
		break;

	case db::AddFoe::kType:
		DoAddFoe(head, (const db::AddFoe&)*data );
		break;

	case db::RemoveFriend::kType:
		DoRemoveFriend( (const db::RemoveFriend&)*data);
		break;

	case db::RemoveFoe::kType:
		DoRemoveFoe( (const db::RemoveFoe&)*data );
		break;

	default:
		break;
	}
}


int main()
{
#ifdef WIN32
	WSADATA wsadata;
	auto ret = WSAStartup(0x0202, &wsadata);
#endif

	InitProcessor();

	// for world
	auto& world_node = CreateMQ4World(kDbForWorld);


	//for interact
	auto& interact_node = CreateMQ4Interact(kDbForInteract);



	//////////////////////////////////////////////////////////////////////////

	for (;;)
	{
		try
		{
			DealwithMQ(world_node, ProcessMsgFromWorld);
			DealwithMQ(interact_node, ProcessMsgFromInteract);
		}
		catch (std::exception& e)
		{
			std::cout <<e.what()<<std::endl;
		}
		catch (...)
		{
			std::cout <<"Unkown exception!"<<std::endl;
		}
		std::this_thread::sleep_for(std::chrono::milliseconds(1));
	}
}




static_assert(kfEnd<=256, "");
