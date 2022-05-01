-- phpMyAdmin SQL Dump
-- version 4.6.6deb4+deb9u2
-- https://www.phpmyadmin.net/
--
-- Värd: localhost:3306
-- Tid vid skapande: 16 apr 2022 kl 19:31
-- Serverversion: 10.1.48-MariaDB-0+deb9u2
-- PHP-version: 7.0.33-0+deb9u11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databas: `tract`
--

DELIMITER $$
--
-- Procedurer
--

DELIMITER ;;
CREATE PROCEDURE add_node_no_trigger_action(
  IN n_node_uid VARCHAR(255),
  IN n_node_name VARCHAR(255),
  IN n_is_part_of INT,
  IN n_node_type INT,
  IN n_node_status VARCHAR(255)
)
BEGIN
INSERT INTO logical_devices (uid, name, trigger_action, install_date, is_part_of, type, status) VALUES ("88A904A4BD", "testDevice", 1, CURRENT_DATE(), 1, 1, "SETUP")

  INSERT INTO logical_device (node_uid, node_name, trigger_action, install_date, is_part_of, node_type, node_status)
  VALUES (n_node_uid, n_node_name, 0, CURRENT_DATE(), n_is_part_of, n_node_type, n_node_status);
END;;
DELIMITER ;
INSERT INTO `logical_devices` (`id`, `uid`, `name`, `trigger_action`, `install_date`, `is_part_of`, `type`, `status`) VALUES (NULL, `n_uid`, `n_name`, `n_trigger_action`, CURRENT_DATE(), `n_is_part_of`, `n_type`, `n_status`);
END$$

CREATE DEFINER=`tractteam`@`%` PROCEDURE `add_test_logical_device_base` ()  BEGIN
-- node threshold
INSERT INTO `node_thresholds` (`id`, `action`, `trigger_action`) VALUES (NULL, 'test action', 'test trigger action');
-- space
INSERT INTO `spaces` (`id`, `type`, `name`, `agent`, `has_capability`, `is_part_of`)
VALUES (NULL, 'test', 'test space', '1', '123', NULL);
-- logical device
INSERT INTO `logical_devices` (`id`, `uid`, `name`, `trigger_action`, `install_date`, `is_part_of`, `status`)
VALUES (NULL, '123456', 'test logical device', '1', CURRENT_DATE(), '1', 'active');
END$$

CREATE DEFINER=`tractteam`@`%` PROCEDURE `delete_node` (IN `p_id` INT, IN `p_company_id` INT)  NO SQL
BEGIN
DELETE l
  FROM logical_devices l
  LEFT JOIN spaces s
  ON s.id = l.is_part_of
 WHERE l.id = p_id
 	AND s.agent = p_company_id
    AND l.status = "DELETED"
 ;
END$$

CREATE DEFINER=`abodsakka`@`localhost` PROCEDURE `get_amount_type_of_sensor` (IN `sensor_type` VARCHAR(255), IN `company_id` VARCHAR(255))  BEGIN
  SELECT COUNT(*) AS amount FROM `logical_devices_all` WHERE `type_name` = sensor_type AND `company_id` = company_id;
END$$

CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_company_settings` (IN `company_id` INT)  BEGIN
    SELECT 
      *
    FROM `company_settings`;
END$$

CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_logical_device_all` (IN `p_id` INT(11), IN `p_company_id` INT(11))  NO SQL
BEGIN
SELECT *
FROM logical_devices_all
WHERE p_id=id AND p_company_id=company_id;
END$$

CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_logical_device_status` (IN `p_id` INT(11), IN `p_company_id` INT(11))  NO SQL
BEGIN
SELECT `status`
FROM `logical_devices_with_company_id`
WHERE p_id=id AND p_company_id=company_id;
END$$

CREATE DEFINER=`tractteam`@`%` PROCEDURE `get_node_from_uid` (IN `p_uid` VARCHAR(20) CHARSET utf8mb4)  NO SQL
    COMMENT 'get all logical_device info for a certain UID'
BEGIN
SELECT *
FROM logical_devices_all
WHERE p_uid=uid;
END$$

CREATE DEFINER=`abodsakka`@`localhost` PROCEDURE `get_users_for_company` (IN `company_id` INT)  BEGIN
  SELECT * FROM `user_login` WHERE `company_id` = company_id;
END$$

CREATE DEFINER=`abodsakka`@`localhost` PROCEDURE `logical_devices_for_company` (IN `company_id` INT)  BEGIN
  SELECT * FROM `logical_devices_all` WHERE `company_id` = company_id;
END$$

CREATE DEFINER=`tractteam`@`%` PROCEDURE `set_device_as_deleted` (IN `p_id` INT(11), IN `company_id` INT(11))  BEGIN
    UPDATE logical_devices l
    LEFT OUTER JOIN spaces s
    ON l.is_part_of = s.id
    SET l.status = "DELETED"
    WHERE l.id = p_id AND s.agent = company_id;
END$$

CREATE DEFINER=`tractteam`@`%` PROCEDURE `update_company_settings` (IN `company_id` INT, IN `color` VARCHAR(255), IN `logo` VARCHAR(255))  BEGIN
    UPDATE `website_settings`
    SET `color` = color,
        `logo` = logo
    WHERE `comp_id` = company_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tabellstruktur `acess`
--

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

CREATE TABLE `assets` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `artic_num` varchar(255) NOT NULL,
  `located_in` int(11) NOT NULL,
  `has_capability` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellstruktur `companies`
--

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
(1, 'Tract', 'info@abodsakka.xyz', '0721282737'),
(2, 'allBinary', 'test@test.test', '00000');

-- --------------------------------------------------------

--
-- Ersättningsstruktur för vy `company_settings`
-- (See below for the actual view)
--
CREATE TABLE `company_settings` (
`color` varchar(255)
,`logo` varchar(255)
,`comp_id` int(11)
,`name` varchar(255)
);

-- --------------------------------------------------------

--
-- Tabellstruktur `logical_devices`
--

CREATE TABLE `logical_devices` (
  `id` int(11) NOT NULL,
  `uid` varchar(20) NOT NULL,
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
(16, '89390484BD', 'switch-sensor', 4, '2022-04-07', 2, 2, 'active'),
(24, 'ACB914A4BD', 'analog-wheel-sensor', 3, '2022-04-07', 1, 3, 'active'),
(42, 'ACB904843D', 'temp-sensor', 3, '2022-04-05', 2, 1, 'active'),
(102, 'ADB900243F', 'all-binary-node', 3, '2022-04-14', 4, 1, 'active'),
(103, '23531345', 'Device 1', 1, '2022-04-16', 1, 2, 'ACTIVE');

-- --------------------------------------------------------

--
-- Ersättningsstruktur för vy `logical_devices_all`
-- (See below for the actual view)
--
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

CREATE TABLE `node_preloaded` (
  `uid` varchar(100) NOT NULL,
  `type` int(20) NOT NULL,
  `company_id` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `node_preloaded`
--

INSERT INTO `node_preloaded` (`uid`, `type`, `company_id`) VALUES
('88A904A4BD', 3, 1),
('89390484BD', 2, 1),
('ACB904843D', 1, 1),
('ACB914A4BD', 3, 1);

-- --------------------------------------------------------

--
-- Tabellstruktur `node_thresholds`
--

CREATE TABLE `node_thresholds` (
  `id` int(11) NOT NULL,
  `action` varchar(255) NOT NULL,
  `trigger_action` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `node_thresholds`
--

INSERT INTO `node_thresholds` (`id`, `action`, `trigger_action`) VALUES
(1, 'test action', 'test trigger action'),
(3, 'test action', 'test trigger action'),
(4, 'test action', 'test trigger action');

-- --------------------------------------------------------

--
-- Tabellstruktur `node_types`
--

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

CREATE TABLE `shared_log` (
  `id` int(11) NOT NULL,
  `prod_name` varchar(255) NOT NULL,
  `artic_num` varchar(255) NOT NULL,
  `reg_date` varchar(255) NOT NULL,
  `install_date` varchar(255) NOT NULL,
  `time_stamp` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellstruktur `spaces`
--

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
(1, 'test', 'test space 1', 1, 123, NULL),
(2, 'test', 'test space 2', 1, 123, NULL),
(3, 'test', 'test space 3', 1, 123, NULL),
(4, 'allbinary', 'test', 2, 123, 2);

-- --------------------------------------------------------

--
-- Tabellstruktur `users`
--

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

CREATE TABLE `user_log` (
  `id` int(11) NOT NULL,
  `in_space` int(11) NOT NULL,
  `from_device` int(11) DEFAULT NULL,
  `report_date` varchar(255) NOT NULL,
  `msg` varchar(255) NOT NULL,
  `priority` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabellstruktur `user_login`
--

CREATE TABLE `user_login` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `nickname` varchar(255) NOT NULL,
  `email_Verified` tinyint(1) NOT NULL,
  `role` int(11) NOT NULL,
  `company_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `user_login`
