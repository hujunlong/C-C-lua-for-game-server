#pragma once
#include "../system/mq_node.h"
#include "../protocol/db.h"


MQNode& CreateMQ2Gate(const char* apAddress);
MQNode& CreateMQ2DB(const char* apAddress);
MQNode& CreateMQ2World(const char* apAddress);
MQNode& CreateMQ4GM( const char* addr );

void Send2GM(MqHead& head, void* data, int32_t aLen);

struct GMSystemNotice
{
	uint32_t start_time;	//开始时间
	uint32_t end_time;		//结束时间
	uint32_t interval;		//间隔, 单位为秒
	uint32_t last_notice;	//上一次推送时间
	uint16_t type;			//公告类型	{跑马灯1,聊天框2,同时3}
	StringLength len;		//公告内容
	char	 notice[1024];	//公告内容
};

int  DoGMSystemNotice(GMSystemNotice& sn);
void ExeGMSystemNotice();


//

void InitAllUser();
//from gate

void Login( MqHead& head);

void Exit( MqHead& head);

void GetUserInfo(MqHead& head, p::GetUserInfoByName& get);
void GetUserInfo(MqHead& head, db::UserInfoResult& info, bool from_db);

void NotifyPlayerLineState( UserID uid, int8_t online );
void NotifyUserInfoChange(const NotifyPlayerInfoChange& cg);

void AddFriend( MqHead& head, const p::AddFriend& add);
void AddFriend( MqHead& head, const _User& friend_user, bool from_db);

void RemoveFriend( MqHead& head, const p::RemoveFriend& remove);

void AddFoe( MqHead& head, const p::AddFoe& add);
void AddFoe( MqHead& head, const _User& foe_user, bool from_db);

void RemoveFoe( MqHead& head, const p::RemoveFoe& remove);

void GetAssociatedUsersList( MqHead& head, const p::GetAssociatedUsersList& get);
void SetAssociatedUsersList(MqHead& head, const p::AssociatedUsersListResult& ass_users);

void SendPrivateText(MqHead& head, p::WhisperTo& whisper);
void SendPublicText(MqHead& head, p::TextTo& text);

void StoreUserInfo(const db::UserInfo& userinfo);

void SendMail(MqHead& head, p::PlayerSendMail& mail);
void SendMail2(MqHead& head, db::PlayerSendMail& mail, bool from_db);
void SendMail3(MqHead& head, db::SendMailResult& result);

void GetMailsList(MqHead& head, p::GetMailsList& get_list);
void GetMailsList(MqHead& head, p::MailsListResult& mails_list);
void GetMailNums(MqHead& head, p::GetMailNums& get_nums);
void GetMailNums(MqHead& head, p::MailNumsResult& nums);
void GetMail(MqHead& head, p::GetMail& get_mail);
void GetMail(MqHead& head, p::MailResult& mail);
void ExtractMailAttachment(MqHead& head, p::ExtractAttachment& ea);
void ExtractMailAttachment(MqHead& head, p::ExtractAttachmentResult& ear);
void DeleteMail(MqHead& head, p::DeleteMail& del_mail);
void DeleteMail(MqHead& head, p::DeleteMailResult& result);

void NotifyNewMail(MqHead& head, p::NotifyOfNewMail& notify);

