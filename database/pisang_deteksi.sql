-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.4.3 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for pisang_deteksi
CREATE DATABASE IF NOT EXISTS `pisang_deteksi` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `pisang_deteksi`;

-- Dumping structure for table pisang_deteksi.penyakit
CREATE TABLE IF NOT EXISTS `penyakit` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `deskripsi` text COLLATE utf8mb4_general_ci,
  `gambar` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `gejala` text COLLATE utf8mb4_general_ci,
  `pencegahan` text COLLATE utf8mb4_general_ci,
  `mengatasi` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `bahaya` text COLLATE utf8mb4_general_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table pisang_deteksi.penyakit: ~5 rows (approximately)
INSERT INTO `penyakit` (`id`, `nama`, `deskripsi`, `gambar`, `gejala`, `pencegahan`, `mengatasi`, `bahaya`, `created_at`) VALUES
	(1, 'Yellow Sigatoka', 'Yellow Siagtoka merupakan penyakit daun pisang yang disebabkan oleh jamur Mycosphaerella musicola. Penyakit ini umumnya berkembang pada kondisi lingkungan yang hangat dan lembab, serta dapat menyebar melalui angin dan percikan air.', '37_aug.jpeg', '- Bercak kuning kecil muncul dipermukaan daun, biasanya berbentuk titik-titik halus.\r\n- Bercak berkembang menjadi garis-garis memanjang bewarna kuning sejajar dengan tulang daun.\r\n- Warna bercak berubah menjadi coklat muda hingga coklat tua, menandakan jaringan daun mulai rusak.\r\n- Bagian tengah bercak dapat menjadi kering dan nekrotik (mati).\r\n- Pada serangan berat, daun tampak menguning luas, mengering, dan akhirnya robek atau mati.\r\n- Daun yang terinfeksi parah akan kehilangan fungsi fotosintesis, sehingga terlihat layu dan tidak segar.', '- Gunakan bibit sehat dan tahan penyakit agar risiko infeksi lebih rendah.\r\n- Atur jarak tanam supaya sirkulasi udara baik dan kelembapan tidak terlalu tinggi.\r\n- Sanitasi kebun dengan membersihkan daun-daun tua atau yang terinfeksi.\r\n- Pemupukan seimbang (terutama kalium) untuk meningkatkan daya tahan tanaman.\r\n- Pengendalian gulma agar tidak menjadi tempat berkembangnya jamur.\r\n- Hindari penyiraman berlebihan yang membuat daun tetap basah dalam waktu lama.', '- Pangkas dan musnahkan daun yang terinfeksi untuk mencegah penyebaran.\r\n- Gunakan fungisida (misalnya berbahan aktif mankozeb atau propikonazol) secara teratur sesuai dosis.\r\n- Terapkan rotasi fungisida agar jamur tidak kebal.\r\n- Tingkatkan drainase lahan untuk mengurangi kelembapan.\r\n- Jika serangan parah, lakukan peremajaan tanaman dengan bibit baru yang sehat.', 'Jika dibiarkan, penyakit ini bisa membuat hasil pisang berkurang banyak (bahkan dapat sampai setengahnya), buah jadi kurang bagus, dan biaya perawatan jadi lebih mahal.', '2026-02-27 05:39:58'),
	(3, 'Pestalotiopsis', 'Pestalotiopsis adalah penyakit daun pisang yang disebabkan oleh jamur dari genus Pestalotiopsis. Penyakit ini umumnya muncul pada kondisi lembab dan dapat menyebabr melalui angin, air, atau alat pertanian yang terkontaminasi.', '3_aug.jpeg', '- Munculnya bercak coklat kecil, lalu meluas disertai klorosis (pemudaan) disekitar bercak, daun mulai menguning, dan fungsi fotosintesis terganggu.\r\n- Bercak bisa menyatu, sehingga membentuk area luas yang kering.\r\n- Daun terlihat kering, rapuh, dan mudah sobek.', '- Gunakan bibit sehat supaya tidak membawa penyakit dari awal.\n- Jangan tanam terlalu rapat agar udara lancar dan daun tidak lembab.\n- Jaga kebersihan kebun dengan membuang daun kering atau yang sakit.\n- Hindari daun terlalu lama basah (misalnya karena penyiraman berlebihan).\n- Rawat tanaman dengan pupuk agar tetap kuat dan tidak mudah terserang penyakit.', '- Potong daun yang sudah terkena penyakit lalu buang atau bakar agar tidak menular.\r\n- Semprot obat jamur (fungisida) yang bisa dibeli di toko pertanian.\r\n- Kurangi kelembapan dengan menjaga jarak tanam atau drainase.\r\n- Periksa tanaman secara rutin supaya penyakit cepat diketahui dan ditangani.', 'Penyakit ini bisa cepat menyebar saat musim hujan atau kebun lembap, menurunkan hasil panen atau memperlambat pertumbuhan tanaman, dan dalam kondisi sangat parah, tanaman bisa mati jika tidak segera ditangani.', '2026-02-27 05:40:44'),
	(4, 'Cordana', 'Cordana adalah penyakit daun pisang yang disebabkan oleh jamur Cordana musae. Serangan Cordana umumnya disebabkan kondisi lingkungan lembab dan basah.', '27_aug.jpeg', '- Muncul bercak kecil bewarna coklat pada daun.\r\n- Bercak berbentuk bulat atau oval dan semakin membesar.\r\n- Bagian tengah bercak biasanya lebih terang (abu-abu) dengan tepi lebih gelap.\r\n- Bercak bisa menyatu sehingga menjadi area luas yang kering.\r\n- Daun terlibat menguning di sekitar bercak.\r\n- Pada serangan parah, daun menjadi kering, robek, dan akhirnya mati.', '- Gunakan bibit yang sehat.\n- Atur jarak tanaman supaya tidak terlalu rapat dan udara bisa mengalir dengan baik.\n- Jaga kebersihan kebun, buang daun kering atau yang sudah sakit.\n- Hindari daun terlalu lama basah, terutama setelah penyiraman atau hujan.\n- Rawat tanaman dengan pupuk agar tetap kuat dan tidak mudah terserang penyakit.', '- Potong daun yang sudah terinfeksi lalu buang atau bakar supaya tidak menular.\r\n- Semprot obat jamur (fungisida) sesuai anjuran dari toko pertanian.\r\n- Kurangi kelembapan dengan memperbaiki drainase dan jarak tanam.\r\n- Cek tanaman secara rutin agar penyakit cepat diketahui dan ditangani.', 'Gangguan daun bisa menurunkan produktivitas, jika banyak daun terkena dan dibiarkan terus-menerus.', '2026-02-27 05:42:19'),
	(5, 'Sehat', 'Daun pisang yang sehat memiliki permukaan yang halus, tidak terdapat bercak, bewarna hijau cerah hingga tua yang merata, tidak mudah robek. Sehingga, daun pisang yang sehat biasanya mampu berfotesintesis dengan baik. \nUntuk menjaga kualitas daun pisang agar tetap sehat, lakukanlah perawatan rutin dan pemupukan yang seimbang.', '20260304_154924.jpg', '-', '-', '-', '-', '2026-05-19 09:20:27'),
	(6, 'no_leaf', '-', NULL, '-', '-', '-', '-', '2026-05-19 09:21:24');

