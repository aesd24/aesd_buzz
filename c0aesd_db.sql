-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 15, 2025 at 11:34 PM
-- Server version: 10.11.14-MariaDB-0+deb12u2
-- PHP Version: 8.2.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `c0aesd_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `actualites`
--

CREATE TABLE `actualites` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `titre` varchar(255) NOT NULL,
  `contenu` text NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `date_publication` datetime DEFAULT NULL,
  `date_expiration` datetime DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `administrateur_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `add_photo`
--

CREATE TABLE `add_photo` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `photo_path` varchar(255) NOT NULL,
  `church_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `add_photo`
--

INSERT INTO `add_photo` (`id`, `photo_path`, `church_id`, `created_at`, `updated_at`) VALUES
(1, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/church-photos/1765653152_téléchargement.jpeg', 1, '2025-12-13 18:12:32', '2025-12-13 18:12:32'),
(2, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/church-photos/1765750982_Screenshot_20251202-115615.png', 1, '2025-12-14 21:23:03', '2025-12-14 21:23:03');

-- --------------------------------------------------------

--
-- Table structure for table `administrateurs`
--

CREATE TABLE `administrateurs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `id_card_recto` varchar(255) DEFAULT NULL,
  `id_card_verso` varchar(255) DEFAULT NULL,
  `role` enum('editor','admin','super_admin') NOT NULL DEFAULT 'editor',
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `administrateurs`
--

INSERT INTO `administrateurs` (`id`, `id_card_recto`, `id_card_verso`, `role`, `user_id`, `created_at`, `updated_at`) VALUES
(1, NULL, NULL, 'super_admin', 1, '2025-12-08 21:43:38', '2025-12-08 21:43:38');

-- --------------------------------------------------------

--
-- Table structure for table `admin_invitations`
--

CREATE TABLE `admin_invitations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT 0,
  `expires_at` timestamp NOT NULL,
  `invited_by` bigint(20) UNSIGNED DEFAULT NULL,
  `role` enum('editor','admin','super_admin') NOT NULL DEFAULT 'editor',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ceremonies`
--

CREATE TABLE `ceremonies` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `media` varchar(255) DEFAULT NULL,
  `event_date` date NOT NULL,
  `id_eglise` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chantres`
--

CREATE TABLE `chantres` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `manager` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `churches`
--

CREATE TABLE `churches` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(255) NOT NULL,
  `adresse` varchar(255) NOT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `is_main` tinyint(1) NOT NULL DEFAULT 0,
  `description` text DEFAULT NULL,
  `attestation_file_path` varchar(255) DEFAULT NULL,
  `validation_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `type_church` varchar(255) NOT NULL,
  `main_church_id` int(11) DEFAULT NULL,
  `owner_servant_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `churches`
--

INSERT INTO `churches` (`id`, `name`, `email`, `phone`, `adresse`, `logo`, `is_main`, `description`, `attestation_file_path`, `validation_status`, `type_church`, `main_church_id`, `owner_servant_id`, `created_at`, `updated_at`) VALUES
(1, 'Eglise assemblée de Dieu', 'raoulgompou77@gmail.com', '0777638112', 'faya akouedo', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/logos/church_logo_1765651783.jpg', 1, 'temple Emmanuel de akouedo', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/attestations/church_attestation_1765651784.pdf', 'approved', 'Evangelique', NULL, 4, '2025-12-13 17:49:44', '2025-12-13 18:01:03'),
(2, 'Eglise assemblée de Dieu - Bimbresso', 'macdylanjaphetkouame00@gmail.com', '0556600878', 'Abadjin-Koute', NULL, 0, 'Annexe de Eglise assemblée de Dieu', NULL, 'approved', 'Evangelique', 1, 4, '2025-12-14 21:38:09', '2025-12-14 21:38:09'),
(4, 'Eglise assemblée de Dieu - Bimbresso', 'macdylanjaphetkouame8@gmail.com', '0556600878', 'Abadjin-Koute', NULL, 0, 'Annexe de Eglise assemblée de Dieu', NULL, 'approved', 'Evangelique', 1, 4, '2025-12-14 21:41:06', '2025-12-14 21:41:06');

-- --------------------------------------------------------

--
-- Table structure for table `church_programme`
--

CREATE TABLE `church_programme` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `day` enum('lundi','mardi','mercredi','jeudi','vendredi','samedi','dimanche') NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `church_id` bigint(20) UNSIGNED NOT NULL,
  `programme_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `church_programme`
--

INSERT INTO `church_programme` (`id`, `day`, `start_time`, `end_time`, `church_id`, `programme_id`, `created_at`, `updated_at`) VALUES
(1, 'lundi', '00:10:00', '14:09:00', 1, 1, '2025-12-14 21:10:46', '2025-12-14 21:10:46');

-- --------------------------------------------------------

--
-- Table structure for table `discussion_groups`
--

CREATE TABLE `discussion_groups` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `cover_image` varchar(255) DEFAULT NULL,
  `is_private` tinyint(1) NOT NULL DEFAULT 0,
  `church_id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `discussion_groups_users`
--

CREATE TABLE `discussion_groups_users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `discussion_group_id` bigint(20) UNSIGNED NOT NULL,
  `role` enum('member','moderator','admin') NOT NULL DEFAULT 'member',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `discussion_messages`
--

CREATE TABLE `discussion_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `discussion_group_id` bigint(20) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dons`
--

CREATE TABLE `dons` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `objectif` double NOT NULL,
  `end_at` datetime DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `current_amount` double DEFAULT NULL,
  `recipiendaire` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evenements`
--

CREATE TABLE `evenements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `titre` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `date_debut` datetime NOT NULL,
  `date_fin` datetime NOT NULL,
  `lieu` varchar(255) NOT NULL,
  `file` varchar(255) NOT NULL,
  `type_evenement` varchar(255) NOT NULL,
  `categorie_evenement` varchar(255) NOT NULL,
  `date_debut_publication` datetime DEFAULT NULL,
  `date_fin_publication` datetime DEFAULT NULL,
  `prix_journalier` decimal(10,2) DEFAULT NULL,
  `validation_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `cout_total` decimal(10,2) DEFAULT NULL,
  `organisateur` varchar(255) NOT NULL,
  `eglise_id` bigint(20) UNSIGNED NOT NULL,
  `est_public` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expert_invitations`
--

CREATE TABLE `expert_invitations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `sujet_id` bigint(20) UNSIGNED NOT NULL,
  `domain_expertise` varchar(255) NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','accepted','expired') NOT NULL DEFAULT 'pending',
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fideles`
--

CREATE TABLE `fideles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `fideles`
--

INSERT INTO `fideles` (`id`, `user_id`, `created_at`, `updated_at`) VALUES
(1, 6, '2025-12-13 17:52:51', '2025-12-13 17:52:51');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_09_18_000000_create_churches_table', 1),
(2, '2014_10_12_000000_create_users_table', 1),
(3, '2014_10_12_100000_create_password_reset_tokens_table', 1),
(4, '2014_10_12_200000_add_two_factor_columns_to_users_table', 1),
(5, '2019_08_19_000000_create_failed_jobs_table', 1),
(6, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(7, '2020_05_21_100000_create_teams_table', 1),
(8, '2020_05_21_200000_create_team_user_table', 1),
(9, '2020_05_21_300000_create_team_invitations_table', 1),
(10, '2024_10_18_191300_create_serviteurs_de_dieu_table', 1),
(11, '2024_10_18_191327_create_fideles_table', 1),
(12, '2024_10_18_191338_create_chantres_table', 1),
(13, '2024_10_18_191347_create_administrateurs_table', 1),
(14, '2024_10_18_191353_create_sujets_de_discussion_table', 1),
(15, '2024_10_18_191359_create_quizz_table', 1),
(16, '2024_10_18_191360_create_questions', 1),
(17, '2024_10_18_191406_create_propositions_de_reponses_table', 1),
(18, '2024_10_18_191414_create_opportunites_jeunes_table', 1),
(19, '2024_10_18_191423_create_dons_table', 1),
(20, '2024_10_18_191428_create_temoignages_table', 1),
(21, '2024_10_18_191439_create_ceremonies_table', 1),
(22, '2024_10_18_191445_create_programmes_table', 1),
(23, '2024_10_18_191517_create_users_quizz_table', 1),
(24, '2024_10_18_191524_create_users_opportunites_jeunes_table', 1),
(25, '2024_10_18_191528_create_users_dons_table', 1),
(26, '2024_10_18_191533_create_postes_table', 1),
(27, '2024_10_20_010518_create_sessions_table', 1),
(28, '2024_12_04_071436_create_actualites_table', 1),
(29, '2024_12_04_104415_create_post_users_table', 1),
(30, '2024_12_12_203056_create_evenements_table', 1),
(31, '2025_01_19_132833_create_add_photo_table', 1),
(32, '2025_02_06_152120_create_church_programme_table', 1),
(33, '2025_02_16_125418_create_serviteur_user_table', 1),
(34, '2025_04_01_000657_create_discussion_groups_table', 1),
(35, '2025_04_01_001425_create_discussion_groups_users_table', 1),
(36, '2025_04_01_001657_create_discussion_messages_table', 1),
(37, '2025_04_18_170652_create_admin_invitations_table', 1),
(38, '2025_05_21_141208_create_users_sujets_de_discussion', 1),
(39, '2025_05_21_161503_create_expert_invitations', 1),
(40, '2025_07_28_134921_create_notifications_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `opportunites_jeunes`
--

CREATE TABLE `opportunites_jeunes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `titre` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `post_profile` varchar(255) NOT NULL,
  `exigence` varchar(255) NOT NULL,
  `deadline` time NOT NULL,
  `localisation_du_poste` varchar(255) NOT NULL,
  `is_published_at` datetime DEFAULT NULL,
  `study_level` varchar(255) NOT NULL,
  `experience` varchar(255) NOT NULL,
  `type_contract` varchar(255) NOT NULL,
  `administrateur_id` bigint(20) UNSIGNED NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(3, 'App\\Models\\User', 4, 'auth_token', 'e8131beb09160f0a84bbb73c6cdb54b8ea1bce8c03a44501fc4ae072e89753fd', '[\"*\"]', '2025-12-09 14:43:17', NULL, '2025-12-09 14:42:09', '2025-12-09 14:43:17'),
