#include <iostream>
#include <vector>
#include "../protocol/internal.h"
#include "logic.h"
#include "all_users.h"
#include "../protocol/GM.h"
#include "../protocol/db.h"
#include "../protocol/broadcast.h"


namespace
{
	OnlineUsers g_online_users;		//在线用户
	AllUsers g_all_users;			//所有用户

	MQNode g_db_mq;					//db接口
	MQNode g_world_mq;				//world接口
}

namespace
{
	void StoreUser(const _User& user)
	{
		g_all_users.AddUser(user);
	}

	MQNode& GetGateMq()
	{
		static MQNode gate_mq;
		return gate_mq;
	}

	MQNode& GetWorldMq()
	{
		static MQNode world_mq;
		return world_mq;
	}

	MQNode& GetMQ4GM()
	{
		static MQNode gm_mq;
		return gm_mq;
	}

	//template<typename Msg>
	//void Send2GateBackup(UserID to, const Msg& msg)
	//{
	//	GetGateMq().Send(to, msg);
	//}

	template<typename Msg>
	void Send2Gate(MqHead& head, const Msg& msg)
	{
		GetGateMq().Send(head, msg);
	}

	template<typename Msg>
	void Send2Gate(MqHead& head, const Msg& msg, size_t aLen)
	{
		GetGateMq().Send(head.aid, msg.kType, head.flag, msg, aLen);
	}

}

void Send2GM(MqHead& head, void* data, int32_t aLen)
{
	GetMQ4GM().Send(head, data, aLen);
}

MQNode& CreateMQ2Gate( const char* apAddress )
{
	auto& node =  GetGateMq();
	node.Init(NodeType::kClient, apAddress);
	return node;
}

MQNode& CreateMQ2DB( const char* apAddress )
{
	g_db_mq.Init(NodeType::kClient, apAddress);
	return g_db_mq;
}

MQNode& CreateMQ2World( const char* apAddress )
{
	g_world_mq.Init(NodeType::kClient, apAddress);
	return g_world_mq;
}

MQNode& CreateMQ4GM( const char* addr )
{
	auto& mq = GetMQ4GM();
	mq.Init(NodeType::kServer, addr);
	return mq;
}

void InitAllUser()
{
	g_all_users.SetOnline(&g_online_users);
}



void Login( MqHead& head )
{
	UserEnter enter_msg;
	g_db_mq.Send(head, enter_msg);
	//
	g_online_users.Add(head.aid);
	NotifyPlayerLineState(head.aid, 1);
}

void Exit( MqHead& head )
{
	//UserExit exit_msg;
	//g_db_mq.Send(head, exit_msg);
	g_all_users.UserOffline(head.aid);
	//
	g_online_users.Remove(head.aid);
	NotifyPlayerLineState(head.aid, 0);
}

void StoreUserInfo(const db::UserInfo& userinfo )
{
	StoreUser( userinfo.user );
}

void GetUserInfo(MqHead& head, p::GetUserInfoByName& get)
{
	p::UserIDResult uid_result;
	uid_result.uid = 0;
	//判断字符串
	if( get.name.len<1 || get.name.len>sizeof(get.name.str) || get.name.str[0]==0 )
	{
		Send2Gate(head, uid_result);
		return;
	}
	db::UserInfoResult info;
	info.user.role.uid = 0;
	//是否存在此昵称
	if( g_all_users.SearchNickname( info.user, get.name) )
	{
		info.type = get.type;
		GetUserInfo(head, info, false);
	}else
	{
		g_db_mq.Send(head, get);
	}
}

void GetUserInfo(MqHead& head, db::UserInfoResult& info, bool from_db)
{
	UserID uid = info.user.role.uid;
	p::UserIDResult uid_result;
	uid_result.uid = uid;
	//是否来自数据库的消息
	if( from_db )
	{
		if( uid != 0)
			g_all_users.AddUser( info.user);
	}
	if(info.type == GetUserInfoType::kUserID)
	{
		Send2Gate(head, uid_result);
	}
}

