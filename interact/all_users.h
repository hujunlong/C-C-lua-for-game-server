#pragma once
#include "../protocol/common.h"
#include <boost/noncopyable.hpp>
#include <map>
#include <set>
#include <time.h>
#include <algorithm>


//在线用户类
class OnlineUsers : private  boost::noncopyable
{

public:
	OnlineUsers()
	{
		static_assert( kMaxFoesCount<=UsersList::kMaxPersonsCount 
			&& kMaxFriendsCount<=UsersList::kMaxPersonsCount,
			"Error max count" );
	}
	//添加用户
	void Add(UserID uid)
	{
		//printf("online add uid: %d \n",uid);
		//assert(!Has(uid));	//如果用户登录,然后断线,时间不长,再次登录,导致服务端判定其未登出,此断言出错
		users_.erase(uid);
		users_[uid] = OnlineUser();
		users_[uid].last_speak_time = 0;
	}
	//移除
	void Remove(UserID uid)
	{
		//printf("online remove uid: %d \n",uid);
		//assert( Has(uid) );  //如果interact启动前已经有用户连接到gate,此用户再退出,此断言就会报错
		users_.erase(uid);
	}
	//好友,黑名单
	void SetAssociatedUsers(UserID uid, UsersListType type, const UserID associate_uids[], size_t len)
	{
		auto iter = users_.find(uid);
		if (iter != users_.end())
		{
			switch (type)
			{
			case UsersListType::kFriend:
				iter->second.friends_set.insert(associate_uids, associate_uids+len);
				break;
			case UsersListType::kFoe:
				iter->second.foes_set.insert(associate_uids, associate_uids+len);
				break;
			default:
				break;
			}
		}
	}
	//加好友
	enum _AddFResult { AF_Succeeded=0, AF_Failed=1, AF_AlreadyExist=2, AF_MaxCount=3 };
	int32_t AddFriend(UserID uid, UserID friend_id)
	{
		auto iter = users_.find(uid);
		if (iter != users_.end())
		{
			if (iter->second.friends_set.size() < kMaxFriendsCount)
			{
				auto result = iter->second.friends_set.insert(friend_id);
				if(result.second == false)
					return AF_AlreadyExist;// friend already exist
				iter->second.foes_set.erase(friend_id);
				return AF_Succeeded;//succeeded
			}else
			{
				return AF_MaxCount; //max
			}
		}
		return AF_Failed;//false
	}
	//删除好友
	bool RemoveFriend(UserID uid, UserID friend_id)
	{
		auto iter = users_.find(uid);
		if (iter != users_.end())
		{
			iter->second.friends_set.erase(friend_id);
		}
		return true;
	}
	//添加黑名单
	int32_t AddFoe(UserID uid, UserID foe)
	{
		auto iter = users_.find(uid);
		if (iter != users_.end())
		{
			if (iter->second.foes_set.size() < kMaxFoesCount)
			{
				auto result = iter->second.foes_set.insert(foe);
				if(result.second == false)
					return AF_AlreadyExist;//foe already exist
				iter->second.friends_set.erase(foe);
				return AF_Succeeded;
			}else
			{
				return AF_MaxCount;//max
			}
		}
		return AF_Failed;
	}
	//移出黑名单
	bool RemoveFoe(UserID uid, UserID foe)
	{
		auto iter = users_.find(uid);
		if (iter != users_.end())
		{
			iter->second.foes_set.erase(foe);
		}
		return true;
	}
	//判断是否存在于黑名单中
	bool IsFoe(UserID uid, UserID other_uid)
	{
		auto iter = users_.find(uid);
		if(iter != users_.end())
		{
			auto foe_iter = iter->second.foes_set.find(other_uid);
			if( foe_iter != iter->second.foes_set.end() )
				return true;
		}
		return false;
	}
	//是否在线
	bool Has(UserID uid)
	{
		return users_.find(uid) != users_.end();
	}
	//可否发言
	bool CanDo( UserID uid, uint32_t interval )
	{
		auto iter = users_.find(uid);
		if(iter != users_.end())
		{
			uint32_t cur_time = (uint32_t)time(nullptr);
			if( (iter->second.last_speak_time+interval) <= cur_time )
			{
				iter->second.last_speak_time = cur_time;
				return true;
			}
		}
		return false;
	}

public:

	template<typename Func>
	void DoEach(UserID uid, UsersListType type, Func& f)
	{
		auto iter = users_.find(uid);
		if (iter != users_.end())
		{
			switch (type)
			{
			case UsersListType::kFriend:
				for (UserID id: iter->second.friends_set)
				{
					f(id);
				}
				break;
			case UsersListType::kFoe:
				for (UserID id: iter->second.foes_set)
				{
					f(id);
				}
				break;
			default:
				break;
			}
		}
	}
	template<typename Func>
	void DoEach(Func& func, p::TextType type, int16_t country, int16_t guild)
	{
		switch (type)
		{
		case p::TextType::kWorld:
			for( const auto& iter: users_)
			{
				func(iter.first, 0);
			}
			break;
		case p::TextType::kCountry:
			for( const auto& iter: users_ )
			{
				func(iter.first, country);
			}
			break;
		case p::TextType::kGuild:
			for( const auto& iter: users_)
			{
				func(iter.first, guild);
			}
			break;
		case p::TextType::kSystem:
			for( const auto& iter: users_)
			{
				func(iter.first, 0);
			}
			break;
		default:
			break;
		}
	}
	template<typename Func>
	void DoEach(UserID uid, Func& f)
	{
		for( const auto& iter: users_)
		{
			const auto& fiter = iter.second.friends_set.find(uid);
			if( fiter != iter.second.friends_set.end() )
			{
				f( iter.first, 1 );
			}else
			{
				const auto& foeiter = iter.second.foes_set.find(uid);
				if( foeiter != iter.second.foes_set.end() )
					f( iter.first, 0 );
			}
		}
	}
	
private:
	

private:
	struct OnlineUser
	{
		typedef std::set<UserID> SetType;
		SetType friends_set;
		SetType foes_set;
		SetType observers_set;
		uint32_t last_speak_time;
	};
	std::map<UserID,OnlineUser> users_;

private:
	enum {kMaxFriendsCount=50, kMaxFoesCount=20};

};
//所有用户类
class AllUsers
{
public:
	//包含在线指针
	void SetOnline(OnlineUsers* p)
	{
		p_online_users = p;
	}
	//添加
	void AddUser(const _User& user)
	{
		users_[user.role.uid] = user;
		if( p_online_users->Has(user.role.uid) )
			users_[user.role.uid].role.online = Role::OnlineStatus::kOnline;
		else
			users_[user.role.uid].role.online = Role::OnlineStatus::kOffline;
	}
	//设置用户信息
	bool SetUser(const NotifyPlayerInfoChange& cg, _User& user)
	{
		if( Has(cg.uid) )
		{
			if(cg.type==NotifyPlayerInfoChange::kLevelChange)
				users_[cg.uid].level = cg.data;
			else if(cg.type==NotifyPlayerInfoChange::kCountryChange)
				users_[cg.uid].country = cg.data;
			else if(cg.type==NotifyPlayerInfoChange::kGuildChange)
				users_[cg.uid].guild_id = cg.data;
			user = users_[cg.uid];
			return true;
		}
		return false;
	}
	//用户离线
	void UserOffline( UserID uid)
	{
		if( Has(uid) )
			users_[uid].role.online = Role::OnlineStatus::kOffline;
	}
	//是否存在
	bool Has(UserID uid)
	{
		return users_.find(uid) != users_.end();
	}
	//查找
	bool Find(_User& user, UserID uid)
	{
		auto iter = users_.find(uid);
		if (iter != users_.end())
		{
			user = iter->second;
			return true;
		}
		return false;
	}
	//搜索
	bool SearchNickname(_User& user, const Nickname& nickname)
	{
		for( const auto& iter : users_)
		{
			if( iter.second.role.nickname.len == nickname.len )
			{
				if( 0 == memcmp(iter.second.role.nickname.str, nickname.str, nickname.len))
				{
					user = iter.second;
					return true;
				}
			}
		}
		return false;
	}


private:
	std::map<UserID,_User> users_;
	OnlineUsers* p_online_users;
	//数据库更新level时需要通知interact更新用户级别, g_all_user.users_[uid].level
	//玩家所在工会id
};