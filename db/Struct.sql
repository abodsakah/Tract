-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Värd: db
-- Tid vid skapande: 09 jun 2022 kl 07:30
-- Serverversion: 5.7.38
-- PHP-version: 8.0.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databas: `tract`
--
DROP DATABASE IF EXISTS `tract`;
CREATE DATABASE IF NOT EXISTS `tract` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `tract`;

DELIMITER $$
--
-- Procedurer
--
DROP PROCEDURE IF EXISTS `add_node`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `add_node` (IN `n_uid` VARCHAR(255), IN `n_name` VARCHAR(255), IN `n_trigger_action` INT(11), IN `n_is_part_of` INT(11), IN `n_type` INT(11), IN `n_status` VARCHAR(255))   BEGIN
INSERT INTO `logical_devices` (`id`, `uid`, `name`, `trigger_action`, `comp_id`, `install_date`, `is_part_of`, `type`, `status`) VALUES (NULL, `n_uid`, `n_name`, `n_trigger_action`, CURRENT_DATE(), `n_is_part_of`, `n_type`, `n_status`);
END$$

DROP PROCEDURE IF EXISTS `add_node_no_trigger_action`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `add_node_no_trigger_action` (IN `n_node_uid` VARCHAR(255), IN `n_node_name` VARCHAR(255), IN `n_asset_id` INT(11), IN `n_node_type` INT(11), IN `n_node_status` VARCHAR(255))   BEGIN
SELECT @is_part_of := located_in FROM assets WHERE id = n_asset_id;

  INSERT INTO logical_devices (uid, name, trigger_action, install_date, is_part_of, type, status)
  VALUES (n_node_uid, n_node_name, 1, CURRENT_DATE(), @is_part_of, n_node_type, n_node_status);
  
SELECT @device_id := id FROM logical_devices WHERE uid = n_node_uid;
  
CALL set_asset_hosts(n_asset_id, @device_id);
END$$

DROP PROCEDURE IF EXISTS `add_styling`$$
CREATE DEFINER=`tractteam`@`localhost` PROCEDURE `add_styling` (IN `n_comp_id` INT, IN `n_color` VARCHAR(255), IN `n_logo` VARCHAR(255))   BEGIN
  INSERT INTO `website_settings` (`comp_id`, `color`, `logo`) VALUES (n_comp_id, n_color, n_logo);
END$$

DROP PROCEDURE IF EXISTS `add_test_logical_device_base`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `add_test_logical_device_base` ()   BEGIN
-- node threshold
INSERT INTO `node_thresholds` (`id`, `action`, `trigger_action`) VALUES (NULL, 'test action', 'test trigger action');
-- space
INSERT INTO `spaces` (`id`, `type`, `name`, `agent`, `has_capability`, `is_part_of`)
VALUES (NULL, 'test', 'test space', '1', '123', NULL);
-- logical device
INSERT INTO `logical_devices` (`id`, `uid`, `name`, `trigger_action`, `install_date`, `is_part_of`, `status`)
VALUES (NULL, '123456', 'test logical device', '1', CURRENT_DATE(), '1', 'ACTIVE');
END$$

DROP PROCEDURE IF EXISTS `add_to_log`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `add_to_log` (IN `n_msg` VARCHAR(255), IN `n_company_id` INT)   BEGIN
  INSERT INTO `company_log` (`msg`, `company_id`, `report_date`) VALUES (n_msg, n_company_id, NOW());
END$$

DROP PROCEDURE IF EXISTS `create_company`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `create_company` (IN `n_name` VARCHAR(255), IN `n_email` VARCHAR(255), IN `n_phone` VARCHAR(255))   BEGIN
  INSERT INTO `companies` (`name`, `support_email`, `support_phone`) VALUES (n_name, n_email, n_phone);
    SELECT LAST_INSERT_ID() AS id;
END$$

DROP PROCEDURE IF EXISTS `create_threshold`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `create_threshold` (IN `n_action` VARCHAR(10), IN `n_treshold` INT(255))   begin
  INSERT INTO node_thresholds (action, threshold) VALUES (n_action, n_treshold);
  -- select the id of the last inserted row
  SELECT LAST_INSERT_ID() as id;
end$$

DROP PROCEDURE IF EXISTS `delete_logical_device_from_uid`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `delete_logical_device_from_uid` (IN `p_uid` VARCHAR(255))  NO SQL DELETE FROM `logical_devices`
WHERE `logical_devices`.`uid` = p_uid$$

DROP PROCEDURE IF EXISTS `delete_node`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `delete_node` (IN `p_id` INT, IN `p_company_id` INT)  NO SQL BEGIN
DELETE l
  FROM logical_devices l
  LEFT JOIN spaces s
  ON s.id = l.is_part_of
 WHERE l.id = p_id
 	AND s.agent = p_company_id
    AND l.status = "DELETED"
 ;
END$$

DROP PROCEDURE IF EXISTS `get_all_buildings`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_all_buildings` (IN `company_id` INT)   begin
  SELECT * FROM spaces WHERE is_part_of IS NULL AND agent = company_id;
end$$

DROP PROCEDURE IF EXISTS `get_amount_type_of_sensor`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_amount_type_of_sensor` (IN `n_sensor_type` VARCHAR(255), IN `n_company_id` INT)   BEGIN
  SELECT COUNT(*) AS amount FROM `logical_devices_all` WHERE `type_name` = n_sensor_type AND `company_id` = n_company_id AND `status` != "DELETED" AND `status` != "TBD";
END$$

DROP PROCEDURE IF EXISTS `get_assets_in_space`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_assets_in_space` (IN `space_id` INT)   BEGIN
  SELECT * FROM assets
  WHERE located_in = space_id
  AND `hosts` IS null;
END$$

DROP PROCEDURE IF EXISTS `get_asset_from_id`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_asset_from_id` (IN `p_id` INT(11))  NO SQL BEGIN
  SELECT * FROM assets WHERE p_id = `id`;
END$$

DROP PROCEDURE IF EXISTS `get_asset_from_logical_device_id`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_asset_from_logical_device_id` (IN `p_id` INT(11))  NO SQL BEGIN
  SELECT * FROM assets WHERE p_id = `hosts`;
END$$

DROP PROCEDURE IF EXISTS `get_company_log`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_company_log` (IN `p_company_id` INT(11))  NO SQL BEGIN
  SELECT
  *
  FROM `company_log`
  WHERE `p_company_id` = company_id
  ORDER BY `id` DESC
  LIMIT 15;
END$$

DROP PROCEDURE IF EXISTS `get_company_settings`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_company_settings` (IN `company_id` INT)   BEGIN
    SELECT 
      *
    FROM `company_settings`;
END$$

DROP PROCEDURE IF EXISTS `get_logical_device_all`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_logical_device_all` (IN `p_id` INT(11), IN `p_company_id` INT(11))  NO SQL BEGIN
SELECT *
FROM logical_devices_all
WHERE p_id=id AND p_company_id=company_id;
END$$