(10, 'App\\Models\\User', 6, 'auth_token', 'c0d8812d1840088d87793fbc27c70fa3456819308b9f0e6ed17974ac29746216', '[\"*\"]', '2025-12-13 18:15:25', NULL, '2025-12-13 18:12:07', '2025-12-13 18:15:25'),
(12, 'App\\Models\\User', 8, 'auth_token', '05ea0ef05afb74ba09f357f15af987985a9428b0e4456d0d0aa63b187f689462', '[\"*\"]', '2025-12-15 17:54:28', NULL, '2025-12-13 19:19:18', '2025-12-15 17:54:28'),
(18, 'App\\Models\\User', 5, 'auth_token', '34d09c90b5094d3eaac6bcdd716672c7a93c000a6454e16f6cae684e4385fff0', '[\"*\"]', '2025-12-14 21:16:16', NULL, '2025-12-14 21:14:39', '2025-12-14 21:16:16'),
(19, 'App\\Models\\User', 2, 'auth_token', 'e5551f3e0931a2f1209517357e7fb5b620c00f01d31c505932a3cb6ede881327', '[\"*\"]', '2025-12-15 21:12:32', NULL, '2025-12-15 16:53:17', '2025-12-15 21:12:32'),
(20, 'App\\Models\\User', 3, 'auth_token', '9ce020228e148028a49b3f36fde614d2640b11e40251805479701f2468d204f2', '[\"*\"]', '2025-12-15 18:20:28', NULL, '2025-12-15 18:20:14', '2025-12-15 18:20:28');

-- --------------------------------------------------------

--
-- Table structure for table `postes`
--

CREATE TABLE `postes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `contenu` text NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `nombre_vue` varchar(255) DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `servant_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `postes`
--

