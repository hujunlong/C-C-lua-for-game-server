#pragma once

#include "../system/mq_node.h"

MQNode& CreateMQ2DB(const char* apAddress);
MQNode& CreateMQ2Gate(const char* apAddress);
MQNode& CreateMQ4GM(const char* addr);
MQNode& CreateMQ4GM(const char* addr);
MQNode& CreateMQ4Interact( const char* addr );
MQNode& CreateMQ2WorldWar( const char* addr );

MQNode& GetMQ2DB();
MQNode& GetMQ2Gate();
MQNode& GetMQ4GM();
MQNode& GetMQ4GM();
MQNode& GetMQ4Interact();
MQNode& GetMQ2WorldWar();