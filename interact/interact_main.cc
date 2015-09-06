#include <zmq.hpp>
#include <thread>
#include <chrono>
#include "../mq/config.h"
#include "../system/mq_helper.h"
#include <iostream>
#include "../protocol/db.h"
#include "../protocol/internal.h"
#include "../system/cJSON.h"
#include "../protocol/GM.h"
#include "logic.h"



void ProcessMsgFromGate(const MqHead& h, uint8_t* data, size_t len)
{
	//printf("Got msg: %d from gate\n",h.type);
	MqHead head = h;
	switch ( head.type)
	{
	case p::Login::kType:
		break;

	case (int16_t)UserEnter::kType:
		Login(head);
		break;

	case p::Exit::kType:
		break;

	case (int16_t)UserExit::kType:
		Exit(head);
		break;

	case p::GetUserInfoByName::kType:
		GetUserInfo(head, (p::GetUserInfoByName&)*data);
		break;

	case p::AddFriend::kType:
		AddFriend(head, (p::AddFriend&)*data);
		break;

    case p::RemoveFriend::kType:
        RemoveFriend(head, (p::RemoveFriend&)*data);
        break;

	case p::AddFoe::kType:
		AddFoe(head, (p::AddFoe&)*data);
		break;

    case p::RemoveFoe::kType:
        RemoveFoe(head, (p::RemoveFoe&)*data);
        break;

    case p::GetAssociatedUsersList::kType:
        GetAssociatedUsersList(head, (p::GetAssociatedUsersList&)*data);
        break;

	case p::WhisperTo::kType:
		SendPrivateText(head, (p::WhisperTo&)*data);
		break;

	case p::TextTo::kType:
		SendPublicText(head, (p::TextTo&)*data);
		break;

	case p::PlayerSendMail::kType:
		SendMail(head,(p::PlayerSendMail&)*data);
		break;

	case p::GetMailsList::kType:
		GetMailsList(head, (p::GetMailsList&)*data);
		break;

	case p::GetMailNums::kType:
		GetMailNums(head, (p::GetMailNums&)*data);
		break;

	case p::GetMail::kType:
		GetMail(head, (p::GetMail&)*data);
		break;

	case p::ExtractAttachment::kType:
		ExtractMailAttachment(head,(p::ExtractAttachment&)*data);
		break;

	case p::DeleteMail::kType:
		DeleteMail(head, (p::DeleteMail&)*data);
		break;

	default:
		break;
	}
}

void ProcessMsgFromDb(const MqHead& h, uint8_t* data, size_t len)
{
	MqHead head = h;
	switch (head.type)
	{
	case db::UserInfoResult::kType:
		GetUserInfo(head, (db::UserInfoResult&)*data, true);
		break;

	case db::AddFriendInfo::kType:
		{
			const auto& add = (db::AddFriendInfo&)*data;
			AddFriend( head, add.user, true );
		}
		break;

	case db::AddFoeInfo::kType:
		AddFoe(head, ((db::AddFoeInfo&)*data).user, true);
		break;

	case db::UserInfo::kType:
		StoreUserInfo( (db::UserInfo&)*data );
		break;

	case p::AssociatedUsersListResult::kType:
		SetAssociatedUsersList( head,(p::AssociatedUsersListResult&)*data );
		break;

	case db::PlayerSendMail::kType:
		SendMail2(head, (db::PlayerSendMail&)*data, true);
		break;

	case db::SendMailResult::kType:
		SendMail3(head, (db::SendMailResult&)*data);
		break;

	case p::MailsListResult::kType:
		GetMailsList(head, (p::MailsListResult&)*data);
		break;

	case p::MailNumsResult::kType:
		GetMailNums(head, (p::MailNumsResult&)*data);
		break;

	case p::MailResult::kType:
		GetMail(head, (p::MailResult&)*data);
		break;

	case p::DeleteMailResult::kType:
		DeleteMail(head, (p::DeleteMailResult&)*data);
		break;

	default:
		break;

	}
}