-- Dumping structure for table pisang_deteksi.riwayat_deteksi
CREATE TABLE IF NOT EXISTS `riwayat_deteksi` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `penyakit_id` int DEFAULT NULL,
  `waktu_deteksi` datetime NOT NULL,
  `filename` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `confidence` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `riwayat_deteksi_ibfk_1` (`user_id`),
  KEY `fk_penyakit` (`penyakit_id`),
  CONSTRAINT `fk_penyakit` FOREIGN KEY (`penyakit_id`) REFERENCES `penyakit` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `riwayat_deteksi_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=295 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table pisang_deteksi.riwayat_deteksi: ~15 rows (approximately)
INSERT INTO `riwayat_deteksi` (`id`, `user_id`, `penyakit_id`, `waktu_deteksi`, `filename`, `created_at`, `confidence`) VALUES
	(279, 1, 3, '2026-05-19 21:59:17', 'deteksi_1_1779177557.jpg', '2026-05-19 14:59:17', 0.757993),
	(280, 1, 6, '2026-05-19 22:00:02', 'deteksi_1_1779177602.jpg', '2026-05-19 15:00:02', 0.967139),
	(281, 1, 1, '2026-05-20 21:04:45', 'deteksi_1_1779260685.jpg', '2026-05-20 14:04:45', 0.997638),
	(282, 1, 6, '2026-05-20 21:07:07', 'deteksi_1_1779260827.jpg', '2026-05-20 14:07:07', 0.996971),
	(283, 1, 6, '2026-05-20 22:09:09', 'deteksi_1_1779264549.jpg', '2026-05-20 15:09:09', 0.993806),
	(284, 1, 1, '2026-05-24 13:22:51', 'deteksi_1_1779578571.jpg', '2026-05-24 06:22:51', 0.990392),
	(285, 1, 1, '2026-05-24 14:36:12', 'deteksi_1_1779582972.jpg', '2026-05-24 07:36:12', 0.990392),
	(287, 1, 4, '2026-05-24 14:37:53', 'deteksi_1_1779583073.jpg', '2026-05-24 07:37:53', 0.998875),
	(288, 1, 3, '2026-05-24 14:39:11', 'deteksi_1_1779583151.jpg', '2026-05-24 07:39:11', 0.889039),
	(289, 1, 6, '2026-05-24 14:39:49', 'deteksi_1_1779583188.jpg', '2026-05-24 07:39:49', 0.984389),
	(290, 1, 5, '2026-05-24 14:40:25', 'deteksi_1_1779583225.jpg', '2026-05-24 07:40:25', 0.998535),
	(291, 1, 6, '2026-05-24 14:54:49', 'deteksi_1_1779584088.jpg', '2026-05-24 07:54:49', 0.988181),
	(292, 1, 6, '2026-05-24 14:55:02', 'deteksi_1_1779584102.jpg', '2026-05-24 07:55:02', 0.998295),
	(293, 1, 6, '2026-05-24 14:56:06', 'deteksi_1_1779584166.jpg', '2026-05-24 07:56:06', 0.995251),
	(294, 1, 6, '2026-05-24 14:56:54', 'deteksi_1_1779584214.jpg', '2026-05-24 07:56:54', 0.996392);

-- Dumping structure for table pisang_deteksi.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `no_telepon` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `alamat` text COLLATE utf8mb4_general_ci,
  `foto` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `no_telepon` (`no_telepon`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table pisang_deteksi.users: ~2 rows (approximately)
INSERT INTO `users` (`id`, `nama`, `email`, `no_telepon`, `alamat`, `foto`, `username`, `password`, `created_at`) VALUES
	(1, 'aura zulaikha', 'aura@gmail.com', '081234567890', 'Swiss', 'user_aura_1772646715.jpg', 'aura', '$2b$12$U36S021Jx9PgvotO6hlvMe74nCkYddZw6DbSC8hzQj3snTwWcbW.a', '2026-03-05 00:51:55'),
	(3, 'coba', 'coba@gmail.com', '081123456789', 'Padang', 'user_coba_1776556329.jpg', 'coba', '$2b$12$VhZGw754UrpWDzxr5DmMI.vocHZqE.iQqh56MQ5C./R9QswU8PkXm', '2026-04-19 06:52:09');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
