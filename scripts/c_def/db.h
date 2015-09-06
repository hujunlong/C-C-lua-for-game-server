#pragma once
#include "common.h"
#include "playgroud.h"


enum  DbType 
{
	kDbStart = 20000,
	kUserInfo,
	kUserInfoResult,
	kAssociatedUsers,
	kAddFriend,
	kRemoveFriend,
	kAddFoe,
	kRemoveFoe,
	kAddFriendInfo,
	kAddFoeInfo,
	//---------
	kPlayerSendMail = kDbStart+100,
	kSystemSendMail,
	kSendMailResult,
};

namespace db
{
struct UserInfo
{
	static const int16_t kType = kUserInfo;
	_User user;
};
struct UserInfoResult
{
	static const int16_t kType = kUserInfoResult;	//客户端使用uid或name请求用户信息
	GetUserInfoType type;
	_User user;
};
struct AddFriend
{
	static const int16_t kType = kAddFriend;
	UserID uid;
	UserID friend_id;
};

struct AddFriendInfo
{
	static const int16_t kType = kAddFriendInfo;
	_User user;
};
struct AddFoeInfo
{
	static const int16_t kType = kAddFoeInfo;
	_User user;
};
struct RemoveFriend
{
	static const int16_t kType = kRemoveFriend;
	UserID uid;
	UserID friend_id;
};

struct AddFoe
{
	static const int16_t kType = kAddFoe;
	UserID uid;
	UserID foe_id;
};

struct RemoveFoe
{
	static const int16_t kType = kRemoveFoe;
	UserID uid;
	UserID foe_id;
};

struct PlayerSendMail
{
	static const int16_t kType = kPlayerSendMail;
	Nickname sender_name;
	_User receiver;
	Mail mail;
	bool bIsFoe;
	bool bHosRelUnknow;//if true ,敌对关系不确定,请求数据库判断
	bool bSave;
};
struct SendMailResult
{
	static const int16_t kType = kSendMailResult;
	Result result_db;
	UserID rec_uid;
};

}//namespace db


