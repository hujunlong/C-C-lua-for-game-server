#pragma once

#include "../system/mq_node.h"
#include "../protocol/common.h"

MQNode& CreateMQ4Interact(const char* apAddress );

void ProcessPlayerMsg2Interact( const MqHead& head, const uint8_t* data, size_t len);

void NotifyUserExit2Interact(UserID uid);

void NotifyUserEnter2Interact(UserID uid, int16_t flag);