DROP PROCEDURE IF EXISTS `get_logical_device_status`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_logical_device_status` (IN `p_id` INT(11), IN `p_company_id` INT(11))  NO SQL BEGIN
SELECT `status`
FROM `logical_devices_with_company_id`
WHERE p_id=id AND p_company_id=company_id;
END$$

DROP PROCEDURE IF EXISTS `get_logical_device_type`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_logical_device_type` (IN `p_id` INT(11), IN `p_company_id` INT(11))  NO SQL BEGIN
SELECT type
FROM logical_devices_all
WHERE p_id=id AND p_company_id=company_id;
END$$

DROP PROCEDURE IF EXISTS `get_nodes_for_type`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_nodes_for_type` (IN `n_company_id` INT, IN `n_sensor_type` INT)   BEGIN
  SELECT *
  FROM `logical_devices_all`
  WHERE `type` = n_sensor_type
  AND `company_id` = n_company_id
  AND `status` != "DELETED"
  AND `status` != "TBD";
END$$

DROP PROCEDURE IF EXISTS `get_node_from_uid`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_node_from_uid` (IN `p_uid` VARCHAR(20) CHARSET utf8mb4)  NO SQL COMMENT 'get all logical_device info for a certain UID' BEGIN
SELECT *
FROM logical_devices_all
WHERE p_uid=uid;
END$$

DROP PROCEDURE IF EXISTS `get_preloaded_node`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_preloaded_node` (IN `n_uid` VARCHAR(255), IN `n_company_id` INT(11))  NO SQL SELECT * FROM node_preloaded WHERE uid = n_uid AND company_id = n_company_id$$

DROP PROCEDURE IF EXISTS `get_spaces_for_building`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_spaces_for_building` (IN `space_id` INT)   BEGIN
  SELECT * FROM spaces WHERE is_part_of = space_id;
END$$

DROP PROCEDURE IF EXISTS `get_space_from_id`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_space_from_id` (IN `p_id` INT)  NO SQL BEGIN
  SELECT * FROM spaces WHERE id = p_id;
END$$

DROP PROCEDURE IF EXISTS `get_threshold`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_threshold` (IN `thresholdId` INT(11))  NO SQL BEGIN
	SELECT * FROM node_thresholds WHERE id = thresholdId;
END$$