void NotifyPlayerLineState( UserID uid, int8_t online )
{
	_User user;
	if( g_all_users.Find(user, uid) )
	{
		p::NotifyPlayerBaseInfo notify = { uid,online,0, (uint8_t)user.level, (int8_t)user.country, user.guild_id };
		MqHead h = { 0, notify.kType, -1 };
		auto func = [&h,&notify](UserID to_uid, int8_t bfriend)
		{
			h.aid = to_uid;
			notify.bfriend = bfriend;
			Send2Gate(h, notify);
		};
		g_online_users.DoEach(uid, func);
	}
}

void NotifyUserInfoChange(const NotifyPlayerInfoChange& cg)
{
	_User user;
	if( g_all_users.SetUser(cg, user) )
	{
		p::NotifyPlayerBaseInfo notify = { cg.uid, (int8_t)user.role.online, 0, (uint8_t)user.level, (uint8_t)user.country, user.guild_id };
		MqHead h = { 0, notify.kType, -1 };
		auto func = [&h,&notify](UserID to_uid, int8_t bfriend)
		{
			h.aid = to_uid;
			notify.bfriend = bfriend;
			Send2Gate(h, notify);
		};
		g_online_users.DoEach(cg.uid, func);
	}
}

void AddFriend( MqHead& head, const p::AddFriend& add)
{
	p::AddFriendResult result;
	if( add.friend_id == head.aid )
	{
		result.result = eAddFriendIsSelf;
		Send2Gate(head, result);
		return;
	}
	_User friend_user;
	//在缓存里查找用户
	if( g_all_users.Find(friend_user, add.friend_id) )
	{
		//这个用户已在缓存
		AddFriend(head, friend_user, false);
	}
	else
	{
		db::AddFriend db_add = { 0, add.friend_id };
		g_db_mq.Send(head, db_add);
	}
}

void AddFriend( MqHead& head, const _User& friend_user, bool from_db )
{
	int32_t iret = 0;
	UserID uid = head.aid;
	UserID friend_uid = friend_user.role.uid ;
	_User from_user;
	p::AddFriendResult result = {eInvalidValue};
	if( friend_uid == 0)//id判断
	{
		result.result = eAddFriendNotExist;
	}else if ( g_all_users.Find(from_user, uid) )//id判断
	{
		if( from_db )//来自db
			g_all_users.AddUser(friend_user);
		iret = g_online_users.AddFriend(uid, friend_uid );
		//添加好友成功
		if ( iret == OnlineUsers::AF_Succeeded)
		{
			result.result = eSucceeded;
			memcpy(&result.user, &friend_user, sizeof(_User));

			db::AddFriend add_friend = {uid, friend_uid };
			g_db_mq.Send(head, add_friend);

			if ( g_online_users.Has(friend_uid ) )//在线
			{
				p::NotifyOfAddFriend notify = { from_user.role };
				MqHead h = {friend_uid, (Type)notify.kType, -1};
				Send2Gate(h, notify);
			}
		}else if( iret == OnlineUsers::AF_AlreadyExist)//存在了
		{
			result.result = eAddFriendExist;
		}else if( iret == OnlineUsers::AF_MaxCount)//最大数量
		{
			result.result = eAddFriendMax;
		}
	}
	else
	{
		std::cout<< "Exception of AddFriend, file name is logic.cc" << std::endl;
	}
	Send2Gate(head, result);
}

void RemoveFriend( MqHead& head, const p::RemoveFriend& remove)
{
	UserID uid = head.aid;
	p::RemoveFriendResult result = { eInvalidValue };
	if (g_online_users.RemoveFriend(uid, remove.friend_id))//移除好友
	{
		db::RemoveFriend remove_friend = {uid, remove.friend_id};
		g_db_mq.Send(head, remove_friend);
		result.result = eSucceeded;
	}
	Send2Gate(head, result);
}

