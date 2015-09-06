#pragma once
#include <climits>
#include <chrono>
#include <cstdlib>
#include <iostream>
#include <thread>
#include "../system/mq_node.h"


MQNode& CreateMQ4Data(const char* apAddress );

void ProcessPlayerMsg2Data( const MqHead& head, const uint8_t* data, size_t len);