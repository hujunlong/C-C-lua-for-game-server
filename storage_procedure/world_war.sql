-- phpMyAdmin SQL Dump
-- version 3.3.7
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2013 年 05 月 07 日 17:29
-- 服务器版本: 5.1.60
-- PHP 版本: 5.2.17p1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 数据库: `world_war`
--

-- --------------------------------------------------------

--
-- 表的结构 `grade_top`
--
-- 创建时间: 2013 年 04 月 26 日 14:13
-- 最后更新: 2013 年 05 月 06 日 00:00
--

DROP TABLE IF EXISTS `grade_top`;
CREATE TABLE IF NOT EXISTS `grade_top` (
  `server` tinyint(4) unsigned NOT NULL COMMENT '服务器ID',
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `rank` int(11) unsigned NOT NULL COMMENT '玩家排名',
  `index` int(11) unsigned NOT NULL COMMENT '实际名次',
  PRIMARY KEY (`server`,`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='特殊军阶榜';

-- --------------------------------------------------------

--
-- 表的结构 `world_war_country`
--
-- 创建时间: 2013 年 01 月 26 日 13:28
-- 最后更新: 2013 年 05 月 07 日 13:14
-- 最后检查: 2013 年 03 月 01 日 16:13
--

DROP TABLE IF EXISTS `world_war_country`;
CREATE TABLE IF NOT EXISTS `world_war_country` (
  `map` tinyint(4) unsigned NOT NULL COMMENT '地图ID',
  `location` tinyint(4) unsigned NOT NULL COMMENT '路点ID',
  `country` tinyint(4) unsigned NOT NULL COMMENT '所属国家',
  PRIMARY KEY (`map`,`location`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='国战交火归属';

-- --------------------------------------------------------

--
-- 表的结构 `world_war_history`
--
-- 创建时间: 2013 年 01 月 26 日 13:28
-- 最后更新: 2013 年 05 月 06 日 00:00
-- 最后检查: 2013 年 03 月 01 日 16:13
--

DROP TABLE IF EXISTS `world_war_history`;
CREATE TABLE IF NOT EXISTS `world_war_history` (
  `history` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '新闻ID',
  `map` tinyint(4) unsigned NOT NULL COMMENT '地图',
  `attack` tinyint(4) unsigned NOT NULL COMMENT '攻击方',
  `defend` tinyint(4) unsigned NOT NULL COMMENT '防守方',
  `type` tinyint(4) unsigned NOT NULL COMMENT '类型',
  `time` int(11) unsigned NOT NULL COMMENT '新闻时间',
  `term` int(11) unsigned NOT NULL COMMENT '第几期',
  PRIMARY KEY (`history`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='国战历史信息' AUTO_INCREMENT=136 ;

-- --------------------------------------------------------

--
-- 表的结构 `world_war_info`
--
-- 创建时间: 2013 年 01 月 26 日 13:28
-- 最后更新: 2013 年 05 月 07 日 17:24
-- 最后检查: 2013 年 03 月 01 日 16:13
--

DROP TABLE IF EXISTS `world_war_info`;
CREATE TABLE IF NOT EXISTS `world_war_info` (
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `server` tinyint(4) unsigned NOT NULL COMMENT '服务器',
  `country` tinyint(4) unsigned NOT NULL COMMENT '国家',
  `vip` tinyint(4) unsigned NOT NULL COMMENT 'VIP等级',
  `grade` tinyint(4) unsigned NOT NULL COMMENT '军阶等级',
  `level` tinyint(4) unsigned NOT NULL COMMENT '玩家等级',
  `rank` int(11) unsigned NOT NULL DEFAULT '1200' COMMENT 'rank值',
  `point` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '战场点数',
  `score` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '国家贡献',
  `count` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '战斗次数',
  `robot` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '自动参战',
  `auto` tinyint(4) unsigned NOT NULL COMMENT '自动参战次数',
  `vote` tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '投票目标',
  `time` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'CD时间',
  `nickname` varchar(6) NOT NULL COMMENT '玩家名称',
  PRIMARY KEY (`player`,`server`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='国战玩家信息';

-- --------------------------------------------------------

--
-- 表的结构 `world_war_location`
--
-- 创建时间: 2013 年 01 月 26 日 13:28
-- 最后更新: 2013 年 05 月 07 日 17:24
-- 最后检查: 2013 年 03 月 01 日 16:13
--

DROP TABLE IF EXISTS `world_war_location`;
CREATE TABLE IF NOT EXISTS `world_war_location` (
  `map` tinyint(4) unsigned NOT NULL COMMENT '地图ID',
  `location1` int(11) unsigned NOT NULL COMMENT '路点1',
  `location2` int(11) unsigned NOT NULL COMMENT '路点2',
  `progress` tinyint(4) unsigned NOT NULL DEFAULT '50' COMMENT '进攻方当前进度',
  PRIMARY KEY (`map`,`location1`,`location2`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='国战交火状态';

-- --------------------------------------------------------

--
-- 表的结构 `world_war_map`
--
-- 创建时间: 2013 年 04 月 19 日 11:01
-- 最后更新: 2013 年 05 月 07 日 16:43
--

DROP TABLE IF EXISTS `world_war_map`;
CREATE TABLE IF NOT EXISTS `world_war_map` (
  `map` tinyint(4) unsigned NOT NULL COMMENT '地图ID',
  `country` tinyint(4) unsigned NOT NULL COMMENT '所属国家',
  `vote1` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '国家1投票数',
  `vote2` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '国家2投票数',
  `vote3` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '国家3投票数',
  PRIMARY KEY (`map`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='国家地图';

-- --------------------------------------------------------

--
-- 表的结构 `world_war_running`
--
-- 创建时间: 2013 年 01 月 26 日 13:28
-- 最后更新: 2013 年 05 月 07 日 13:14
-- 最后检查: 2013 年 03 月 01 日 16:13
--

DROP TABLE IF EXISTS `world_war_running`;
CREATE TABLE IF NOT EXISTS `world_war_running` (
  `map` tinyint(4) unsigned NOT NULL COMMENT '地图',
  `attack` tinyint(4) unsigned NOT NULL COMMENT '攻击方',
  `defend` tinyint(4) unsigned NOT NULL COMMENT '防守方',
  `progress` int(11) unsigned NOT NULL COMMENT '进攻进度(占领个数)',
  PRIMARY KEY (`map`),
  UNIQUE KEY `attack` (`attack`,`defend`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='本期国战地图';

-- --------------------------------------------------------

--
-- 表的结构 `world_war_server`
--
-- 创建时间: 2013 年 01 月 26 日 13:28
-- 最后更新: 2013 年 05 月 07 日 17:27
-- 最后检查: 2013 年 03 月 01 日 16:13
--

DROP TABLE IF EXISTS `world_war_server`;
CREATE TABLE IF NOT EXISTS `world_war_server` (
  `id` tinyint(4) NOT NULL COMMENT '服务器ID',
  `name` varchar(18) NOT NULL COMMENT '服务器名称',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='联运服务器组';

-- --------------------------------------------------------

--
-- 表的结构 `world_war_status`
--
-- 创建时间: 2013 年 01 月 26 日 13:28
-- 最后更新: 2013 年 05 月 07 日 12:00
-- 最后检查: 2013 年 03 月 01 日 16:13
--

DROP TABLE IF EXISTS `world_war_status`;
CREATE TABLE IF NOT EXISTS `world_war_status` (
  `key` int(11) unsigned NOT NULL,
  `value` int(11) unsigned NOT NULL DEFAULT '0',
  `name` tinytext NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='服务器运行信息';

-- --------------------------------------------------------

--
-- 表的结构 `world_war_top`
--
-- 创建时间: 2013 年 01 月 26 日 13:28
-- 最后更新: 2013 年 05 月 07 日 12:00
-- 最后检查: 2013 年 03 月 01 日 16:13
--

DROP TABLE IF EXISTS `world_war_top`;
CREATE TABLE IF NOT EXISTS `world_war_top` (
  `server` tinyint(4) unsigned NOT NULL COMMENT '服务器ID',
  `player` int(11) unsigned NOT NULL COMMENT '玩家ID',
  `rank` int(11) unsigned NOT NULL COMMENT '玩家排名',
  `reward` int(11) NOT NULL DEFAULT '0' COMMENT '玩家奖励{负数代表已经领奖}',
  `index` int(10) unsigned NOT NULL COMMENT '实际名次',
  PRIMARY KEY (`server`,`player`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