DROP PROCEDURE IF EXISTS `get_users_for_company`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_users_for_company` (IN `company_id` INT)   begin
  SELECT * FROM `user_login` WHERE `company_id` = company_id;
end$$

DROP PROCEDURE IF EXISTS `logical_devices_for_company`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `logical_devices_for_company` (IN `company_id` INT)   BEGIN
  SELECT * FROM `logical_devices_all` WHERE `company_id` = company_id;
END$$

DROP PROCEDURE IF EXISTS `reported_logical_devices_for_company`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `reported_logical_devices_for_company` (IN `n_company_id` INT)  NO SQL BEGIN
  SELECT * FROM `logical_devices_all` WHERE `company_id` = n_company_id AND `status` = "REPORTED";
END$$

DROP PROCEDURE IF EXISTS `set_asset_hosts`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `set_asset_hosts` (IN `p_id` INT(11), IN `hosts_id` INT(11))  NO SQL BEGIN
  UPDATE `assets` SET `hosts` = hosts_id
  WHERE `id` = p_id;
END$$

DROP PROCEDURE IF EXISTS `set_device_as_active`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `set_device_as_active` (IN `p_id` INT(11), IN `p_company_id` INT(11))  NO SQL BEGIN
    UPDATE logical_devices l
    LEFT OUTER JOIN spaces s
    ON l.is_part_of = s.id
    SET l.status = "ACTIVE"
    WHERE l.id = p_id AND s.agent = p_company_id;
END$$

DROP PROCEDURE IF EXISTS `set_device_as_deleted`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `set_device_as_deleted` (IN `p_id` INT(11), IN `p_company_id` INT(11))   BEGIN
    UPDATE logical_devices l
    LEFT OUTER JOIN spaces s
    ON l.is_part_of = s.id
    SET l.status = "DELETED"
    WHERE l.id = p_id AND s.agent = p_company_id;
END$$

DROP PROCEDURE IF EXISTS `set_device_as_reported`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `set_device_as_reported` (IN `p_id` INT(11), IN `P_company_id` INT(11))  NO SQL BEGIN
    UPDATE logical_devices l
    LEFT OUTER JOIN spaces s
    ON l.is_part_of = s.id
    SET l.status = "REPORTED"
    WHERE l.id = p_id AND s.agent = p_company_id;
END$$

DROP PROCEDURE IF EXISTS `set_device_to_be_deleted`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `set_device_to_be_deleted` (IN `p_id` INT(11), IN `p_company_id` INT(11))  NO SQL BEGIN
    UPDATE logical_devices l
    LEFT OUTER JOIN spaces s
    ON l.is_part_of = s.id
    SET l.status = "TBD"
    WHERE l.id = p_id AND s.agent = p_company_id;
    
    UPDATE assets a
    SET a.hosts = null
    WHERE a.hosts = p_id;
END$$

DROP PROCEDURE IF EXISTS `set_node_as_active`$$
CREATE DEFINER=`tractteam`@`localhost` PROCEDURE `set_node_as_active` (IN `node_id` INT)   BEGIN
  UPDATE `logical_devices` SET `status` = 'ACTIVE' WHERE `logical_devices`.`id` = node_id;
END$$

DROP PROCEDURE IF EXISTS `update_company_info`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `update_company_info` (IN `n_comp_id` INT, IN `n_name` VARCHAR(255), IN `n_email` VARCHAR(255), IN `n_phone` VARCHAR(255), IN `n_color` VARCHAR(255), IN `n_logo` VARCHAR(255))   BEGIN
  UPDATE `companies` SET `name` = n_name, `support_email` = n_email, `support_phone` = n_phone WHERE `id` = n_comp_id;
  UPDATE `website_settings` SET `color` = n_color, `logo` = n_logo WHERE `comp_id` = n_comp_id;
END$$

DROP PROCEDURE IF EXISTS `update_company_settings`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `update_company_settings` (IN `company_id` INT, IN `color` VARCHAR(255), IN `logo` VARCHAR(255))   BEGIN
    UPDATE `website_settings`
    SET `color` = color,
        `logo` = logo
    WHERE `comp_id` = company_id;
END$$

DROP PROCEDURE IF EXISTS `update_logical_device_threshold`$$
CREATE DEFINER=`tractteam`@`localhost` PROCEDURE `update_logical_device_threshold` (IN `n_uid` VARCHAR(255), IN `n_threshold` INT)   BEGIN
  UPDATE `logical_devices` SET `trigger_action` = n_threshold WHERE uid = n_uid;
  UPDATE `logical_devices` SET `status` = 'ACTIVE' WHERE `logical_devices`.`uid` = n_uid;
END$$

DROP PROCEDURE IF EXISTS `update_threshold`$$
CREATE DEFINER=`tractteam`@`%` PROCEDURE `update_threshold` (IN `n_id` INT, IN `n_action` VARCHAR(255), IN `n_value` INT)   BEGIN
  UPDATE `node_thresholds` SET `action` = n_action, `threshold` = n_value WHERE `id` = n_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellstruktur `acess`
--

DROP TABLE IF EXISTS `acess`;
CREATE TABLE `acess` (
  `node_id` int(11) NOT NULL,
  `comp_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `grade` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellstruktur `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
CREATE TABLE `api_keys` (
  `id` int(11) NOT NULL,
  `key` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `api_keys`
--

INSERT INTO `api_keys` (`id`, `key`) VALUES
(1, '377307b0-fdf6-4762-8403-00084d164de5');

-- --------------------------------------------------------

--
-- Tabellstruktur `assets`
--

DROP TABLE IF EXISTS `assets`;
CREATE TABLE `assets` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `artic_num` varchar(255) NOT NULL,
  `located_in` int(11) NOT NULL,
  `hosts` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `assets`
--

INSERT INTO `assets` (`id`, `name`, `artic_num`, `located_in`, `hosts`) VALUES
(1, 'Dörr', '1234567', 1, NULL),
(3, 'Chair 2', '231242', 4, 22),
(16, 'test asset', '123123123', 2, 20),
(17, 'test-hiss', '0000000', 2, 40),
(18, 'test_asset', '123543', 3, 25),
(19, 'ICA elevator', '123-123-123', 5, NULL),
(20, 'Entré dörr', '123123', 3, NULL),
(21, 'Taklampa 1', '183283', 6, NULL),
(22, 'Taklampa 2', '183845', 2, 44),
(23, 'Dörrkarm', '412341', 1, NULL),
(24, 'Taklampa 4', '123542', 5, NULL),
(25, 'Dörr', '31634', 8, NULL),
(26, 'Taklampa 3', '734567', 8, NULL);

-- --------------------------------------------------------

--
-- Tabellstruktur `companies`
--

DROP TABLE IF EXISTS `companies`;
CREATE TABLE `companies` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `support_email` varchar(255) NOT NULL,
  `support_phone` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `companies`
--

INSERT INTO `companies` (`id`, `name`, `support_email`, `support_phone`) VALUES
(1, 'Tract', 'info@tractteam.xyz', '0721282737'),
(28, 'testTest', 'testi@test.se', '0503285746'),
(31, 'fwefewf', 'ewfwef@ewfew.com', 'efwefwef'),
(32, 'ica', 'ica@gmail.com', '123456789');

-- --------------------------------------------------------

--
-- Tabellstruktur `company_log`
--

DROP TABLE IF EXISTS `company_log`;
CREATE TABLE `company_log` (
  `id` int(11) NOT NULL,
  `report_date` varchar(255) NOT NULL,
  `msg` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `company_log`
--

INSERT INTO `company_log` (`id`, `report_date`, `msg`, `company_id`) VALUES
(2, '2022-05-10 19:13:30', 'Threshold 42 has been updated', 1),
(3, '2022-05-10 19:14:35', 'Threshold 142 has been updated', 1),
(4, '2022-05-11 14:37:51', 'Threshold 42 has been updated', 1),
(5, '2022-05-13 12:13:00', 'Threshold 42 has been updated', 1),
(6, '2022-05-14 19:20:19', 'Threshold 42 has been updated', 1),
(7, '2022-05-14 19:20:32', 'Company information and/or styling updated', 1),
(8, '2022-05-14 19:20:52', 'Company information and/or styling updated', 1),
(9, '2022-05-14 19:21:11', 'Company information and/or styling updated', 1),
(10, '2022-05-14 19:21:18', 'Company information and/or styling updated', 1),
(11, '2022-05-14 19:21:54', 'User 19 created', 25),
(38, '2022-05-16 07:00:13', 'Sensor 77 set to reported', 1),
(39, '2022-05-16 08:07:22', 'Sensor 77 workOrder has been resolved, sensor now set to active.', 1),
(40, '2022-05-16 08:41:29', 'Sensor 77 set to reported', 1),
(41, '2022-05-16 10:02:55', 'Sensor 16 set to reported', 1),
(42, '2022-05-16 10:11:17', 'Sensor 16 workOrder has been resolved, sensor now set to active.', 1),
(43, '2022-05-16 10:11:18', 'Sensor 16 workOrder has been resolved, sensor now set to active.', 1),
(44, '2022-05-16 10:11:22', 'Sensor 77 workOrder has been resolved, sensor now set to active.', 1),
(45, '2022-05-16 10:11:22', 'Sensor 77 workOrder has been resolved, sensor now set to active.', 1),
(46, '2022-05-16 11:13:22', 'Sensor 77 set to reported', 1),
(47, '2022-05-17 19:01:52', 'Sensor another_name added', 1),
(48, '2022-05-19 11:39:43', 'Sensor 16 set to reported', 1),
(49, '2022-05-19 11:39:43', 'Sensor 16 set to reported', 1),
(50, '2022-05-19 12:26:46', 'Sensor 50 set to deleted', 1),
(51, '2022-05-19 13:02:56', 'Sensor 42 set to deleted', 1),
(52, '2022-05-19 13:02:56', 'Sensor 42 set to deleted', 1),
(53, '2022-05-19 13:02:58', 'Sensor 42 set to deleted', 1),
(54, '2022-05-19 13:02:59', 'Sensor 42 set to deleted', 1),
(55, '2022-05-19 13:02:59', 'Sensor 42 set to deleted', 1),
(56, '2022-05-19 13:03:05', 'Sensor 77 set to deleted', 1),
(57, '2022-05-19 13:03:36', 'Sensor 77 has been deleted', 1),
(58, '2022-05-19 13:10:27', 'Sensor analog sensor added', 1),
(59, '2022-05-19 13:11:04', 'Sensor ACB914A4BD setup is finished', 0),
(60, '2022-05-19 13:16:47', 'Sensor 79 set to deleted', 1),
(61, '2022-05-19 13:21:03', 'Sensor 79 has been deleted', 1),
(62, '2022-05-19 13:21:03', 'Sensor 79 has been deleted', 1),
(63, '2022-05-19 13:22:43', 'Sensor analog test added', 1),
(64, '2022-05-19 13:22:52', 'Sensor ACB914A4BD setup is finished', 0),
(65, '2022-05-19 13:22:53', 'Sensor ACB914A4BD setup is finished', 0),
(66, '2022-05-19 13:28:30', 'Sensor 80 set to deleted', 1),
(67, '2022-05-19 13:28:39', 'Sensor 80 has been deleted', 1),
(68, '2022-05-19 13:30:06', 'Sensor analog test added', 1),
(69, '2022-05-19 13:30:09', 'Sensor ACB914A4BD setup is finished', 0),
(70, '2022-05-19 13:33:06', 'Sensor 81 set to deleted', 1),
(71, '2022-05-19 13:33:29', 'Sensor 81 has been deleted', 1),
(72, '2022-05-19 13:33:29', 'Sensor 81 has been deleted', 1),
(73, '2022-05-19 13:33:58', 'Sensor analog test added', 1),
(74, '2022-05-19 13:42:13', 'Sensor test added', 1),
(75, '2022-05-19 13:42:26', 'Sensor 88A904A4BD setup is finished', 88),
(76, '2022-05-19 13:45:42', 'Sensor 86 set to deleted', 1),
(77, '2022-05-19 13:48:46', 'Sensor test sensor added', 1),
(78, '2022-05-19 13:49:37', 'Threshold of sensor 82 has been updated', 1),
(79, '2022-05-19 13:49:49', 'Threshold of sensor 82 has been updated', 1),
(80, '2022-05-19 13:49:55', 'Threshold of sensor 82 has been updated', 1),
(81, '2022-05-19 13:50:02', 'Threshold of sensor 82 has been updated', 1),
(82, '2022-05-19 13:50:06', 'Threshold of sensor 82 has been updated', 1),
(83, '2022-05-19 13:50:18', 'Threshold of sensor 82 has been updated', 1),
(84, '2022-05-19 13:50:22', 'Threshold of sensor 82 has been updated', 1),
(85, '2022-05-19 13:50:55', 'Threshold of sensor 82 has been updated', 1),
(86, '2022-05-19 13:53:36', 'Sensor test added', 1),
(87, '2022-05-19 13:53:39', 'Sensor 88A904A4BD setup is finished', 88),
(88, '2022-05-19 13:54:59', 'Sensor test senor added', 1),
(89, '2022-05-19 13:55:02', 'Sensor 88A904A4BD setup is finished', 88),
(90, '2022-05-19 14:14:49', 'User 22 created', 26),
(91, '2022-05-19 14:32:31', 'Company information and/or styling updated', 26),
(92, '2022-05-19 14:32:35', 'Company information and/or styling updated', 26),
(93, '2022-05-19 14:32:59', 'Company information and/or styling updated', 1),
(94, '2022-05-19 14:33:05', 'Company information and/or styling updated', 1),
(95, '2022-05-19 14:33:41', 'User 23 created', 24),
(96, '2022-05-19 14:36:36', 'User 24 created', 26),
(97, '2022-05-19 15:00:24', 'Sensor test-name added', 1),
(98, '2022-05-19 15:02:03', 'Sensor test-name added', 1),
(99, '2022-05-19 15:03:13', 'Sensor test-name added', 1),
(100, '2022-05-19 15:03:41', 'Sensor test-name added', 1),
(101, '2022-05-19 15:05:08', 'Sensor test-name added', 1),
(102, '2022-05-19 15:12:51', 'Sensor test-name added', 1),
(103, '2022-05-19 15:13:39', 'Sensor test-name added', 1),
(104, '2022-05-19 15:14:47', 'Sensor test-name added', 1),
(105, '2022-05-19 15:18:20', 'Sensor 82 set to deleted', 1),
(106, '2022-05-19 15:18:51', 'Sensor 82 has been deleted', 1),
(107, '2022-05-19 15:19:12', 'Sensor analog test added', 1),
(108, '2022-05-19 15:19:16', 'Sensor ACB914A4BD setup is finished', 0),
(109, '2022-05-19 15:30:00', 'Sensor test-name added', 1),
(110, '2022-05-19 15:30:38', 'Sensor test-name added', 1),
(111, '2022-05-19 15:35:28', 'Sensor test-name added', 1),
(112, '2022-05-19 15:43:25', 'Sensor 105 set to deleted', 1),
(113, '2022-05-19 15:43:54', 'Sensor 105 has been deleted', 1),
(114, '2022-05-19 15:43:54', 'Sensor 105 has been deleted', 1),
(115, '2022-05-19 15:44:33', 'Sensor analog test added', 1),
(116, '2022-05-19 15:44:36', 'Sensor ACB914A4BD setup is finished', 0),
(117, '2022-05-19 15:45:00', 'Sensor 109 set to reported', 1),
(118, '2022-05-19 15:45:00', 'Sensor 109 set to reported', 1),
(119, '2022-05-19 15:48:58', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(120, '2022-05-19 15:48:58', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(121, '2022-05-19 15:48:59', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(122, '2022-05-19 15:49:07', 'Sensor 109 work order has been resolved, sensor now set to active.', 1),
(123, '2022-05-19 15:49:07', 'Sensor 109 work order has been resolved, sensor now set to active.', 1),
(124, '2022-05-19 15:49:08', 'Sensor 109 work order has been resolved, sensor now set to active.', 1),
(125, '2022-05-19 15:49:12', 'Sensor 16 set to reported', 1),
(126, '2022-05-19 15:49:12', 'Sensor 16 set to reported', 1),
(127, '2022-05-19 15:50:08', 'Sensor 109 set to reported', 1),
(128, '2022-05-19 15:50:08', 'Sensor 109 set to reported', 1),
(129, '2022-05-19 15:51:45', 'Sensor 109 set to deleted', 1),
(130, '2022-05-19 15:52:18', 'Sensor 109 has been deleted', 1),
(131, '2022-05-19 15:52:18', 'Sensor 109 has been deleted', 1),
(132, '2022-05-19 15:52:18', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(133, '2022-05-19 15:52:18', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(134, '2022-05-19 15:52:18', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(135, '2022-05-19 16:08:39', 'Sensor 16 set to reported', 1),
(136, '2022-05-19 16:08:39', 'Sensor 16 set to reported', 1),
(137, '2022-05-19 16:16:23', 'Threshold of sensor 108 has been updated', 1),
(138, '2022-05-19 16:16:46', 'Threshold of sensor 108 has been updated', 1),
(139, '2022-05-19 16:21:14', 'Sensor 109 set to reported', 1),
(140, '2022-05-19 16:55:19', 'Company information and/or styling updated', 26),
(141, '2022-05-19 16:55:38', 'Company information and/or styling updated', 26),
(142, '2022-05-20 06:59:40', 'User 25 created', 25),
(143, '2022-05-20 07:01:35', 'User 26 created', 1),
(144, '2022-05-20 07:02:46', 'User 27 created', 1),
(145, '2022-05-20 17:04:36', 'User 28 created', 1),
(146, '2022-05-21 14:26:11', 'Sensor 16 set to deleted', 1),
(147, '2022-05-21 14:27:00', 'Sensor 16 set to deleted', 1),
(148, '2022-05-21 14:28:02', 'Sensor 16 set to deleted', 1),
(149, '2022-05-21 14:29:03', 'Sensor 16 set to deleted', 1),
(150, '2022-05-21 14:30:05', 'Sensor 16 set to deleted', 1),
(151, '2022-05-21 14:33:55', 'Sensor 16 set to deleted', 1),
(152, '2022-05-22 13:22:07', 'Sensor 16 set to deleted', 1),
(153, '2022-05-22 18:02:49', 'Sensor 16 set to deleted', 1),
(154, '2022-05-22 20:01:59', 'Sensor 16 set to deleted', 1),
(155, '2022-05-23 13:19:31', 'Sensor test added', 1),
(156, '2022-05-23 13:19:48', 'Sensor 16 set to deleted', 1),
(157, '2022-05-23 13:20:24', 'Sensor 16 has been deleted', 1),
(158, '2022-05-23 13:21:07', 'Sensor test added', 1),
(159, '2022-05-23 13:23:32', 'Sensor test added', 1),
(160, '2022-05-23 13:23:35', 'Sensor 88A904A4BD setup is finished', 1),
(161, '2022-05-23 13:27:21', 'Threshold of sensor 108 has been updated', 1),
(162, '2022-05-23 13:27:57', 'Threshold of sensor 112 has been updated', 1),
(163, '2022-05-23 13:28:16', 'Threshold of sensor 10 has been updated', 1),
(164, '2022-05-23 13:28:34', 'Threshold of sensor 10 has been updated', 1),
(165, '2022-05-26 09:18:05', 'User 29 created', 1),
(166, '2022-05-28 11:18:01', 'User 30 created', 27),
(167, '2022-05-28 11:20:43', 'Company information and/or styling updated', 27),
(168, '2022-05-28 11:21:49', 'Company information and/or styling updated', 27),
(169, '2022-05-28 11:29:07', 'User 31 created', 27),
(170, '2022-05-28 11:46:47', 'User 32 created', 28),
(171, '2022-05-28 11:47:32', 'Company information and/or styling updated', 28),
(172, '2022-05-28 11:49:00', 'User 33 created', 29),
(173, '2022-05-28 11:51:17', 'Company information and/or styling updated', 27),
(174, '2022-05-28 12:01:10', 'User 34 created', 30),
(175, '2022-05-28 12:02:19', 'User 35 created', 31),
(176, '2022-05-28 12:03:36', 'User 36 created', 31),
(177, '2022-05-28 12:16:23', 'User 37 created', 28),
(178, '2022-05-28 12:17:24', 'Company information and/or styling updated', 28),
(179, '2022-05-28 12:19:27', 'Company information and/or styling updated', 28),
(180, '2022-05-28 12:19:53', 'Sensor test-name has been deleted', 1),
(181, '2022-05-28 12:22:13', 'User 38 created', 32),
(182, '2022-05-28 12:22:52', 'Company information and/or styling updated', 32),
(183, '2022-05-28 12:23:30', 'User 39 created', 32),
(184, '2022-05-28 12:33:54', 'Sensor analog wheel added', 32),
(185, '2022-05-28 12:42:17', 'Sensor 118 set to reported', 32),
(186, '2022-05-28 12:42:57', 'Sensor analog wheel has been deleted', 32),
(187, '2022-05-28 12:45:30', 'Sensor analog wheel added', 1),
(188, '2022-05-28 12:47:46', 'Sensor 119 set to reported', 1),
(189, '2022-05-28 12:52:56', 'Sensor 119 work order has been resolved, sensor now set to active.', 1),
(190, '2022-05-28 12:54:59', 'Sensor 119 set to reported', 1),
(191, '2022-05-28 12:56:43', 'Sensor analog wheel has been deleted', 1),
(192, '2022-05-30 13:19:11', 'Sensor another_name has been deleted', 1),
(193, '2022-05-30 13:19:36', 'Sensor test has been deleted', 1),
(194, '2022-06-03 16:45:11', 'Sensor test-name has been deleted', 1),
(195, '2022-06-03 16:51:53', 'Sensor Test added', 1),
(196, '2022-06-07 14:15:54', 'Sensor 16 set to reported', 1),
(197, '2022-06-07 14:15:54', 'Sensor 16 set to reported', 1),
(198, '2022-06-07 14:15:54', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(199, '2022-06-07 14:20:25', 'Sensor 16 set to reported', 1),
(200, '2022-06-07 14:21:33', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(201, '2022-06-07 14:24:02', 'Sensor 25 set to reported', 1),
(202, '2022-06-07 14:26:13', 'Sensor analog 12 added', 1),
(203, '2022-06-07 14:40:48', 'Sensor analog 12 has been deleted', 1),
(204, '2022-06-07 14:40:50', 'Sensor analog 12 has been deleted', 1),
(205, '2022-06-07 14:49:14', 'Sensor 16 set to reported', 1),
(206, '2022-06-07 14:52:37', 'Sensor analog 12 has been deleted', 1),
(207, '2022-06-07 14:56:38', 'Sensor test temp added', 1),
(208, '2022-06-07 14:57:32', 'Threshold of sensor 30 has been updated', 1),
(209, '2022-06-07 14:57:53', 'Threshold of sensor 30 has been updated', 1),
(210, '2022-06-07 14:58:07', 'Threshold of sensor 30 has been updated', 1),
(211, '2022-06-07 14:58:17', 'Sensor test temp has been deleted', 1),
(212, '2022-06-07 15:00:54', 'Sensor test temp added', 1),
(213, '2022-06-07 15:02:19', 'Sensor test temp has been deleted', 1),
(214, '2022-06-07 15:02:57', 'Sensor test temp added', 1),
(215, '2022-06-07 15:03:20', 'Sensor test temp has been deleted', 1),
(216, '2022-06-07 15:03:47', 'Sensor walla habib test added', 1),
(217, '2022-06-07 15:05:19', 'Sensor walla habib test has been deleted', 1),
(218, '2022-06-07 15:08:56', 'Sensor test temp added', 1),
(219, '2022-06-07 15:10:27', 'Sensor test temp has been deleted', 1),
(220, '2022-06-07 15:11:21', 'Sensor temp test added', 1),
(221, '2022-06-07 15:11:35', 'Sensor temp test has been deleted', 1),
(222, '2022-06-07 15:12:11', 'Sensor temperatur sensor added', 1),
(223, '2022-06-07 15:12:23', 'Sensor temperatur sensor has been deleted', 1),
(224, '2022-06-07 15:13:16', 'Sensor temperatur node added', 1),
(225, '2022-06-07 15:13:32', 'Threshold of sensor 40 has been updated', 1),
(226, '2022-06-07 15:13:54', 'Sensor 40 set to reported', 1),
(227, '2022-06-07 15:15:48', 'Threshold of sensor 40 has been updated', 1),
(228, '2022-06-07 15:15:55', 'Threshold of sensor 40 has been updated', 1),
(229, '2022-06-07 23:05:53', 'Sensor 25 work order has been resolved, sensor now set to active.', 1),
(230, '2022-06-08 08:50:52', 'User 40 created', 1),
(231, '2022-06-08 08:53:48', 'Sensor 16 work order has been resolved, sensor now set to active.', 1),
(232, '2022-06-08 08:56:30', 'Sensor 16 set to reported', 1),
(233, '2022-06-08 08:58:21', 'Sensor switch-sensor has been deleted', 1),
(234, '2022-06-08 08:58:24', 'Sensor switch-sensor has been deleted', 1),
(235, '2022-06-08 09:01:37', 'Sensor switch-sensor has been deleted', 1),
(236, '2022-06-08 09:04:02', 'Sensor switch-sensor has been deleted', 1),
(237, '2022-06-08 09:06:05', 'Sensor switch-sensor has been deleted', 1),
(238, '2022-06-08 09:08:02', 'Sensor Switch 1 added', 1),
(239, '2022-06-08 09:10:46', 'Threshold of sensor 44 has been updated', 1),
(240, '2022-06-08 09:10:51', 'Sensor 44 set to reported', 1),
(241, '2022-06-08 09:17:15', 'Company information and/or styling updated', 1);

-- --------------------------------------------------------

--
-- Ersättningsstruktur för vy `company_settings`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `company_settings`;
CREATE TABLE `company_settings` (
`color` varchar(255)
,`logo` varchar(255)
,`comp_id` int(11)
,`name` varchar(255)
);

-- --------------------------------------------------------

--
-- Ersättningsstruktur för vy `company_website_settings`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `company_website_settings`;
CREATE TABLE `company_website_settings` (
`id` int(11)
,`name` varchar(255)
,`support_email` varchar(255)
,`support_phone` varchar(255)
,`color` varchar(255)
,`logo` varchar(255)
);

-- --------------------------------------------------------

--
-- Tabellstruktur `logical_devices`
--

DROP TABLE IF EXISTS `logical_devices`;
CREATE TABLE `logical_devices` (
  `id` int(11) NOT NULL,
  `uid` varchar(20) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `trigger_action` int(11) NOT NULL,
  `install_date` varchar(255) NOT NULL,
  `is_part_of` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `status` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `logical_devices`
--

INSERT INTO `logical_devices` (`id`, `uid`, `name`, `trigger_action`, `install_date`, `is_part_of`, `type`, `status`) VALUES
(10, '123456', 'another_name', 1, '2022-05-17', 2, 2, 'ACTIVE'),
(20, 'ACB914A4BD', 'analog wheel', 44, '2022-05-28', 2, 3, 'ACTIVE'),
(22, '22222222', 'test-name', 1, '2022-05-19', 4, 1, 'TBD'),
(25, '88A904A4BD', 'Test', 45, '2022-06-03', 3, 3, 'ACTIVE'),
(40, 'ACB904843D', 'temperatur node', 1, '2022-06-07', 2, 1, 'REPORTED'),
(44, '89390484BD', 'Switch 1', 49, '2022-06-08', 2, 2, 'REPORTED');

-- --------------------------------------------------------

--
-- Ersättningsstruktur för vy `logical_devices_all`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `logical_devices_all`;
CREATE TABLE `logical_devices_all` (
`id` int(11)
,`uid` varchar(20)
,`name` varchar(255)
,`trigger_action` int(11)
,`install_date` varchar(255)
,`is_part_of` int(11)
,`type` int(11)
,`status` varchar(255)
,`company_id` int(11)
,`type_name` varchar(255)
,`app_settings` varchar(255)
);

-- --------------------------------------------------------

--
-- Ersättningsstruktur för vy `logical_devices_with_company_id`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `logical_devices_with_company_id`;
CREATE TABLE `logical_devices_with_company_id` (
`id` int(11)
,`uid` varchar(20)
,`name` varchar(255)
,`trigger_action` int(11)
,`install_date` varchar(255)
,`is_part_of` int(11)
,`type` int(11)
,`status` varchar(255)
,`company_id` int(11)
);

-- --------------------------------------------------------

--
-- Tabellstruktur `nc_evolutions`
--

DROP TABLE IF EXISTS `nc_evolutions`;
CREATE TABLE `nc_evolutions` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `titleDown` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `batch` int(11) DEFAULT NULL,
  `checksum` varchar(255) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `nc_evolutions`
--

INSERT INTO `nc_evolutions` (`id`, `title`, `titleDown`, `description`, `batch`, `checksum`, `status`, `created`, `created_at`, `updated_at`) VALUES
(1, '20220322_175512217.up.sql', '20220322_175512217.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(2, '20220322_175833961.up.sql', '20220322_175833961.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(3, '20220322_175903904.up.sql', '20220322_175903904.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(4, '20220322_175935474.up.sql', '20220322_175935474.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(5, '20220322_180201875.up.sql', '20220322_180201875.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(6, '20220322_180204770.up.sql', '20220322_180204770.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(7, '20220322_180603623.up.sql', '20220322_180603623.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(8, '20220322_181302277.up.sql', '20220322_181302277.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(9, '20220325_125825936.up.sql', '20220325_125825936.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL),
(10, '20220325_125847174.up.sql', '20220325_125847174.down.sql', NULL, NULL, NULL, 0, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Tabellstruktur `node_preloaded`
--

DROP TABLE IF EXISTS `node_preloaded`;
CREATE TABLE `node_preloaded` (
  `uid` varchar(100) NOT NULL,
  `type` int(20) NOT NULL,
  `company_id` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `node_preloaded`
--

INSERT INTO `node_preloaded` (`uid`, `type`, `company_id`) VALUES
('123456', 2, 1),
('88A904A4BD', 3, 1),
('89390484BD', 2, 1),
('A83910B471', 2, 1),
('ACB904843D', 1, 1),
('ACB914A4BD', 3, 1);

-- --------------------------------------------------------

--
-- Tabellstruktur `node_thresholds`
--

DROP TABLE IF EXISTS `node_thresholds`;
CREATE TABLE `node_thresholds` (
  `id` int(11) NOT NULL,
  `action` varchar(255) NOT NULL,
  `threshold` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `node_thresholds`
--

INSERT INTO `node_thresholds` (`id`, `action`, `threshold`) VALUES
(1, 'SAME', 22),
(3, 'UNDER', 37),
(4, 'SAME', 0),
(21, 'UNDER', 0),
(22, 'SAME', 0),
(23, 'SAME', 2),
(24, 'UNDER', 5000),
(26, 'SAME', 5),
(27, 'DOWN', 100),
(28, 'SAME', 100),
(29, 'SAME', 100),
(30, 'SAME', 0),
(31, 'SAME', 0),
(32, 'SAME', 0),
(33, 'SAME', 1),
(34, 'DOWN', 0),
(35, 'DOWN', 0),
(36, 'DOWN', 0),
(37, 'DOWN', 11000),
(38, 'UP', 10000),
(39, 'UP', 10000),
(40, 'UP', 121000),
(41, 'UP', 100012),
(42, 'SAME', 100012),
(43, 'UP', 15000),
(44, 'DOWN', 10000),
(45, 'DOWN', 25000),
(46, 'UP', 20000),
(47, 'UP', 1),
(48, 'UP', 1),
(49, 'SAME', 0);

-- --------------------------------------------------------

--
-- Tabellstruktur `node_types`
--

DROP TABLE IF EXISTS `node_types`;
CREATE TABLE `node_types` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `app_settings` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `node_types`
--

INSERT INTO `node_types` (`id`, `name`, `app_settings`) VALUES
(1, 'temp-humidity', '020100504100000000000000000000000000000000000000'),
(2, 'switch', '0102005041000100000080004f0c0c0c0000000000000000'),
(3, 'analog-wheel', '010300504100010200000002010c0c0c0000000000000000');

-- --------------------------------------------------------

--
-- Tabellstruktur `shared_log`
--

DROP TABLE IF EXISTS `shared_log`;
CREATE TABLE `shared_log` (
  `id` int(11) NOT NULL,
  `prod_name` varchar(255) NOT NULL,
  `artic_num` varchar(255) NOT NULL,
  `reg_date` varchar(255) NOT NULL,
  `install_date` varchar(255) NOT NULL,
  `error_date` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellstruktur `spaces`
--

DROP TABLE IF EXISTS `spaces`;
CREATE TABLE `spaces` (
  `id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `agent` int(11) NOT NULL,
  `has_capability` int(11) NOT NULL,
  `is_part_of` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `spaces`
