-- phpMyAdmin SQL Dump
-- version 3.3.7
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2013 年 05 月 10 日 15:20
-- 服务器版本: 5.1.60
-- PHP 版本: 5.2.17p1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 数据库: `game`
--

-- --------------------------------------------------------

--
-- 表的结构 `account`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 08 日 13:42
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `account`;
CREATE TABLE IF NOT EXISTS `account` (
  `player` int(11) NOT NULL,
  `register_time` datetime NOT NULL,
  `last_logout_time` datetime NOT NULL,
  `enable` tinyint(4) NOT NULL COMMENT '允许登录',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `achievement`
--
-- 创建时间: 2013 年 04 月 19 日 14:58
-- 最后更新: 2013 年 05 月 10 日 13:17
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `achievement`;
CREATE TABLE IF NOT EXISTS `achievement` (
  `player` int(11) NOT NULL,
  `id` smallint(5) unsigned NOT NULL,
  `time` int(10) unsigned NOT NULL DEFAULT '0',
  KEY `player` (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='成就表';

-- --------------------------------------------------------

--
-- 表的结构 `action`
--
-- 创建时间: 2013 年 04 月 19 日 14:58
-- 最后更新: 2013 年 05 月 10 日 15:14
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `action`;
CREATE TABLE IF NOT EXISTS `action` (
  `player` int(11) NOT NULL,
  `id` smallint(5) unsigned NOT NULL,
  `kind` int(11) NOT NULL DEFAULT '0',
  `max` int(11) DEFAULT '0',
  `value` bigint(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`player`,`id`,`kind`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家行为统计   用于成就系统';

-- --------------------------------------------------------

--
-- 表的结构 `action_stamp`
--
-- 创建时间: 2013 年 04 月 22 日 11:18
-- 最后更新: 2013 年 05 月 10 日 00:00
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `action_stamp`;
CREATE TABLE IF NOT EXISTS `action_stamp` (
  `action` int(11) unsigned NOT NULL COMMENT '操作类型',
  `time` int(11) NOT NULL DEFAULT '0' COMMENT '执行时间戳',
  `name` text NOT NULL,
  PRIMARY KEY (`action`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='执行操作时间戳';

-- --------------------------------------------------------

--
-- 表的结构 `anti_addiction`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:20
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `anti_addiction`;
CREATE TABLE IF NOT EXISTS `anti_addiction` (
  `player` int(11) NOT NULL,
  `b_anti` tinyint(4) NOT NULL COMMENT '是否防沉迷',
  `online_time` int(10) unsigned NOT NULL COMMENT '累计在线',
  `logout_time` int(10) unsigned NOT NULL COMMENT '登出时间',
  `name` varchar(6) DEFAULT NULL COMMENT '名字',
  `id` char(18) DEFAULT NULL COMMENT '号码',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `arena_challenge`
--
-- 创建时间: 2013 年 05 月 07 日 16:43
-- 最后更新: 2013 年 05 月 10 日 15:14
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `arena_challenge`;
CREATE TABLE IF NOT EXISTS `arena_challenge` (
  `challenge_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增字段',
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `challenger` int(11) unsigned NOT NULL COMMENT '挑战ID',
  `rank_change` int(11) NOT NULL COMMENT '排名改变',
  `war_id` int(11) unsigned NOT NULL COMMENT '战报ID',
  PRIMARY KEY (`challenge_id`),
  KEY `player` (`player`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='竞技场挑战离线信息' AUTO_INCREMENT=612 ;

-- --------------------------------------------------------

--
-- 表的结构 `arena_history`
--
-- 创建时间: 2013 年 05 月 08 日 10:36
-- 最后更新: 2013 年 05 月 10 日 15:17
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `arena_history`;
CREATE TABLE IF NOT EXISTS `arena_history` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `target` int(11) unsigned NOT NULL COMMENT '对手ID',
  `winner` tinyint(4) unsigned NOT NULL,
  `rank_self` int(11) NOT NULL COMMENT '排名改变，0为未改变',
  `rank_target` int(11) NOT NULL COMMENT '排名改变，0为未改变',
  `war_id` int(11) unsigned NOT NULL COMMENT '战报ID',
  `time` int(11) unsigned NOT NULL COMMENT '发生时间',
  KEY `player` (`player`),
  KEY `target` (`target`),
  KEY `time` (`time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='竞技场战报历史记录';

-- --------------------------------------------------------

--
-- 表的结构 `arena_info`
--
-- 创建时间: 2013 年 05 月 07 日 16:44
-- 最后更新: 2013 年 05 月 10 日 15:14
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `arena_info`;
CREATE TABLE IF NOT EXISTS `arena_info` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `rank` int(11) unsigned NOT NULL COMMENT '排名',
  `reward` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '用于奖励的排名戳',
  `time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '最后挑战时间',
  `count` tinyint(4) NOT NULL DEFAULT '0' COMMENT '今日挑战次数',
  `buy_count` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '购买挑战次数',
  `win_count` smallint(11) unsigned NOT NULL DEFAULT '0' COMMENT '连续胜利次数',
  PRIMARY KEY (`player`),
  KEY `rank` (`rank`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='竞技场信息';

-- --------------------------------------------------------

--
-- 表的结构 `array`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 14:46
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `array`;
CREATE TABLE IF NOT EXISTS `array` (
  `player` int(11) NOT NULL,
  `id` tinyint(4) NOT NULL COMMENT '阵形id',
  `array` binary(10) NOT NULL COMMENT '阵形数据',
  KEY `player` (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `assistant`
--
-- 创建时间: 2013 年 05 月 09 日 15:56
-- 最后更新: 2013 年 05 月 10 日 15:14
--

DROP TABLE IF EXISTS `assistant`;
CREATE TABLE IF NOT EXISTS `assistant` (
  `player` int(11) NOT NULL,
  `activity` smallint(6) NOT NULL COMMENT '活跃度',
  `draw` smallint(4) NOT NULL COMMENT '奖励',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='小助手';

-- --------------------------------------------------------

--
-- 表的结构 `assistant_task`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:20
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `assistant_task`;
CREATE TABLE IF NOT EXISTS `assistant_task` (
  `player` int(11) NOT NULL,
  `task_id` int(11) NOT NULL COMMENT '任务id',
  `times` int(11) NOT NULL COMMENT '完成次数',
  `b_retrieve` tinyint(4) NOT NULL COMMENT '可否找回',
  `times_back` int(11) NOT NULL COMMENT '备份次数,用于找回',
  `remain_times` int(11) NOT NULL COMMENT '余下次数',
  KEY `player` (`player`,`task_id`),
  KEY `player_2` (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `auction`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 30 日 10:46
-- 最后检查: 2013 年 03 月 30 日 10:46
--

DROP TABLE IF EXISTS `auction`;
CREATE TABLE IF NOT EXISTS `auction` (
  `uuid` int(11) unsigned NOT NULL COMMENT '物品唯一ID',
  `seller` int(11) NOT NULL COMMENT '卖家',
  `buyer` int(11) NOT NULL DEFAULT '-1' COMMENT '最后出价玩家',
  `count` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '竞拍次数',
  `start` int(11) unsigned NOT NULL COMMENT '起拍价',
  `price` int(11) unsigned NOT NULL COMMENT '一口价',
  `time` int(11) unsigned NOT NULL COMMENT '结束时间',
  PRIMARY KEY (`uuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `auction_info`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 29 日 17:04
-- 最后检查: 2013 年 03 月 30 日 10:46
--

DROP TABLE IF EXISTS `auction_info`;
CREATE TABLE IF NOT EXISTS `auction_info` (
  `uuid` int(11) unsigned NOT NULL COMMENT '物品唯一ID',
  `seller` int(11) NOT NULL COMMENT '卖家',
  `buyer` int(11) NOT NULL DEFAULT '-1' COMMENT '买家',
  `status` tinyint(4) unsigned NOT NULL DEFAULT '3' COMMENT '{0=未卖出，没人买},{1=已卖出，竞拍成功},{2=已卖出，一口价购买},{3=正在出售,参与竞拍}',
  `price` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '金额',
  `kind` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '物品种类',
  `amount` smallint(6) unsigned NOT NULL COMMENT '数量',
  `time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '完成时间',
  PRIMARY KEY (`uuid`),
  KEY `player` (`seller`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `auction_offline`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `auction_offline`;
CREATE TABLE IF NOT EXISTS `auction_offline` (
  `uuid` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `kind` int(11) unsigned NOT NULL COMMENT '物品类型',
  `gold` int(11) unsigned NOT NULL COMMENT '返还金币',
  PRIMARY KEY (`uuid`),
  KEY `player` (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `base_info`
--
-- 创建时间: 2013 年 05 月 08 日 10:34
-- 最后更新: 2013 年 05 月 10 日 15:19
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `base_info`;
CREATE TABLE IF NOT EXISTS `base_info` (
  `player` int(11) NOT NULL COMMENT '玩家id',
  `nickname` varchar(6) NOT NULL COMMENT '昵称',
  `sex` tinyint(4) NOT NULL DEFAULT '0' COMMENT '性别',
  `country` tinyint(4) NOT NULL DEFAULT '0' COMMENT '国家',
  `gold` int(11) NOT NULL DEFAULT '0' COMMENT '金币',
  `silver` double NOT NULL DEFAULT '0' COMMENT '银币',
  `exp` int(11) NOT NULL DEFAULT '0' COMMENT '经验',
  `energy` smallint(6) unsigned NOT NULL DEFAULT '200' COMMENT '能量',
  `feat` int(11) NOT NULL DEFAULT '0' COMMENT ' 功绩',
  `prestige` int(11) NOT NULL DEFAULT '0' COMMENT '威望',
  `mobility` smallint(6) unsigned NOT NULL DEFAULT '200' COMMENT '行动力',
  `level` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '等级',
  `progress` smallint(6) NOT NULL DEFAULT '1' COMMENT '主线进度',
  `array` tinyint(6) NOT NULL DEFAULT '1' COMMENT '英雄阵形',
  `recharged_gold` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '充值金币',
  `guild_id` int(11) NOT NULL DEFAULT '0' COMMENT '公会ID',
  PRIMARY KEY (`player`),
  UNIQUE KEY `nickname` (`nickname`),
  KEY `country` (`country`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家（领主）基本信息';

-- --------------------------------------------------------

--
-- 表的结构 `battle_record`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:14
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `battle_record`;
CREATE TABLE IF NOT EXISTS `battle_record` (
  `id` bigint(20) unsigned NOT NULL COMMENT '战报ID',
  `record` blob NOT NULL COMMENT '战报',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='战报存储';

-- --------------------------------------------------------

--
-- 表的结构 `boss_section`
--
-- 创建时间: 2013 年 05 月 07 日 16:57
-- 最后更新: 2013 年 05 月 10 日 00:00
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `boss_section`;
CREATE TABLE IF NOT EXISTS `boss_section` (
  `player` int(11) NOT NULL,
  `id` smallint(6) NOT NULL COMMENT '关卡id',
  `times` tinyint(4) NOT NULL COMMENT '已击杀次数',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `branch_task`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 10:27
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `branch_task`;
CREATE TABLE IF NOT EXISTS `branch_task` (
  `player` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `accomplish` tinyint(4) NOT NULL DEFAULT '0' COMMENT '完成，0未完成，非0表示完成的次数   这个值暂时未使用',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家已完成的一次性支线任务';

-- --------------------------------------------------------

--
-- 表的结构 `business_building`
--
-- 创建时间: 2013 年 05 月 08 日 10:36
-- 最后更新: 2013 年 05 月 10 日 15:18
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `business_building`;
CREATE TABLE IF NOT EXISTS `business_building` (
  `player` int(11) NOT NULL COMMENT '玩家id',
  `id` int(11) NOT NULL COMMENT 'Town item ID',
  `kind` smallint(6) NOT NULL COMMENT '建筑物的sid',
  `x` tinyint(4) NOT NULL COMMENT 'x坐标',
  `y` tinyint(4) NOT NULL COMMENT 'y坐标',
  `aspect` tinyint(4) NOT NULL DEFAULT '0' COMMENT '方向',
  `warehoused` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否在仓库',
  `progress` tinyint(4) NOT NULL DEFAULT '0' COMMENT '建造进度',
  `last_reap` datetime NOT NULL DEFAULT '2010-01-01 00:00:00' COMMENT '最后一次收获时间',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `decoration`
--
-- 创建时间: 2013 年 04 月 18 日 16:49
-- 最后更新: 2013 年 05 月 10 日 15:17
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `decoration`;
CREATE TABLE IF NOT EXISTS `decoration` (
  `player` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `kind` smallint(6) NOT NULL,
  `x` tinyint(4) NOT NULL,
  `y` tinyint(4) NOT NULL,
  `aspect` tinyint(4) NOT NULL DEFAULT '0',
  `warehoused` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='字段注释参考business_building';

-- --------------------------------------------------------

--
-- 表的结构 `equipment`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 14:04
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `equipment`;
CREATE TABLE IF NOT EXISTS `equipment` (
  `player` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `level` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `strength` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '力量',
  `agility` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '敏捷',
  `intelligence` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '智力',
  `hero` smallint(6) NOT NULL DEFAULT '-1' COMMENT '装备在哪个英雄身上',
  `equiped` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否被装备过',
  `holes` binary(3) NOT NULL COMMENT '孔',
  `gems` binary(6) NOT NULL COMMENT '镶嵌的珠宝的kind',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `escort_info`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 04 月 12 日 00:00
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `escort_info`;
CREATE TABLE IF NOT EXISTS `escort_info` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `count` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '今日护送次数',
  `defend_count` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '今日护卫次数',
  `defend_total` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '护卫总次数',
  `intercept` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '今日拦截次数',
  `win_count` smallint(6) unsigned NOT NULL DEFAULT '0' COMMENT '连续胜利次数',
  `score` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '积分',
  `auto_accept` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '自动应答',
  `transport` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '交通工具',
  `time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '上次打劫时间',
  `refresh` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '刷新次数',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='护送基本信息';

-- --------------------------------------------------------

--
-- 表的结构 `escort_reward`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 08 日 13:42
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `escort_reward`;
CREATE TABLE IF NOT EXISTS `escort_reward` (
  `reward_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增字段',
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `transport` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '交通工具',
  `count` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '被拦截次数',
  `help` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '是否是帮手',
  `silver` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '获取银币/积分',
  `prestige` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '获取威望',
  PRIMARY KEY (`reward_id`),
  KEY `player` (`player`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='护送奖励离线信息' AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- 表的结构 `escort_road`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 08 日 13:42
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `escort_road`;
CREATE TABLE IF NOT EXISTS `escort_road` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `transport` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '交通工具',
  `guardian` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '护卫者',
  `time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '护送开始时间',
  `count` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '被拦截次数',
  `looter1` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '打劫者1',
  `looter2` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '打劫者2',
  `silver` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '获得银币',
  `prestige` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '获得威望',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='丝绸之路';

-- --------------------------------------------------------

--
-- 表的结构 `escort_robbed`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `escort_robbed`;
CREATE TABLE IF NOT EXISTS `escort_robbed` (
  `rob_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增字段',
  `player` int(11) unsigned NOT NULL COMMENT '护送/护卫者',
  `robber` int(11) unsigned NOT NULL COMMENT '打劫者',
  `help` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '是否是护卫者',
  `transport` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '交通工具',
  `winner` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '胜利',
  `silver` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '损失银币',
  `prestige` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '损失威望',
  PRIMARY KEY (`rob_id`),
  KEY `player` (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='护送打劫离线信息' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `fish`
--
-- 创建时间: 2013 年 05 月 02 日 16:47
-- 最后更新: 2013 年 05 月 10 日 15:13
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `fish`;
CREATE TABLE IF NOT EXISTS `fish` (
  `player` int(11) NOT NULL,
  `fish_times` tinyint(3) unsigned NOT NULL COMMENT '可钓鱼次数',
  `gold_times` tinyint(3) unsigned NOT NULL COMMENT '黄金次数',
  `torpedo_times` tinyint(3) unsigned NOT NULL COMMENT '鱼雷次数',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `fish_record`
--
-- 创建时间: 2013 年 05 月 06 日 14:52
-- 最后更新: 2013 年 05 月 10 日 15:10
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `fish_record`;
CREATE TABLE IF NOT EXISTS `fish_record` (
  `player` int(11) NOT NULL,
  `kind` smallint(5) unsigned NOT NULL COMMENT '鱼种类',
  `weight` smallint(5) unsigned NOT NULL COMMENT '重量',
  UNIQUE KEY `player` (`player`,`kind`),
  KEY `player_2` (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `foe`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 11:04
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `foe`;
CREATE TABLE IF NOT EXISTS `foe` (
  `player` int(11) NOT NULL,
  `foe` int(11) NOT NULL COMMENT '黑名单',
  UNIQUE KEY `player_2` (`player`,`foe`),
  KEY `player` (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `formula`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `formula`;
CREATE TABLE IF NOT EXISTS `formula` (
  `player` int(11) NOT NULL,
  `id` smallint(6) NOT NULL,
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `friend`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 11:04
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `friend`;
CREATE TABLE IF NOT EXISTS `friend` (
  `player` int(11) NOT NULL,
  `friend` int(11) NOT NULL COMMENT '好友',
  KEY `player` (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `function_building`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 14:05
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `function_building`;
CREATE TABLE IF NOT EXISTS `function_building` (
  `player` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `kind` smallint(6) NOT NULL,
  `x` tinyint(4) NOT NULL,
  `y` tinyint(4) NOT NULL,
  `aspect` tinyint(4) NOT NULL DEFAULT '0',
  `level` tinyint(4) unsigned NOT NULL DEFAULT '1',
  `progress` tinyint(4) NOT NULL DEFAULT '0',
  `last_reap` datetime NOT NULL DEFAULT '2000-11-11 00:00:00',
  PRIMARY KEY (`player`,`id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='字段注释参考business_building';

-- --------------------------------------------------------

--
-- 表的结构 `grade`
--
-- 创建时间: 2013 年 05 月 08 日 10:28
-- 最后更新: 2013 年 05 月 10 日 15:19
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `grade`;
CREATE TABLE IF NOT EXISTS `grade` (
  `player` int(11) NOT NULL COMMENT '玩家ID',
  `level` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '军阶',
  `progress` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '英雄激活状态{8位}',
  `reward` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否领取奖励',
  PRIMARY KEY (`player`),
  KEY `level` (`level`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='军阶系统';

-- --------------------------------------------------------

--
-- 表的结构 `guild`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:14
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild`;
CREATE TABLE IF NOT EXISTS `guild` (
  `guild_id` int(11) NOT NULL COMMENT '公会ID',
  `name` varchar(24) DEFAULT NULL COMMENT '公会名',
  `level` int(11) NOT NULL COMMENT '公会等级',
  `leader` int(11) NOT NULL COMMENT '会长id',
  `icon` int(11) NOT NULL COMMENT '公会图标',
  `icon_frame` int(11) NOT NULL COMMENT '会标框',
  `exp` int(11) NOT NULL COMMENT '公会经验',
  `activity_exp` int(11) NOT NULL COMMENT '活跃度',
  `heavensent` binary(20) NOT NULL COMMENT '天赋加点',
  `call_board` varchar(600) NOT NULL COMMENT '公告板',
  `worshiped_guild_count` int(11) NOT NULL DEFAULT '0' COMMENT '公会被膜拜次数',
  PRIMARY KEY (`guild_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='公会';

-- --------------------------------------------------------

--
-- 表的结构 `guild_application`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 09 日 16:44
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild_application`;
CREATE TABLE IF NOT EXISTS `guild_application` (
  `guild_id` int(32) NOT NULL COMMENT '公会id',
  `player_id` int(32) NOT NULL COMMENT '玩家id',
  `time` int(32) NOT NULL COMMENT '申请时间',
  `player_name` varchar(24) NOT NULL COMMENT '玩家名字',
  `player_level` int(11) NOT NULL COMMENT '玩家等级'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guild_authority`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 11:00
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild_authority`;
CREATE TABLE IF NOT EXISTS `guild_authority` (
  `guild_id` int(11) NOT NULL COMMENT '公会ID',
  `guild_grade_level` int(11) NOT NULL COMMENT '公会会阶等级',
  `grade_name` varchar(24) NOT NULL COMMENT '会阶名',
  `grade_authority` binary(8) NOT NULL COMMENT '会阶权限',
  UNIQUE KEY `id_grade_level` (`guild_id`,`guild_grade_level`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guild_giving`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 12:00
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild_giving`;
CREATE TABLE IF NOT EXISTS `guild_giving` (
  `guild_war_id` int(11) NOT NULL COMMENT '公会战场id',
  `guild_id` int(11) NOT NULL COMMENT '公会id',
  `guild_count` int(11) NOT NULL COMMENT '公会领取的宝箱个数',
  `box_type` int(11) NOT NULL,
  KEY `box_type` (`box_type`),
  KEY `guild_war_id` (`guild_war_id`),
  KEY `guild_id` (`guild_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guild_icon`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 08 日 13:42
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild_icon`;
CREATE TABLE IF NOT EXISTS `guild_icon` (
  `guild_id` int(11) NOT NULL COMMENT '公会ID',
  `icon_bin` blob NOT NULL COMMENT '上传图标',
  PRIMARY KEY (`guild_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='公会上传图标';

-- --------------------------------------------------------

--
-- 表的结构 `guild_map_sign_list`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 09 日 16:30
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild_map_sign_list`;
CREATE TABLE IF NOT EXISTS `guild_map_sign_list` (
  `guild_id` int(32) NOT NULL COMMENT '队ID',
  `war_field_id` int(32) NOT NULL COMMENT '地图ID'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guild_member_info`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:14
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild_member_info`;
CREATE TABLE IF NOT EXISTS `guild_member_info` (
  `player` int(11) NOT NULL COMMENT '玩家ID',
  `guild_id` int(11) NOT NULL COMMENT '公会ID',
  `guild_grade_level` int(11) NOT NULL COMMENT '公会职责等级',
  `guild_offer` int(11) NOT NULL COMMENT '公会贡献度(跟据 威望计算)',
  `player_fight_box` int(11) NOT NULL COMMENT '分配给玩家的公会战斗箱子',
  `player_guild_box` int(11) NOT NULL COMMENT '公会每日领取的箱子给玩家分配的',
  `player_box` int(11) NOT NULL COMMENT '玩家自己每天领取的箱子',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guild_war_fields`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 09 日 09:33
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild_war_fields`;
CREATE TABLE IF NOT EXISTS `guild_war_fields` (
  `id` int(11) NOT NULL COMMENT '战场ID',
  `guild_id` int(11) NOT NULL COMMENT '占领公会ID',
  `technology_level` int(11) NOT NULL COMMENT '科技等级',
  `technology_exp` int(11) NOT NULL COMMENT '科技当前经验',
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guild_war_member_info`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 12:00
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `guild_war_member_info`;
CREATE TABLE IF NOT EXISTS `guild_war_member_info` (
  `player` int(11) NOT NULL COMMENT '玩家ID',
  `guild_id` int(11) NOT NULL COMMENT '公会ID',
  `war_field_id` int(11) NOT NULL COMMENT '领地ID',
  `war_field_offer` int(11) NOT NULL COMMENT '领地贡献',
  `is_get_member_box` int(11) NOT NULL COMMENT '是否领取当天领地宝箱'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `hero`
--
-- 创建时间: 2013 年 05 月 08 日 13:40
-- 最后更新: 2013 年 05 月 10 日 15:20
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `hero`;
CREATE TABLE IF NOT EXISTS `hero` (
  `player` int(11) NOT NULL COMMENT '玩家id',
  `id` tinyint(6) NOT NULL COMMENT '英雄id，所有玩家到同一个英雄，id相同',
  `level` tinyint(6) unsigned NOT NULL DEFAULT '1' COMMENT '英雄等级',
  `location` tinyint(4) NOT NULL DEFAULT '0' COMMENT '英雄所在的阵位',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `exp` int(11) NOT NULL DEFAULT '0' COMMENT '英雄当前等级到经验',
  `bringup_bin` binary(12) NOT NULL COMMENT '培养信息',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `lord_buffer`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `lord_buffer`;
CREATE TABLE IF NOT EXISTS `lord_buffer` (
  `player` int(11) NOT NULL,
  `kind` smallint(6) NOT NULL COMMENT 'buffer的种类',
  `value` smallint(6) NOT NULL DEFAULT '0' COMMENT 'buffer当前值',
  `time` int(10) unsigned NOT NULL COMMENT '起始或结束时间，或者是总时间，或者是累计时间， 依具体的kind而定',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `mail`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 14:58
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `mail`;
CREATE TABLE IF NOT EXISTS `mail` (
  `player` int(11) NOT NULL,
  `mail_id` tinyint(3) unsigned NOT NULL COMMENT '邮件id',
  `read` tinyint(4) NOT NULL COMMENT '已读',
  `type` tinyint(4) NOT NULL COMMENT '邮件类型',
  `has_attach` tinyint(4) NOT NULL COMMENT '带附件',
  `time` int(10) unsigned NOT NULL COMMENT '过期时间',
  `uid` int(11) NOT NULL COMMENT '发送人',
  `nickname` varchar(6) NOT NULL COMMENT '发送人昵称',
  `subject` varchar(20) NOT NULL COMMENT '主题',
  `content` varchar(1000) NOT NULL COMMENT '内容',
  `attach` varbinary(264) DEFAULT NULL COMMENT '附件',
  PRIMARY KEY (`player`,`mail_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `misc_info`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:17
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `misc_info`;
CREATE TABLE IF NOT EXISTS `misc_info` (
  `player` int(11) NOT NULL,
  `fight_power` int(11) NOT NULL DEFAULT '0' COMMENT '玩家战斗力',
  `degree_of_prosperity` int(11) NOT NULL DEFAULT '0' COMMENT '玩家繁荣度',
  `worshiped_level_count` int(11) NOT NULL DEFAULT '0' COMMENT '玩家等级被膜拜次数',
  `worshiped_silver_count` int(11) NOT NULL DEFAULT '0' COMMENT '玩家银币被膜拜次数',
  `worshiped_fightingpower_count` int(11) NOT NULL DEFAULT '0' COMMENT '玩家战斗力被膜拜次数',
  `worshiped_degree_of_prosperity_count` int(11) NOT NULL DEFAULT '0' COMMENT '玩家繁荣度被膜拜次数',
  `used_worship_count` int(11) NOT NULL DEFAULT '0' COMMENT '膜拜使用次数',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `number_of_online`
--
-- 创建时间: 2013 年 05 月 02 日 16:25
-- 最后更新: 2013 年 05 月 10 日 15:09
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `number_of_online`;
CREATE TABLE IF NOT EXISTS `number_of_online` (
  `time` datetime NOT NULL,
  `amount` int(10) unsigned NOT NULL,
  PRIMARY KEY (`time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player_worship_list`
--
-- 创建时间: 2013 年 03 月 23 日 13:03
-- 最后更新: 2013 年 05 月 09 日 23:00
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `player_worship_list`;
CREATE TABLE IF NOT EXISTS `player_worship_list` (
  `player` int(11) NOT NULL COMMENT '玩家id',
  `worshiped_id` int(11) NOT NULL COMMENT '被膜拜玩家id',
  `type` int(11) NOT NULL COMMENT '1-4玩家相关，5公会'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家膜拜的链表';

-- --------------------------------------------------------

--
-- 表的结构 `playground`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 04 月 22 日 15:17
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `playground`;
CREATE TABLE IF NOT EXISTS `playground` (
  `player` int(11) NOT NULL,
  `tickets` int(10) unsigned NOT NULL COMMENT '游乐券',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playground_dragon`
--
-- 创建时间: 2013 年 05 月 08 日 16:54
-- 最后更新: 2013 年 05 月 08 日 16:54
-- 最后检查: 2013 年 05 月 08 日 16:54
--

DROP TABLE IF EXISTS `playground_dragon`;
CREATE TABLE IF NOT EXISTS `playground_dragon` (
  `dragon` int(11) NOT NULL AUTO_INCREMENT,
  `player` int(11) NOT NULL,
  `kind` smallint(6) NOT NULL COMMENT '种类',
  `sex` tinyint(4) NOT NULL COMMENT '性别',
  `signup` tinyint(4) NOT NULL COMMENT '报名',
  `strength` smallint(6) NOT NULL COMMENT '力量',
  `agility` smallint(6) NOT NULL COMMENT '敏捷',
  `intellect` smallint(6) NOT NULL COMMENT '智力',
  `max_str` smallint(6) NOT NULL COMMENT '最大力量',
  `max_agi` smallint(6) NOT NULL COMMENT '最大敏捷',
  `max_int` smallint(6) NOT NULL COMMENT '最大智力',
  `his_rank` int(11) NOT NULL COMMENT '最高名次',
  `m_time` int(11) NOT NULL COMMENT '可交配时间',
  `ch_name` tinyint(4) NOT NULL COMMENT '改过名',
  `d_name` varchar(21) NOT NULL COMMENT '名字',
  PRIMARY KEY (`dragon`,`player`),
  KEY `player` (`player`),
  KEY `dragon` (`dragon`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `playground_props`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `playground_props`;
CREATE TABLE IF NOT EXISTS `playground_props` (
  `player` int(11) NOT NULL,
  `kind` int(11) NOT NULL COMMENT '种类',
  `amount` int(11) NOT NULL COMMENT '数量',
  `buy_count` int(11) NOT NULL COMMENT '次数',
  KEY `player` (`player`,`kind`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playground_race_guess`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `playground_race_guess`;
CREATE TABLE IF NOT EXISTS `playground_race_guess` (
  `player` int(11) NOT NULL,
  `guess` smallint(6) NOT NULL COMMENT '竞猜赛道',
  `money` smallint(6) NOT NULL COMMENT '金额'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playground_race_history`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `playground_race_history`;
CREATE TABLE IF NOT EXISTS `playground_race_history` (
  `season` smallint(6) NOT NULL COMMENT '赛季',
  `rank` tinyint(4) NOT NULL COMMENT '名次',
  `dragon` int(11) NOT NULL,
  `player` int(11) NOT NULL,
  `raceway` tinyint(4) NOT NULL COMMENT '赛道',
  `live1` int(11) unsigned NOT NULL COMMENT '实况1',
  `live2` int(10) unsigned NOT NULL COMMENT '实况2',
  `speed` smallint(6) NOT NULL COMMENT '全速',
  `kind` smallint(6) NOT NULL COMMENT '种类',
  `ch_name` tinyint(4) NOT NULL COMMENT '是否改过名',
  `d_name` varchar(7) DEFAULT NULL COMMENT '龙名',
  PRIMARY KEY (`season`,`rank`,`dragon`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playground_race_signup`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `playground_race_signup`;
CREATE TABLE IF NOT EXISTS `playground_race_signup` (
  `order` int(11) NOT NULL COMMENT '报名顺序',
  `dragon` int(11) NOT NULL,
  `player` int(11) NOT NULL,
  `d_state` tinyint(4) NOT NULL COMMENT '龙的状态',
  `kind` smallint(6) NOT NULL COMMENT '种类',
  `strength` smallint(6) NOT NULL COMMENT '力量',
  `agility` smallint(6) NOT NULL COMMENT '敏捷',
  `intellect` smallint(6) NOT NULL COMMENT '智力',
  `raceway` tinyint(4) NOT NULL COMMENT '赛道',
  `rank` int(11) NOT NULL COMMENT '名次',
  `his_rank` int(11) NOT NULL COMMENT '历史名次',
  PRIMARY KEY (`order`,`dragon`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `playground_rear`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `playground_rear`;
CREATE TABLE IF NOT EXISTS `playground_rear` (
  `player` int(11) NOT NULL,
  `rooms` tinyint(4) NOT NULL COMMENT '育龙室数量',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `prop`
--
-- 创建时间: 2013 年 05 月 07 日 18:03
-- 最后更新: 2013 年 05 月 10 日 15:17
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `prop`;
CREATE TABLE IF NOT EXISTS `prop` (
  `uuid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `player` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `bind` tinyint(4) NOT NULL COMMENT '绑定',
  `location` tinyint(4) NOT NULL COMMENT '在区域中的位置',
  `amount` tinyint(6) NOT NULL DEFAULT '0' COMMENT '数量',
  `kind` smallint(6) NOT NULL COMMENT '道具sid',
  `area` tinyint(4) NOT NULL COMMENT '1=背包 2=仓库 3=英雄 4=回购区 5=宝石 6=拍卖行 7=附件',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `player` (`player`,`id`,`location`,`area`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=263418 ;

-- --------------------------------------------------------

--
-- 表的结构 `prop_setting`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 08 日 16:12
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `prop_setting`;
CREATE TABLE IF NOT EXISTS `prop_setting` (
  `player` int(11) NOT NULL,
  `bag_grids_count` tinyint(4) NOT NULL DEFAULT '21' COMMENT '背包的格子',
  `warehouse_grids_count` tinyint(4) NOT NULL DEFAULT '27' COMMENT '仓库的格子',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `purchase_count`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 03 月 22 日 10:29
--

DROP TABLE IF EXISTS `purchase_count`;
CREATE TABLE IF NOT EXISTS `purchase_count` (
  `player` int(11) NOT NULL,
  `id` tinyint(3) unsigned NOT NULL COMMENT '用来标识是何种消费',
  `count` tinyint(3) unsigned NOT NULL COMMENT '当日已购买的次数',
  PRIMARY KEY (`player`),
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家花金币购买的次数';

-- --------------------------------------------------------

--
-- 表的结构 `raiders`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 10:57
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `raiders`;
CREATE TABLE IF NOT EXISTS `raiders` (
  `type` int(11) NOT NULL COMMENT '记录类型 1剧情 2英雄 3试练塔',
  `id` int(11) NOT NULL COMMENT '第X关',
  `sub_id` int(11) NOT NULL COMMENT '第X个',
  `player` int(11) NOT NULL COMMENT '玩家ID',
  `record` int(11) NOT NULL COMMENT '战报ID',
  `level` int(11) NOT NULL COMMENT '玩家当时等级',
  `time` int(11) NOT NULL COMMENT '时间',
  PRIMARY KEY (`type`,`id`,`sub_id`,`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `road`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 09 日 09:41
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `road`;
CREATE TABLE IF NOT EXISTS `road` (
  `player` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `kind` smallint(6) NOT NULL,
  `x` tinyint(4) NOT NULL,
  `y` tinyint(4) NOT NULL,
  `aspect` tinyint(4) NOT NULL DEFAULT '0',
  `warehoused` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='城镇里的路';

-- --------------------------------------------------------

--
-- 表的结构 `rune_info`
--
-- 创建时间: 2013 年 05 月 08 日 10:30
-- 最后更新: 2013 年 05 月 10 日 15:11
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `rune_info`;
CREATE TABLE IF NOT EXISTS `rune_info` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家id',
  `id` int(11) unsigned NOT NULL COMMENT '符文id',
  `type` tinyint(4) unsigned NOT NULL COMMENT '符文类型｛SID｝',
  `location` tinyint(4) NOT NULL DEFAULT '-2' COMMENT '符文位置，-1背包，-2熔炉，其它英雄ID',
  `position` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '具体位置',
  `locked` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '是否锁定',
  `exp` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '总经验',
  PRIMARY KEY (`player`,`id`),
  KEY `location` (`location`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='符文信息【制造好的】';

-- --------------------------------------------------------

--
-- 表的结构 `rune_status`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:11
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `rune_status`;
CREATE TABLE IF NOT EXISTS `rune_status` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `status` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '点亮进度{使用前5位}',
  `energy` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '总能量',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='符文基本状态';

-- --------------------------------------------------------

--
-- 表的结构 `section`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 10:57
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `section`;
CREATE TABLE IF NOT EXISTS `section` (
  `player` int(11) NOT NULL,
  `id` smallint(6) NOT NULL COMMENT '主线的节的 id',
  `score` tinyint(4) NOT NULL DEFAULT '0' COMMENT '得分',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家关卡的信息（评分等）';

-- --------------------------------------------------------

--
-- 表的结构 `settings`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 14:53
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `settings`;
CREATE TABLE IF NOT EXISTS `settings` (
  `player` int(11) unsigned NOT NULL,
  `setting` tinyblob NOT NULL,
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='前端设置';

-- --------------------------------------------------------

--
-- 表的结构 `skill`
--
-- 创建时间: 2013 年 03 月 27 日 16:40
-- 最后更新: 2013 年 05 月 10 日 13:14
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `skill`;
CREATE TABLE IF NOT EXISTS `skill` (
  `player` int(11) NOT NULL COMMENT '玩家id',
  `id` tinyint(4) NOT NULL COMMENT '技能id',
  `level` tinyint(4) NOT NULL COMMENT '技能等级',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家科技等级';

-- --------------------------------------------------------

--
-- 表的结构 `status`
--
-- 创建时间: 2013 年 04 月 25 日 15:24
-- 最后更新: 2013 年 05 月 10 日 15:20
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `status`;
CREATE TABLE IF NOT EXISTS `status` (
  `player` int(11) NOT NULL,
  `last_logout_time` datetime NOT NULL COMMENT '最后一次注销时间',
  `last_active_time` int(10) unsigned NOT NULL COMMENT '最后一次活跃时间',
  `army_area` smallint(4) unsigned NOT NULL DEFAULT '0' COMMENT '部队所在的区域',
  `army_location` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '部队在区域中的位置点',
  `encounter_cd` tinyint(4) NOT NULL DEFAULT '0' COMMENT '地图上遇怪的剩余步数',
  `trunk_task_progress` tinyint(4) NOT NULL DEFAULT '1' COMMENT '当前主线任务的进度',
  `trunk_task` smallint(6) NOT NULL DEFAULT '1' COMMENT '当前进行的主线任务',
  `branch_task` int(6) NOT NULL DEFAULT '0' COMMENT '当前进行的支线任务',
  `branch_task_progress` tinyint(4) NOT NULL DEFAULT '0' COMMENT '当前支线任务的进度',
  `boss_killing_times` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已使用的boss怪击杀次数',
  `passed_section` smallint(6) NOT NULL DEFAULT '0' COMMENT '关卡打到哪里了（index）',
  `passed_boss_section` smallint(6) NOT NULL DEFAULT '0' COMMENT 'boss关卡进度',
  `replenish_time` int(10) unsigned NOT NULL COMMENT '补充体力到期时间',
  `back_time` int(10) unsigned NOT NULL COMMENT '回城时间',
  `stamina` smallint(5) unsigned NOT NULL DEFAULT '200' COMMENT '体力',
  `stamina_take` smallint(5) unsigned NOT NULL DEFAULT '100' COMMENT '携带体力',
  `fight_power` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '战斗力',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `territory`
--
-- 创建时间: 2013 年 04 月 28 日 09:02
-- 最后更新: 2013 年 05 月 10 日 15:02
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `territory`;
CREATE TABLE IF NOT EXISTS `territory` (
  `country` tinyint(4) unsigned NOT NULL COMMENT '国家',
  `type` tinyint(4) unsigned NOT NULL COMMENT '领地类型',
  `page` int(11) unsigned NOT NULL COMMENT '页数',
  `style` tinyint(4) unsigned NOT NULL COMMENT '该页分布类型',
  `seral` tinyint(4) unsigned NOT NULL COMMENT '序号',
  `kind` tinyint(4) unsigned NOT NULL COMMENT '0城池 1-10资源点',
  `owner` int(11) unsigned NOT NULL COMMENT '拥有者',
  PRIMARY KEY (`country`,`type`,`page`,`seral`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='服务器领地信息';

-- --------------------------------------------------------

--
-- 表的结构 `territory_info`
--
-- 创建时间: 2013 年 04 月 28 日 09:02
-- 最后更新: 2013 年 05 月 10 日 15:20
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `territory_info`;
CREATE TABLE IF NOT EXISTS `territory_info` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `skin` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '城池外观',
  `move` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '能否迁移',
  `grab` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '能否占领',
  `robber` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '剿匪次数',
  `assist` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '帮助次数',
  `time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '占领时间',
  `reap` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '收获时间',
  `move_cd` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '迁移CD',
  `grab_cd` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '占领CD',
  `kill_cd` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '剿匪CD',
  `last_active_time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '最近活动时间',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家领地信息';

-- --------------------------------------------------------

--
-- 表的结构 `territory_offline`
--
-- 创建时间: 2013 年 04 月 22 日 14:11
-- 最后更新: 2013 年 05 月 09 日 16:28
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `territory_offline`;
CREATE TABLE IF NOT EXISTS `territory_offline` (
  `player` int(11) NOT NULL COMMENT '玩家ID',
  `time` int(11) NOT NULL COMMENT '收回时间',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='领地离线消息';

-- --------------------------------------------------------

--
-- 表的结构 `top_rank`
--
-- 创建时间: 2013 年 05 月 08 日 17:36
-- 最后更新: 2013 年 05 月 10 日 15:17
--

DROP TABLE IF EXISTS `top_rank`;
CREATE TABLE IF NOT EXISTS `top_rank` (
  `player` int(11) NOT NULL DEFAULT '0' COMMENT '玩家id',
  `rank_level` int(11) NOT NULL DEFAULT '0' COMMENT '经验排名',
  `level_num` int(11) NOT NULL DEFAULT '0' COMMENT '经验多少',
  `worshiped_level_count` int(12) NOT NULL COMMENT '等级膜拜次数',
  `rank_silver` int(11) NOT NULL DEFAULT '0' COMMENT '银币排名',
  `silver_num` int(11) NOT NULL DEFAULT '0' COMMENT '银币数据',
  `worshiped_silver_count` int(11) NOT NULL COMMENT '银币膜拜次数',
  `rank_fightingpower` int(11) NOT NULL DEFAULT '0' COMMENT '战斗力排名',
  `fightingpower_num` int(11) NOT NULL DEFAULT '0' COMMENT '战斗力数据',
  `worshiped_fightingpower_count` int(11) NOT NULL COMMENT '战斗力膜拜次数',
  `rank_degree_of_prosperity` int(11) NOT NULL DEFAULT '0' COMMENT '繁荣度排名',
  `degree_of_prosperity_num` int(11) NOT NULL DEFAULT '0' COMMENT '繁荣度数据',
  `worshiped_degree_of_prosperity_count` int(11) NOT NULL COMMENT '繁荣度膜拜次数',
  `nickname` varchar(6) NOT NULL COMMENT '呢称',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `tower`
--
-- 创建时间: 2013 年 04 月 18 日 11:38
-- 最后更新: 2013 年 05 月 10 日 15:14
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `tower`;
CREATE TABLE IF NOT EXISTS `tower` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `tower` tinyint(4) unsigned NOT NULL DEFAULT '1' COMMENT '试炼塔进度',
  `layer` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '层进度',
  `refresh` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '刷新次数',
  `status` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '0挑战 >0 扫荡塔数',
  `suspend` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '扫荡挂起层数',
  `time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '挑战CD',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `town`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 09 日 17:36
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `town`;
CREATE TABLE IF NOT EXISTS `town` (
  `player` int(11) NOT NULL,
  `blocks` binary(36) NOT NULL COMMENT '开启的区域',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='玩家的城镇相关信息存储';

-- --------------------------------------------------------

--
-- 表的结构 `town_warehouse`
--
-- 创建时间: 2013 年 04 月 28 日 17:31
-- 最后更新: 2013 年 05 月 10 日 15:17
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `town_warehouse`;
CREATE TABLE IF NOT EXISTS `town_warehouse` (
  `player` int(11) NOT NULL,
  `id` int(11) NOT NULL COMMENT '建筑id',
  `expire_time` int(11) unsigned NOT NULL COMMENT '到期时间',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `train`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:08
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `train`;
CREATE TABLE IF NOT EXISTS `train` (
  `player` int(4) NOT NULL COMMENT '玩家id',
  `train_num` smallint(6) NOT NULL DEFAULT '0' COMMENT '训练次数',
  `buy_num` smallint(6) NOT NULL DEFAULT '0' COMMENT '购买次数',
  `add_count_time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '最后加点时间',
  `buy_last_train_time` int(11) NOT NULL COMMENT '购买训练最后一次时间',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `tree_log`
--
-- 创建时间: 2013 年 05 月 08 日 17:52
-- 最后更新: 2013 年 05 月 10 日 15:01
--

DROP TABLE IF EXISTS `tree_log`;
CREATE TABLE IF NOT EXISTS `tree_log` (
  `player` int(11) NOT NULL,
  `id` tinyint(3) unsigned NOT NULL COMMENT 'id',
  `uid` int(11) NOT NULL COMMENT '来访玩家',
  `time` int(10) unsigned NOT NULL COMMENT '动作时间',
  PRIMARY KEY (`player`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `tree_seed`
--
-- 创建时间: 2013 年 05 月 06 日 14:58
-- 最后更新: 2013 年 05 月 10 日 15:18
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `tree_seed`;
CREATE TABLE IF NOT EXISTS `tree_seed` (
  `player` int(11) NOT NULL,
  `location` tinyint(3) unsigned NOT NULL COMMENT '种子位置',
  `watered` tinyint(3) unsigned NOT NULL COMMENT '今日浇神水次数',
  `kind` smallint(5) unsigned NOT NULL COMMENT '果实种类',
  `status` tinyint(4) NOT NULL COMMENT '果实状态',
  `ripe_time` int(10) unsigned NOT NULL COMMENT '剩余成熟时间',
  `last_water` int(10) unsigned NOT NULL COMMENT '上一次浇灌时间',
  UNIQUE KEY `player` (`player`,`location`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `tree_water`
--
-- 创建时间: 2013 年 05 月 06 日 14:13
-- 最后更新: 2013 年 05 月 10 日 15:07
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `tree_water`;
CREATE TABLE IF NOT EXISTS `tree_water` (
  `player` int(11) NOT NULL,
  `water_amount` tinyint(3) unsigned NOT NULL COMMENT '神水数量',
  `buy_count` tinyint(3) unsigned NOT NULL COMMENT '购买次数',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `turntable`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 14:53
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `turntable`;
CREATE TABLE IF NOT EXISTS `turntable` (
  `player` int(11) NOT NULL,
  `times` tinyint(3) unsigned NOT NULL COMMENT '剩余次数',
  `re_times` smallint(5) unsigned NOT NULL COMMENT '今日重转次数',
  `cur_point` tinyint(4) NOT NULL COMMENT '当前指向',
  `result` smallint(6) NOT NULL COMMENT '转盘结果',
  `should_return` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否应该重转',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `vip_count`
--
-- 创建时间: 2013 年 03 月 22 日 10:29
-- 最后更新: 2013 年 05 月 10 日 15:11
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `vip_count`;
CREATE TABLE IF NOT EXISTS `vip_count` (
  `player` int(10) unsigned NOT NULL COMMENT '玩家ID',
  `energy` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '购买能量次数',
  `mobility` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '购买行动力次数',
  `alchemy` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '使用炼金术次数',
  `rune` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '符文激活次数',
  PRIMARY KEY (`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='VIP系统各种次数';

-- --------------------------------------------------------

--
-- 表的结构 `world_boss`
--
-- 创建时间: 2013 年 04 月 18 日 16:56
-- 最后更新: 2013 年 05 月 10 日 15:00
-- 最后检查: 2013 年 05 月 08 日 13:42
--

DROP TABLE IF EXISTS `world_boss`;
CREATE TABLE IF NOT EXISTS `world_boss` (
  `id` tinyint(4) unsigned NOT NULL COMMENT 'BOSS ID',
  `level` tinyint(4) unsigned NOT NULL COMMENT '等级',
  `dead` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '0活着，1死亡',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

DELIMITER $$
--
-- 存储过程
--
DROP PROCEDURE IF EXISTS `AddDragon`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddDragon`(
in _player int,in _kind smallint,in _sex tinyint,
in _strength smallint, in _agility smallint,in _intellect smallint,
in _max_str smallint, in _max_agi smallint, in _max_int smallint)
BEGIN
insert into playground_dragon 
(player,kind,sex,signup,strength,agility,intellect,max_str,max_agi,max_int,
his_rank,m_time,ch_name)
values(_player,_kind,_sex,0,_strength,_agility,_intellect,_max_str,
_max_agi,_max_int,0,0,0);
select last_insert_id() as dragon;
END$$

DROP PROCEDURE IF EXISTS `add_guild`$$
CREATE DEFINER=`root`@`%` PROCEDURE `add_guild`(IN _guild_id int,IN _guild_name varchar(24),IN _leader int,IN _icon int,IN _guild_level1_name varchar(24),IN _guild_level2_name varchar(24),IN _guild_level100_name varchar(24))
BEGIN
	#插入新公会
	INSERT INTO guild(guild_id, guild.name, guild.level, leader, icon, icon_frame, exp, activity_exp, heavensent) VALUES(_guild_id, _guild_name, 1 , _leader , _icon, 1, 0, 0,0x0100020003000400050006000700080009000a00);
	#插入会阶
	INSERT INTO guild_authority(guild_id, guild_grade_level, grade_name, grade_authority) VALUES(_guild_id, 1,  _guild_level1_name, 0x0101010101010101);	#对应8种权限，每种权限1个字节
	INSERT INTO guild_authority(guild_id, guild_grade_level, grade_name, grade_authority) VALUES(_guild_id, 2,  _guild_level2_name, 0x0101010100000000);	#后期添加权限时候需做对应修改
	INSERT INTO guild_authority(guild_id, guild_grade_level, grade_name, grade_authority) VALUES(_guild_id, 100, _guild_level100_name, 0x0100000000000000);
	#绑定到玩家
	UPDATE base_info SET guild_id=_guild_id WHERE player=_leader;
	#插入成员信息
	INSERT INTO guild_member_info(player, guild_id, guild_grade_level, guild_offer) VALUES(_leader, _guild_id, 1, 0);
END$$

DROP PROCEDURE IF EXISTS `add_heros`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_heros`(_id_start int, _id_end int)
begin
	repeat
		insert into hero (player,id) values(_id_start,1);
		insert into hero (player,id) values(_id_start,2);
		set _id_start = _id_start+1;
	UNTIL _id_start>=_id_end
	end repeat;
end$$

DROP PROCEDURE IF EXISTS `add_new_guild_grade`$$
CREATE DEFINER=`root`@`%` PROCEDURE `add_new_guild_grade`(IN _guild_id int,IN _new_guild_grade int,IN _guild_new_grade_name varchar(24))
BEGIN
	#插入新会阶
	INSERT INTO guild_authority(guild_id, guild_grade_level, grade_name, grade_authority) VALUES(_guild_id, _new_guild_grade, _guild_new_grade_name, 0x0100000000000000);
END$$

DROP PROCEDURE IF EXISTS `create_player`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_player`(in _id int,in _name char(6),in _sex int)
BEGIN
declare v_had,result int default 0;
select count(*) into v_had from base_info where player=_id or nickname=_name;
if v_had=0 then
insert into base_info (player,nickname, sex, progress, gold, silver) values(_id, _name, _sex,1, 200, 0);
insert into misc_info (player) values(_id);
		insert into town (player,blocks) values(_id, 0x000000000000000000000000000e0f000000001415000000000000000000000000000000);
		insert into prop_setting (player,bag_grids_count,warehouse_grids_count) values(_id,20,20);
		insert into hero (player,id,location,status) values(_id,17,2,1);
		insert into hero (player,id,location,status) values(_id,21,5,1);
		insert into skill (player,id,level) values(_id,12,1);
		insert into status(player) values(_id);
                insert into train(player) values(_id);
		insert into settings (player) values(_id);
		insert into prop (player, id, location, amount, kind, area) values(_id, 1, 3,1,10025,3);
		insert into equipment (player, id, hero, equiped) values(_id,1,17,1);
		insert into prop (player, id, location, amount, kind, area) values(_id, 2, 3,1,10027,3);
		insert into equipment (player, id, hero,equiped) values(_id,2,21,1);
                insert into prop (player, id, location, amount, kind, area) values(_id, 3, 0,1,2101,1);
		
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '13', '3004', '27', '0', '0', '71');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '19', '3004', '18', '0', '0', '82');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '9', '3004', '28', '0', '0', '100');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '13', '3006', '19', '0', '0', '101');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '19', '3006', '27', '0', '0', '102');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '12', '3006', '31', '0', '0', '103');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '23', '3004', '28', '0', '0', '104');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '19', '3023', '19', '0', '0', '106');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '13', '3023', '16', '0', '0', '107');
INSERT INTO `decoration` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '22', '3006', '22', '0', '0', '109');
INSERT INTO `function_building` (`level`, `x`, `id`, `y`, `aspect`, `player`, `kind`, `progress`) VALUES ('1', '11', '1', '28', '3', _id, '1001', '6');
INSERT INTO `function_building` (`level`, `x`, `id`, `y`, `aspect`, `player`, `kind`, `progress`) VALUES ('1', '9', '2', '22', '3', _id, '1007', '1');
INSERT INTO `function_building` (`level`, `x`, `id`, `y`, `aspect`, `player`, `kind`, `progress`) VALUES ('1', '16', '3', '22', '3', _id, '1017', '1');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '16', '3030', '20', '0', '0', '12');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '18', '3030', '20', '0', '0', '13');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3030', '30', '0', '1', '27');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '22', '3030', '20', '0', '2', '29');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3030', '28', '0', '1', '42');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3030', '20', '0', '3', '44');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3030', '24', '0', '1', '45');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3030', '22', '0', '1', '46');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3030', '30', '0', '1', '72');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '10', '3030', '20', '0', '0', '75');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3030', '20', '0', '3', '76');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '12', '3030', '20', '0', '0', '81');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '20', '3030', '26', '0', '1', '95');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3030', '28', '0', '0', '96');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3030', '26', '0', '0', '97');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3030', '24', '0', '0', '98');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '14', '3030', '22', '0', '0', '99');
INSERT INTO `road` (`player`, `x`, `kind`, `y`, `warehoused`, `aspect`, `id`) VALUES (_id, '8', '3030', '20', '0', '0', '108');

insert into playground (player,tickets) values(_id,0);
insert anti_addiction (player,b_anti,online_time,logout_time) values(_id,1,0,0);
insert assistant (player,activity) values(_id,0);
insert account (player,register_time,`enable`) values(_id, now(), 1);
	set result=1;
else
	select count(*) into v_had from base_info where player=_id;
	if v_had!=0 then
		set result=2;
	else
		set result=3;
	end if;
end if;
select result;
END$$

DROP PROCEDURE IF EXISTS `del_guild`$$
CREATE DEFINER=`root`@`%` PROCEDURE `del_guild`(IN _guild_id int)
BEGIN
	#删除公会
	DELETE FROM guild WHERE guild_id=_guild_id;
	#删除公会对应会阶
	DELETE FROM guild_authority WHERE guild_id=_guild_id;
	#玩家跟公会解绑
	UPDATE base_info SET guild_id=0 WHERE guild_id=_guild_id;
	#删除成员信息
	DELETE FROM guild_member_info WHERE guild_id=_guild_id;
	#删除公会自定义图标
	DELETE FROM guild_icon WHERE guild_id=_guild_id;
	#删除公会仓库数据
	DELETE FROM guild_giving WHERE guild_id=_guild_id;
	#删除公会时需要特别注意,因公会子表很多,需要同时删除子表相关信息
	#特别是后期新添加的数据库
END$$

DROP PROCEDURE IF EXISTS `GetAllTownItems`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllTownItems`(_uid int)
L:
begin
	select * from function_building where player=_uid;
	select * from business_building where player=_uid;
	select * from decoration where player=_uid;
	select * from road where player=_uid;
end L$$

DROP PROCEDURE IF EXISTS `GetFoes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFoes`(in uid int)
BEGIN
select a.player,a.nickname,a.sex,a.country,a.`level`,a.guild_id 
from base_info as a inner join foe as b 
on a.player=b.foe where b.player=uid limit 20;
END$$

DROP PROCEDURE IF EXISTS `GetFriends`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFriends`(in uid int)
BEGIN
	select a.player,a.nickname,a.sex,a.country,a.`level`,a.guild_id 
from base_info as a inner join friend as b 
on a.player=b.friend where b.player=uid limit 50;
END$$

DROP PROCEDURE IF EXISTS `GetGuildMembersInfo`$$
CREATE DEFINER=`root`@`%` PROCEDURE `GetGuildMembersInfo`(IN _guild_id int)
BEGIN
	#取公会成员列表
	SELECT base_info.player, base_info.nickname, base_info.sex, base_info.level, guild_member_info.guild_grade_level, guild_member_info.guild_offer, guild_authority.grade_name, status.last_logout_time
	FROM base_info, status, guild_authority, guild_member_info
	WHERE base_info.player=status.player and base_info.guild_id=guild_authority.guild_id and base_info.player = guild_member_info.player and guild_member_info.guild_grade_level=guild_authority.guild_grade_level and base_info.guild_id=_guild_id;
END$$

DROP PROCEDURE IF EXISTS `GetGuildsInfo`$$
CREATE DEFINER=`root`@`%` PROCEDURE `GetGuildsInfo`()
BEGIN
	#取所有公会信息
	SELECT guild.guild_id, guild.level, guild.leader, base_info.nickname, icon, icon_frame, guild.exp, guild.activity_exp, guild.name, heavensent, call_board
	FROM guild, base_info
	WHERE guild.guild_id = base_info.guild_id and guild.leader = base_info.player
	ORDER BY guild.guild_id;
END$$

DROP PROCEDURE IF EXISTS `GetMail`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMail`(in uid int, in timet int unsigned,in mailid tinyint)
BEGIN
delete from mail where player=uid and `time`<timet and has_attach=0;
select has_attach,content,attach from mail where player=uid and mail_id=mailid;
update mail set `read`=1 where player=uid and mail_id=mailid;
END$$

DROP PROCEDURE IF EXISTS `GetMailAttachments`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMailAttachments`(
in _player int, in _timet int unsigned, in _mailid tinyint)
BEGIN
declare v_type,v_attach tinyint default 0;
delete from mail where player=_player and `time`<_timet and has_attach=0;
select `type`,has_attach into v_type,v_attach from mail where player=_player and mail_id=_mailid;
if ifnull(v_attach,false) then
	if v_attach=1 and v_type=1 then
		select attach from mail where player=_player and mail_id=_mailid;
	end if;
end if;
END$$

DROP PROCEDURE IF EXISTS `GetMailNums`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMailNums`(in uid int, in timet int unsigned)
BEGIN
delete from mail where player=uid and `time`<timet and has_attach=0;
select count(*) from mail where player=uid;
END$$

DROP PROCEDURE IF EXISTS `GetMailsList51`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMailsList51`(in _uid int, in _timet int unsigned)
BEGIN
delete from mail where player=_uid and `time`<_timet and has_attach=0;
select `mail_id`,`read`,`type`,`has_attach`,`time`,`uid`,`nickname`,`subject` from mail
	           where player=_uid order by has_attach desc,time desc limit 100;
END$$

DROP PROCEDURE IF EXISTS `GetPlayerBasicInfo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPlayerBasicInfo`(_uid int)
L:
begin
	select * from base_info where player=_uid;
end L$$

DROP PROCEDURE IF EXISTS `GetRaceDragonGuessInfo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRaceDragonGuessInfo`()
BEGIN
declare pp1,pp2,pp3,pp4,pp5,pp6,pp7,pp8,pp9,pp10,pp11,pp12 smallint default 0;
declare mm1,mm2,mm3,mm4,mm5,mm6,mm7,mm8,mm9,mm10,mm11,mm12 int unsigned default 0;
select count(*) into pp1 from playground_race_guess where guess=1;
select count(*) into pp2 from playground_race_guess where guess=2;
select count(*) into pp3 from playground_race_guess where guess=3;
select count(*) into pp4 from playground_race_guess where guess=4;
select count(*) into pp5 from playground_race_guess where guess=5;
select count(*) into pp6 from playground_race_guess where guess=6;
select count(*) into pp7 from playground_race_guess where guess=7;
select count(*) into pp8 from playground_race_guess where guess=8;
select count(*) into pp9 from playground_race_guess where guess=9;
select count(*) into pp10 from playground_race_guess where guess=10;
select count(*) into pp11 from playground_race_guess where guess=11;
select count(*) into pp12 from playground_race_guess where guess=12;

if pp1!=0 then
	select sum(money) into mm1 from playground_race_guess where guess=1;
end if;
if pp2!=0 then
	select sum(money) into mm2 from playground_race_guess where guess=2;
end if;
if pp3!=0 then
	select sum(money) into mm3 from playground_race_guess where guess=3;
end if;
if pp4!=0 then
	select sum(money) into mm4 from playground_race_guess where guess=4;
end if;
if pp5!=0 then
	select sum(money) into mm5 from playground_race_guess where guess=5;
end if;
if pp6!=0 then
	select sum(money) into mm6 from playground_race_guess where guess=6;
end if;
if pp7!=0 then
	select sum(money) into mm7 from playground_race_guess where guess=7;
end if;
if pp8!=0 then
	select sum(money) into mm8 from playground_race_guess where guess=8;
end if;
if pp9!=0 then
	select sum(money) into mm9 from playground_race_guess where guess=9;
end if;
if pp10!=0 then
	select sum(money) into mm10 from playground_race_guess where guess=10;
end if;
if pp11!=0 then
	select sum(money) into mm11 from playground_race_guess where guess=11;
end if;
if pp12!=0 then
	select sum(money) into mm12 from playground_race_guess where guess=12;
end if;
select pp1,pp2,pp3,pp4,pp5,pp6,pp7,pp8,pp9,pp10,pp11,pp12,mm1,mm2,mm3,mm4,mm5,mm6,mm7,mm8,mm9,mm10,mm11,mm12;

END$$

DROP PROCEDURE IF EXISTS `join_guild`$$
CREATE DEFINER=`root`@`%` PROCEDURE `join_guild`(IN _player int,IN _guild_id int)
BEGIN
	#进入公会
	UPDATE base_info SET guild_id=_guild_id WHERE player=_player;

	#插入成员信息
	INSERT INTO guild_member_info(player, guild_id, guild_grade_level, guild_offer) VALUES(_player, _guild_id, 100, 0);
END$$

DROP PROCEDURE IF EXISTS `leave_guild`$$
CREATE DEFINER=`root`@`%` PROCEDURE `leave_guild`(IN _player int)
BEGIN
	#退出公会
	UPDATE base_info SET guild_id=0 WHERE player=_player;

	#删除自己的信息
	DELETE FROM guild_member_info WHERE player=_player;
END$$

DROP PROCEDURE IF EXISTS `ModifyAssistantTask`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ModifyAssistantTask`(
in _uid int, in _task_id int, in _times int, 
in _b_retrieve tinyint, in _times_back int,
in _remain_times int)
BEGIN
declare v_amount int default 0;
select count(*) into v_amount from assistant_task where player=_uid and task_id=_task_id;
if v_amount=0 then
	insert assistant_task (player,task_id,times,b_retrieve,times_back,remain_times) values(_uid,_task_id,_times,0,0,_remain_times);
else
	update assistant_task set times=_times,b_retrieve=_b_retrieve,times_back=_times_back,remain_times=_remain_times where player=_uid and task_id=_task_id;
end if;
END$$

DROP PROCEDURE IF EXISTS `ModifyPlaygroundProp`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ModifyPlaygroundProp`(
in _uid int, in _kind int, in _amount int, in _buy_count int)
BEGIN
declare v_amount int default 0;
select count(*) into v_amount from playground_props where player=_uid and kind=_kind;
if v_amount=0 then
	insert playground_props (player,kind,amount,buy_count) values(_uid,_kind,_amount,_buy_count);
else
	update playground_props set amount=_amount,buy_count=_buy_count where player=_uid and kind=_kind;
end if;
END$$

DROP PROCEDURE IF EXISTS `myliy_add_good_into_storehouse`$$
CREATE DEFINER=`root`@`%` PROCEDURE `myliy_add_good_into_storehouse`(`_player` int,`_prop_start` int,`_prop_end` int,`_addtime` int,`_is_can_overlap` int)
BEGIN
	#向仓库添加道具
  #玩家ID _player
  #道具ID区间 [_prop_start,_prop_end]
  #添加次数 _addtime
  #是否可叠加 _is_can_overlap ,1表示可叠加,0表示不可叠加

  DECLARE num int DEFAULT 0;
  DECLARE _loop int DEFAULT 0; 
  DECLARE maxid int DEFAULT 0;
  DECLARE _location int DEFAULT 0;
  DECLARE _holes BINARY DEFAULT 0x010101;
  DECLARE _amount int DEFAULT 1;

  IF _is_can_overlap=1 THEN
     SET _amount = 99;
  end if;

  #清空仓库
  DELETE FROM prop where area=2;
  
  SET maxid = (SELECT MAX(id) FROM prop);
  WHILE _prop_start <= _prop_end DO
    SET _loop = 0;
    WHILE _loop < _addtime DO
      set maxid = maxid + 1;
      SET _loop = _loop + 1;
      INSERT INTO prop (player,id,location,amount,kind,area) VALUES (_player,maxid,_location,_amount,_prop_start,2);
      SET _location = _location + 1;
      IF _prop_start > 10001 THEN
        DELETE FROM equipment where player=_player and id=maxid;
        INSERT INTO equipment (player,id,level) VALUES (_player,maxid,1);
        UPDATE equipment SET holes=0x010101 WHERE player=_player AND id=maxid;
      END if;
    END WHILE;
    SET _prop_start = _prop_start + 1;
  END WHILE;

END$$

DROP PROCEDURE IF EXISTS `myliy_add_heros`$$
CREATE DEFINER=`root`@`%` PROCEDURE `myliy_add_heros`(IN `_start_id` int,IN `_end_id` int,IN `_hero_id` int,IN `_hero_end_id` int)
BEGIN
  #测试用 批量添加英雄
  DECLARE i INT DEFAULT 0;
  DECLARE new_start_id INT DEFAULT 0;

  WHILE _hero_id<=_hero_end_id DO
    SET new_start_id = _start_id;
    WHILE new_start_id<=_end_id DO
      SET i = (SELECT COUNT(*) FROM hero WHERE player=new_start_id AND id=_hero_id);
      IF i=0 THEN
        INSERT INTO hero (id,`level`,`status`,`exp`,player) VALUES (_hero_id,1,1,0,new_start_id);
      END IF;
      UPDATE hero SET `status`=1,exp=0,`level`=1 WHERE player=_start_id AND id=_hero_id;
      SET new_start_id = new_start_id+1;
    END WHILE;
    SET _hero_id = _hero_id + 1;
  END WHILE;
END$$

DROP PROCEDURE IF EXISTS `myliy_update_trunk_task`$$
CREATE DEFINER=`root`@`%` PROCEDURE `myliy_update_trunk_task`(IN `_start_id` int,IN `_end_id` int,IN `_main_task_progress` smallint,IN `_main_task` smallint,IN `_country` int,IN `_is_random_country` bit)
BEGIN
	#测试用，修改主线进度
  #[_start_id,_end_id]玩家ID区间
  #_main_task_progress=2时为国家城建场景，其他数值表示为罗德岛场景
  #_main_task为主线任务进度，当main_task_progress=2时该值应大于配置表上的获得封地任务对应ID，其他应小于等于选择国家对应ID
  #_is_random_country是否随机国家，1是，0否
  DECLARE i INT DEFAULT 0;
  DECLARE m INT DEFAULT 0;

  WHILE _start_id <= _end_id DO
    SET i = (SELECT COUNT(*) FROM `status` WHERE player=_start_id);
    IF i > 0 THEN
      UPDATE `status` SET trunk_task_progress=_main_task_progress,trunk_task=_main_task WHERE player=_start_id;
    END IF;
    IF _main_task_progress=2 THEN
      UPDATE town SET blocks=0x000000000000708090000000d0e0f000000131415000000000000000000000000000000 WHERE player=_start_id;
      IF _is_random_country = 0 THEN
        UPDATE base_info SET country=_country where player=_start_id;
      ELSE
        SET m = CEIL(RAND()*3);
        UPDATE base_info SET country=m WHERE player=_start_id;
      END IF;
    END IF;
    SET _start_id = _start_id + 1;
  END WHILE;

END$$

DROP PROCEDURE IF EXISTS `RaceDragonSignup`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RaceDragonSignup`(
in _player int, in _dragon int)
BEGIN
declare vk,vs,va,vi,vh int default 0;
declare vorder int default 0;

select max(`order`) into vorder from playground_race_signup;
set vorder=vorder+1;
select kind,strength,agility,intellect,his_rank 
	into vk,vs,va,vi,vh from playground_dragon where dragon=_dragon;
insert into playground_race_signup (`order`,dragon,player,kind,strength,agility,intellect,raceway,rank,his_rank)
	value (vorder,_dragon,_player,vk,vs,va,vi,0,0,vh);
update playground_dragon set signup=1 where dragon=_dragon;
END$$

DROP PROCEDURE IF EXISTS `RearDragonChangeName`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `RearDragonChangeName`(
in _dragon int, in _d_name varchar(7))
BEGIN
	update playground_dragon set ch_name=1,d_name=_d_name where dragon=_dragon;
	update playground_race_history set d_name=_d_name where dragon=_dragon;
END$$

DROP PROCEDURE IF EXISTS `SaveRaceDragonMassSelectRank`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SaveRaceDragonMassSelectRank`(in _dragon int,
in _rank int, in _his_rank int)
BEGIN
if _his_rank=0 or _rank<_his_rank then
	update playground_dragon set his_rank=_rank where dragon=_dragon;
end if;
	update playground_race_signup set rank=_rank where dragon=_dragon;
END$$

DROP PROCEDURE IF EXISTS `SaveRaceDragonToptenRank`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SaveRaceDragonToptenRank`(
in _season smallint, in _dragon int, in _player int,
in _rank tinyint, in _his_rank int, in _raceway tinyint,
in _live1 int unsigned, in _live2 int unsigned, 
in _speed smallint, in _kind smallint,
in _ch_name tinyint,
in _d_name varchar(7))
BEGIN
if _his_rank=0 or _rank<_his_rank then
	update playground_dragon set his_rank=_rank where dragon=_dragon;
end if;
	update playground_race_signup set rank=_rank where dragon=_dragon;
	insert playground_race_history (season,rank,dragon,player,raceway,live1,live2,speed,kind,ch_name,d_name) 
		values (_season,_rank,_dragon,_player,_raceway,_live1,_live2,_speed,_kind,_ch_name,_d_name);
END$$

DROP PROCEDURE IF EXISTS `SendMail`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SendMail`(
in _uid int, in _sender_uid int,
in _timet int unsigned, in _type tinyint,in _has_attach tinyint,
in _nickname varchar(6),
in _subject varchar(20),in _content varchar(1000),
in _attach binary(200))
BEGIN
declare mail_nums,mailid,tmpid,mail_cur,tmpindex,result tinyint default 0;
declare expiredtime int unsigned;
declare cur1 cursor for select mail_id from mail where player=_uid order by mail_id;

delete from mail where player=_uid and `time`<_timet and has_attach=0;
select count(*) into mail_nums from mail where player=_uid;
if mail_nums>=100 then
	select count(*) into mailid from mail where player=_uid and has_attach=0;
	if mailid!=0 then
		select mail_id into mailid from mail where player=_uid and has_attach=0 order by time limit 1;
		set mailid=mailid+100;
	end if;
elseif mail_nums!=0 then
	open cur1;
	fetch cur1 into tmpid;
	set mail_cur=1;
	lab_getid: repeat
		set tmpindex=tmpindex+1;
		if tmpindex!=tmpid then
			set mailid=tmpindex;
			leave lab_getid;
		else
			if mail_cur>=mail_nums then
				iterate lab_getid;
			else
				fetch cur1 into tmpid;
				set mail_cur=mail_cur+1;
			end if;
		end if;
	until tmpindex>=100 end repeat;
	close cur1;
else
	set mailid=1;
end if;
if mailid!=0 then
	set expiredtime=_timet+7*24*3600;
	if _has_attach=0 then
		set _attach=null;
	end if;
	if mailid<=100 then
		insert into mail (`player`,`mail_id`,`read`,`type`,`has_attach`,`time`,`uid`,`nickname`,`subject`,`content`,`attach`)
			values (_uid,mailid,0,_type,_has_attach,expiredtime,_sender_uid,_nickname,_subject,_content,_attach);
	else
		set mailid=mailid-100;
		update mail set `read`=0,`type`=_type,`has_attach`=_has_attach,`time`=expiredtime,
			`uid`=_sender_uid,`nickname`=_nickname,`subject`=_subject,
			`content`=_content,`attach`=_attach where player=_uid and mail_id=mailid;
	end if;
	set result=1;
else
	set result=0;
end if;
select result;
END$$

DROP PROCEDURE IF EXISTS `SetRearroomLevel`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SetRearroomLevel`(
in _player int, in _level smallint)
BEGIN
declare v_rooms smallint default 0;
select count(*) into v_rooms from playground_rear where player=_player;
if v_rooms=0 then
	insert playground_rear (player,rooms) value(_player,_level);
else
	update playground_rear set rooms=_level where player=_player;
end if;
END$$

DROP PROCEDURE IF EXISTS `test_back`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_back`(in str varchar(18))
BEGIN
	select * from playground_dragon limit 5;
END$$

DROP PROCEDURE IF EXISTS `test_p`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_p`()
BEGIN
declare v_uid int default 0;
set v_uid=99999;
repeat
	insert assistant (player,activity)
values(v_uid,0);
	set v_uid=v_uid-1;
until v_uid=0
end repeat;
END$$

DROP PROCEDURE IF EXISTS `update_action`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_action`(_player int, _id int, _kind int, _max int, _value int)
begin
	declare m int;
	select action.max into m from action where player=_player and id=_id and kind=_kind;
	if ifnull(m, true) then 
		insert into action values(_player, _id, _kind, _max, _value);
	else
		if m>_max then
			set _max=m;
		end if;
		update action set max=_max,value=value+_value where player=_player and id=_id and kind=_kind;
	end if;
	
end$$

DROP PROCEDURE IF EXISTS `update_war_field_guild`$$
CREATE DEFINER=`root`@`%` PROCEDURE `update_war_field_guild`(IN _war_field_id int,IN _guild_id int)
BEGIN
	#更新领地占领工会ID
	UPDATE guild_war_fields SET guild_id=_guild_id WHERE war_field_id=_war_field_id;
	
	#删除以先前占领公会相关信息
	DELETE FROM guild_war_member_info WHERE war_field_id=_war_field_id;
	
	#变量新公会的成员ID,依次插入guild_war_fields
	INSERT INTO guild_war_member_info(player, guild_id, war_field_id)
	SELECT guild_member_info.player, guild_member_info.guild_id, guild_war_fields.war_field_id
	FROM guild_member_info, guild_war_fields
	WHERE guild_member_info.guild_id = guild_war_fields.guild_id and guild_war_fields.war_field_id = _war_field_id;
END$$

DELIMITER ;
