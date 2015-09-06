#pragma once
#include "../system/mq_node.h"
#include "../protocol/common.h"

MQNode& CreateMQ4World(const char* apAddress );

void ProcessPlayerMsg2World(const MqHead& head, const uint8_t* data, size_t len);

void NotifyUserExit2World(UserID uid);

void NotifyUserEnter2World(UserID uid, int16_t flag);