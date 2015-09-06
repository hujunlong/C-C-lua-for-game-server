#include "../system/cJSON.h"
#include "account.h"


bool g_anti = true;

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

template<typename Msg>
int32_t GetMsgFromJson(cJSON* object,int32_t type, Msg& msg)
{
	int32_t iret = 0;
	switch (type)
	{
	case kGMProveAntiAddiction:			//=9
		InternalProveAntiAddictionInfo* paa;
		paa = &msg;
		if( GetJsonString(object, "name", paa->name, sizeof(paa->name),paa->name_len)==kJsonError )
			return kJsonError;
		if( GetJsonString(object, "IDcard", paa->id, sizeof(paa->id),paa->id_len)==kJsonError )
			return kJsonError;
		break;
	default:
		break;
	}
	return kJsonSucceeded;
}

void ProcessMsgFromGate(const MqHead& h, uint8_t* data, size_t len)
{
	MqHead head = h;
	//printf("got msg: %d\n", h.type);
	switch ( h.type )
	{
	case InternalLogin::kType:
		DoUserLogin(head, (InternalLogin&)*data, g_anti);
		break;
	case InternalLoginSucceeded::kType:
		DoUserLoginSucceeded((InternalLoginSucceeded&)*data);
		break;
	case InternalLogout::kType:
		DoUserLogout((InternalLogout&)*data);
		break;
	case InternalRegister::kType:
		DoUserRegister(head, (InternalRegister&)*data);
		break;
	case InternalIsUidExist::kType:
		DoIsUidExist(head, (InternalIsUidExist&)*data);
		break;
	case InternalIsNicknameExist::kType:
		DoIsNicknameExist(head, (InternalIsNicknameExist&)*data);
		break;
	case InternalProveAntiAddictionInfo::kType:
		DoProveAntiAddictionInfo(head, (InternalProveAntiAddictionInfo&)*data);
		break;
	case KickUser::kType:
		DoKickUser( (KickUser&)*data );
		break;
	case p::GetAntiAddictionInfo::kType:
		DoGetAntiAddictionInfo(head);
		break;
	default:
		break;
	}
}

void SendMsg2GM(MqHead& head, void* data)
{
	cJSON* json;
	char*  json_str;
	uint16_t   json_len;
	char   json_res[256];
	json = cJSON_CreateObject();
	switch (head.type)
	{
	case kGMPlayerLogin:
		GMPlayerLogin * login;
		login = (GMPlayerLogin *)data;
		cJSON_AddNumberToObject(json, "loginTime", login->loginTime);
		cJSON_AddStringToObject(json, "ipAddress", login->ipAddress);
		break;
	case kGMPlayerRegister:
		GMPlayerRegister* reg;
		reg = (GMPlayerRegister*)data;
		cJSON_AddNumberToObject(json, "registerTime", reg->registerTime);
		cJSON_AddStringToObject(json, "ipAddress", reg->ipAddress);
		break;
	case kGMPlayerExit:
		GMPlayerExit* p_exit;
		p_exit = (GMPlayerExit*)data;
		cJSON_AddNumberToObject(json, "online_time", p_exit->online_time);
		break;
	case kGMNumberOfOnline:
		GMNumberOfOnline* p_online;
		p_online = (GMNumberOfOnline*)data;
		cJSON_AddNumberToObject(json, "number_of_online", p_online->number_of_online);
		cJSON_AddNumberToObject(json, "time", p_online->time);
		break;
	default:
		break;
	}
	json_str = cJSON_PrintUnformatted(json);
	cJSON_Delete(json);
	json_len = *(uint16_t*)json_res = strlen(json_str);
	memcpy(json_res+2, json_str, json_len+1);
	//printf("type=%d,len=%d, str=%s\n", head.type, (2+json_len), json_str);
	free(json_str);
	Push2GM(head, json_res, 2+json_len);
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
		case kGMProveAntiAddiction:
			InternalProveAntiAddictionInfo paa;
			paa.uid = head.aid;
			if( GetMsgFromJson(json, kGMProveAntiAddiction, paa)==kJsonError )
				break;
			result = DoGMProveAntiAddiction(head, paa);
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

int main(int argc, char* argv[])
{
	if (argc == 2)
	{
		if( atoi(argv[1]) ==0 )	//¹Ø±Õ·À³ÁÃÔ ./interact 0
			g_anti = false;
	}
	InitProcessor();

	int32_t major, minor, patch;
	zmq_version(&major, &minor, &patch);
	printf("zmq_version: %d.%d.%d\n",major, minor, patch);

	//connect to gate server
	auto& mq_gate = CreateMQ2Gate(kGateForAccount);

	//listen for gm
	auto& mq_gm = CreateMQ4GM(kAccountForGM);
	
	auto& mq_push_gm = CreateMQ4PushGM(kAccountForPushGM);

	uint32_t count = 0;
	for (;;)
	{
		DealwithMQ(mq_gate, ProcessMsgFromGate);
		DealwithMQ(mq_gm, ProcessMsgFromGM);

		++count;
		if(count>=100)
		{
			if( g_anti )
			{
				DoCalcOnlineTime();
			}
			{
				DoCalcNumberOfOnline();
			}
			
			count=0;
		}
		std::this_thread::sleep_for(std::chrono::milliseconds(10));
	}
	return 0;
}