void AddFoe( MqHead& head, const p::AddFoe& add)
{
	p::AddFoeResult result;
	if( add.foe_id == head.aid )//是自已
	{
		result.result = eAddFoeIsSelf;
		Send2Gate(head, result);
		return;
	}
	_User foe_user;
	if (g_all_users.Find(foe_user, add.foe_id) )//找到缓存
	{
		AddFoe(head, foe_user, false);
	}
	else
	{
		db::AddFoe db_add = { 0, add.foe_id };
		g_db_mq.Send(head, db_add);
	}
}

void AddFoe( MqHead& head, const _User& foe_user, bool from_db)
{
	int32_t iret = 0;
	UserID uid = head.aid;
	UserID foe_uid = foe_user.role.uid;
	p::AddFoeResult result = {eInvalidValue};
	if( foe_uid == 0)//判断id
	{
		result.result = eAddFoeNotExist;
	}else
	{
		if( from_db )
			g_all_users.AddUser(foe_user);
		iret = g_online_users.AddFoe(uid, foe_uid);
		//添加黑名单
		if ( iret == OnlineUsers::AF_Succeeded)
		{
			result.result = eSucceeded;
			memcpy(&result.user, &foe_user, sizeof(_User));

			db::AddFoe add_foe = {uid, foe_uid};
			g_db_mq.Send(head, add_foe);
		}else if( iret == OnlineUsers::AF_AlreadyExist)//已经存在
		{
			result.result = eAddFoeExist;
		}else if(iret == OnlineUsers::AF_MaxCount)//最大数量
		{
			result.result = eAddFoeMax;
		}
	}
	Send2Gate(head, result);
}

void RemoveFoe( MqHead& head, const p::RemoveFoe& remove)
{
	UserID uid = head.aid;
	p::RemoveFoeResult result = { eInvalidValue };
	if (g_online_users.RemoveFoe(uid, remove.foe_id))//删除黑名单
	{
		db::RemoveFoe remove_foe = {uid, remove.foe_id};
		g_db_mq.Send(head, remove_foe);
		result.result = eSucceeded;
	}
	Send2Gate(head, result);
}

void GetAssociatedUsersList( MqHead& head, const p::GetAssociatedUsersList& get)
{
	UserID uid = head.aid;
	p::AssociatedUsersListResult users;
	users.list.len = 0;
	users.list.type = get.type;
	auto func = [&users](UserID id)
	{
		g_all_users.Find(users.list.users[users.list.len++], id);
	};
	g_online_users.DoEach(uid, get.type, func);
	Send2Gate(head, users, 4+sizeof(users.list.users[0])*users.list.len);
}

void SetAssociatedUsersList(MqHead& head, const p::AssociatedUsersListResult& ass_users )
{
	assert(ass_users.list.len <= (int16_t)ass_users.list.kMaxPersonsCount);
	UserID uids[ass_users.list.kMaxPersonsCount];
	for (int16_t i=0; i<ass_users.list.len; ++i)
	{
		uids[i] = ass_users.list.users[i].role.uid;
	}
	g_online_users.SetAssociatedUsers(head.aid, (UsersListType)ass_users.list.type, uids, ass_users.list.len);
	for (int16_t i=0; i<ass_users.list.len; ++i)
	{
		StoreUser(ass_users.list.users[i]);
	}
}

