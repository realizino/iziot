-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Sep 25, 2024 at 07:37 PM
-- Server version: 8.3.0
-- PHP Version: 8.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `b_service`
--

-- --------------------------------------------------------

--
-- Table structure for table `airquality_arch_tbl`
--

DROP TABLE IF EXISTS `airquality_arch_tbl`;
CREATE TABLE IF NOT EXISTS `airquality_arch_tbl` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hub_id` int NOT NULL,
  `date_time` varchar(50) NOT NULL,
  `value` varchar(50) NOT NULL,
  `attribute` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14787 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `airquality_tbl`
--

DROP TABLE IF EXISTS `airquality_tbl`;
CREATE TABLE IF NOT EXISTS `airquality_tbl` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hub_id` int DEFAULT NULL,
  `date_time` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `attribute` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `hub_id` (`hub_id`)
) ENGINE=MyISAM AUTO_INCREMENT=231762 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `airquality_tbl`
--

INSERT INTO `airquality_tbl` (`id`, `hub_id`, `date_time`, `value`, `attribute`) VALUES
(231713, 15, '2024-09-25T22:08:13.995813300', '10', '-'),
(231714, 15, '2024-09-25T22:08:51.905660900', '10', '-'),
(231715, 15, '2024-09-25T22:09:21.838295700', '10', '-'),
(231716, 15, '2024-09-25T22:09:51.839889600', '10', '-'),
(231717, 15, '2024-09-25T22:10:21.842263800', '10', '-'),
(231718, 15, '2024-09-25T22:10:51.828806400', '10', '-'),
(231719, 15, '2024-09-25T22:11:21.843657', '10', '-'),
(231720, 15, '2024-09-25T22:11:51.836187400', '10', '-'),
(231721, 15, '2024-09-25T22:12:21.828806200', '10', '-'),
(231722, 15, '2024-09-25T22:12:51.831252400', '10', '-'),
(231723, 15, '2024-09-25T22:13:21.832995600', '10', '-'),
(231724, 15, '2024-09-25T22:13:51.842265200', '10', '-'),
(231725, 15, '2024-09-25T22:14:21.829813200', '10', '-'),
(231726, 15, '2024-09-25T22:14:51.833348800', '10', '-'),
(231727, 15, '2024-09-25T22:15:21.839385100', '10', '-'),
(231728, 15, '2024-09-25T22:15:51.836860', '10', '-'),
(231729, 15, '2024-09-25T22:16:21.844153700', '10', '-'),
(231730, 15, '2024-09-25T22:16:51.837708200', '10', '-'),
(231731, 15, '2024-09-25T22:17:21.833196100', '10', '-'),
(231732, 15, '2024-09-25T22:17:51.832189500', '10', '-'),
(231733, 15, '2024-09-25T22:18:21.843108500', '10', '-'),
(231734, 15, '2024-09-25T22:18:51.843977500', '10', '-'),
(231735, 15, '2024-09-25T22:19:21.841819800', '10', '-'),
(231736, 15, '2024-09-25T22:19:51.842607100', '10', '-'),
(231737, 15, '2024-09-25T22:20:21.841972100', '10', '-'),
(231738, 15, '2024-09-25T22:20:51.832482500', '10', '-'),
(231739, 15, '2024-09-25T22:21:21.835159900', '10', '-'),
(231740, 15, '2024-09-25T22:21:51.838297500', '10', '-'),
(231741, 15, '2024-09-25T22:22:21.833424700', '10', '-'),
(231742, 15, '2024-09-25T22:22:51.841565600', '10', '-'),
(231743, 15, '2024-09-25T22:23:21.837828300', '10', '-'),
(231744, 15, '2024-09-25T22:23:51.841199100', '10', '-'),
(231745, 15, '2024-09-25T22:24:21.832128700', '10', '-'),
(231746, 15, '2024-09-25T22:24:51.829014800', '10', '-'),
(231747, 15, '2024-09-25T22:25:21.837472200', '10', '-'),
(231748, 15, '2024-09-25T22:25:51.834555700', '10', '-'),
(231749, 15, '2024-09-25T22:26:21.841306300', '10', '-'),
(231750, 15, '2024-09-25T22:26:51.841541500', '10', '-'),
(231751, 15, '2024-09-25T22:27:21.831089600', '10', '-'),
(231752, 15, '2024-09-25T22:27:51.836302300', '10', '-'),
(231753, 15, '2024-09-25T22:28:21.843045100', '10', '-'),
(231754, 15, '2024-09-25T22:28:51.845822700', '10', '-'),
(231755, 15, '2024-09-25T22:29:21.832008100', '10', '-'),
(231756, 15, '2024-09-25T22:29:51.834058700', '10', '-'),
(231757, 15, '2024-09-25T22:30:21.833400200', '10', '-'),
(231758, 15, '2024-09-25T22:30:51.839119500', '10', '-'),
(231759, 15, '2024-09-25T22:31:21.840985', '10', '-'),
(231760, 15, '2024-09-25T22:31:51.841060800', '10', '-'),
(231761, 15, '2024-09-25T22:32:21.831799800', '10', '-');

-- --------------------------------------------------------

--
-- Table structure for table `ai_tags_tbl`
--