void ProcessMsgFromWorld(const MqHead& h, uint8_t* data, size_t len)
{
	MqHead head = h;
	switch (head.type)
	{
	case ExtractAttachmentResult::kType:
		ExtractMailAttachment(head, (p::ExtractAttachmentResult&)*data);
		break;
	case NotifyOfNewMail::kType:
		NotifyNewMail(head, (p::NotifyOfNewMail&)*data);
		break;
	case NotifyPlayerInfoChange::kType:
		NotifyUserInfoChange((const NotifyPlayerInfoChange&)*data);
		break;
	default:
		break;
	}
}

#define kJsonSucceeded	0
#define kJsonError		-1

int32_t GetJsonNumber(cJSON * object, const char* string, int32_t& val)
{
	cJSON* json_val;
	json_val= cJSON_GetObjectItem( object, string);
	if(json_val && (json_val->type&255) == cJSON_Number)
	{
		val = json_val->valueint;
		return kJsonSucceeded;
	}
	return kJsonError;
}

int32_t GetJsonString(cJSON * object, const char* string, char* buff, StringLength len, StringLength& out_len)
{
	cJSON* json_val;
	uint16_t val_len;
	json_val= cJSON_GetObjectItem( object, string);
	if(json_val && (json_val->type&255) == cJSON_String)
	{
		val_len = strlen(json_val->valuestring);
		if( val_len!=0 )
		{
			val_len = len>=val_len?val_len:len;
			memcpy(buff, json_val->valuestring, val_len);
			out_len = val_len;
			return kJsonSucceeded;
		}
	}
	out_len = 0;
	return kJsonError;
}

void ProcessMsgFromGM(const MqHead& h, uint8_t* data, size_t len)
{
	cJSON* json;
	char*  json_str;
	char   json_res[64];
	uint16_t   json_len;
	MqHead head = h;
	int32_t result = kGMInvalid;

	//printf("got msg: %d\n", h.type);
	json=cJSON_Parse((const char*)(data+2));
	if( json && (json->type&0xFF)==cJSON_Object )
	{
		switch ( h.type )
		{
		case kGMSystemNotice:
			GMSystemNotice sn;
			if( GetJsonNumber(json, "start_time", (int32_t&)sn.start_time)==kJsonError )
				break;
			if( GetJsonNumber(json, "end_time", (int32_t&)sn.end_time)==kJsonError )
				break;
			if( GetJsonNumber(json, "interval", (int32_t&)sn.interval)==kJsonError )
				break;
			if( GetJsonNumber(json, "type", (int32_t&)sn.type) == kJsonError )
				break;
			if( GetJsonString(json, "string", sn.notice, sizeof(sn.notice), sn.len)==kJsonError )
				break;
			result = DoGMSystemNotice(sn);
			break;
		default:
			result = kGMUnknown;
			break;
		}
		cJSON_Delete(json);
	}else
	{
		result = kGMJsonFail;
	}
	json = cJSON_CreateObject();
	cJSON_AddNumberToObject(json, "result", result);
	json_str = cJSON_PrintUnformatted(json);
	cJSON_Delete(json);
	json_len = *(uint16_t*)json_res = strlen(json_str);
	memcpy(json_res+2, json_str, json_len+1);
	//printf("type=%d,len=%d, str=%s\n", head.type, (2+json_len), json_str);
	free(json_str);
	Send2GM(head, json_res, 2+json_len);
}

int main()
{
	//connect to gate server
	auto& mq_gate = CreateMQ2Gate(kGateForInteract);

	//connect to db server
	auto& mq_db = CreateMQ2DB(kDbForInteract);

	//connect to world server
	auto& mq_world = CreateMQ2World(kWorldForInteract);

	auto& mq_gm = CreateMQ4GM(kInteractForGM);

	//³õÊ¼»¯
	InitAllUser();

	uint32_t count = 0;

	for (;;)
	{
		DealwithMQ(mq_gate, ProcessMsgFromGate);
		DealwithMQ(mq_db, ProcessMsgFromDb);
		DealwithMQ(mq_world, ProcessMsgFromWorld);
		DealwithMQ(mq_gm, ProcessMsgFromGM);
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
		
		++count;
		if( count>=100 )
		{
			ExeGMSystemNotice();
			count = 0;
		}
	}
}