void SendPrivateText(MqHead& head, p::WhisperTo& whisper)
{
	p::WhisperToResult result = { 0 };
	p::WhisperFrom  info;
	if( !g_online_users.CanDo(head.aid, 1) )//能否发言(时间1秒)
		result.result = eCantSpeakNow;
	else if( head.aid == whisper.to_uid )//判断对象为自已
		result.result = eNotDoWithSelf;
	else if( whisper.msg_len<1 || whisper.msg_len > sizeof(whisper.msg) )//字串轻判断
		result.result = eInvalidValue;
	else
	{
		_User user;
		//使用昵称发信息
		if( whisper.to_uid==0 )//id
		{
			if( whisper.to_name.len>0 && whisper.to_name.len<=sizeof(whisper.to_name.str) && g_all_users.SearchNickname(user, whisper.to_name) )
				whisper.to_uid = user.role.uid;
			else
				result.result = eWhisperNotOnline;
		}
		//缓存查找
		if( g_all_users.Find(user, head.aid) )
		{
			//是否在线
			if( whisper.to_uid!=0 && g_online_users.Has(whisper.to_uid) )
			{
				//黑名单过滤
				if( g_online_users.IsFoe(whisper.to_uid, head.aid) )
					result.result = eCantSendToFoe;
				else
				{
					info.from_uid = head.aid;
					info.msg_len = whisper.msg_len;
					memcpy( info.msg, whisper.msg, info.msg_len );
					memcpy( &info.name, &user.role.nickname, sizeof(Nickname) );
					MqHead h = { whisper.to_uid, info.kType, -1 };
					Send2Gate(h, info, sizeof(info)-sizeof(info.msg)+info.msg_len);
					//
					g_all_users.Find( user, whisper.to_uid);
					h.aid = head.aid;
					result.result = eSucceeded;
					result.to_uid = whisper.to_uid;
					result.msg_len = whisper.msg_len;
					memcpy( result.msg, whisper.msg, result.msg_len );
					memcpy( &result.name, &user.role.nickname, sizeof(Nickname) );
				}
			}else
			{
				result.result = eWhisperNotOnline;
			}
		}else
			result.result = eInvalidValue;
	}
	Send2Gate(head, result, sizeof(result)-sizeof(result.msg)+result.msg_len);
}

void SendPublicText(MqHead& head, p::TextTo& text)
{
	p::TextToResult result;
	p::TextFrom text_info;
	if( !g_online_users.CanDo(head.aid, 1) )
		result.result = eCantSpeakNow;
	else if( text.msg_len<1 || text.msg_len > sizeof(text.msg) )//字串轻判断
	{
		result.result = eInvalidValue;
	}else
	{
		_User _user;
		if( g_all_users.Find( _user, head.aid ) )// 
		{
			result.result = eSucceeded;
			text_info.message_type = text.message_type;
			text_info.from_uid = head.aid;
			text_info.msg_len = text.msg_len;
			memcpy( text_info.msg, text.msg, text.msg_len);
			memcpy( &text_info.from_name, &_user.role.nickname, sizeof(Nickname) );
			//
			MqHead h = { 0, text.kType, -1 };
			//世界信息
			auto func_world = [&h,&text_info](UserID uid, int32_t unuse)
			{
				h.aid = uid;
				Send2Gate(h, text_info, sizeof(text_info)-sizeof(text_info.msg)+text_info.msg_len);
			};
			//国家信息
			auto func_country = [&h,&text_info](UserID uid, int32_t country)
			{
				_User user;
				if( g_all_users.Find(user, uid) )
				{
					if(user.country == (int16_t)country)
					{
						h.aid = uid;
						Send2Gate(h, text_info, sizeof(text_info)-sizeof(text_info.msg)+text_info.msg_len);
					}
				}
			};
			//公会信息
			auto func_guild = [&h,&text_info](UserID uid, int32_t guild_id)
			{
				_User user;
				if( g_all_users.Find(user, uid) )
				{
					if( user.guild_id == guild_id )
					{
						h.aid = uid;
						Send2Gate(h, text_info, sizeof(text_info)-sizeof(text_info.msg)+text_info.msg_len);
					}
				}
			};
			switch (text.message_type)
			{
			case p::TextType::kWorld:
				g_online_users.DoEach(func_world, text.message_type, _user.country, _user.guild_id );
				break;
			case p::TextType::kCountry:
				g_online_users.DoEach(func_country, text.message_type, _user.country, _user.guild_id);
				break;
			case p::TextType::kGuild:
				if( _user.guild_id != 0)
					g_online_users.DoEach(func_guild, text.message_type, _user.country, _user.guild_id);
				else
					result.result = eNotJoinGuild;
				break;
			//case p::TextType::kSystem:
			default:
				result.result = eInvalidValue;
				break;
			}
		}else
		{
			printf("SendPublicText <Sender_Role<uid; %d>> not exist, logic.cc\n", head.aid);
			return;
		}
	}
	Send2Gate(head, result);
}
//
void SendMail(MqHead& head, p::PlayerSendMail & send_mail)
{//from gate<player>, must call this func
	//
	p::PlayerSendMailResult mail_result;
	if( send_mail.mail.receiver_uid == head.aid )//不能是自已
	{
		mail_result.result = eReceiverIsSelf;
		Send2Gate(head, mail_result);
		return;
	}
	db::PlayerSendMail db_mail;
	db_mail.receiver.role.uid = 0;
	db_mail.bIsFoe = true;
	db_mail.bHosRelUnknow = true;
	db_mail.bSave = true;
	memcpy(&db_mail.mail,&send_mail.mail,sizeof(Mail));
	if (g_all_users.Has(send_mail.mail.receiver_uid) )//缓存
	{
		UserID rec_uid = send_mail.mail.receiver_uid;
		db_mail.receiver.role.uid = rec_uid;
		db_mail.bSave = false;
		//在线
		if( g_online_users.Has( rec_uid ) )
		{
			if( g_online_users.IsFoe( rec_uid, head.aid) )//黑名单
			{
				mail_result.result = eCantSendToFoe;
				Send2Gate(head, mail_result);
				return;
			}else
			{
				db_mail.bHosRelUnknow = false;
				db_mail.bIsFoe = false;
				SendMail2(head, db_mail, false);
				return ;
			}
		}
	}
	//check uid and decide hostile relation from db
	g_db_mq.Send(head,db_mail);
}

