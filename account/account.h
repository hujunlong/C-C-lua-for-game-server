#pragma once
#include <thread>
#include <chrono>
#include "../mq/config.h"
#include "../system/mq_node.h"
#include "../system/mq_helper.h"
#include "../protocol/define.h"
#include "../protocol/common.h"
#include "../protocol/internal.h"
#include "../protocol/GM.h"

bool InitProcessor();

MQNode& CreateMQ2Gate( const char* apAddress );

MQNode& CreateMQ4GM( const char* apAddress );

MQNode& CreateMQ4PushGM(const char* addr);

void Send2GM(MqHead& head, void* data, int32_t aLen);

void Push2GM(MqHead& head, void* data, int32_t aLen);

void SendMsg2GM(MqHead& head, void* data);

void DoUserLogin( MqHead& h, InternalLogin& login, bool b_anti);

void DoUserLogout( InternalLogout& logout );

void DoUserRegister( MqHead& h, InternalRegister& reg);

void DoIsUidExist( MqHead& h, InternalIsUidExist& ue);

void DoIsNicknameExist( MqHead&h, InternalIsNicknameExist& ne);

void DoUserLoginSucceeded( InternalLoginSucceeded& ls );

void DoProveAntiAddictionInfo(MqHead& h,InternalProveAntiAddictionInfo& paa);

int32_t DoGMProveAntiAddiction(MqHead& h, InternalProveAntiAddictionInfo& paa);

void DoKickUser( KickUser& kick );

void DoGetAntiAddictionInfo(MqHead&h);

void DoCalcOnlineTime();

void DoCalcNumberOfOnline();