--

INSERT INTO `spaces` (`id`, `type`, `name`, `agent`, `has_capability`, `is_part_of`) VALUES
(1, 'office', 'Kontor 1', 1, 123, 7),
(2, 'food-court', 'Matsal', 1, 123, 7),
(3, 'entrance', 'Entré', 1, 123, 7),
(4, 'allbinary', 'test', 1, 123, 2),
(5, 'main-building', 'ICA Kontor', 32, 123, NULL),
(6, 'Cleaning closet', 'Städskrubb', 32, 123, 5),
(7, 'main-building', 'Huvudbyggnad', 1, 123, NULL),
(8, 'office', 'Kontor 12', 32, 123, 5);

-- --------------------------------------------------------

--
-- Tabellstruktur `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `role` int(11) NOT NULL,
  `company_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `users`
--

INSERT INTO `users` (`id`, `user_id`, `role`, `company_id`) VALUES
(2, '620523493dbc5d0068b2f2a9', 0, 1),
(3, '62069b4fcd0cab00711b040d', 2, 1);

-- --------------------------------------------------------

--
-- Tabellstruktur `user_log`
--

DROP TABLE IF EXISTS `user_log`;
CREATE TABLE `user_log` (
  `id` int(11) NOT NULL,
  `from_device` int(11) DEFAULT NULL,
  `report_date` varchar(255) NOT NULL,
  `msg` varchar(255) NOT NULL,
  `priority` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellstruktur `user_login`
--

DROP TABLE IF EXISTS `user_login`;
CREATE TABLE `user_login` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `nickname` varchar(255) NOT NULL,
  `email_Verified` tinyint(1) NOT NULL DEFAULT '1',
  `role` int(11) NOT NULL,
  `company_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `user_login`
--

INSERT INTO `user_login` (`id`, `email`, `password`, `first_name`, `last_name`, `nickname`, `email_Verified`, `role`, `company_id`) VALUES
(1, 'tractteam2001@gmail.com', '$2a$12$gFm.o6d8we7jugAYottmcOfZTFUJ5aE9qHgialKOtH1yBK99fC5HC', 'Abdulrahman', 'Sakah', 'tractteam', 1, 0, 1),
(3, 'hloarab@gmail.com', '$2b$12$roLpC2B0FCur/o6t1mosOurbsxJ9nVJl8Hb1M3V5VjVfS82r9E3ai', 'abod', 'sakah', 'abodsakah', 0, 2, 3),
(4, 'info@tractteam.xyz', '$2a$12$Xgnx3FpzmTxIg5LDm81zvO7WSdZwk/Z6LuplnNyGtGuyev6VCeM02', 'Tract', 'Builders', 'TractBuilders', 1, 0, 1),
(27, 'tester@email.com', '$2a$12$wLaXfuCMOh1C0oG.e.5p.eJCW6gTggU46HAtKzQtsH5aGoJA6Swpy', 'Test', 'user', 'testerUser', 0, 2, 1),
(28, 'tract@allbin.se', '$2y$10$MqZ.z6IzqDaR8/jAiax2G.iHEFP.tkWpQTJT78PS/trH4WTM1F6C.', 'Tract', 'Admin', 'tractAdmin', 0, 0, 1),
(29, 'abodsakka2001@gmail.com', '$2b$12$rU1lc19EHxI8On1SdMOHL.ksFR1EahunwYi61LLl/7a.HhwsH0utO', 'Abdulrahman', 'Sakah', 'abodsakka', 1, 0, 1),
(30, 'test@test.test', '$2b$12$uA.SM4QzPdklsHW/MD/Nsule.I5BXsYUQOBfyKoBCvBnpRDJ.bFUW', 'test', 'test', 'test', 1, 1, 27),
(31, 'testAdmin@test.se', '$2b$12$4okCvv5aT9nNcJs3Hlufq..1E/cnaIW06PVgEOEWPu2O8MB4GuKE6', 'testAdmin', 'adminTest', 'test', 1, 1, 27),
(32, 'testi@test.se', '$2b$12$mC/bfdp6Du34TrvG4oeUje4fZr1WmoB3X5HQvw6mQhF/PM/IneEsa', 'testi', 'testtest', 'testiAdmin', 1, 1, 28),
(33, 'abodefdw@grwegr.com', '$2b$12$ESQPo2ORewNHQseiR.gRj.PIWNbwmSjMp0rdXOVNqTqy7HE6j8Du2', 'ewfwefwef', 'dwfewfefw', 'efwfwefewfwef', 1, 1, 29),
(34, 'fwefewf@wfwef.com', '$2b$12$EVOGSIt3YNrPZcdkgxrLLubGKk9px./Bum5AVBT.Uk.XM3mpRQZ8m', 'efwefe', 'ewfwef', 'ewfwef', 1, 1, 30),
(35, 'fwef@refewf.com', '$2b$12$CpRWLebFF9WWl.39Q.SEXeVnLabBUg1DGBiJyn8oetogBTYFyTOia', 'wefwefwef', 'qwefwefew', 'ewfwefewfewf', 1, 1, 31),
(36, 'abodsakka2021@gmail.com', '$2b$12$bJ94IohCKpxF8E4EOvayRO1JeSNqwPCoXWLIv5gP32xQK14Y1wQgq', 'test32', 'user', 'abodsasdasd', 1, 2, 31),
(37, 'wfewfewfwef@gwefwef.com', '$2b$12$99dllEvTCRP4z9aFzVQL4.i1IJYfr.iPwXGNmj2Hxuu0BMdpz3NQ.', 'fwefewfe', 'efewfef', 'wfweewffe', 1, 0, 28),
(38, 'icaadmin@gmail.com', '$2b$12$qVNiTAr8jx1mWqsl.gxsI.PC09a4PmUAvsh69vMsKlhHkttoNqbVO', 'icadmin', 'admin', 'adminica', 1, 1, 32),
(39, 'icatest@gmail.com', '$2b$12$SsZUKOukWh255kCKsqW07OrGiCrm5GzLwjnGCYnIYbUQE4Og44i/q', 'ica', 'admin', 'icatest', 1, 1, 32),
(40, 'tomas.sareklint@allbinary.se', '$2b$12$GNJAzHNwpTFSYsrnOYNmB.RLWzMknfOZL1uVRVRsqcHuKceNVkKJG', 'Tomas', 'Sareklint', 'Tomas', 1, 0, 1);

-- --------------------------------------------------------

--
-- Tabellstruktur `website_settings`
--

DROP TABLE IF EXISTS `website_settings`;
CREATE TABLE `website_settings` (
  `comp_id` int(11) NOT NULL,
  `color` varchar(255) NOT NULL,
  `logo` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `website_settings`
--

INSERT INTO `website_settings` (`comp_id`, `color`, `logo`) VALUES
(1, '00ff11', 'Asset 1.png'),
(28, '0074f0', 'Kalmar_Omsorg_stöd.png'),
(31, '26a697', 'Asset 1.png'),
(32, 'f11313', 'download.png');

-- --------------------------------------------------------

--
-- Struktur för vy `company_settings`
--
DROP TABLE IF EXISTS `company_settings`;

DROP VIEW IF EXISTS `company_settings`;
CREATE ALGORITHM=UNDEFINED DEFINER=`tractteam`@`localhost` SQL SECURITY DEFINER VIEW `company_settings`  AS SELECT `ws`.`color` AS `color`, `ws`.`logo` AS `logo`, `ws`.`comp_id` AS `comp_id`, `c`.`name` AS `name` FROM (`website_settings` `ws` join `companies` `c` on((`ws`.`comp_id` = `c`.`id`)))  ;

-- --------------------------------------------------------

--
-- Struktur för vy `company_website_settings`
--
DROP TABLE IF EXISTS `company_website_settings`;

DROP VIEW IF EXISTS `company_website_settings`;
CREATE ALGORITHM=UNDEFINED DEFINER=`tractteam`@`localhost` SQL SECURITY DEFINER VIEW `company_website_settings`  AS SELECT `companies`.`id` AS `id`, `companies`.`name` AS `name`, `companies`.`support_email` AS `support_email`, `companies`.`support_phone` AS `support_phone`, `website_settings`.`color` AS `color`, `website_settings`.`logo` AS `logo` FROM (`companies` left join `website_settings` on((`companies`.`id` = `website_settings`.`comp_id`)))  ;

-- --------------------------------------------------------

--
-- Struktur för vy `logical_devices_all`
--
DROP TABLE IF EXISTS `logical_devices_all`;

DROP VIEW IF EXISTS `logical_devices_all`;
CREATE ALGORITHM=UNDEFINED DEFINER=`tractteam`@`%` SQL SECURITY DEFINER VIEW `logical_devices_all`  AS SELECT `l`.`id` AS `id`, `l`.`uid` AS `uid`, `l`.`name` AS `name`, `l`.`trigger_action` AS `trigger_action`, `l`.`install_date` AS `install_date`, `l`.`is_part_of` AS `is_part_of`, `l`.`type` AS `type`, `l`.`status` AS `status`, `s`.`agent` AS `company_id`, `t`.`name` AS `type_name`, `t`.`app_settings` AS `app_settings` FROM ((`logical_devices` `l` join `spaces` `s` on((`s`.`id` = `l`.`is_part_of`))) join `node_types` `t` on((`t`.`id` = `l`.`type`)))  ;

-- --------------------------------------------------------

--
-- Struktur för vy `logical_devices_with_company_id`
--
DROP TABLE IF EXISTS `logical_devices_with_company_id`;

DROP VIEW IF EXISTS `logical_devices_with_company_id`;
CREATE ALGORITHM=UNDEFINED DEFINER=`tractteam`@`%` SQL SECURITY DEFINER VIEW `logical_devices_with_company_id`  AS SELECT `l`.`id` AS `id`, `l`.`uid` AS `uid`, `l`.`name` AS `name`, `l`.`trigger_action` AS `trigger_action`, `l`.`install_date` AS `install_date`, `l`.`is_part_of` AS `is_part_of`, `l`.`type` AS `type`, `l`.`status` AS `status`, `s`.`agent` AS `company_id` FROM (`logical_devices` `l` join `spaces` `s` on((`s`.`id` = `l`.`is_part_of`)))  ;

--
-- Index för dumpade tabeller
--

--
-- Index för tabell `acess`
--
ALTER TABLE `acess`
  ADD PRIMARY KEY (`node_id`,`comp_id`,`user_id`),
  ADD KEY `comp_id` (`comp_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index för tabell `api_keys`
--
ALTER TABLE `api_keys`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `assets`
--
ALTER TABLE `assets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `located_in` (`located_in`),
  ADD KEY `assets_ibfk_2` (`hosts`);

--
-- Index för tabell `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `company_log`
--
ALTER TABLE `company_log`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `logical_devices`
--
ALTER TABLE `logical_devices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uid` (`uid`),
  ADD KEY `trigger_action` (`trigger_action`),
  ADD KEY `logical_devices_ibfk_3` (`type`),
  ADD KEY `logical_devices_ibfk_2` (`is_part_of`);

--
-- Index för tabell `nc_evolutions`
--
ALTER TABLE `nc_evolutions`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `node_preloaded`
--
ALTER TABLE `node_preloaded`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `node_preloaded_ibfk_1` (`type`);

--
-- Index för tabell `node_thresholds`
--
ALTER TABLE `node_thresholds`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `node_types`
--
ALTER TABLE `node_types`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `shared_log`
--
ALTER TABLE `shared_log`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `spaces`
--
ALTER TABLE `spaces`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agent` (`agent`),
  ADD KEY `spaces_ibfk_2` (`is_part_of`);

--
-- Index för tabell `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`);

--
-- Index för tabell `user_log`
--
ALTER TABLE `user_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `from_device` (`from_device`);

--
-- Index för tabell `user_login`
--
ALTER TABLE `user_login`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `website_settings`
--
ALTER TABLE `website_settings`
  ADD PRIMARY KEY (`comp_id`);

--
-- AUTO_INCREMENT för dumpade tabeller
--

--
-- AUTO_INCREMENT för tabell `api_keys`
--
ALTER TABLE `api_keys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT för tabell `assets`
--
ALTER TABLE `assets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT för tabell `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT för tabell `company_log`
--
ALTER TABLE `company_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=242;

--
-- AUTO_INCREMENT för tabell `logical_devices`
--
ALTER TABLE `logical_devices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT för tabell `nc_evolutions`
--
ALTER TABLE `nc_evolutions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT för tabell `node_thresholds`
--
ALTER TABLE `node_thresholds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT för tabell `node_types`
--
ALTER TABLE `node_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT för tabell `spaces`
--
ALTER TABLE `spaces`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT för tabell `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT för tabell `user_log`
--
ALTER TABLE `user_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT för tabell `user_login`
--
ALTER TABLE `user_login`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- Restriktioner för dumpade tabeller
--

--
-- Restriktioner för tabell `acess`
--
ALTER TABLE `acess`
  ADD CONSTRAINT `acess_ibfk_1` FOREIGN KEY (`node_id`) REFERENCES `logical_devices` (`id`),
  ADD CONSTRAINT `acess_ibfk_2` FOREIGN KEY (`comp_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `acess_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Restriktioner för tabell `assets`
--
ALTER TABLE `assets`
  ADD CONSTRAINT `assets_ibfk_1` FOREIGN KEY (`located_in`) REFERENCES `spaces` (`id`),
  ADD CONSTRAINT `assets_ibfk_2` FOREIGN KEY (`hosts`) REFERENCES `logical_devices` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Restriktioner för tabell `logical_devices`
--
ALTER TABLE `logical_devices`
  ADD CONSTRAINT `logical_devices_ibfk_1` FOREIGN KEY (`trigger_action`) REFERENCES `node_thresholds` (`id`),
  ADD CONSTRAINT `logical_devices_ibfk_2` FOREIGN KEY (`is_part_of`) REFERENCES `spaces` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `logical_devices_ibfk_3` FOREIGN KEY (`type`) REFERENCES `node_types` (`id`);

--
-- Restriktioner för tabell `node_preloaded`
--
ALTER TABLE `node_preloaded`
  ADD CONSTRAINT `node_preloaded_ibfk_1` FOREIGN KEY (`type`) REFERENCES `node_types` (`id`);

--
-- Restriktioner för tabell `spaces`
--
ALTER TABLE `spaces`
  ADD CONSTRAINT `spaces_ibfk_1` FOREIGN KEY (`agent`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `spaces_ibfk_2` FOREIGN KEY (`is_part_of`) REFERENCES `spaces` (`id`) ON UPDATE CASCADE;

--
-- Restriktioner för tabell `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`);

--
-- Restriktioner för tabell `website_settings`
--
ALTER TABLE `website_settings`
  ADD CONSTRAINT `website_settings_ibfk_1` FOREIGN KEY (`comp_id`) REFERENCES `companies` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