void SendMail2(MqHead& head, db::PlayerSendMail& send_mail,bool from_db)
{//from up or db, call this func
	//
	UserID sender_uid = head.aid;
	UserID receiver_uid = send_mail.receiver.role.uid;
	p::PlayerSendMailResult mail_result;

	if( receiver_uid == 0)
	{
		mail_result.result = eReceiverNotExist;
		Send2Gate(head,mail_result);
		return;
	}
	//来自数据库, 同时保存用户
	if( from_db && send_mail.bSave )
		g_all_users.AddUser( send_mail.receiver );
	//黑名单
	if( send_mail.bIsFoe || g_online_users.IsFoe(sender_uid, receiver_uid) )
	{
		mail_result.result = eCantSendToFoe;
		Send2Gate(head, mail_result);
		return;
	}

	_User sender_user;
	if( false == g_all_users.Find(sender_user, sender_uid ) )// 
	{
		printf("Exception SendMail< why don't sender_role<uid:%d> exist? >, filename is logic.cc\n",sender_uid);
		return;
	}
	//this mail will save to db, nickname must be sender.
	memcpy( &send_mail.sender_name,&sender_user.role.nickname,sizeof(Nickname) );
	//
	//search and replace sensitive words
	//
	g_db_mq.Send(head, send_mail);

}

void SendMail3(MqHead& head, db::SendMailResult& result)
{
	//
	p::PlayerSendMailResult mail_result = { result.result_db };
	if( result.result_db != eInvalidValue)//结果
	{
		if( g_online_users.Has(result.rec_uid) )//在线
		{
			p::NotifyOfNewMail notify = { result.result_db };
			MqHead recevier_head = { result.rec_uid, (int16_t)notify.kType, -1 };
			Send2Gate(recevier_head,notify);
		}
	}
	Send2Gate(head,mail_result);
}

void GetMailsList(MqHead& head, p::GetMailsList& get_list)
{
	g_db_mq.Send(head, get_list);
}

void GetMailsList(MqHead& head, p::MailsListResult& mails_list)
{
	Send2Gate(head, mails_list, 8+mails_list.len*sizeof(p::MailsListResult::MailInfo));
}