INSERT INTO `postes` (`id`, `contenu`, `image`, `nombre_vue`, `published_at`, `servant_id`, `created_at`, `updated_at`) VALUES
(5, 'Ok allons y pour les tests', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/images/1765835999_Capture d’écran 2025-06-14 214407.png', NULL, NULL, 1, '2025-12-15 21:00:00', '2025-12-15 21:00:00'),
(6, 'Test web post', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/images/1765836322_macbook.jpeg', NULL, NULL, 1, '2025-12-15 21:05:22', '2025-12-15 21:05:22'),
(7, 'Test Post mobile', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/images/1765836363_Screenshot_20251215-175511.png', NULL, NULL, 1, '2025-12-15 21:06:04', '2025-12-15 21:06:04'),
(8, 'Test post compte didier Web', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/images/1765836682_image_eglise (1).jpeg', NULL, NULL, 4, '2025-12-15 21:11:23', '2025-12-15 21:11:23'),
(9, 'Test 2 Web post Didier', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/images/1765836800_téléchargement.jpeg', NULL, NULL, 4, '2025-12-15 21:13:20', '2025-12-15 21:13:20');

-- --------------------------------------------------------

--
-- Table structure for table `postes_users`
--

CREATE TABLE `postes_users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `comment` text DEFAULT NULL,
  `like` tinyint(1) DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `post_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `postes_users`
--

INSERT INTO `postes_users` (`id`, `comment`, `like`, `user_id`, `post_id`, `created_at`, `updated_at`) VALUES
(5, NULL, 1, 2, 7, '2025-12-15 21:06:50', '2025-12-15 21:06:50'),
(6, 'salut les gars', NULL, 2, 7, '2025-12-15 21:07:08', '2025-12-15 21:07:08'),
(7, NULL, 1, 2, 8, '2025-12-15 21:12:04', '2025-12-15 21:12:04');

-- --------------------------------------------------------

--
-- Table structure for table `programmes`
--

CREATE TABLE `programmes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `programmes`
--

INSERT INTO `programmes` (`id`, `title`, `description`, `file`, `created_at`, `updated_at`) VALUES
(1, 'Culte d\'action de grâce', 'Dkdkldfllf', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/images/1765750245_Screenshot_20251202-111153.png', '2025-12-14 21:10:46', '2025-12-14 21:10:46');

-- --------------------------------------------------------

--
-- Table structure for table `propositions_de_reponses`
--

CREATE TABLE `propositions_de_reponses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `intitule` varchar(255) NOT NULL,
  `exact` tinyint(1) NOT NULL DEFAULT 0,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `propositions_de_reponses`
--

INSERT INTO `propositions_de_reponses` (`id`, `intitule`, `exact`, `question_id`, `created_at`, `updated_at`) VALUES
(1, 'Noé', 1, 1, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(2, 'Moïse', 0, 1, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(3, 'Abraham', 0, 1, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(4, 'Élie', 0, 1, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(5, '3 jours', 0, 2, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(6, '5 jours', 0, 2, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(7, '6 jours', 1, 2, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(8, '7 jours', 0, 2, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(9, 'Paul', 0, 3, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(10, 'Pierre', 1, 3, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(11, 'Thomas', 0, 3, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(12, 'Judas', 0, 3, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(13, 'Joseph', 0, 4, '2025-12-09 14:21:06', '2025-12-09 14:21:06'),
(14, 'Pierre', 0, 4, '2025-12-09 14:21:06', '2025-12-09 14:21:06'),
(15, 'Jacques', 0, 4, '2025-12-09 14:21:06', '2025-12-09 14:21:06'),
(16, 'Jean le Baptiste', 1, 4, '2025-12-09 14:21:06', '2025-12-09 14:21:06'),
(17, 'Nazareth', 0, 5, '2025-12-09 14:21:06', '2025-12-09 14:21:06'),
(18, 'Jérusalem', 0, 5, '2025-12-09 14:21:06', '2025-12-09 14:21:06'),
(19, 'Bethléem', 1, 5, '2025-12-09 14:21:06', '2025-12-09 14:21:06'),
(20, 'Galilée', 0, 5, '2025-12-09 14:21:06', '2025-12-09 14:21:06');

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `intitule` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `points` int(11) NOT NULL DEFAULT 1,
  `quizz_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`id`, `intitule`, `description`, `points`, `quizz_id`, `created_at`, `updated_at`) VALUES
(1, 'Qui a construit l’Arche ?', NULL, 2, 1, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(2, 'Combien de jours a duré la création ?', NULL, 3, 1, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(3, 'Qui a renié Jésus trois fois ?', NULL, 5, 1, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(4, 'Qui a baptisé Jésus ?', NULL, 5, 2, '2025-12-09 14:21:06', '2025-12-09 14:21:06'),
(5, 'Où Jésus est-il né ?', NULL, 1, 2, '2025-12-09 14:21:06', '2025-12-09 14:21:06');

-- --------------------------------------------------------

--
-- Table structure for table `quizz`
--

CREATE TABLE `quizz` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `theme` varchar(255) NOT NULL,
  `intitule` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `administrateur_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quizz`
--

INSERT INTO `quizz` (`id`, `theme`, `intitule`, `date`, `administrateur_id`, `created_at`, `updated_at`) VALUES
(1, 'Bible – Ancien & Nouveau Testament', 'Bases de la Bible', '2025-12-09', 1, '2025-12-09 14:13:55', '2025-12-09 14:13:55'),
(2, 'Vie de Jésus', 'Nouveau Testament', '2025-12-09', 1, '2025-12-09 14:21:06', '2025-12-09 14:21:06');

-- --------------------------------------------------------

--
-- Table structure for table `serviteurs_de_dieu`
--

CREATE TABLE `serviteurs_de_dieu` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `is_main` tinyint(1) NOT NULL DEFAULT 0,
  `appel` enum('DOC','EVA','PRO','PAS','APO') NOT NULL,
  `certif_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `is_assigned` tinyint(1) NOT NULL DEFAULT 0,
  `id_card_recto` varchar(255) DEFAULT NULL,
  `id_card_verso` varchar(255) DEFAULT NULL,
  `certified_at` timestamp NULL DEFAULT NULL,
  `deadline_at` timestamp NULL DEFAULT NULL,
  `last_reminder_sent_at` timestamp NULL DEFAULT NULL,
  `reminder_count` int(11) NOT NULL DEFAULT 0,
  `church_assignment_completed` tinyint(1) NOT NULL DEFAULT 0,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `serviteurs_de_dieu`
--

INSERT INTO `serviteurs_de_dieu` (`id`, `is_main`, `appel`, `certif_status`, `is_assigned`, `id_card_recto`, `id_card_verso`, `certified_at`, `deadline_at`, `last_reminder_sent_at`, `reminder_count`, `church_assignment_completed`, `user_id`, `created_at`, `updated_at`) VALUES
(1, 0, 'EVA', 'approved', 0, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/recto_Dylan Kouamé_1765234048.jpg', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/verso_Dylan Kouamé_1765234048.jpg', '2025-12-08 21:48:47', '2025-12-15 21:48:47', NULL, 0, 1, 2, '2025-12-08 21:47:29', '2025-12-14 21:41:06'),
(2, 0, 'DOC', 'approved', 0, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/recto_Jean-Cherel Gokou_1765276350.jpg', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/verso_Jean-Cherel Gokou_1765276350.jpg', '2025-12-12 12:05:37', '2025-12-19 12:05:37', NULL, 0, 0, 3, '2025-12-09 09:32:31', '2025-12-12 12:05:37'),
(3, 0, 'PRO', 'approved', 0, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/recto_Kilet Elisée_1765294899.jpg', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/verso_Kilet Elisée_1765294899.jpg', '2025-12-12 12:07:30', '2025-12-19 12:07:30', NULL, 0, 0, 4, '2025-12-09 14:41:40', '2025-12-12 12:07:30'),
(4, 1, 'PAS', 'approved', 0, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/recto_raoul gompou_1765544630.jpeg', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/verso_raoul gompou_1765544631.jpeg', '2025-12-12 12:06:38', NULL, NULL, 0, 1, 5, '2025-12-12 12:03:51', '2025-12-13 18:01:03'),
(5, 0, 'EVA', 'pending', 0, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/recto_ange_1765657141.jpg', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/Carte_Identite/verso_ange_1765657141.jpg', NULL, NULL, NULL, 0, 0, 8, '2025-12-13 19:19:01', '2025-12-13 19:19:01');

-- --------------------------------------------------------

--
-- Table structure for table `serviteur_user`
--

CREATE TABLE `serviteur_user` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `serviteur_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `serviteur_user`
--

INSERT INTO `serviteur_user` (`id`, `user_id`, `serviteur_id`, `created_at`, `updated_at`) VALUES
(1, 2, 4, '2025-12-13 22:24:38', '2025-12-13 22:24:38');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('0fO6cbWNI4zje7MNLcUcECjoMVOQPl0UERSmY0xU', NULL, '110.249.202.242', 'Mozilla/5.0 (Linux; Android 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; Bytespider; https://zhanzhang.toutiao.com/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSDdPZmZDalQ0Q2dOMmVVblh3TUEzaGFzN3RvWldPZWpqUWd4blM0MCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765807134),
('1EYosJQgMrRG4NGApglN1kTP0a8d30KZRQnNjb0m', NULL, '170.106.35.137', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiYzdnMWp4elBlbWowY3Z2clFhVW9VaWVpeTZEOHpNSDdGZ0E3WWZmciI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765816928),
('1vl1AHWFHb6FCX6430O9Fwl0aNZ7QcHZzOH2Jc4i', NULL, '203.55.131.3', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOWtIejBDMXRoVFNrTmtUYnplZUdvQ0tVQmI4VUt3VXl4TXRlZ00yWiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDQ6Imh0dHBzOi8vc2VjcmV0LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765840071),
('21X26UzsHcyBfTkKK51yRTRXhdMyZcVOfrrX3xDq', NULL, '179.42.111.201', 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRmNmbW1JZmxoUUVvWVBOdjZWZWswSWgwblRGbEplWUNYVHJWQkJTdiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjY6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvQ2hhbnRyZXNfbGlzdCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765779284),
('44LoCzrn5CHA7bRSAjXKsSdAQYymzyUQTYhp5Vu0', NULL, '188.66.210.71', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Brave Chrome/89.0.4389.72 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVG5qNVlxMzNNZjZFN1h0NzJQUUIxT2xLWVhmeVpteUNPR2FOT1AzdSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vU2Vydml0ZXVycy8zIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765800786),
('4ZhV2cUCuEx8RXBJXgImoxWm0Boi9hoofKiqQTDx', NULL, '103.135.134.23', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRGI3cXVrOEU1NXB1d1ltVldQM3N1cVd3YUlGdGxidXFGcDVtUWI2bCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vcHJpdmFjeS1wb2xpY3kiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765797118),
('5BFu7h08BqzTS31D9Pujupx5as7tfeG2FUb1Mnb4', NULL, '114.119.158.167', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiU3UxMHN2R01KcWlXZlZWU05CUlZySjFvR2tESlNUZFBoSGdlQVNDWiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvZG9ucyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765828887),
('5fmWcJHq1ZnQrgvBXGixwemYPMQdNFeUxeXdXcOl', NULL, '3.82.158.185', 'Mozilla/5.0 (X11; Linux i686; rv:124.0) Gecko/20100101 Firefox/124.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVExoRTlQOFhVSGdHTDlLVzZtMk5VUWNsNlY5cjR1NW9oN2FocEdsUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765841449),
('6CytluY1QXz9EHZ89OSJfNWo32IE3J6eIbslfL35', NULL, '94.25.68.138', 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiM2x3NThvMWlBZU1oTDdLNUNYc1N2NWNKTnl3M1owNWlkbmxxV01sMyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTE6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQ2hhbnRyZXNfbGlzdCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765808200),
('6wd2y7N3riXq3IXJdYnCbqyHT04TKDKS6IISIBYM', NULL, '46.137.197.8', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36 Assetnote/1.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWkI4T0ZIRmMzRTFwQlFEZ1dicXpyZm9FQWxrYmcwb2VVc3N4RmNTciI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDQ6Imh0dHBzOi8vc2VjcmV0LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765776350),
('6ZOK6KLonMLVe3LbqWLpR4h4IVwkaA0zksArjZSB', NULL, '105.156.48.224', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Brave Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOFNDNlZqbkY1SlU3WmFMeDFRUklmblk1OE9adHZnQkJqVnROVWtldiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vU2Vydml0ZXVycy82Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765804440),
('7CVEwHNJeQPvzAnQP1Xdk2IFNboL83uijp3Tam13', 2, '102.209.216.88', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTo1OntzOjY6Il90b2tlbiI7czo0MDoibXVUY1lyTWtrOVBoQmFRZjUyN042eTdJWFR0QUhHUHl2OVlxcWJsVyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vZWdsaXNlcy1saXN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MjtzOjIxOiJwYXNzd29yZF9oYXNoX3NhbmN0dW0iO3M6NjA6IiQyeSQxMiRtaVFmTS9ZZmlFblBNV2hraDQzMVJ1ZXQudEphTE1KdVJjNlJKSDBIaFhxMXMwSlk5ZTJwMiI7fQ==', 1765841324),
('7tpHqdLg3U7odw2mf23D8hIgWY1c5eVlugLHi33b', NULL, '177.191.239.81', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Brave Chrome/78.0.3904.70 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSHFvbk1ObXhwOFl6YW5nUVZwbXRKeEJ5djFOc0dYekpMdTFIUXRpRCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjY6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvU2Vydml0ZXVycy8xMSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765808029),
('8CutztqwxJI9sCOx0mo867TScuIdzE5qvMz2J7ZV', NULL, '114.119.149.71', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieHc4cVB4dnJZSEZHTHRTR2o5aEZjbkc0RUpzVGpTY3c4eFVnM3pVdSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Njk6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvaW5kZXgucGhwL2ZvcnVtcyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765815251),
('9hD8X3msNtglgVoeIFM9jSaLEJyVFbOo8yEWnew1', NULL, '66.132.153.122', 'Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWlJYUU16cW53V3NySGl6TWhKS29OSHhDZ1d0YTNHcnRhRGx4QzcwWSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765827508),
('b6oBpR9JZMD5s6fYG6SRD0DmqdU1XmwaaH7nEjfJ', NULL, '66.249.65.202', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicFhOMWdrMjQ3MzFEWDFaZWtJdEMxaDBIbzNGTExxRzBoNTRXbTZHaCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL3ByaXZhY3ktcG9saWN5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765797250),
('BOtnEug1GyZTiXNT7sWLIBiOPCDaefxvHXOEPQeR', NULL, '192.144.148.122', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUG50dm5qTFpVMDVjeGsxQ09Tam9VbDVHMUt4NWtna0FKZlJZTjlZRSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL0Flc2RXZWIvcHVibGljIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765794265),
('BSHt0J32wPMEgJhj2E25g3TFs413i8nQQ1214YNV', NULL, '170.244.65.140', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.67 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiblp3aVF3UXRMQmllbTBRQzhpemp3TXIxV1dIbFdvWDRkV2ZtNlprRSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Njc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvcHJpdmFjeS1wb2xpY3kiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765786645),
('C4rtY38fgx6pKP1lF4zPISJEXwUOGq5h3JiVo2nG', NULL, '49.233.45.47', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicXBXbUMwY1ZRdFpXV0d4RWt2a2ZhYWdPV2kxOUhzTFdFUFFlSjRoMSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL0Flc2RXZWIvcHVibGljIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765838928),
('catTDM8TJqJdiLqVXjMN2iyuk4kjja2KgzYuHTlU', NULL, '43.157.158.178', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibFM2aFZZYllaVzVtMDF3c0MxMkllbnVkcXdKZlNER0FyYXFZdHY2UiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765839493),
('CufyJz7b9keq7IgkmEflLr0QaHnaZDYcKu3SBBzw', NULL, '185.252.100.243', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicGlYVFRVTGxVVW5LcmdQSWJ6ZjVCM0FiZ3ZSVzNiZWlHNnV6bEI4WCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTk6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvZm9ydW1zIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765793542),
('D6AvdnFFy6LUa45G8nfJKxyDXJ1S9OQDdBMyDQ2l', NULL, '182.42.111.156', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV2xWcHBieWt5aXJrakFKRmNMSmthNnFCNmE3bVN6S2F3Q3QwMmlHQiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765817737),
('DiKJZ5YXEDcSATBI44jHFtQqZznO7BZevVSfnyXp', NULL, '51.68.111.207', 'Mozilla/5.0 (compatible; MJ12bot/v2.0.4; http://mj12bot.com/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMHFOaU5RVng5eEhCQmxGZDdzZTZUeFM2QmtwNHZRbFRFdjk2a0pTMiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765826500),
('dMzefIWwWbSrxLlKBymwAR27KcadTNp41CDRe1pT', NULL, '181.86.64.200', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Brave Chrome/86.0.4240.75 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNnRuR1pNd1dyaW44bnZZRGU0TXlnQ1VHc2N6aWxSM245Q1FWQ1FoRCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjY6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvU2Vydml0ZXVycy8xMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765793745),
('DU54Lui6WuMWPH2hl8T5QWH6DtXxKjJxmR9Jqk4J', NULL, '45.5.141.149', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.61 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWklZWEMwQ0drRzB0WFYxWmRRZUpRSGRFODBUamxhMW5BTDhZSWt4SSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjU6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvU2Vydml0ZXVycy84Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765797204),
('dyhdIk75A5CH29CFtQfJfpm4mM2OtsFOgFJYrYIl', NULL, '114.119.130.33', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRUtXZGE5U3AyQlpGZEtuRjhvbEF4TjFWaTRETFBzbm9tVThBSmp6aSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Njg6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvUHVibGljYXRpb25zLzEzIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765825486),
('Eirne8kothYYCEgI1EOpFP7AH7APHMzN3I4EiMGS', NULL, '66.132.153.142', 'Mozilla/5.0 (compatible; CensysInspect/1.1; +https://about.censys.io/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiR2ZsRVhkMEphbkRTSXhZR0VtWldGWnRaNnVCT2xUd3luSXhjODVyNCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765829288),
('FigFtCnFOfRFJdQ8iVnA4Gyx1olQvas3sh3iklfQ', NULL, '66.249.65.37', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicXJHZEhpQk9IN3hRUHUybWdFeTZNNmNJbGs0MFhFdzgzWGpHWHZ3YSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765796714),
('FwN96LySk2Ip69Gjw7KAWzRYpa4h5B0e67Z6Oer9', NULL, '204.76.203.25', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiaHpYOW1PZXlwRTdzRzB0SkRCRmd3VkgzVm1TM09aY21EMXVtU2NPTiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDQ6Imh0dHBzOi8vc2VjcmV0LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765834966),
('HljeJYleA40Si6uZIUmjS4U2IjRs1ZSPxji5DL5t', NULL, '66.249.65.38', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTmY5blpRcE95dktxd2J6WTRmbFdqdUxVbW1xM0ZDN3BkdXp3eFA3UyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765796709),
('hRZIUCFbGPZmHvJqrGvdieOuXu8XtIhOfioI9GpN', NULL, '111.225.148.92', 'Mozilla/5.0 (Linux; Android 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; Bytespider; https://zhanzhang.toutiao.com/)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNUx2S3JTZjdxemhjRkhkSmJGOU9JYU5GaWk5aHRDZmlUSjMxaUk4SCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765803987),
('HW3oO5VUvwMR7OPLPKSev3N7YKVINszj7l7lrCnG', NULL, '66.249.83.134', 'Google', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNTZaeVU3N21rT09IQTN1eVo5b0RwTHJPZG4zekEzWTJmOEF4V2h2aiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765791904),
('IWEdXytxOyP3pUqDKuDJRpJTsNZDsPcyRafwWCvX', NULL, '35.202.27.233', 'Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:125.0) Gecko/20100101 Firefox/125.0', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiUGdiYmc2d0lGNlkzU2E0bWlyNjhmcjl2U2VZMGMwQkREMGNkZ2NYWSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765834271),
('jf2A5Xzpb7lAQPrY3KpavU409vfHX653W3ZPsiTK', NULL, '66.249.65.202', 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTkZIT2gzYXhiV0tsdnd2WFVkSHFoQmpaaXM3ZzAxR3Btb0dPejdzdyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL3ByaXZhY3ktcG9saWN5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765797195),
('KSgzS4hFYRtrpazJMmimeUWc8QcOhnJbxElkgzCM', NULL, '102.64.167.63', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.64 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidUk3WWgybFdYMWRmTFlwdFhnUDhqcHE2R1hRYjBkRHByRWRINmZXYiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDQ6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vZm9ydW1zIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765790180),
('KsiobwLsYhioTm7plyq7VIEIfg8FwAOJ2lhrjSs9', NULL, '186.235.126.115', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4564.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTGdmeWN1SXdpQ1BwdHZId1VJNTJTU2JiaFBHZ2hSZ0VYdlVaSGZ4dSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NzA6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvb3Bwb3J0dW5pdCVDMyVBOXMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765793753),
('kv2H74NdZ8iwXJjsSD1ayY6pcrIfDwiaCCb81fQN', NULL, '186.149.54.63', 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicDh6T3dkQ0MyY2NFNG43TTQxZmxiMXdpS2pzVTN5aHFKR0V0dTRxVSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vU2Vydml0ZXVycy83Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765779334),
('L7OXof1XgsL82cQhXbIaVevSTbYI0gZNF6KexAKm', NULL, '34.106.24.195', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.6422.112 Safari/537.36 Brave/1.63.120', 'YToyOntzOjY6Il90b2tlbiI7czo0MDoiQVp6SzZkd1hURHZIRURvWjhzU1NSeVU3R1R0M0h6R3dNQ0FmWm83cSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765823598),
('LfKQXpbEUkhwANVflZ5ebjNbtl47kPoVjVjgpyB9', NULL, '102.182.120.215', 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVmUyS0JRNXVtWGhLR0h4Sk40SjJGYlZaZGpROVpnRkVnYWR6R0JKcCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Njk6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvdGVybXMtb2Ytc2VydmljZSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765811882),
('MDVdEkOnYhCSTM9XF4jhjTtq2ZLyMKNs6fjkZeQl', NULL, '181.116.179.161', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidEpKMExhNDVxcjJLQ2pQdGxMOEdJbmI0aUgxSkxkNHpPNENXMVVKUCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL1B1YmxpY2F0aW9ucyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765807877),
('MHQXBqpeSt0KvfQFLMLrTCwluqTJcbjs5q5HjIFW', NULL, '101.32.52.164', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVGVWVUFMNkZDTVVQaTJGRlZzRk5Qa3VWaG80ZmVqc3hycFZINkxOaiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL0Flc2RXZWIvcHVibGljIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765778186),
('nlXSdOyJK3EmesFIo4ihdizt7agdOUeqrlVfgoXM', NULL, '114.119.141.71', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTVlFRGpyc1pXSWtGc21zMWpPejZScGtqTWtkMjEzYWZGeGpnYXQwVSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Njk6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvdGVybXMtb2Ytc2VydmljZSI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765780125),
('oczZ5zV0fnxf0S2EnRBYbG4wB9WD8Tgh69cTV4Io', NULL, '3.106.214.30', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36 Assetnote/1.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoickFvZnJVekZ1ejZVNjNPU01oRVZ6WDh4aUdZQ3lTOTQ2anZ3cjJIZyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765774983),
('OOgVVnaxE36DN1tEwhETVCsRQcbNH2SogRrEKhUj', NULL, '43.157.188.74', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTWl0SkJFRDBPNExXbFFJd29JT3RsbUdRMUttaWJVdlNRb1FDUThiRSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL0Flc2RXZWIvcHVibGljIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765800462),
('Pj3wITiVNwXwfaXPKqKG83JkZRMCjW7SGeDeUnVA', NULL, '13.71.30.28', 'Mozilla/5.0 (Linux; Android 12; SM-A525F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Mobile Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVEx4cVY4cElmQ01sNHVDd29CZjRGZFFMaWZnUlhXckZYZDVnT2JuSSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvaW5kZXgucGhwIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765808225),
('pv7GPLTFHjB61CN8fpUmJ1wqNErqDXj8tyzUQwcv', NULL, '114.119.158.167', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVEdaemt1blRwSkk2UGh1RmVQaXluTE5Dc2xCdnBFUkZ6UTZ5QU9RcyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjQ6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvbW9uRWdsaXNlLzIiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765780219),
('q0EQUE7IHLyufCKWv2sMej5Sj6kRAP26i2lKaKMC', NULL, '13.71.30.28', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/118.0 Mobile/15E148 Safari/605.1.15', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidzNMQ3kxS2VJaU9KS2p3QnloVXdCam1ic0hHalBTSXM5WWIwNUhvdSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvaW5kZXgucGhwIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765808224),
('qBAiP39NPRo9WxfU6GnjmqdorkulXzqdJmnfo1n0', NULL, '114.119.138.183', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia2Y4UTBhajJVQXYxZzhPQUZPRjIweDBMMkJyZmtjbTEwc3drcWNpNyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTM6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vZm9yZ290LXBhc3N3b3JkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765816329),
('Qj0ZSySPir7nMnOeAhvxesKKJ7sEFuWccSp1BTyE', NULL, '114.119.145.194', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicFdsODhoOGNNeUZxVU5GbjZTbHRaSVJabHc1YXJXN0RMRHk0RFRnbiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDM6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vbG9naW4iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765840414),
('QkWH7LBcZ4y2zBzgWJ666AneMSoLY3oAtvS2kYHT', NULL, '216.73.216.6', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; ClaudeBot/1.0; +claudebot@anthropic.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNHduWUlsNXprMGRlcmI2bUc3OFZDUmhNT3BacUhqd2dpd240bzJadSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTg6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL3Rlcm1zLW9mLXNlcnZpY2UiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765835566),
('roAAkt3P6N8O0sJelMSMmJOOCyrzM1c1sCl57eQj', NULL, '186.249.214.213', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Brave Chrome/89.0.4389.90 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicERxS1VmdkhLc01sSnJnSHAwUTJHTTNhRFI3ajdxRFF4V1V0MXhydCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTU6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vb3Bwb3J0dW5pdCVDMyVBOXMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765800727),
('S1DtAACYWUODpnOo88kWPitHNqTOIJGBbrtlB4Pp', NULL, '66.249.65.201', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.122 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiOU1Kd1VOQmRPcVBKQU1penV1TDNmV2ZQVFZKTlRMNjFWWWV4eWNHQyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjM6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL0Flc2RXZWIvcHVibGljL2ZvcnVtcyI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765782313),
('SCh2S2ZOZ7Si5PG1ouAb8pRybQNXk8GZFq5aRVhh', NULL, '43.154.127.188', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVTFOZHlpeHZvSVFldlAyZnkzWndPMDFHbFNES1g3dUxSZ3BSa3FXUSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL0Flc2RXZWIvcHVibGljIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765822429),
('Sd2xbRUBbXWw2ufRlej3I5OC7l27jwTc5nojb7js', NULL, '114.119.137.174', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUngzdkRNcDZGaWxnTFRoc2JRTVZqVk1RU2c3RmNOZXUwNnc0SDhEMiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NzY6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvaW5kZXgucGhwL0NoYW50cmVzX2xpc3QiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765798969),
('T112parFCgzV21i1mutjUKJL2txQXlT0gksXU1qK', NULL, '178.159.211.189', 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiajNSUE9kQXFDMGFseko4dlVKTEVXUkE3Ylc0MmtmcGhjVVp3aHJacCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjU6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvU2Vydml0ZXVycy80Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765786563),
('tHVyRzPNqUYsNlQPwlTASExdTsK5MnJWMZzn1134', NULL, '114.119.137.174', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoic1FjMUVuSms0aGc4S0MxV2VKcUVlZzZWdkxzbDNLbmprbXBPOFd1YiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vZWdsaXNlcy1saXN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765792771),
('UbLhUi0ycG2yAXUaawiwyWFxU1IZlVPjYYCIEv67', NULL, '43.156.232.190', 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUUEzSG1iV1BaSDZSYVpWOUdZdWZ6T3M2SENtazZldGs3c3o2ZHZ6RCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTI6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765794634),
('ukUKAwyQwNMXo04XwXMIJgjGKZYt1yeWNsv2WDbe', NULL, '216.73.216.6', 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; ClaudeBot/1.0; +claudebot@anthropic.com)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiNFdVc24zZ28zeHZzUm90U2dkdllRNkpFZEozVzk3WTRhRVBxRGpOOSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL3ByaXZhY3ktcG9saWN5Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765835746),
('VECf8Gj4DhAmQuohhrrVQCpFDDCqhBkMZlcyoHMu', NULL, '66.249.65.202', 'Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.122 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoicm04MFhhVk5TckNqSTBrVVk0MndvZk5WN2RTVldXM2J4YkpFekk1ViI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Njk6Imh0dHBzOi8vd3d3LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL0Flc2RXZWIvcHVibGljL2VnbGlzZXMtbGlzdCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1765787096),
('vo4PA22VVudOtpZzTYCd7sCyGxcytSPcP7PQEiQ3', 5, '102.209.222.195', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTo1OntzOjY6Il90b2tlbiI7czo0MDoid3NTSnU3ZnVFMk9xZjN6bkU4dktCOUNZallUNkdqa1dVcFlZOGNHViI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTQ6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vcHVibGljYXRpb24vbGlzdCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjU7czoyMToicGFzc3dvcmRfaGFzaF9zYW5jdHVtIjtzOjYwOiIkMnkkMTIkaW5DcVFUT0JUQ3lBUkpQUGN4d1ZqT05zQTEvWTJMd3I0bWRGejNWbk1rbTBDZXQ4Q241VHUiO30=', 1765836800),
('XnAGx7Mm7jssIQTUd1hi3qR6oyLheJCPrK04QhvI', NULL, '95.27.38.138', 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoibTdOWmFWMHdaRVJSUHZTQWpkcUhobk5hOEVSWmdMV2drbXhBQWpiYSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTA6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vU2Vydml0ZXVycy84Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765811954),
('YXh2Gr4fCJEsRgVivqEl0w3tavKwbYwyoRS3jcTA', NULL, '3.106.214.30', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36 Assetnote/1.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTUdMdVZWRUpVOWV6UTFsNktmMUhtTWVDcnpZSHltdjVVdVN4ajJWMiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765774983),
('zHyY86ucHoH0lNAuvDodCD2sPXA0cTpwDSyKjdMD', 1, '102.209.222.195', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', 'YTo0OntzOjY6Il90b2tlbiI7czo0MDoiSFRySlFvMFpydWhnN3lIbWRqd0JhbnRLdW5VWVRtbkhXa0o2UXV3TCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NzQ6Imh0dHBzOi8vc2VjcmV0LmVnbGlzZXNldHNlcnZpdGV1cnNkZWRpZXUuY29tL3N1cGVyX2FkbWluL3B1YmxpY2F0aW9ucy9saXN0Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTt9', 1765836075),
('Zn14exgWInbXSJmmhW92VqXHpoGZ3ZMcTP6wtt72', NULL, '114.119.155.78', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUDdKU1NReVN0QWdvRjFTM1lWMEtyOHVYTEp6SWFEVjh1QWRuU3NEOCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjE6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvZm9ydW1zLzEiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765795595),
('ZreJkjNK1Hu1moWP7LQJMu4BDzGspw0Fbf0WDS1U', NULL, '114.119.155.78', 'Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVzk4ZDZubzRxM21GcG16QVhBdjlpaDJsSHlxaDB0d3E0TmkxTUN2USI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Njg6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20vQWVzZFdlYi9wdWJsaWMvaW5kZXgucGhwL2xvZ2luIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1765780345),
('zTBl9hLQtAF3zv2cLMtP2Vofgah8pkIMcLhlfYj6', NULL, '204.76.203.25', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.3', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRXFYdEdUaWNWOU1id01OSE4yZkgzbkhuM3Vqd3VYdXVHeWh1TlNBbiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzc6Imh0dHBzOi8vZWdsaXNlc2V0c2Vydml0ZXVyc2RlZGlldS5jb20iO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1765834966);

-- --------------------------------------------------------

--
-- Table structure for table `sujets_de_discussion`
--

CREATE TABLE `sujets_de_discussion` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `theme` varchar(255) NOT NULL,
  `date_publication` date NOT NULL,
  `body` text NOT NULL,
  `date_expiration` date DEFAULT NULL,
  `is_closed` tinyint(1) NOT NULL DEFAULT 0,
  `expert_comment` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sujets_de_discussion`
--

INSERT INTO `sujets_de_discussion` (`id`, `theme`, `date_publication`, `body`, `date_expiration`, `is_closed`, `expert_comment`, `created_at`, `updated_at`) VALUES
(1, 'Pourquoi Dieu permet-il les épreuves ?', '2025-12-09', 'Beaucoup de chrétiens se demandent pourquoi Dieu laisse certaines souffrances ou épreuves dans nos vies.\r\nSelon vous, sont-elles nécessaires pour renforcer notre foi ? Avez-vous vécu une épreuve qui vous a rapproché(e) de Dieu ?', NULL, 0, NULL, '2025-12-09 14:22:56', '2025-12-09 14:22:56'),
(2, 'Comment reconnaître la voix de Dieu ?', '2025-12-09', 'Certains disent que Dieu parle par des songes, d\'autres par la Parole, d’autres encore par des signes.\r\nComment, selon vous, un chrétien peut-il discerner la voix de Dieu au milieu du bruit du monde ?', '2025-12-13', 0, NULL, '2025-12-09 14:23:36', '2025-12-09 14:23:36');

-- --------------------------------------------------------

--
-- Table structure for table `teams`
--

CREATE TABLE `teams` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `personal_team` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `team_invitations`
--

CREATE TABLE `team_invitations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `team_id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `role` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `team_user`
--

CREATE TABLE `team_user` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `team_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `role` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `temoignages`
--

CREATE TABLE `temoignages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `confession_file_path` varchar(255) NOT NULL,
  `published_at` datetime NOT NULL,
  `is_anonymous` tinyint(1) NOT NULL DEFAULT 0,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `temoignages`
--

INSERT INTO `temoignages` (`id`, `title`, `confession_file_path`, `published_at`, `is_anonymous`, `user_id`, `created_at`, `updated_at`) VALUES
(1, 'Test du Samedi', 'https://bucketaesd.s3.eu-north-1.amazonaws.com/confessions/1765623697_cd5f1ff799c10c5c786e3f9f2c655f5e_1765611812131.mp4', '2025-12-13 00:00:00', 0, 2, '2025-12-13 10:01:38', '2025-12-13 10:01:38');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `two_factor_secret` text DEFAULT NULL,
  `two_factor_recovery_codes` text DEFAULT NULL,
  `two_factor_confirmed_at` timestamp NULL DEFAULT NULL,
  `device_token` varchar(255) DEFAULT NULL,
  `device_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `account_type` varchar(255) DEFAULT NULL,
  `adresse` varchar(255) DEFAULT NULL,
  `points_obtenus` int(11) DEFAULT NULL,
  `temps_total` varchar(255) DEFAULT NULL,
  `church_id` bigint(20) UNSIGNED DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `current_team_id` bigint(20) UNSIGNED DEFAULT NULL,
  `profile_photo` varchar(255) DEFAULT NULL,
  `status` enum('normal','is_expert') NOT NULL DEFAULT 'normal',
  `otp_code` varchar(255) DEFAULT NULL,
  `otp_expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `two_factor_secret`, `two_factor_recovery_codes`, `two_factor_confirmed_at`, `device_token`, `device_name`, `phone`, `account_type`, `adresse`, `points_obtenus`, `temps_total`, `church_id`, `remember_token`, `current_team_id`, `profile_photo`, `status`, `otp_code`, `otp_expires_at`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'admin@eglisesetserviteursdedieu.com', '2025-12-08 21:43:38', '$2y$12$Kkik050wOkQnPTl6BwkAH.6CWW4EA9Tdtz7xRr4gWllY0qXf6ZK.y', NULL, NULL, NULL, NULL, NULL, '+22500000000', 'administrateur', 'Abidjan, Côte d\'Ivoire', NULL, NULL, NULL, NULL, NULL, NULL, 'normal', NULL, NULL, '2025-12-08 21:43:38', '2025-12-08 21:43:38'),
(2, 'Dylan Kouamé', 'macdylanjaphetkouame76@gmail.com', NULL, '$2y$12$miQfM/YfiEnPMWhkh431Ruet.tJaLMJuRc6RJH0HhXq1s0JY9e2p2', NULL, NULL, NULL, 'f_imsLkYRdSIOHJOk62NgZ:APA91bHoRZWmsjzx6wchYZAIN-oVmrZwZqic6lx_RchaUT-0dqnjupuS0pfZ_KQpZV1iV2J0Tw9qAUXX56W8vF8nXyJOYm381AzgODT0JXzgeFXB4UqiSDw', 'Infinix X657B', '0788571436', 'serviteur_de_dieu', 'Abidjan', NULL, NULL, 4, '0pt51gvVUnDDQWoTITr76sln5RXdLUT8NjXfWerBOiZEp2lXUbyyV3MpjNIc', NULL, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/profile-photos/user_2_1765234047.jpg', 'normal', NULL, NULL, '2025-12-08 21:47:27', '2025-12-15 16:53:17'),
(3, 'Jean-Cherel Gokou', 'jeancherelgokou@gmail.com', NULL, '$2y$12$UJU/UFZw8.P0iIZ7g3GvkeuRkvr/Q3.7MoGeZNtFhiHlen2gJ5l/C', NULL, NULL, NULL, 'fjynFKM0SKGOiy0Wjiz1kI:APA91bHgmi6TG_rKuA_DosiZ4lEjo6F-wr_FYbfhsWSgNnn-o5yaEbRQjaNfBsnT-jIx2aRkbr9a_meOEA6_RXKETPGjNB2nm3gM79m3nczbZ-w_P-KLvBg', 'SM-A566E', '0767645045', 'serviteur_de_dieu', 'Yopougon Ananeraie Mamy Adjoa', NULL, NULL, NULL, NULL, NULL, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/profile-photos/user_3_1765276348.jpg', 'normal', NULL, NULL, '2025-12-09 09:32:28', '2025-12-15 18:20:14'),
(4, 'Kilet Elisée', 'kiletelisee@gmail.com', NULL, '$2y$12$Ej059bOzAxrqwjebn9VjgePARnHkpJqeaGXTYyBvMe.GClVx9VoDW', NULL, NULL, NULL, 'd_fspPqLR0u6DD3ETNZLrg:APA91bFIIqGtOD0obfy2shzaJIfJ-4gdUZtu-Iwe-gi3-Q2n79tA-MwpVaC9Ej_WF-R0alNBNv9Ix_EFc0nkI0Us_OsSU_2s5iaxLxEoJzR8GNX_X_UFL0s', 'SM-A217F', '0779900842', 'serviteur_de_dieu', 'Bingerville', NULL, NULL, NULL, NULL, NULL, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/profile-photos/user_4_1765294898.jpg', 'normal', NULL, NULL, '2025-12-09 14:41:38', '2025-12-09 14:42:09'),
(5, 'raoul gompou', 'raoulgompou77@gmail.com', NULL, '$2y$12$inCqQTOBTCyARJPPcxwVjONsA1/Y2Lwr4mdFz3VnMkm0Cet8Cn5Tu', NULL, NULL, NULL, 'fn45TT_0QVOgq0xzcysK08:APA91bE_yqfp52WLYc0tcYMrcm2chSGGNuCSKIOPHemSTr_Jby9nNO8oB8okdzz4G4b_GY_z63rP7akTIMhqYz3hJZ_3zgWlE0q3kca8lK6AMCe5vujON_8', 'SM-A115M', '0777638112', 'serviteur_de_dieu', 'abidjan', NULL, NULL, 1, 'Xw0BbfQqDCMxdZtLRtGBsWSVx9vst7UVc9ttGwA7ngkvAaZoStFYAPLFj6re', NULL, NULL, 'normal', NULL, NULL, '2025-12-12 12:03:50', '2025-12-14 21:14:39'),
(6, 'Didier', 'didier.gompou@epitech.eu', NULL, '$2y$12$sPiqJ29jvjugYBVuSheS9uyEAU8CCjKqmzjeUkbTQWRIeh4ZJXxtW', NULL, NULL, NULL, 'chVAOejDQ5CxvfCMR9QSBJ:APA91bG0aqEMmMsGGiVdNczbxZhtF0McDES4btEjl1c8wmwVQn0ghtOJQFVCes9LAB6ZCsAfhDfUOIGlbMl6IrijZHr-7Z4rLF3_wEn6Pb4kGhopP9yo8FY', '23117RA68G', '0757567344', 'fidele', 'Cocody', NULL, NULL, 1, NULL, NULL, NULL, 'normal', NULL, NULL, '2025-12-13 17:52:51', '2025-12-13 18:13:52'),
(8, 'ange', 'angepfait@gmail.com', NULL, '$2y$12$VCD7JUfNlj64XDB3OvSWYu.LIk9N/.MhvhpcLn663/a2kkcSKgu6u', NULL, NULL, NULL, 'dpF6gRJITKS0dXF_KR2nbc:APA91bEviVlZUvaTP_tB_3gK4V-IbNKRjJ6c2kF-4PNZKl6mP9OGfm7mlIrcrR_kPC-QZf1uzliSurlLdZ5qLPT2nTsbJTj5_A54w_YoUFSMOSF7yEUd_rA', 'SM-S901U', '0748486558', 'serviteur_de_dieu', 'bingerville', NULL, NULL, NULL, NULL, NULL, 'https://bucketaesd.s3.eu-north-1.amazonaws.com/profile-photos/user_8_1765657140.jpg', 'normal', NULL, NULL, '2025-12-13 19:19:00', '2025-12-13 19:19:18');

-- --------------------------------------------------------

--
-- Table structure for table `users_dons`
--

CREATE TABLE `users_dons` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `reference_paiement` varchar(255) NOT NULL,
  `date_paiement` date NOT NULL,
  `montant_paiement` decimal(10,3) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `don_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_opportunites_jeunes`
--

CREATE TABLE `users_opportunites_jeunes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `cv` varchar(255) NOT NULL,
  `letter` varchar(255) NOT NULL,
  `detail` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `opportunite_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_quizz`
--

CREATE TABLE `users_quizz` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `reponses` varchar(255) NOT NULL,
  `score` varchar(255) DEFAULT NULL,
  `time_remaining` varchar(255) DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `quiz_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_sujets_de_discussion`
--

CREATE TABLE `users_sujets_de_discussion` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `sujet_id` bigint(20) UNSIGNED NOT NULL,
  `comment` text DEFAULT NULL,
  `is_liked` tinyint(1) NOT NULL DEFAULT 0,
  `expert_user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users_sujets_de_discussion`
--

INSERT INTO `users_sujets_de_discussion` (`id`, `user_id`, `sujet_id`, `comment`, `is_liked`, `expert_user_id`, `created_at`, `updated_at`) VALUES
(1, 8, 1, NULL, 0, NULL, '2025-12-15 17:52:42', '2025-12-15 17:52:49'),
(2, 2, 1, 'Salut famille je vais super bien', 1, NULL, '2025-12-15 20:39:17', '2025-12-15 20:39:39');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `actualites`
--
ALTER TABLE `actualites`
  ADD PRIMARY KEY (`id`),
  ADD KEY `actualites_administrateur_id_foreign` (`administrateur_id`);

--
-- Indexes for table `add_photo`
--
ALTER TABLE `add_photo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `add_photo_church_id_foreign` (`church_id`);

--
-- Indexes for table `administrateurs`
--
ALTER TABLE `administrateurs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `administrateurs_id_card_recto_unique` (`id_card_recto`),
  ADD UNIQUE KEY `administrateurs_id_card_verso_unique` (`id_card_verso`),
  ADD KEY `administrateurs_user_id_foreign` (`user_id`);

--
-- Indexes for table `admin_invitations`
--
ALTER TABLE `admin_invitations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admin_invitations_email_unique` (`email`),
  ADD UNIQUE KEY `admin_invitations_token_unique` (`token`),
  ADD KEY `admin_invitations_invited_by_foreign` (`invited_by`);

--
-- Indexes for table `ceremonies`
--
ALTER TABLE `ceremonies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ceremonies_id_eglise_foreign` (`id_eglise`);

--
-- Indexes for table `chantres`
--
ALTER TABLE `chantres`
  ADD PRIMARY KEY (`id`),
  ADD KEY `chantres_user_id_foreign` (`user_id`);

--
-- Indexes for table `churches`
--
ALTER TABLE `churches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `churches_email_unique` (`email`);

--
-- Indexes for table `church_programme`
--
ALTER TABLE `church_programme`
  ADD PRIMARY KEY (`id`),
  ADD KEY `church_programme_church_id_foreign` (`church_id`),
  ADD KEY `church_programme_programme_id_foreign` (`programme_id`);

--
-- Indexes for table `discussion_groups`
--
ALTER TABLE `discussion_groups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `discussion_groups_church_id_foreign` (`church_id`),
  ADD KEY `discussion_groups_admin_id_foreign` (`admin_id`);

--
-- Indexes for table `discussion_groups_users`
--
ALTER TABLE `discussion_groups_users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `discussion_groups_users_user_id_foreign` (`user_id`),
  ADD KEY `discussion_groups_users_discussion_group_id_foreign` (`discussion_group_id`);

--
-- Indexes for table `discussion_messages`
--
ALTER TABLE `discussion_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `discussion_messages_user_id_foreign` (`user_id`),
  ADD KEY `discussion_messages_discussion_group_id_foreign` (`discussion_group_id`);

--
-- Indexes for table `dons`
--
ALTER TABLE `dons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `evenements`
--
ALTER TABLE `evenements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `evenements_eglise_id_foreign` (`eglise_id`);

--
-- Indexes for table `expert_invitations`
--
ALTER TABLE `expert_invitations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `expert_invitations_token_unique` (`token`),
  ADD KEY `expert_invitations_sujet_id_foreign` (`sujet_id`),
  ADD KEY `expert_invitations_sender_id_foreign` (`sender_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `fideles`
--
ALTER TABLE `fideles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fideles_user_id_foreign` (`user_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `opportunites_jeunes`
--
ALTER TABLE `opportunites_jeunes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `opportunites_jeunes_administrateur_id_foreign` (`administrateur_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `postes`
--
ALTER TABLE `postes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `postes_servant_id_foreign` (`servant_id`);

--
-- Indexes for table `postes_users`
--
ALTER TABLE `postes_users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `postes_users_user_id_foreign` (`user_id`),
  ADD KEY `postes_users_post_id_foreign` (`post_id`);

--
-- Indexes for table `programmes`
--
ALTER TABLE `programmes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `propositions_de_reponses`
--
ALTER TABLE `propositions_de_reponses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `propositions_de_reponses_question_id_foreign` (`question_id`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `questions_quizz_id_foreign` (`quizz_id`);

--
-- Indexes for table `quizz`
--
ALTER TABLE `quizz`
  ADD PRIMARY KEY (`id`),
  ADD KEY `quizz_administrateur_id_foreign` (`administrateur_id`);

--
-- Indexes for table `serviteurs_de_dieu`
--
ALTER TABLE `serviteurs_de_dieu`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `serviteurs_de_dieu_id_card_recto_unique` (`id_card_recto`),
  ADD UNIQUE KEY `serviteurs_de_dieu_id_card_verso_unique` (`id_card_verso`),
  ADD KEY `serviteurs_de_dieu_user_id_foreign` (`user_id`);

--
-- Indexes for table `serviteur_user`
--
ALTER TABLE `serviteur_user`
  ADD PRIMARY KEY (`id`),
  ADD KEY `serviteur_user_user_id_foreign` (`user_id`),
  ADD KEY `serviteur_user_serviteur_id_foreign` (`serviteur_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `sujets_de_discussion`
--
ALTER TABLE `sujets_de_discussion`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`id`),
  ADD KEY `teams_user_id_index` (`user_id`);

--
-- Indexes for table `team_invitations`
--
ALTER TABLE `team_invitations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `team_invitations_team_id_email_unique` (`team_id`,`email`);

--
-- Indexes for table `team_user`
--
ALTER TABLE `team_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `team_user_team_id_user_id_unique` (`team_id`,`user_id`);

--
-- Indexes for table `temoignages`
--
ALTER TABLE `temoignages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `temoignages_user_id_foreign` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_profile_photo_unique` (`profile_photo`),
  ADD KEY `users_church_id_foreign` (`church_id`);

--
-- Indexes for table `users_dons`
--
ALTER TABLE `users_dons`
  ADD PRIMARY KEY (`id`),
  ADD KEY `users_dons_user_id_foreign` (`user_id`),
  ADD KEY `users_dons_don_id_foreign` (`don_id`);

--
-- Indexes for table `users_opportunites_jeunes`
--
ALTER TABLE `users_opportunites_jeunes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `users_opportunites_jeunes_user_id_foreign` (`user_id`),
  ADD KEY `users_opportunites_jeunes_opportunite_id_foreign` (`opportunite_id`);

--
-- Indexes for table `users_quizz`
--
ALTER TABLE `users_quizz`
  ADD PRIMARY KEY (`id`),
  ADD KEY `users_quizz_user_id_foreign` (`user_id`),
  ADD KEY `users_quizz_quiz_id_foreign` (`quiz_id`);

--
-- Indexes for table `users_sujets_de_discussion`
--
ALTER TABLE `users_sujets_de_discussion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `users_sujets_de_discussion_user_id_foreign` (`user_id`),
  ADD KEY `users_sujets_de_discussion_sujet_id_foreign` (`sujet_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `actualites`
--
ALTER TABLE `actualites`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `add_photo`
--
ALTER TABLE `add_photo`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `administrateurs`
--
ALTER TABLE `administrateurs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `admin_invitations`
--
ALTER TABLE `admin_invitations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ceremonies`
--
ALTER TABLE `ceremonies`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chantres`
--
ALTER TABLE `chantres`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `churches`
--
ALTER TABLE `churches`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `church_programme`
--
ALTER TABLE `church_programme`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `discussion_groups`
--
ALTER TABLE `discussion_groups`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `discussion_groups_users`
--
ALTER TABLE `discussion_groups_users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `discussion_messages`
--
ALTER TABLE `discussion_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dons`
--
ALTER TABLE `dons`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `evenements`
--
ALTER TABLE `evenements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expert_invitations`
--
ALTER TABLE `expert_invitations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fideles`
--
ALTER TABLE `fideles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `opportunites_jeunes`
--
ALTER TABLE `opportunites_jeunes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `postes`
--
ALTER TABLE `postes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `postes_users`
--
ALTER TABLE `postes_users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `programmes`
--
ALTER TABLE `programmes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `propositions_de_reponses`
--
ALTER TABLE `propositions_de_reponses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `quizz`
--
ALTER TABLE `quizz`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `serviteurs_de_dieu`
--
ALTER TABLE `serviteurs_de_dieu`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `serviteur_user`
--
ALTER TABLE `serviteur_user`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sujets_de_discussion`
--
ALTER TABLE `sujets_de_discussion`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `teams`
--
ALTER TABLE `teams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `team_invitations`
--
ALTER TABLE `team_invitations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `team_user`
--
ALTER TABLE `team_user`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `temoignages`
--
ALTER TABLE `temoignages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users_dons`
--
ALTER TABLE `users_dons`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_opportunites_jeunes`
--
ALTER TABLE `users_opportunites_jeunes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_quizz`
--
ALTER TABLE `users_quizz`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_sujets_de_discussion`
--
ALTER TABLE `users_sujets_de_discussion`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `actualites`
--
ALTER TABLE `actualites`
  ADD CONSTRAINT `actualites_administrateur_id_foreign` FOREIGN KEY (`administrateur_id`) REFERENCES `administrateurs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `add_photo`
--
ALTER TABLE `add_photo`
  ADD CONSTRAINT `add_photo_church_id_foreign` FOREIGN KEY (`church_id`) REFERENCES `churches` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `administrateurs`
--
ALTER TABLE `administrateurs`
  ADD CONSTRAINT `administrateurs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `admin_invitations`
--
ALTER TABLE `admin_invitations`
  ADD CONSTRAINT `admin_invitations_invited_by_foreign` FOREIGN KEY (`invited_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `ceremonies`
--
ALTER TABLE `ceremonies`
  ADD CONSTRAINT `ceremonies_id_eglise_foreign` FOREIGN KEY (`id_eglise`) REFERENCES `churches` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `chantres`
--
ALTER TABLE `chantres`
  ADD CONSTRAINT `chantres_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `church_programme`
--
ALTER TABLE `church_programme`
  ADD CONSTRAINT `church_programme_church_id_foreign` FOREIGN KEY (`church_id`) REFERENCES `churches` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `church_programme_programme_id_foreign` FOREIGN KEY (`programme_id`) REFERENCES `programmes` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `discussion_groups`
--
ALTER TABLE `discussion_groups`
  ADD CONSTRAINT `discussion_groups_admin_id_foreign` FOREIGN KEY (`admin_id`) REFERENCES `serviteurs_de_dieu` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `discussion_groups_church_id_foreign` FOREIGN KEY (`church_id`) REFERENCES `churches` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `discussion_groups_users`
--
ALTER TABLE `discussion_groups_users`
  ADD CONSTRAINT `discussion_groups_users_discussion_group_id_foreign` FOREIGN KEY (`discussion_group_id`) REFERENCES `discussion_groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `discussion_groups_users_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `discussion_messages`
--
ALTER TABLE `discussion_messages`
  ADD CONSTRAINT `discussion_messages_discussion_group_id_foreign` FOREIGN KEY (`discussion_group_id`) REFERENCES `discussion_groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `discussion_messages_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `evenements`
--
ALTER TABLE `evenements`
  ADD CONSTRAINT `evenements_eglise_id_foreign` FOREIGN KEY (`eglise_id`) REFERENCES `churches` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `expert_invitations`
--
ALTER TABLE `expert_invitations`
  ADD CONSTRAINT `expert_invitations_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `expert_invitations_sujet_id_foreign` FOREIGN KEY (`sujet_id`) REFERENCES `sujets_de_discussion` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fideles`
--
ALTER TABLE `fideles`
  ADD CONSTRAINT `fideles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `opportunites_jeunes`
--
ALTER TABLE `opportunites_jeunes`
  ADD CONSTRAINT `opportunites_jeunes_administrateur_id_foreign` FOREIGN KEY (`administrateur_id`) REFERENCES `administrateurs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `postes`
--
ALTER TABLE `postes`
  ADD CONSTRAINT `postes_servant_id_foreign` FOREIGN KEY (`servant_id`) REFERENCES `serviteurs_de_dieu` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `postes_users`
--
ALTER TABLE `postes_users`
  ADD CONSTRAINT `postes_users_post_id_foreign` FOREIGN KEY (`post_id`) REFERENCES `postes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `postes_users_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `propositions_de_reponses`
--
ALTER TABLE `propositions_de_reponses`
  ADD CONSTRAINT `propositions_de_reponses_question_id_foreign` FOREIGN KEY (`question_id`) REFERENCES `questions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `questions_quizz_id_foreign` FOREIGN KEY (`quizz_id`) REFERENCES `quizz` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `quizz`
--
ALTER TABLE `quizz`
  ADD CONSTRAINT `quizz_administrateur_id_foreign` FOREIGN KEY (`administrateur_id`) REFERENCES `administrateurs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `serviteurs_de_dieu`
--
ALTER TABLE `serviteurs_de_dieu`
  ADD CONSTRAINT `serviteurs_de_dieu_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `serviteur_user`
--
ALTER TABLE `serviteur_user`
  ADD CONSTRAINT `serviteur_user_serviteur_id_foreign` FOREIGN KEY (`serviteur_id`) REFERENCES `serviteurs_de_dieu` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `serviteur_user_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `team_invitations`
--
ALTER TABLE `team_invitations`
  ADD CONSTRAINT `team_invitations_team_id_foreign` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `temoignages`
--
ALTER TABLE `temoignages`
  ADD CONSTRAINT `temoignages_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_church_id_foreign` FOREIGN KEY (`church_id`) REFERENCES `churches` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `users_dons`
--
ALTER TABLE `users_dons`
  ADD CONSTRAINT `users_dons_don_id_foreign` FOREIGN KEY (`don_id`) REFERENCES `dons` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `users_dons_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users_opportunites_jeunes`
--
ALTER TABLE `users_opportunites_jeunes`
  ADD CONSTRAINT `users_opportunites_jeunes_opportunite_id_foreign` FOREIGN KEY (`opportunite_id`) REFERENCES `opportunites_jeunes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `users_opportunites_jeunes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users_quizz`
--
ALTER TABLE `users_quizz`
  ADD CONSTRAINT `users_quizz_quiz_id_foreign` FOREIGN KEY (`quiz_id`) REFERENCES `quizz` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `users_quizz_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users_sujets_de_discussion`
--
ALTER TABLE `users_sujets_de_discussion`
  ADD CONSTRAINT `users_sujets_de_discussion_sujet_id_foreign` FOREIGN KEY (`sujet_id`) REFERENCES `sujets_de_discussion` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `users_sujets_de_discussion_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