--

INSERT INTO `user_login` (`id`, `email`, `password`, `first_name`, `last_name`, `nickname`, `email_Verified`, `role`, `company_id`) VALUES
(1, 'abodsakka2001@gmail.com', '$2a$12$gFm.o6d8we7jugAYottmcOfZTFUJ5aE9qHgialKOtH1yBK99fC5HC', 'Abdulrahman', 'Sakah', 'abodsakka', 1, 0, 1),
(3, 'hloarab@gmail.com', '$2b$12$roLpC2B0FCur/o6t1mosOurbsxJ9nVJl8Hb1M3V5VjVfS82r9E3ai', 'abod', 'sakah', 'abodsakah', 0, 2, 3),
(4, 'info@abodsakka.xyz', '$2a$12$Xgnx3FpzmTxIg5LDm81zvO7WSdZwk/Z6LuplnNyGtGuyev6VCeM02', 'Tract', 'Builders', 'TractBuilders', 1, 0, 1);

-- --------------------------------------------------------

--
-- Tabellstruktur `website_settings`
--

CREATE TABLE `website_settings` (
  `comp_id` int(11) NOT NULL,
  `color` varchar(255) NOT NULL,
  `logo` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumpning av Data i tabell `website_settings`
--

INSERT INTO `website_settings` (`comp_id`, `color`, `logo`) VALUES
(1, '38e39a', 'Asset 1.png');

-- --------------------------------------------------------

--
-- Struktur för vy `company_settings`
--
DROP TABLE IF EXISTS `company_settings`;

CREATE ALGORITHM=UNDEFINED DEFINER=`abodsakka`@`localhost` SQL SECURITY DEFINER VIEW `company_settings`  AS  select `ws`.`color` AS `color`,`ws`.`logo` AS `logo`,`ws`.`comp_id` AS `comp_id`,`c`.`name` AS `name` from (`website_settings` `ws` join `companies` `c` on((`ws`.`comp_id` = `c`.`id`))) ;

-- --------------------------------------------------------

--
-- Struktur för vy `logical_devices_all`
--
DROP TABLE IF EXISTS `logical_devices_all`;

CREATE ALGORITHM=UNDEFINED DEFINER=`tractteam`@`%` SQL SECURITY DEFINER VIEW `logical_devices_all`  AS  select `l`.`id` AS `id`,`l`.`uid` AS `uid`,`l`.`name` AS `name`,`l`.`trigger_action` AS `trigger_action`,`l`.`install_date` AS `install_date`,`l`.`is_part_of` AS `is_part_of`,`l`.`type` AS `type`,`l`.`status` AS `status`,`s`.`agent` AS `company_id`,`t`.`name` AS `type_name`,`t`.`app_settings` AS `app_settings` from ((`logical_devices` `l` join `spaces` `s` on((`s`.`id` = `l`.`is_part_of`))) join `node_types` `t` on((`t`.`id` = `l`.`type`))) ;

-- --------------------------------------------------------

--
-- Struktur för vy `logical_devices_with_company_id`
--
DROP TABLE IF EXISTS `logical_devices_with_company_id`;

CREATE ALGORITHM=UNDEFINED DEFINER=`tractteam`@`%` SQL SECURITY DEFINER VIEW `logical_devices_with_company_id`  AS  select `l`.`id` AS `id`,`l`.`uid` AS `uid`,`l`.`name` AS `name`,`l`.`trigger_action` AS `trigger_action`,`l`.`install_date` AS `install_date`,`l`.`is_part_of` AS `is_part_of`,`l`.`type` AS `type`,`l`.`status` AS `status`,`s`.`agent` AS `company_id` from (`logical_devices` `l` join `spaces` `s` on((`s`.`id` = `l`.`is_part_of`))) ;

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
  ADD KEY `has_capability` (`has_capability`);

--
-- Index för tabell `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `logical_devices`
--
ALTER TABLE `logical_devices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uid` (`uid`),
  ADD KEY `trigger_action` (`trigger_action`),
  ADD KEY `logical_devices_ibfk_2` (`is_part_of`),
  ADD KEY `logical_devices_ibfk_3` (`type`);

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
  ADD KEY `is_part_of` (`is_part_of`);

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
  ADD KEY `in_space` (`in_space`),
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT för tabell `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;
--
-- AUTO_INCREMENT för tabell `logical_devices`
--
ALTER TABLE `logical_devices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;
--
-- AUTO_INCREMENT för tabell `nc_evolutions`
--
ALTER TABLE `nc_evolutions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT för tabell `node_thresholds`
--
ALTER TABLE `node_thresholds`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT för tabell `node_types`
--
ALTER TABLE `node_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT för tabell `spaces`
--
ALTER TABLE `spaces`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
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
  ADD CONSTRAINT `assets_ibfk_2` FOREIGN KEY (`has_capability`) REFERENCES `logical_devices` (`id`);

--
-- Restriktioner för tabell `logical_devices`
--
ALTER TABLE `logical_devices`
  ADD CONSTRAINT `logical_devices_ibfk_1` FOREIGN KEY (`trigger_action`) REFERENCES `node_thresholds` (`id`),
  ADD CONSTRAINT `logical_devices_ibfk_2` FOREIGN KEY (`is_part_of`) REFERENCES `spaces` (`id`),
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
  ADD CONSTRAINT `spaces_ibfk_2` FOREIGN KEY (`is_part_of`) REFERENCES `spaces` (`id`);

--
-- Restriktioner för tabell `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`);

--
-- Restriktioner för tabell `user_log`
--
ALTER TABLE `user_log`
  ADD CONSTRAINT `user_log_ibfk_1` FOREIGN KEY (`in_space`) REFERENCES `spaces` (`id`),
  ADD CONSTRAINT `user_log_ibfk_2` FOREIGN KEY (`from_device`) REFERENCES `logical_devices` (`id`);

--
-- Restriktioner för tabell `website_settings`
--
ALTER TABLE `website_settings`
  ADD CONSTRAINT `website_settings_ibfk_1` FOREIGN KEY (`comp_id`) REFERENCES `companies` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

DROP PROCEDURE IF EXISTS `get_all_buildings`;
DELMIMTER ;;
CREATE PROCEDURE `get_all_buildings`(IN `company_id` INT)
BEGIN
  SELECT * FROM spaces WHERE is_part_of = NULL AND agent = company_id;
END;;
DELMIMTER ;

DROP PROCEDURE IF EXISTS `get_spaces_for_company`;
DELIMITER ;;
CREATE PROCEDURE `get_spaces_for_company`(IN `company_id` INT, IN `space_id` INT)
BEGIN
  SELECT * FROM spaces WHERE is_part_of = space_id;
END;;
DELIMITER ;

DROP PROCEDURE IF EXISTS `get_assets_in_space`;
DELIMITER ;;
CREATE PROCEDURE `get_assets_in_space`(IN `space_id` INT)
BEGIN
  SELECT * FROM assets WHERE located_in = space_id;
END;;
DELIMITER ;

DROP PROCEDURE IF EXISTS update_threshold;
DELIMITER ;;
CREATE PROCEDURE update_threshold(IN deviceUid, IN thresholdId)
BEGIN
  UPDATE logical_devices SET trigger_action = thresholdId WHERE id = deviceUid;
END;;
DELIMITER ;

DROP PROCEDURE IF EXISTS create_threshold;
DELIMITER ;;
CREATE PROCEDURE create_threshold(IN n_action vARCHAR(10), IN n_treshold VARCHAR(255))
BEGIN
  INSERT INTO node_thresholds (action, threshold) VALUES (n_action, n_treshold);
  -- select the id of the last inserted row
  SELECT LAST_INSERT_ID() AS id;
END;;

DROP PROCEDURE IF EXISTS get_node_threshold;
DELIMITER ;;
CREATE PROCEDURE get_node_threshold(IN deviceUid)
BEGIN
  SELECT * FROM node_thresholds WHERE id = deviceUid;
END;;
DELIMITER ;

DROP PROCEDURE IF EXISTS get_nodes_for_type;
DELIMITER ;;
CREATE PROCEDURE get_nodes_for_type(IN company_id INT, IN node_type VARCHAR(255))
BEGIN
  SELECT * FROM `logical_devices_all` WHERE `type_name` = node_type AND `company_id` = company_id;
END;;
DELIMITER ;
