#pragma once

#include <climits>
#include <chrono>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <fstream>
#include <map>
#include "../system/mq_node.h"
#include "../protocol/common.h"


void InitAccount();

int32_t GetMyVersion();

MQNode& CreateMQ4Account(const char* apAddress );

void NotifyUserEnter2Account( int16_t flag, InternalLogin& login );

void NotifyUserLoginSucceeded2Account( InternalLoginSucceeded& ls );

void NotifyUserExit2Account( InternalLogout& logout );

void NotifyUserRegister2Account( int16_t flag, InternalRegister& reg);

void NotifyUidExist2Account(int16_t flag, InternalIsUidExist& ue);

void NotifyProveAntiAddictionInfo(int16_t flag, InternalProveAntiAddictionInfo& paa);

void NotifyKick2Account(KickUser& kick);

void ProcessMsg2Account( const MqHead& head, const uint8_t* data, size_t len );