void GetMailNums(MqHead& head, p::GetMailNums& get_nums)
{
	g_db_mq.Send(head, get_nums);
}

void GetMailNums(MqHead& head, p::MailNumsResult& nums)
{
	Send2Gate(head, nums);
}

void GetMail(MqHead& head, p::GetMail& get_mail)
{
	g_db_mq.Send(head, get_mail);
}

void GetMail(MqHead& head, p::MailResult& mail)
{
	uint32_t s_size = (uint32_t)((char*)(&mail.content) - (char*)(&mail)) + (uint32_t)mail.len;
	Send2Gate(head, mail, s_size);
}

void ExtractMailAttachment(MqHead& head, p::ExtractAttachment& ea)
{
	p::ExtractAttachmentResult res = { eExtractAttachmentFailed };
	if( ea.mail_id > 100 || ea.mail_id == 0 )//邮件数量不超过100封的
		Send2Gate(head, res);
	else
	{
		ExtractAttachment e_ma;
		//发送给world提取附件
		e_ma.mail_id = ea.mail_id;
		e_ma.attach_id = ea.attach_id;
		g_world_mq.Send(head, e_ma);
	}
}

void ExtractMailAttachment(MqHead& head, p::ExtractAttachmentResult& ear)
{
	Send2Gate(head, ear);
}

void DeleteMail(MqHead& head, p::DeleteMail& del_mail)
{
	g_db_mq.Send(head, del_mail);
}

void DeleteMail(MqHead& head, p::DeleteMailResult& result)
{
	Send2Gate(head, result);
}

void NotifyNewMail(MqHead& head, p::NotifyOfNewMail& notify)
{
	Send2Gate(head, notify);
}













//GM

std::vector<GMSystemNotice> vector_gm_sn;
std::vector<GMSystemNotice>::iterator it_gm_sn;


int  DoGMSystemNotice(GMSystemNotice& sn)
{
	int32_t result = kGMInvalid;
	uint32_t cur_time = (uint32_t)time(nullptr);
	if(sn.start_time<=sn.end_time && cur_time<sn.end_time && sn.interval>0)
	{
		sn.last_notice = 0;
		vector_gm_sn.push_back(sn);
		result = kGMSucceced;
	}
	return result;
}

void ExeGMSystemNotice()
{
	uint32_t cur_time = (uint32_t)time(nullptr);
	if( cur_time==0xFFFFFFFF )
		return;
	SystemNotice sn;
	MqHead head;
	size_t size = 0;
	for( it_gm_sn=vector_gm_sn.begin(); it_gm_sn!=vector_gm_sn.end(); )
	{
		if( cur_time>=it_gm_sn->start_time )
		{
			if( it_gm_sn->end_time<=cur_time)
			{
				it_gm_sn = vector_gm_sn.erase(it_gm_sn);
			}
			else if(it_gm_sn->last_notice==0)
			{
				sn.type = it_gm_sn->type;
				sn.len = it_gm_sn->len;
				memcpy(sn.notice, it_gm_sn->notice, sn.len);
				size = 4 + sn.len;
				Send2Gate(head, sn, size);
				it_gm_sn->last_notice = cur_time;
				++it_gm_sn;
			}
			else if(it_gm_sn->last_notice+it_gm_sn->interval>=it_gm_sn->end_time)
			{
				it_gm_sn = vector_gm_sn.erase(it_gm_sn);
			}
			else if( cur_time-it_gm_sn->last_notice>=it_gm_sn->interval)
			{
				sn.type = it_gm_sn->type;
				sn.len = it_gm_sn->len;
				memcpy(sn.notice, it_gm_sn->notice, sn.len);
				size = 4 + sn.len;
				Send2Gate(head, sn, size);
				it_gm_sn->last_notice = cur_time;
				++it_gm_sn;
			}
			else
			{
				++it_gm_sn;
			}
		}else
			++it_gm_sn;
	}
}