DROP TABLE IF EXISTS `ai_tags_tbl`;
CREATE TABLE IF NOT EXISTS `ai_tags_tbl` (
  `id` int NOT NULL AUTO_INCREMENT,
  `image_id` int DEFAULT NULL,
  `date_time` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `tags` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `image_id` (`image_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `city_tbls`
--

DROP TABLE IF EXISTS `city_tbls`;
CREATE TABLE IF NOT EXISTS `city_tbls` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `area` int NOT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `datetime` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `timezone` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `city_tbls`
--

INSERT INTO `city_tbls` (`id`, `name`, `area`, `status`, `datetime`, `timezone`) VALUES
(1, 'Tehran', 0, '1', '2024/9/12 12:37:51', 'GMT+02:30'),
(3, 'Ottawa', 1, '1', '2024/9/12 12:18:46', '-10:00');

-- --------------------------------------------------------

--
-- Table structure for table `file_tbls`
--

DROP TABLE IF EXISTS `file_tbls`;
CREATE TABLE IF NOT EXISTS `file_tbls` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `file_name` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_address` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_address_server` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_extention` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_hash` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_date_time` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `file_tbls`
--

INSERT INTO `file_tbls` (`id`, `file_name`, `file_address`, `file_address_server`, `file_type`, `file_extention`, `file_size`, `file_hash`, `file_date_time`) VALUES
(48, 'empty', 'empty', 'empty', 'PNG', '3.141592653589793', '0', '1020315', '1400'),
(49, '3ef9169b7841ccc3ddc3b5fa10e1513475f2d2d6389c781ad801a522f01bc2b4', 'C:/Users/rezafta/Desktop/iziot/iziotServiceFileRepo/3ef9169b7841ccc3ddc3b5fa10e1513475f2d2d6389c781ad801a522f01bc2b4.png', 'C:/Users/rezafta/Desktop/iziot/iziotServiceFileRepo/3ef9169b7841ccc3ddc3b5fa10e1513475f2d2d6389c781ad801a522f01bc2b4.png', 'png', 'png', '11845', '3ef9169b7841ccc3ddc3b5fa10e1513475f2d2d6389c781ad801a522f01bc2b4', '2024/9/5 11:53:3');

-- --------------------------------------------------------

--
-- Table structure for table `hub_tbl`
--

DROP TABLE IF EXISTS `hub_tbl`;
CREATE TABLE IF NOT EXISTS `hub_tbl` (
  `id` int NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `iot_model` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `iot_type` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `permission` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `date_time` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lat` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lng` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `attribute` varchar(2048) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `default_resolution` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `admin_mobile` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `ip_address` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `url` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `timezone` varchar(60) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `hub_tbl`
--

INSERT INTO `hub_tbl` (`id`, `serial_number`, `iot_model`, `iot_type`, `status`, `permission`, `date_time`, `lat`, `lng`, `attribute`, `default_resolution`, `admin_mobile`, `ip_address`, `url`, `username`, `password`, `title`, `timezone`) VALUES
(15, '1', 'ESP32CAM', 'STAND', 'Diasable', '', '2024-SEPTEMBER-25 21:28', '45.421347149780544', '-75.71030616760254', 'Thermometer,', '480×360', '1565165165', 'http://173.33.224.231:81', 'http://173.33.224.231:81/snapshop.jpg', 'a', 'a', 'a home', 'GMT+02:30');

-- --------------------------------------------------------

--
-- Table structure for table `images_arch_tbl`
--

DROP TABLE IF EXISTS `images_arch_tbl`;
CREATE TABLE IF NOT EXISTS `images_arch_tbl` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hub_id` int NOT NULL,
  `date_time` varchar(50) NOT NULL,
  `file_address` varchar(255) NOT NULL,
  `status` varchar(50) NOT NULL,
  `resolution` varchar(50) NOT NULL,
  `size` varchar(50) NOT NULL,
  `lat` varchar(50) NOT NULL,
  `lng` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `images_tbl`
--

DROP TABLE IF EXISTS `images_tbl`;
CREATE TABLE IF NOT EXISTS `images_tbl` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hub_id` int DEFAULT NULL,
  `date_time` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `file_address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `resolution` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `size` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lat` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lng` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKpbo5dmmnxl9ab2a74jde05t5g` (`hub_id`)
) ENGINE=MyISAM AUTO_INCREMENT=6056 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `images_tbl`
--

INSERT INTO `images_tbl` (`id`, `hub_id`, `date_time`, `file_address`, `status`, `resolution`, `size`, `lat`, `lng`) VALUES
(5815, 12, '2024-09-07T11:45:21.861512900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114519.jpg', '1', '480 × 360', '18025', '10', '20'),
(5816, 12, '2024-09-07T11:45:51.180836900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114549.jpg', '1', '480 × 360', '17903', '10', '20'),
(5817, 12, '2024-09-07T11:46:21.288603300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114619.jpg', '1', '480 × 360', '17808', '10', '20'),
(5818, 12, '2024-09-07T11:46:51.353946700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114649.jpg', '1', '480 × 360', '16522', '10', '20'),
(5819, 12, '2024-09-07T11:47:21.619213600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114719.jpg', '1', '480 × 360', '17651', '10', '20'),
(5820, 12, '2024-09-07T11:47:51.393213400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114749.jpg', '1', '480 × 360', '17951', '10', '20'),
(5821, 12, '2024-09-07T11:48:21.311273700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114819.jpg', '1', '480 × 360', '17441', '10', '20'),
(5822, 12, '2024-09-07T11:48:51.651957200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114849.jpg', '1', '480 × 360', '17725', '10', '20'),
(5823, 12, '2024-09-07T11:49:23.240051300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114919.jpg', '1', '480 × 360', '17908', '10', '20'),
(5824, 12, '2024-09-07T11:49:51.070983400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/114949.jpg', '1', '480 × 360', '17449', '10', '20'),
(5825, 12, '2024-09-07T11:50:21.284896800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115019.jpg', '1', '480 × 360', '17615', '10', '20'),
(5826, 12, '2024-09-07T11:50:51.147953100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115049.jpg', '1', '480 × 360', '17683', '10', '20'),
(5827, 12, '2024-09-07T11:51:21.076491300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115119.jpg', '1', '480 × 360', '17592', '10', '20'),
(5828, 12, '2024-09-07T11:51:51.222872300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115150.jpg', '1', '480 × 360', '17764', '10', '20'),
(5829, 12, '2024-09-07T11:52:21.158070800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115219.jpg', '1', '480 × 360', '17597', '10', '20'),
(5830, 12, '2024-09-07T11:52:51.568828600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115249.jpg', '1', '480 × 360', '17648', '10', '20'),
(5831, 12, '2024-09-07T11:53:21.303325900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115319.jpg', '1', '480 × 360', '17555', '10', '20'),
(5832, 12, '2024-09-07T11:53:51.205691900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115349.jpg', '1', '480 × 360', '17632', '10', '20'),
(5833, 12, '2024-09-07T11:54:21.322154300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115419.jpg', '1', '480 × 360', '17643', '10', '20'),
(5834, 12, '2024-09-07T11:54:51.813366300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115449.jpg', '1', '480 × 360', '17598', '10', '20'),
(5835, 12, '2024-09-07T11:55:21.347862700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115519.jpg', '1', '480 × 360', '17560', '10', '20'),
(5836, 12, '2024-09-07T11:55:51.410334800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115549.jpg', '1', '480 × 360', '17615', '10', '20'),
(5837, 12, '2024-09-07T11:56:21.191383200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115619.jpg', '1', '480 × 360', '17542', '10', '20'),
(5838, 12, '2024-09-07T11:56:51.287085400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115649.jpg', '1', '480 × 360', '17582', '10', '20'),
(5839, 12, '2024-09-07T11:57:20.910527400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115719.jpg', '1', '480 × 360', '17617', '10', '20'),
(5840, 12, '2024-09-07T11:57:51.125873200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115749.jpg', '1', '480 × 360', '17706', '10', '20'),
(5841, 12, '2024-09-07T11:58:21.060314700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115819.jpg', '1', '480 × 360', '17780', '10', '20'),
(5842, 12, '2024-09-07T11:58:51.605776800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115849.jpg', '1', '480 × 360', '17688', '10', '20'),
(5843, 12, '2024-09-07T11:59:21.370034100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115919.jpg', '1', '480 × 360', '17662', '10', '20'),
(5844, 12, '2024-09-07T11:59:51.473153800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/115949.jpg', '1', '480 × 360', '8368', '10', '20'),
(5845, 12, '2024-09-07T12:00:20.844048300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12019.jpg', '1', '480 × 360', '11226', '10', '20'),
(5846, 12, '2024-09-07T12:00:51.509772', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12049.jpg', '1', '480 × 360', '17275', '10', '20'),
(5847, 12, '2024-09-07T12:01:21.176183900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12119.jpg', '1', '480 × 360', '10389', '10', '20'),
(5848, 12, '2024-09-07T12:01:51.349435800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12150.jpg', '1', '480 × 360', '11188', '10', '20'),
(5849, 12, '2024-09-07T12:02:21.002257500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12219.jpg', '1', '480 × 360', '12728', '10', '20'),
(5850, 12, '2024-09-07T12:02:50.970727600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12249.jpg', '1', '480 × 360', '12832', '10', '20'),
(5851, 12, '2024-09-07T12:03:21.272421100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12319.jpg', '1', '480 × 360', '14849', '10', '20'),
(5852, 12, '2024-09-07T12:03:50.958669', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12349.jpg', '1', '480 × 360', '12409', '10', '20'),
(5853, 12, '2024-09-07T12:04:21.577743400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12419.jpg', '1', '480 × 360', '17995', '10', '20'),
(5854, 12, '2024-09-07T12:04:51.302533400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12449.jpg', '1', '480 × 360', '18052', '10', '20'),
(5855, 12, '2024-09-07T12:05:21.469290800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12519.jpg', '1', '480 × 360', '18021', '10', '20'),
(5856, 12, '2024-09-07T12:05:52.472591100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12549.jpg', '1', '480 × 360', '18105', '10', '20'),
(5857, 12, '2024-09-07T12:06:21.094898400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12619.jpg', '1', '480 × 360', '18091', '10', '20'),
(5858, 12, '2024-09-07T12:06:51.212330300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12649.jpg', '1', '480 × 360', '18077', '10', '20'),
(5859, 12, '2024-09-07T12:07:21.620537900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12719.jpg', '1', '480 × 360', '18087', '10', '20'),
(5860, 12, '2024-09-07T12:07:51.518309200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12749.jpg', '1', '480 × 360', '18107', '10', '20'),
(5861, 12, '2024-09-07T12:08:21.147232', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12819.jpg', '1', '480 × 360', '17917', '10', '20'),
(5862, 12, '2024-09-07T12:08:51.155634300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12849.jpg', '1', '480 × 360', '18061', '10', '20'),
(5863, 12, '2024-09-07T12:09:21.733347700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12919.jpg', '1', '480 × 360', '17880', '10', '20'),
(5864, 12, '2024-09-07T12:09:51.566423900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/12949.jpg', '1', '480 × 360', '18062', '10', '20'),
(5865, 12, '2024-09-07T12:10:21.490624800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121019.jpg', '1', '480 × 360', '18080', '10', '20'),
(5866, 12, '2024-09-07T12:10:53.032851800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121049.jpg', '1', '480 × 360', '17956', '10', '20'),
(5867, 12, '2024-09-07T12:11:21.645860700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121119.jpg', '1', '480 × 360', '17857', '10', '20'),
(5868, 12, '2024-09-07T12:11:52.646689', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121149.jpg', '1', '480 × 360', '17907', '10', '20'),
(5869, 12, '2024-09-07T12:12:21.726659400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121219.jpg', '1', '480 × 360', '17933', '10', '20'),
(5870, 12, '2024-09-07T12:12:51.166167300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121249.jpg', '1', '480 × 360', '17937', '10', '20'),
(5871, 12, '2024-09-07T12:13:22.649238100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121319.jpg', '1', '480 × 360', '17943', '10', '20'),
(5872, 12, '2024-09-07T12:13:51.345073', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121349.jpg', '1', '480 × 360', '17927', '10', '20'),
(5873, 12, '2024-09-07T12:14:21.514517100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121419.jpg', '1', '480 × 360', '17900', '10', '20'),
(5874, 12, '2024-09-07T12:14:51.620931200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121449.jpg', '1', '480 × 360', '17921', '10', '20'),
(5875, 12, '2024-09-07T12:15:21.403418200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121519.jpg', '1', '480 × 360', '17912', '10', '20'),
(5876, 12, '2024-09-07T12:15:51.281044300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121549.jpg', '1', '480 × 360', '18493', '10', '20'),
(5877, 12, '2024-09-07T12:16:21.139736800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121619.jpg', '1', '480 × 360', '17832', '10', '20'),
(5878, 12, '2024-09-07T12:16:51.381822100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121649.jpg', '1', '480 × 360', '17738', '10', '20'),
(5879, 12, '2024-09-07T12:17:21.355533600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121719.jpg', '1', '480 × 360', '17646', '10', '20'),
(5880, 12, '2024-09-07T12:17:51.251754300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121749.jpg', '1', '480 × 360', '17830', '10', '20'),
(5881, 12, '2024-09-07T12:18:23.844673800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121822.jpg', '1', '480 × 360', '17775', '10', '20'),
(5882, 12, '2024-09-07T12:18:51.424236700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121849.jpg', '1', '480 × 360', '17696', '10', '20'),
(5883, 12, '2024-09-07T12:19:21.091713600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121919.jpg', '1', '480 × 360', '17701', '10', '20'),
(5884, 12, '2024-09-07T12:19:51.000144900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/121949.jpg', '1', '480 × 360', '17738', '10', '20'),
(5885, 12, '2024-09-07T12:20:21.364526500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122019.jpg', '1', '480 × 360', '17675', '10', '20'),
(5886, 12, '2024-09-07T12:20:51.301337300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122049.jpg', '1', '480 × 360', '17703', '10', '20'),
(5887, 12, '2024-09-07T12:21:21.491419300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122119.jpg', '1', '480 × 360', '17652', '10', '20'),
(5888, 12, '2024-09-07T12:21:51.762932500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122149.jpg', '1', '480 × 360', '17710', '10', '20'),
(5889, 12, '2024-09-07T12:22:21.548306600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122219.jpg', '1', '480 × 360', '17689', '10', '20'),
(5890, 12, '2024-09-07T12:22:51.444996600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122249.jpg', '1', '480 × 360', '17638', '10', '20'),
(5891, 12, '2024-09-07T12:23:21.185640300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122319.jpg', '1', '480 × 360', '17662', '10', '20'),
(5892, 12, '2024-09-07T12:23:51.195677700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122349.jpg', '1', '480 × 360', '17649', '10', '20'),
(5893, 12, '2024-09-07T12:24:21.197295500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122419.jpg', '1', '480 × 360', '17671', '10', '20'),
(5894, 12, '2024-09-07T12:24:51.274230500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122449.jpg', '1', '480 × 360', '17536', '10', '20'),
(5895, 12, '2024-09-07T12:25:21.525462100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122519.jpg', '1', '480 × 360', '17583', '10', '20'),
(5896, 12, '2024-09-07T12:25:51.795448700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122549.jpg', '1', '480 × 360', '17521', '10', '20'),
(5897, 12, '2024-09-07T12:26:22.937599', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122619.jpg', '1', '480 × 360', '17588', '10', '20'),
(5898, 12, '2024-09-07T12:26:51.399753', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122649.jpg', '1', '480 × 360', '17569', '10', '20'),
(5899, 12, '2024-09-07T12:27:21.481172400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122719.jpg', '1', '480 × 360', '17536', '10', '20'),
(5900, 12, '2024-09-07T12:27:51.208612700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122749.jpg', '1', '480 × 360', '17533', '10', '20'),
(5901, 12, '2024-09-07T12:28:21.170251200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122819.jpg', '1', '480 × 360', '17595', '10', '20'),
(5902, 12, '2024-09-07T12:28:51.153350400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122849.jpg', '1', '480 × 360', '17546', '10', '20'),
(5903, 12, '2024-09-07T12:29:21.249000700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122919.jpg', '1', '480 × 360', '17538', '10', '20'),
(5904, 12, '2024-09-07T12:29:50.785086400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/122949.jpg', '1', '480 × 360', '10931', '10', '20'),
(5905, 12, '2024-09-07T12:30:20.974109', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123019.jpg', '1', '480 × 360', '11392', '10', '20'),
(5906, 12, '2024-09-07T12:30:51.659226600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123049.jpg', '1', '480 × 360', '17479', '10', '20'),
(5907, 12, '2024-09-07T12:31:21.096293700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123119.jpg', '1', '480 × 360', '17561', '10', '20'),
(5908, 12, '2024-09-07T12:31:51.338134200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123149.jpg', '1', '480 × 360', '17491', '10', '20'),
(5909, 12, '2024-09-07T12:32:21.386347200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123219.jpg', '1', '480 × 360', '17559', '10', '20'),
(5910, 12, '2024-09-07T12:32:51.431106200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123249.jpg', '1', '480 × 360', '17526', '10', '20'),
(5911, 12, '2024-09-07T12:33:21.781956900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123319.jpg', '1', '480 × 360', '17586', '10', '20'),
(5912, 12, '2024-09-07T12:33:52.304456400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123349.jpg', '1', '480 × 360', '17549', '10', '20'),
(5913, 12, '2024-09-07T12:34:20.938302200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123419.jpg', '1', '480 × 360', '17520', '10', '20'),
(5914, 12, '2024-09-07T12:34:51.284904', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123449.jpg', '1', '480 × 360', '17538', '10', '20'),
(5915, 12, '2024-09-07T12:35:20.968084500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123519.jpg', '1', '480 × 360', '17569', '10', '20'),
(5916, 12, '2024-09-07T12:35:50.899062', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123549.jpg', '1', '480 × 360', '17619', '10', '20'),
(5917, 12, '2024-09-07T12:36:21.090624100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123619.jpg', '1', '480 × 360', '17451', '10', '20'),
(5918, 12, '2024-09-07T12:36:51.263129100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123649.jpg', '1', '480 × 360', '17485', '10', '20'),
(5919, 12, '2024-09-07T12:37:21.113837700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123719.jpg', '1', '480 × 360', '17473', '10', '20'),
(5920, 12, '2024-09-07T12:37:51.104082700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123749.jpg', '1', '480 × 360', '17525', '10', '20'),
(5921, 12, '2024-09-07T12:38:20.999584300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123819.jpg', '1', '480 × 360', '17488', '10', '20'),
(5922, 12, '2024-09-07T12:38:51.043818', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123849.jpg', '1', '480 × 360', '17453', '10', '20'),
(5923, 12, '2024-09-07T12:39:20.915722800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123919.jpg', '1', '480 × 360', '17450', '10', '20'),
(5924, 12, '2024-09-07T12:39:51.061825600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/123949.jpg', '1', '480 × 360', '17504', '10', '20'),
(5925, 12, '2024-09-07T12:40:21.195298800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124019.jpg', '1', '480 × 360', '17437', '10', '20'),
(5926, 12, '2024-09-07T12:40:50.996023600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124049.jpg', '1', '480 × 360', '17424', '10', '20'),
(5927, 12, '2024-09-07T12:41:21.025290200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124119.jpg', '1', '480 × 360', '17456', '10', '20'),
(5928, 12, '2024-09-07T12:41:51.275513200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124149.jpg', '1', '480 × 360', '17383', '10', '20'),
(5929, 12, '2024-09-07T12:42:21.489393600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124220.jpg', '1', '480 × 360', '10259', '10', '20'),
(5930, 12, '2024-09-07T12:42:51.075264', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124249.jpg', '1', '480 × 360', '10682', '10', '20'),
(5931, 12, '2024-09-07T12:43:21.060055200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124320.jpg', '1', '480 × 360', '10590', '10', '20'),
(5932, 12, '2024-09-07T12:43:50.737224600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124349.jpg', '1', '480 × 360', '10641', '10', '20'),
(5933, 12, '2024-09-07T12:44:21.238126', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124419.jpg', '1', '480 × 360', '17416', '10', '20'),
(5934, 12, '2024-09-07T12:44:51.315454700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124449.jpg', '1', '480 × 360', '17618', '10', '20'),
(5935, 12, '2024-09-07T12:45:22.036919200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124520.jpg', '1', '480 × 360', '17585', '10', '20'),
(5936, 12, '2024-09-07T12:45:51.766987700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124549.jpg', '1', '480 × 360', '17574', '10', '20'),
(5937, 12, '2024-09-07T12:46:21.764934100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124619.jpg', '1', '480 × 360', '17551', '10', '20'),
(5938, 12, '2024-09-07T12:46:51.042447', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124649.jpg', '1', '480 × 360', '17509', '10', '20'),
(5939, 12, '2024-09-07T12:47:22.080369800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124719.jpg', '1', '480 × 360', '17515', '10', '20'),
(5940, 12, '2024-09-07T12:47:51.129925800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124749.jpg', '1', '480 × 360', '17601', '10', '20'),
(5941, 12, '2024-09-07T12:48:21.037545100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124819.jpg', '1', '480 × 360', '17570', '10', '20'),
(5942, 12, '2024-09-07T12:48:51.071438600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124849.jpg', '1', '480 × 360', '17561', '10', '20'),
(5943, 12, '2024-09-07T12:49:21.191584600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124919.jpg', '1', '480 × 360', '17584', '10', '20'),
(5944, 12, '2024-09-07T12:49:51.440268100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/124949.jpg', '1', '480 × 360', '17647', '10', '20'),
(5945, 12, '2024-09-07T12:50:21.210786500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125019.jpg', '1', '480 × 360', '17527', '10', '20'),
(5946, 12, '2024-09-07T12:50:53.102291', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125049.jpg', '1', '480 × 360', '17563', '10', '20'),
(5947, 12, '2024-09-07T12:51:21.259351800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125119.jpg', '1', '480 × 360', '17440', '10', '20'),
(5948, 12, '2024-09-07T12:51:53.777357200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125152.jpg', '1', '480 × 360', '17465', '10', '20'),
(5949, 12, '2024-09-07T12:52:21.387659300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125219.jpg', '1', '480 × 360', '17590', '10', '20'),
(5950, 12, '2024-09-07T12:52:51.412052100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125249.jpg', '1', '480 × 360', '17605', '10', '20'),
(5951, 12, '2024-09-07T12:53:21.435868500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125319.jpg', '1', '480 × 360', '17643', '10', '20'),
(5952, 12, '2024-09-07T12:53:51.313322600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125349.jpg', '1', '480 × 360', '17659', '10', '20'),
(5953, 12, '2024-09-07T12:54:21.084065800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125419.jpg', '1', '480 × 360', '17660', '10', '20'),
(5954, 12, '2024-09-07T12:54:51.375630', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125449.jpg', '1', '480 × 360', '17681', '10', '20'),
(5955, 12, '2024-09-07T12:55:21.279199200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125519.jpg', '1', '480 × 360', '17669', '10', '20'),
(5956, 12, '2024-09-07T12:55:50.969817200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125549.jpg', '1', '480 × 360', '17639', '10', '20'),
(5957, 12, '2024-09-07T12:56:21.300626100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125619.jpg', '1', '480 × 360', '17586', '10', '20'),
(5958, 12, '2024-09-07T12:56:51.524813300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125649.jpg', '1', '480 × 360', '17649', '10', '20'),
(5959, 12, '2024-09-07T12:57:21.403319', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125719.jpg', '1', '480 × 360', '17607', '10', '20'),
(5960, 12, '2024-09-07T12:57:51.703115400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125749.jpg', '1', '480 × 360', '17689', '10', '20'),
(5961, 12, '2024-09-07T12:58:21.223705700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125819.jpg', '1', '480 × 360', '17784', '10', '20'),
(5962, 12, '2024-09-07T12:58:51.102447500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125849.jpg', '1', '480 × 360', '17679', '10', '20'),
(5963, 12, '2024-09-07T12:59:21.499261300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125919.jpg', '1', '480 × 360', '17709', '10', '20'),
(5964, 12, '2024-09-07T12:59:51.163207400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/125949.jpg', '1', '480 × 360', '17739', '10', '20'),
(5965, 12, '2024-09-07T13:00:21.334189100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13019.jpg', '1', '480 × 360', '17737', '10', '20'),
(5966, 12, '2024-09-07T13:00:51.158255500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13049.jpg', '1', '480 × 360', '17737', '10', '20'),
(5967, 12, '2024-09-07T13:01:21.072386400', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13119.jpg', '1', '480 × 360', '17728', '10', '20'),
(5968, 12, '2024-09-07T13:01:51.180001700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13149.jpg', '1', '480 × 360', '17777', '10', '20'),
(5969, 12, '2024-09-07T13:02:21.217623500', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13219.jpg', '1', '480 × 360', '17735', '10', '20'),
(5970, 12, '2024-09-07T13:02:51.401850800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13249.jpg', '1', '480 × 360', '17782', '10', '20'),
(5971, 12, '2024-09-07T13:03:20.811906800', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13319.jpg', '1', '480 × 360', '8387', '10', '20'),
(5972, 12, '2024-09-07T13:03:50.969748300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13349.jpg', '1', '480 × 360', '8373', '10', '20'),
(5973, 12, '2024-09-07T13:04:21.260487300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13419.jpg', '1', '480 × 360', '17893', '10', '20'),
(5974, 12, '2024-09-07T13:04:52.641879600', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13449.jpg', '1', '480 × 360', '17934', '10', '20'),
(5975, 12, '2024-09-07T13:05:21.235182900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13519.jpg', '1', '480 × 360', '17925', '10', '20'),
(5976, 12, '2024-09-07T13:05:52.306973200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13550.jpg', '1', '480 × 360', '18054', '10', '20'),
(5977, 12, '2024-09-07T13:06:21.143653300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13619.jpg', '1', '480 × 360', '18042', '10', '20'),
(5978, 12, '2024-09-07T13:06:51.181879700', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13649.jpg', '1', '480 × 360', '18087', '10', '20'),
(5979, 12, '2024-09-07T13:07:20.765311200', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13719.jpg', '1', '480 × 360', '8226', '10', '20'),
(5980, 12, '2024-09-07T13:07:50.763319100', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13749.jpg', '1', '480 × 360', '8212', '10', '20'),
(5981, 12, '2024-09-07T13:08:20.747157300', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13819.jpg', '1', '480 × 360', '8224', '10', '20'),
(5982, 12, '2024-09-07T13:08:50.942607900', 'Present/Snapshots/Snapshots2024SEPTEMBER7/480/10204/13849.jpg', '1', '480 × 360', '8204', '10', '20'),
(5983, 15, '2024-09-11T20:01:19.875263800', 'Present/Snapshots/Snapshots2024SEPTEMBER11/480/1/20110.jpg', '1', '480 × 360', '23922', '45.421347149780544', '-75.71034537140704'),
(5984, 15, '2024-09-11T20:01:36.972037600', 'Present/Snapshots/Snapshots2024SEPTEMBER11/480/1/20133.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(5985, 15, '2024-09-11T20:02:15.495683100', 'Present/Snapshots/Snapshots2024SEPTEMBER11/480/1/2024.jpg', '1', '480 × 360', '24137', '45.421347149780544', '-75.71034537140704'),
(5986, 15, '2024-09-11T20:02:42.213537700', 'Present/Snapshots/Snapshots2024SEPTEMBER11/480/1/20233.jpg', '1', '480 × 360', '23847', '45.421347149780544', '-75.71034537140704'),
(5987, 15, '2024-09-11T20:07:20.996863800', 'Present/Snapshots/Snapshots2024SEPTEMBER11/480/1/20712.jpg', '1', '480 × 360', '23377', '45.421347149780544', '-75.71034537140704'),
(5988, 15, '2024-09-11T20:09:25.558501700', 'Present/Snapshots/Snapshots2024SEPTEMBER11/480/1/20913.jpg', '1', '480 × 360', '24892', '45.421347149780544', '-75.71034537140704'),
(5989, 15, '2024-09-11T21:10:28.871144500', 'Present/Snapshots/Snapshots2024SEPTEMBER11/480/1/211027.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(5990, 15, '2024-09-11T21:12:54.036736', 'Present/Snapshots/Snapshots2024SEPTEMBER11/480/1/211214.jpg', '1', '480 × 360', '24627', '45.421347149780544', '-75.71034537140704'),
(5991, 15, '2024-09-12T12:18:28.353540400', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/121819.jpg', '1', '480 × 360', '8292', '45.421347149780544', '-75.71034537140704'),
(5992, 15, '2024-09-12T12:18:57.059690900', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/121848.jpg', '1', '480 × 360', '8946', '45.421347149780544', '-75.71034537140704'),
(5993, 15, '2024-09-12T12:20:15.368388900', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12208.jpg', '1', '480 × 360', '8282', '45.421347149780544', '-75.71034537140704'),
(5994, 15, '2024-09-12T12:21:13.908063', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12217.jpg', '1', '480 × 360', '8373', '45.421347149780544', '-75.71034537140704'),
(5995, 15, '2024-09-12T12:21:45.011462900', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/122138.jpg', '1', '480 × 360', '8440', '45.421347149780544', '-75.71034537140704'),
(5996, 15, '2024-09-12T12:22:13.853746700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12226.jpg', '1', '480 × 360', '8421', '45.421347149780544', '-75.71034537140704'),
(5997, 15, '2024-09-12T12:22:43.427222800', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/122236.jpg', '1', '480 × 360', '8489', '45.421347149780544', '-75.71034537140704'),
(5998, 15, '2024-09-12T12:23:13.641431100', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12236.jpg', '1', '480 × 360', '8472', '45.421347149780544', '-75.71034537140704'),
(5999, 15, '2024-09-12T12:23:44.171369900', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/122336.jpg', '1', '480 × 360', '8526', '45.421347149780544', '-75.71034537140704'),
(6000, 15, '2024-09-12T12:25:21.059348300', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/122513.jpg', '1', '480 × 360', '8586', '45.421347149780544', '-75.71034537140704'),
(6001, 15, '2024-09-12T12:26:29.701994', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/122627.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6002, 15, '2024-09-12T12:27:55.804673100', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/122653.jpg', '1', '480 × 360', '7840', '45.421347149780544', '-75.71034537140704'),
(6003, 15, '2024-09-12T12:28:25.759493200', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/122722.jpg', '1', '480 × 360', '9802', '45.421347149780544', '-75.71034537140704'),
(6004, 15, '2024-09-12T12:29:43.965063400', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/122936.jpg', '1', '480 × 360', '8509', '45.421347149780544', '-75.71034537140704'),
(6005, 15, '2024-09-12T12:30:13.453154300', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12306.jpg', '1', '480 × 360', '8498', '45.421347149780544', '-75.71034537140704'),
(6006, 15, '2024-09-12T12:30:43.329470500', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/123036.jpg', '1', '480 × 360', '8582', '45.421347149780544', '-75.71034537140704'),
(6007, 15, '2024-09-12T12:31:12.959411500', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12316.jpg', '1', '480 × 360', '8367', '45.421347149780544', '-75.71034537140704'),
(6008, 15, '2024-09-12T12:31:55.292804100', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/123136.jpg', '1', '480 × 360', '8618', '45.421347149780544', '-75.71034537140704'),
(6009, 15, '2024-09-12T12:32:12.795935200', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12326.jpg', '1', '480 × 360', '8591', '45.421347149780544', '-75.71034537140704'),
(6010, 15, '2024-09-12T12:32:43.601379200', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/123236.jpg', '1', '480 × 360', '8572', '45.421347149780544', '-75.71034537140704'),
(6011, 15, '2024-09-12T12:33:13.185423700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12336.jpg', '1', '480 × 360', '8661', '45.421347149780544', '-75.71034537140704'),
(6012, 15, '2024-09-12T12:33:43.055905300', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/123336.jpg', '1', '480 × 360', '8698', '45.421347149780544', '-75.71034537140704'),
(6013, 15, '2024-09-12T12:34:13.675731700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12346.jpg', '1', '480 × 360', '8661', '45.421347149780544', '-75.71034537140704'),
(6014, 15, '2024-09-12T12:34:43.407937400', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/123436.jpg', '1', '480 × 360', '8732', '45.421347149780544', '-75.71034537140704'),
(6015, 15, '2024-09-12T12:35:14.091369300', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12356.jpg', '1', '480 × 360', '8647', '45.421347149780544', '-75.71034537140704'),
(6016, 15, '2024-09-12T12:35:45.302291900', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/123536.jpg', '1', '480 × 360', '8660', '45.421347149780544', '-75.71034537140704'),
(6017, 15, '2024-09-12T12:36:13.685465900', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12366.jpg', '1', '480 × 360', '8635', '45.421347149780544', '-75.71034537140704'),
(6018, 15, '2024-09-12T12:37:11.713362', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/1274.jpg', '1', '480 × 360', '8659', '45.421347149780544', '-75.71034537140704'),
(6019, 15, '2024-09-12T12:37:41.529021700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12733.jpg', '1', '480 × 360', '9231', '45.421347149780544', '-75.71034537140704'),
(6020, 15, '2024-09-12T12:38:41.276821', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12833.jpg', '1', '480 × 360', '8676', '45.421347149780544', '-75.71034537140704'),
(6021, 15, '2024-09-12T12:39:10.548788700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/1293.jpg', '1', '480 × 360', '8631', '45.421347149780544', '-75.71034537140704'),
(6022, 15, '2024-09-12T12:39:41.545880200', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12934.jpg', '1', '480 × 360', '8875', '45.421347149780544', '-75.71034537140704'),
(6023, 15, '2024-09-12T12:40:12.131791700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12104.jpg', '1', '480 × 360', '10509', '45.421347149780544', '-75.71034537140704'),
(6024, 15, '2024-09-12T12:40:42.173387100', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/121034.jpg', '1', '480 × 360', '8795', '45.421347149780544', '-75.71034537140704'),
(6025, 15, '2024-09-12T12:41:10.087673500', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12113.jpg', '1', '480 × 360', '9032', '45.421347149780544', '-75.71034537140704'),
(6026, 15, '2024-09-12T12:41:40.100129100', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/121132.jpg', '1', '480 × 360', '9373', '45.421347149780544', '-75.71034537140704'),
(6027, 15, '2024-09-12T12:42:12.979234500', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/12125.jpg', '1', '480 × 360', '8903', '45.421347149780544', '-75.71034537140704'),
(6028, 15, '2024-09-12T12:42:41.226290', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/121233.jpg', '1', '480 × 360', '8843', '45.421347149780544', '-75.71034537140704'),
(6029, 15, '2024-09-12T13:30:09.363350700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/1300.jpg', '1', '480 × 360', '13717', '45.421347149780544', '-75.71034537140704'),
(6030, 15, '2024-09-12T13:31:21.278364800', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/13110.jpg', '1', '480 × 360', '14071', '45.421347149780544', '-75.71034537140704'),
(6031, 15, '2024-09-12T19:22:42.063107600', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185230.jpg', '1', '480 × 360', '23385', '45.421347149780544', '-75.71034537140704'),
(6032, 15, '2024-09-12T19:23:13.861265300', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/18534.jpg', '1', '480 × 360', '23290', '45.421347149780544', '-75.71034537140704'),
(6033, 15, '2024-09-12T19:24:06.514870300', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185356.jpg', '1', '480 × 360', '23352', '45.421347149780544', '-75.71034537140704'),
(6034, 15, '2024-09-12T19:24:36.230928400', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185427.jpg', '1', '480 × 360', '23346', '45.421347149780544', '-75.71034537140704'),
(6035, 15, '2024-09-12T19:25:08.116050600', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185457.jpg', '1', '480 × 360', '23413', '45.421347149780544', '-75.71034537140704'),
(6036, 15, '2024-09-12T19:26:01.089034700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185552.jpg', '1', '480 × 360', '23296', '45.421347149780544', '-75.71034537140704'),
(6037, 15, '2024-09-12T19:26:58.996046900', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185622.jpg', '1', '480 × 360', '21232', '45.421347149780544', '-75.71034537140704'),
(6038, 15, '2024-09-12T19:28:58.312674', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185856.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6039, 15, '2024-09-12T19:29:28.189312700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185926.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6040, 15, '2024-09-12T19:29:59.310874500', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/185956.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6041, 15, '2024-09-12T19:30:29.596567700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/19026.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6042, 15, '2024-09-12T19:30:59.601542700', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/19057.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6043, 15, '2024-09-12T19:31:29.421148900', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/19126.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6044, 15, '2024-09-12T19:31:57.872547300', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/19156.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6045, 15, '2024-09-12T19:32:27.977578300', 'Present/Snapshots/Snapshots2024SEPTEMBER12/480/1/19226.jpg', '1', '480 × 360', '0', '45.421347149780544', '-75.71034537140704'),
(6046, 15, '2024-09-25T20:18:49.018897', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/194841.jpg', '1', '480 × 360', '18744', '45.421347149780544', '-75.71034537140704'),
(6047, 15, '2024-09-25T20:19:20.438004500', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/194910.jpg', '1', '480 × 360', '18836', '45.421347149780544', '-75.71034537140704'),
(6048, 15, '2024-09-25T20:19:48.489092600', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/194941.jpg', '1', '480 × 360', '18968', '45.421347149780544', '-75.71034537140704'),
(6049, 15, '2024-09-25T20:20:18.288443300', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/195010.jpg', '1', '480 × 360', '19093', '45.421347149780544', '-75.71034537140704'),
(6050, 15, '2024-09-25T20:20:47.423659200', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/195040.jpg', '1', '480 × 360', '18911', '45.421347149780544', '-75.71034537140704'),
(6051, 15, '2024-09-25T20:21:17.239441600', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/195110.jpg', '1', '480 × 360', '19849', '45.421347149780544', '-75.71034537140704'),
(6052, 15, '2024-09-25T20:21:47.545225800', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/195140.jpg', '1', '480 × 360', '18690', '45.421347149780544', '-75.71034537140704'),
(6053, 15, '2024-09-25T20:22:18.492401100', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/195211.jpg', '1', '480 × 360', '18579', '45.421347149780544', '-75.71034537140704'),
(6054, 15, '2024-09-25T20:22:47.118899200', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/195240.jpg', '1', '480 × 360', '18407', '45.421347149780544', '-75.71034537140704'),
(6055, 15, '2024-09-25T20:23:16.745217700', 'Present/Snapshots/Snapshots2024SEPTEMBER25/480/1/195310.jpg', '1', '480 × 360', '18302', '45.421347149780544', '-75.71034537140704');

-- --------------------------------------------------------

--
-- Table structure for table `notifications_tbls`
--

DROP TABLE IF EXISTS `notifications_tbls`;
CREATE TABLE IF NOT EXISTS `notifications_tbls` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `from_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `seen` tinyint(1) NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `settings_tbls`
--

DROP TABLE IF EXISTS `settings_tbls`;
CREATE TABLE IF NOT EXISTS `settings_tbls` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `Version` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ESP32CAM_Code` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings_tbls`
--

INSERT INTO `settings_tbls` (`id`, `Version`, `ESP32CAM_Code`) VALUES
(11, '1', '---');

-- --------------------------------------------------------

--
-- Table structure for table `temperatures_arch_tbl`
--

DROP TABLE IF EXISTS `temperatures_arch_tbl`;
CREATE TABLE IF NOT EXISTS `temperatures_arch_tbl` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hub_id` int NOT NULL,
  `date_time` varchar(50) NOT NULL,
  `temperature` varchar(50) NOT NULL,
  `attribute` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14787 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `temperatures_tbl`
--

DROP TABLE IF EXISTS `temperatures_tbl`;
CREATE TABLE IF NOT EXISTS `temperatures_tbl` (
  `id` int NOT NULL AUTO_INCREMENT,
  `hub_id` int DEFAULT NULL,
  `date_time` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `temperature` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `attribute` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `hub_id` (`hub_id`)
) ENGINE=MyISAM AUTO_INCREMENT=231713 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `temperatures_tbl`
--

INSERT INTO `temperatures_tbl` (`id`, `hub_id`, `date_time`, `temperature`, `attribute`) VALUES
(231448, 12, '2024-09-07T11:45:19.919291300', '29.56', '-'),
(231449, 12, '2024-09-07T11:45:49.925681600', '29.56', '-'),
(231450, 12, '2024-09-07T11:46:19.966731100', '29.56', '-'),
(231451, 12, '2024-09-07T11:46:49.862046400', '29.56', '-'),
(231452, 12, '2024-09-07T11:47:19.882803100', '29.63', '-'),
(231453, 12, '2024-09-07T11:47:49.896505600', '29.56', '-'),
(231454, 12, '2024-09-07T11:48:19.931573900', '29.63', '-'),
(231455, 12, '2024-09-07T11:48:49.849458', '29.56', '-'),
(231456, 12, '2024-09-07T11:49:19.806029', '29.63', '-'),
(231457, 12, '2024-09-07T11:49:49.804605700', '29.63', '-'),
(231458, 12, '2024-09-07T11:50:19.871785600', '29.63', '-'),
(231459, 12, '2024-09-07T11:50:49.827147900', '29.63', '-'),
(231460, 12, '2024-09-07T11:51:19.813794700', '29.63', '-'),
(231461, 12, '2024-09-07T11:51:50.013841900', '29.63', '-'),
(231462, 12, '2024-09-07T11:52:19.853652200', '29.63', '-'),
(231463, 12, '2024-09-07T11:52:49.902524200', '29.69', '-'),
(231464, 12, '2024-09-07T11:53:19.834125900', '29.69', '-'),
(231465, 12, '2024-09-07T11:53:49.820341300', '29.69', '-'),
(231466, 12, '2024-09-07T11:54:19.816549200', '29.69', '-'),
(231467, 12, '2024-09-07T11:54:49.869342900', '29.69', '-'),
(231468, 12, '2024-09-07T11:55:19.876915700', '29.69', '-'),
(231469, 12, '2024-09-07T11:55:49.833709500', '29.69', '-'),
(231470, 12, '2024-09-07T11:56:19.831494100', '29.69', '-'),
(231471, 12, '2024-09-07T11:56:49.832841900', '29.75', '-'),
(231472, 12, '2024-09-07T11:57:19.906856800', '29.75', '-'),
(231473, 12, '2024-09-07T11:57:49.933744300', '29.75', '-'),
(231474, 12, '2024-09-07T11:58:19.896278300', '29.75', '-'),
(231475, 12, '2024-09-07T11:58:49.885986900', '29.75', '-'),
(231476, 12, '2024-09-07T11:59:19.845293100', '29.81', '-'),
(231477, 12, '2024-09-07T11:59:49.892272800', '29.81', '-'),
(231478, 12, '2024-09-07T12:00:19.889993400', '29.81', '-'),
(231479, 12, '2024-09-07T12:00:49.861848200', '29.81', '-'),
(231480, 12, '2024-09-07T12:01:19.859511700', '29.81', '-'),
(231481, 12, '2024-09-07T12:01:50.029825900', '29.81', '-'),
(231482, 12, '2024-09-07T12:02:19.969826100', '29.87', '-'),
(231483, 12, '2024-09-07T12:02:49.869219500', '29.87', '-'),
(231484, 12, '2024-09-07T12:03:19.960756500', '29.87', '-'),
(231485, 12, '2024-09-07T12:03:49.876589100', '29.87', '-'),
(231486, 12, '2024-09-07T12:04:19.919374800', '29.87', '-'),
(231487, 12, '2024-09-07T12:04:49.895514100', '29.94', '-'),
(231488, 12, '2024-09-07T12:05:19.973007700', '29.94', '-'),
(231489, 12, '2024-09-07T12:05:49.808430300', '29.94', '-'),
(231490, 12, '2024-09-07T12:06:19.843480200', '29.94', '-'),
(231491, 12, '2024-09-07T12:06:49.872297100', '29.94', '-'),
(231492, 12, '2024-09-07T12:07:19.814395700', '29.94', '-'),
(231493, 12, '2024-09-07T12:07:49.816081', '29.94', '-'),
(231494, 12, '2024-09-07T12:08:19.812407100', '30.00', '-'),
(231495, 12, '2024-09-07T12:08:49.847394800', '30.00', '-'),
(231496, 12, '2024-09-07T12:09:19.922218400', '30.00', '-'),
(231497, 12, '2024-09-07T12:09:49.840019400', '30.00', '-'),
(231498, 12, '2024-09-07T12:10:19.975020800', '30.00', '-'),
(231499, 12, '2024-09-07T12:10:49.830839400', '30.06', '-'),
(231500, 12, '2024-09-07T12:11:19.810826600', '30.06', '-'),
(231501, 12, '2024-09-07T12:11:49.894380200', '30.06', '-'),
(231502, 12, '2024-09-07T12:12:19.882108500', '30.06', '-'),
(231503, 12, '2024-09-07T12:12:49.785059700', '30.06', '-'),
(231504, 12, '2024-09-07T12:13:19.827769500', '30.06', '-'),
(231505, 12, '2024-09-07T12:13:49.863631200', '30.06', '-'),
(231506, 12, '2024-09-07T12:14:19.936468100', '30.06', '-'),
(231507, 12, '2024-09-07T12:14:49.918219600', '30.06', '-'),
(231508, 12, '2024-09-07T12:15:19.848260400', '30.06', '-'),
(231509, 12, '2024-09-07T12:15:49.829563300', '30.06', '-'),
(231510, 12, '2024-09-07T12:16:19.848780800', '30.12', '-'),
(231511, 12, '2024-09-07T12:16:49.926586800', '30.12', '-'),
(231512, 12, '2024-09-07T12:17:19.872302900', '30.12', '-'),
(231513, 12, '2024-09-07T12:17:49.963270600', '30.12', '-'),
(231514, 12, '2024-09-07T12:18:22.425198600', '30.12', '-'),
(231515, 12, '2024-09-07T12:18:49.942705900', '30.12', '-'),
(231516, 12, '2024-09-07T12:19:19.894974400', '30.06', '-'),
(231517, 12, '2024-09-07T12:19:49.875981600', '30.12', '-'),
(231518, 12, '2024-09-07T12:20:19.862556300', '30.06', '-'),
(231519, 12, '2024-09-07T12:20:49.935430500', '30.12', '-'),
(231520, 12, '2024-09-07T12:21:19.954963500', '30.12', '-'),
(231521, 12, '2024-09-07T12:21:49.832546100', '30.12', '-'),
(231522, 12, '2024-09-07T12:22:19.830750', '30.12', '-'),
(231523, 12, '2024-09-07T12:22:49.817196', '30.12', '-'),
(231524, 12, '2024-09-07T12:23:19.811753300', '30.12', '-'),
(231525, 12, '2024-09-07T12:23:49.841127200', '30.06', '-'),
(231526, 12, '2024-09-07T12:24:19.809599700', '30.06', '-'),
(231527, 12, '2024-09-07T12:24:49.891505900', '30.06', '-'),
(231528, 12, '2024-09-07T12:25:19.827919400', '29.94', '-'),
(231529, 12, '2024-09-07T12:25:49.835748200', '30.06', '-'),
(231530, 12, '2024-09-07T12:26:19.873604800', '30.00', '-'),
(231531, 12, '2024-09-07T12:26:49.842812400', '30.00', '-'),
(231532, 12, '2024-09-07T12:27:19.877829300', '30.00', '-'),
(231533, 12, '2024-09-07T12:27:49.880443700', '30.00', '-'),
(231534, 12, '2024-09-07T12:28:19.818420500', '29.94', '-'),
(231535, 12, '2024-09-07T12:28:49.847152500', '30.00', '-'),
(231536, 12, '2024-09-07T12:29:19.890126500', '30.00', '-'),
(231537, 12, '2024-09-07T12:29:49.898342900', '29.87', '-'),
(231538, 12, '2024-09-07T12:30:19.896558600', '29.87', '-'),
(231539, 12, '2024-09-07T12:30:49.896429700', '29.87', '-'),
(231540, 12, '2024-09-07T12:31:19.910083900', '29.81', '-'),
(231541, 12, '2024-09-07T12:31:49.917866200', '29.81', '-'),
(231542, 12, '2024-09-07T12:32:19.834802', '29.81', '-'),
(231543, 12, '2024-09-07T12:32:49.867013100', '29.81', '-'),
(231544, 12, '2024-09-07T12:33:19.868179900', '29.81', '-'),
(231545, 12, '2024-09-07T12:33:49.880122200', '29.81', '-'),
(231546, 12, '2024-09-07T12:34:19.895735900', '29.75', '-'),
(231547, 12, '2024-09-07T12:34:49.927163900', '29.75', '-'),
(231548, 12, '2024-09-07T12:35:19.888989800', '29.75', '-'),
(231549, 12, '2024-09-07T12:35:49.874953', '29.75', '-'),
(231550, 12, '2024-09-07T12:36:19.928925300', '29.69', '-'),
(231551, 12, '2024-09-07T12:36:49.927455900', '29.69', '-'),
(231552, 12, '2024-09-07T12:37:19.861175700', '29.69', '-'),
(231553, 12, '2024-09-07T12:37:49.834013600', '29.69', '-'),
(231554, 12, '2024-09-07T12:38:19.819227800', '29.69', '-'),
(231555, 12, '2024-09-07T12:38:49.830773100', '29.69', '-'),
(231556, 12, '2024-09-07T12:39:19.816969800', '29.63', '-'),
(231557, 12, '2024-09-07T12:39:49.861143300', '29.63', '-'),
(231558, 12, '2024-09-07T12:40:19.873532400', '29.63', '-'),
(231559, 12, '2024-09-07T12:40:49.776449300', '29.63', '-'),
(231560, 12, '2024-09-07T12:41:19.805042300', '29.56', '-'),
(231561, 12, '2024-09-07T12:41:49.935173500', '29.63', '-'),
(231562, 12, '2024-09-07T12:42:20.062782', '29.56', '-'),
(231563, 12, '2024-09-07T12:42:49.982320900', '29.50', '-'),
(231564, 12, '2024-09-07T12:43:20.007097300', '29.50', '-'),
(231565, 12, '2024-09-07T12:43:49.804091', '29.50', '-'),
(231566, 12, '2024-09-07T12:44:19.827689600', '29.50', '-'),
(231567, 12, '2024-09-07T12:44:49.946094500', '29.50', '-'),
(231568, 12, '2024-09-07T12:45:20.556573800', '29.50', '-'),
(231569, 12, '2024-09-07T12:45:49.834034700', '29.44', '-'),
(231570, 12, '2024-09-07T12:46:19.831459600', '29.44', '-'),
(231571, 12, '2024-09-07T12:46:49.895213800', '29.50', '-'),
(231572, 12, '2024-09-07T12:47:19.920094700', '29.44', '-'),
(231573, 12, '2024-09-07T12:47:49.850264700', '29.44', '-'),
(231574, 12, '2024-09-07T12:48:19.888008600', '29.44', '-'),
(231575, 12, '2024-09-07T12:48:49.899182', '29.44', '-'),
(231576, 12, '2024-09-07T12:49:19.869524700', '29.50', '-'),
(231577, 12, '2024-09-07T12:49:49.916234500', '29.50', '-'),
(231578, 12, '2024-09-07T12:50:19.917371200', '29.44', '-'),
(231579, 12, '2024-09-07T12:50:49.875868300', '29.50', '-'),
(231580, 12, '2024-09-07T12:51:19.979877900', '29.44', '-'),
(231581, 12, '2024-09-07T12:51:52.178064800', '29.44', '-'),
(231582, 12, '2024-09-07T12:52:19.853868600', '29.44', '-'),
(231583, 12, '2024-09-07T12:52:49.919060400', '29.44', '-'),
(231584, 12, '2024-09-07T12:53:19.875465300', '29.44', '-'),
(231585, 12, '2024-09-07T12:53:49.887474400', '29.44', '-'),
(231586, 12, '2024-09-07T12:54:19.897969500', '29.44', '-'),
(231587, 12, '2024-09-07T12:54:49.827831300', '29.44', '-'),
(231588, 12, '2024-09-07T12:55:19.786399300', '29.44', '-'),
(231589, 12, '2024-09-07T12:55:49.797073', '29.44', '-'),
(231590, 12, '2024-09-07T12:56:19.834579100', '29.44', '-'),
(231591, 12, '2024-09-07T12:56:49.912653600', '29.50', '-'),
(231592, 12, '2024-09-07T12:57:19.841778', '29.44', '-'),
(231593, 12, '2024-09-07T12:57:49.785653600', '29.44', '-'),
(231594, 12, '2024-09-07T12:58:19.784517300', '29.44', '-'),
(231595, 12, '2024-09-07T12:58:49.822789500', '29.44', '-'),
(231596, 12, '2024-09-07T12:59:19.873377600', '29.44', '-'),
(231597, 12, '2024-09-07T12:59:49.856858200', '29.44', '-'),
(231598, 12, '2024-09-07T13:00:19.881194300', '29.44', '-'),
(231599, 12, '2024-09-07T13:00:49.824370800', '29.50', '-'),
(231600, 12, '2024-09-07T13:01:19.929777400', '29.44', '-'),
(231601, 12, '2024-09-07T13:01:49.832828400', '29.50', '-'),
(231602, 12, '2024-09-07T13:02:19.817446600', '29.50', '-'),
(231603, 12, '2024-09-07T13:02:49.842128100', '29.44', '-'),
(231604, 12, '2024-09-07T13:03:19.825787200', '29.37', '-'),
(231605, 12, '2024-09-07T13:03:49.863061100', '29.44', '-'),
(231606, 12, '2024-09-07T13:04:19.847705400', '29.44', '-'),
(231607, 12, '2024-09-07T13:04:49.844807600', '29.44', '-'),
(231608, 12, '2024-09-07T13:05:19.896560600', '29.44', '-'),
(231609, 12, '2024-09-07T13:05:50.533558400', '29.50', '-'),
(231610, 12, '2024-09-07T13:06:19.823862100', '29.44', '-'),
(231611, 12, '2024-09-07T13:06:49.928284900', '29.44', '-'),
(231612, 12, '2024-09-07T13:07:19.846217100', '29.50', '-'),
(231613, 12, '2024-09-07T13:07:49.910191600', '29.50', '-'),
(231614, 12, '2024-09-07T13:08:19.893947800', '29.56', '-'),
(231615, 12, '2024-09-07T13:08:49.875498700', '29.50', '-'),
(231616, 12, '2024-09-11T19:51:51.350719200', '-', '-'),
(231617, 12, '2024-09-11T19:52:20.619837500', '-', '-'),
(231618, 12, '2024-09-11T19:52:50.740015100', '-', '-'),
(231619, 12, '2024-09-11T19:53:21.139393400', '-', '-'),
(231620, 12, '2024-09-11T19:53:50.322080800', '-', '-'),
(231621, 15, '2024-09-11T20:01:10.717196500', '26.87', '-'),
(231622, 15, '2024-09-11T20:01:33.265620900', '-', '-'),
(231623, 15, '2024-09-11T20:02:04.956984700', '-', '-'),
(231624, 15, '2024-09-11T20:02:33.915251', '-', '-'),
(231625, 15, '2024-09-11T20:03:18.317337500', '26.81', '-'),
(231626, 15, '2024-09-11T20:03:53.459810', '26.87', '-'),
(231627, 15, '2024-09-11T20:04:15.148185200', '26.87', '-'),
(231628, 15, '2024-09-11T20:04:45.016810500', '26.87', '-'),
(231629, 15, '2024-09-11T20:07:12.494276700', '26.94', '-'),
(231630, 15, '2024-09-11T20:07:42.180124200', '26.94', '-'),
(231631, 15, '2024-09-11T20:09:13.516737500', '26.94', '-'),
(231632, 15, '2024-09-11T21:10:27.659941600', '-', '-'),
(231633, 15, '2024-09-11T21:10:57.251950200', '-', '-'),
(231634, 15, '2024-09-11T21:12:14.405266800', '26.62', '-'),
(231635, 15, '2024-09-11T21:13:07.502903200', '26.69', '-'),
(231636, 15, '2024-09-12T12:18:18.965520100', '25.44', '-'),
(231637, 15, '2024-09-12T12:18:48.089773', '25.44', '-'),
(231638, 15, '2024-09-12T12:19:18.249002200', '25.44', '-'),
(231639, 15, '2024-09-12T12:20:08.692663200', '25.44', '-'),
(231640, 15, '2024-09-12T12:21:06.955994100', '25.44', '-'),
(231641, 15, '2024-09-12T12:21:38.323892700', '25.44', '-'),
(231642, 15, '2024-09-12T12:22:06.661440400', '25.44', '-'),
(231643, 15, '2024-09-12T12:22:36.457788800', '25.50', '-'),
(231644, 15, '2024-09-12T12:23:06.769272100', '25.44', '-'),
(231645, 15, '2024-09-12T12:23:36.568709900', '25.50', '-'),
(231646, 15, '2024-09-12T12:24:41.678034500', '25.50', '-'),
(231647, 15, '2024-09-12T12:25:13.846402', '25.50', '-'),
(231648, 15, '2024-09-12T12:25:31.068259900', '25.50', '-'),
(231649, 15, '2024-09-12T12:26:27.729889200', '-', '-'),
(231650, 15, '2024-09-12T12:26:53.130548300', '25.50', '-'),
(231651, 15, '2024-09-12T12:27:22.931691200', '25.50', '-'),
(231652, 15, '2024-09-12T12:27:52.882710100', '25.50', '-'),
(231653, 15, '2024-09-12T12:28:23.201638800', '25.50', '-'),
(231654, 15, '2024-09-12T12:29:36.816040400', '25.50', '-'),
(231655, 15, '2024-09-12T12:30:06.207046900', '25.50', '-'),
(231656, 15, '2024-09-12T12:30:36.220450800', '25.50', '-'),
(231657, 15, '2024-09-12T12:31:06.207076500', '25.50', '-'),
(231658, 15, '2024-09-12T12:31:36.263869800', '25.50', '-'),
(231659, 15, '2024-09-12T12:32:06.221852800', '25.50', '-'),
(231660, 15, '2024-09-12T12:32:36.420695500', '25.50', '-'),
(231661, 15, '2024-09-12T12:33:06.331218900', '25.56', '-'),
(231662, 15, '2024-09-12T12:33:36.299828200', '25.56', '-'),
(231663, 15, '2024-09-12T12:34:06.343286', '25.56', '-'),
(231664, 15, '2024-09-12T12:34:36.246153200', '25.50', '-'),
(231665, 15, '2024-09-12T12:35:06.236304500', '25.56', '-'),
(231666, 15, '2024-09-12T12:35:36.127965900', '25.56', '-'),
(231667, 15, '2024-09-12T12:36:06.748941800', '25.56', '-'),
(231668, 15, '2024-09-12T12:37:04.319516400', '25.56', '-'),
(231669, 15, '2024-09-12T12:37:33.520869800', '25.56', '-'),
(231670, 15, '2024-09-12T12:38:03.372918200', '25.56', '-'),
(231671, 15, '2024-09-12T12:38:33.482611200', '25.62', '-'),
(231672, 15, '2024-09-12T12:39:03.499840900', '25.62', '-'),
(231673, 15, '2024-09-12T12:39:34.215641800', '25.62', '-'),
(231674, 15, '2024-09-12T12:40:04.116289700', '25.62', '-'),
(231675, 15, '2024-09-12T12:40:34.859241400', '25.56', '-'),
(231676, 15, '2024-09-12T12:41:03.104023700', '25.62', '-'),
(231677, 15, '2024-09-12T12:41:32.902506500', '25.62', '-'),
(231678, 15, '2024-09-12T12:42:05.360879', '25.62', '-'),
(231679, 15, '2024-09-12T12:42:33.625112800', '25.62', '-'),
(231680, 15, '2024-09-12T13:30:00.359243700', '25.44', '-'),
(231681, 15, '2024-09-12T13:31:10.649521700', '25.44', '-'),
(231682, 15, '2024-09-12T19:22:30.241300800', '27.25', '-'),
(231683, 15, '2024-09-12T19:23:04.686673900', '-', '-'),
(231684, 15, '2024-09-12T19:23:56.895191800', '-', '-'),
(231685, 15, '2024-09-12T19:24:27.085043', '-', '-'),
(231686, 15, '2024-09-12T19:24:57.280833', '-', '-'),
(231687, 15, '2024-09-12T19:25:26.543421800', '-', '-'),
(231688, 15, '2024-09-12T19:25:52.594159300', '27.25', '-'),
(231689, 15, '2024-09-12T19:26:22.854224600', '27.25', '-'),
(231690, 15, '2024-09-12T19:26:52.806696800', '27.25', '-'),
(231691, 15, '2024-09-12T19:27:22.938777700', '27.25', '-'),
(231692, 15, '2024-09-12T19:27:52.998874800', '27.25', '-'),
(231693, 15, '2024-09-12T19:28:22.968866600', '27.25', '-'),
(231694, 15, '2024-09-12T19:28:56.304094300', '-', '-'),
(231695, 15, '2024-09-12T19:29:26.230683700', '-', '-'),
(231696, 15, '2024-09-12T19:29:56.333705', '-', '-'),
(231697, 15, '2024-09-12T19:30:26.913037500', '-', '-'),
(231698, 15, '2024-09-12T19:30:57.021702900', '-', '-'),
(231699, 15, '2024-09-12T19:31:26.404264400', '-', '-'),
(231700, 15, '2024-09-12T19:31:56.167593300', '-', '-'),
(231701, 15, '2024-09-12T19:32:26.227896', '-', '-'),
(231702, 15, '2024-09-12T22:35:19.467461', '27.19', '-'),
(231703, 15, '2024-09-25T20:18:41.891545', '26.12', '-'),
(231704, 15, '2024-09-25T20:19:10.660045900', '26.12', '-'),
(231705, 15, '2024-09-25T20:19:41.888649100', '26.12', '-'),
(231706, 15, '2024-09-25T20:20:10.364324500', '26.12', '-'),
(231707, 15, '2024-09-25T20:20:40.549148500', '26.12', '-'),
(231708, 15, '2024-09-25T20:21:10.468834400', '26.12', '-'),
(231709, 15, '2024-09-25T20:21:40.208375200', '26.19', '-'),
(231710, 15, '2024-09-25T20:22:11.825345', '26.12', '-'),
(231711, 15, '2024-09-25T20:22:40.675972200', '26.19', '-'),
(231712, 15, '2024-09-25T20:23:10.368161500', '26.19', '-');

-- --------------------------------------------------------

--
-- Table structure for table `userstype_tbls`
--

DROP TABLE IF EXISTS `userstype_tbls`;
CREATE TABLE IF NOT EXISTS `userstype_tbls` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `en_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `userstype_tbls`
--

INSERT INTO `userstype_tbls` (`id`, `title`, `en_title`) VALUES
(1, 'Admin', 'ADMIN'),
(2, 'User', 'USER');

-- --------------------------------------------------------

--
-- Table structure for table `users_tbls`
--

DROP TABLE IF EXISTS `users_tbls`;
CREATE TABLE IF NOT EXISTS `users_tbls` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `family` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `bio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `login_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `google_auth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `profile_image_file_id` int UNSIGNED NOT NULL,
  `city_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users_tbls`
--

INSERT INTO `users_tbls` (`id`, `username`, `password`, `name`, `family`, `phone`, `email`, `bio`, `login_token`, `date_time`, `user_type`, `status`, `website`, `address`, `google_auth`, `profile_image_file_id`, `city_id`) VALUES
(1, 'rezafta', 'd0f1fa128cee4a68c57bec9305fa28da48e6fec3846e2a0c68d980ca059b13e2', 'Rezaa', 'Farazi', '09386949300', 'rezafarazi1378@gmail.com', 'rezafta', 'd0f1fa128cee4a68c57bec9305fa28da48e6fec3846e2a0c68d980ca059b13e2', '1400', 'ADMIN', '1', 'sorapp.ir', 'sorapp.ir', '', 48, 1),
(6, 'ali', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', 'Ali', 'sss', '9123456879', 'ali@izino.ir', '----', ';8Ì\Z6€).™B.ÙžÝ¸÷Ò_s%~bùCô¶»Ùh', '2024/9/5 11:53:3', 'Admin', '1', '', '--', '', 49, 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_verify_tbls`
--

DROP TABLE IF EXISTS `user_verify_tbls`;
CREATE TABLE IF NOT EXISTS `user_verify_tbls` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `hash_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
