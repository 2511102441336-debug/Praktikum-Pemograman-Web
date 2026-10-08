-- =============================================
-- DATABASE SISTEM KLINIK
-- =============================================
-- Penjelasan: Script ini membuat database untuk sistem informasi klinik
-- yang menangani data pasien, dokter, jadwal, pemeriksaan, obat, resep,
-- pembayaran, serta riwayat penyakit pasien.
-- =============================================

-- Menghapus database lama jika sudah ada agar tidak terjadi error duplicate
DROP DATABASE IF EXISTS db_klinik;

-- Membuat database baru dengan dukungan karakter bahasa Indonesia
-- Penjelasan: utf8mb4 mendukung semua karakter termasuk emoji, collate untuk pengurutan bahasa Indonesia
CREATE DATABASE db_klinik
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

-- Mengaktifkan / memilih database yang akan digunakan
USE db_klinik;

-- Menonaktifkan SQL mode ONLY_FULL_GROUP_BY untuk menghindari error 1055
-- Penjelasan: Mode ini menyebabkan error ketika SELECT menggunakan kolom yang tidak ada di GROUP BY
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- =============================================
-- 1. TABEL PASIEN
-- =============================================
-- Penjelasan: Tabel ini menyimpan data lengkap pasien yang berobat ke klinik
CREATE TABLE IF NOT EXISTS pasien (
    id_pasien INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID unik pasien, otomatis bertambah',
    no_rm VARCHAR(20) UNIQUE NOT NULL COMMENT 'Nomor Rekam Medis, harus unik',
    nama_pasien VARCHAR(100) NOT NULL COMMENT 'Nama lengkap pasien',
    tanggal_lahir DATE NOT NULL COMMENT 'Tanggal lahir pasien',
    jenis_kelamin ENUM('L', 'P') NOT NULL COMMENT 'Jenis kelamin: L = Laki-laki, P = Perempuan',
    alamat TEXT COMMENT 'Alamat lengkap pasien',
    no_telepon VARCHAR(20) COMMENT 'Nomor telepon / HP pasien',
    email VARCHAR(100) COMMENT 'Alamat email pasien (opsional)',
    golongan_darah VARCHAR(5) COMMENT 'Golongan darah pasien (A, B, AB, O)',
    alergi TEXT COMMENT 'Riwayat alergi pasien (obat/makanan)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Waktu data terakhir diupdate'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tabel data pasien klinik';

-- =============================================
-- 2. TABEL DOKTER
-- =============================================
-- Penjelasan: Tabel ini menyimpan data dokter yang praktik di klinik
CREATE TABLE IF NOT EXISTS dokter (
    id_dokter INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID unik dokter',
    nip VARCHAR(20) UNIQUE NOT NULL COMMENT 'Nomor Induk Pegawai, unik',
    nama_dokter VARCHAR(100) NOT NULL COMMENT 'Nama lengkap dokter',
    spesialisasi VARCHAR(100) NOT NULL COMMENT 'Spesialisasi dokter (Penyakit Dalam, Anak, dll)',
    no_telepon VARCHAR(20) COMMENT 'Nomor telepon dokter',
    email VARCHAR(100) COMMENT 'Alamat email dokter',
    jadwal_kerja TEXT COMMENT 'Deskripsi jadwal kerja dokter',
    status ENUM('Aktif', 'Nonaktif') DEFAULT 'Aktif' COMMENT 'Status keaktifan dokter',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Waktu data diupdate'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tabel data dokter';

-- =============================================
-- 3. TABEL JADWAL
-- =============================================
-- Penjelasan: Tabel ini menyimpan jadwal praktik setiap dokter
CREATE TABLE IF NOT EXISTS jadwal (
    id_jadwal INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID jadwal',
    id_dokter INT NOT NULL COMMENT 'ID dokter (foreign key)',
    hari ENUM('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu') NOT NULL COMMENT 'Hari praktik',
    jam_mulai TIME NOT NULL COMMENT 'Jam mulai praktik',
    jam_selesai TIME NOT NULL COMMENT 'Jam selesai praktik',
    kuota INT DEFAULT 20 COMMENT 'Kuota maksimal pasien per hari',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    -- Relasi ke tabel dokter: jika dokter dihapus, jadwal ikut terhapus
    FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tabel jadwal praktik dokter';

-- =============================================
-- 4. TABEL PEMERIKSAAN
-- =============================================
-- Penjelasan: Tabel ini mencatat setiap kali pasien melakukan pemeriksaan
CREATE TABLE IF NOT EXISTS pemeriksaan (
    id_pemeriksaan INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID pemeriksaan',
    id_pasien INT NOT NULL COMMENT 'ID pasien yang diperiksa',
    id_dokter INT NOT NULL COMMENT 'ID dokter yang memeriksa',
    tanggal_pemeriksaan DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Tanggal dan waktu pemeriksaan',
    keluhan TEXT COMMENT 'Keluhan yang disampaikan pasien',
    diagnosis TEXT COMMENT 'Diagnosis dokter berdasarkan pemeriksaan',
    tindakan TEXT COMMENT 'Tindakan medis yang dilakukan',
    biaya_konsultasi DECIMAL(12,2) DEFAULT 0.00 COMMENT 'Biaya konsultasi/jasa dokter',
    status ENUM('Menunggu', 'Selesai', 'Batal') DEFAULT 'Menunggu' COMMENT 'Status pemeriksaan',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Waktu data diupdate',
    -- RESTRICT: tidak boleh hapus pasien/dokter yang memiliki pemeriksaan
    FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tabel data pemeriksaan';

-- =============================================
-- 5. TABEL RIWAYAT PENYAKIT PASIEN
-- =============================================
-- Penjelasan: Tabel untuk mencatat penyakit pasien, dokter yang menangani, dan jadwal konsultasi
CREATE TABLE IF NOT EXISTS riwayat_penyakit (
    id_riwayat INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID riwayat penyakit',
    id_pasien INT NOT NULL COMMENT 'ID pasien yang memiliki riwayat',
    id_dokter INT NOT NULL COMMENT 'ID dokter yang menangani',
    nama_penyakit VARCHAR(150) NOT NULL COMMENT 'Nama penyakit / diagnosis',
    tanggal_konsultasi DATE NOT NULL COMMENT 'Tanggal konsultasi pasien',
    hari ENUM('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu') NOT NULL COMMENT 'Hari konsultasi',
    jam_konsultasi TIME NOT NULL COMMENT 'Jam konsultasi',
    keterangan TEXT COMMENT 'Keterangan tambahan (gejala, catatan khusus)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Waktu data diupdate',
    -- CASCADE: jika pasien dihapus, riwayat penyakit ikut terhapus
    FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien) ON DELETE CASCADE ON UPDATE CASCADE,
    -- RESTRICT: tidak bisa hapus dokter yang memiliki riwayat
    FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Riwayat penyakit pasien beserta jadwal konsultasi';

-- =============================================
-- 6. TABEL REFERENSI PENYAKIT & SPESIALIS DOKTER
-- =============================================
-- Penjelasan: Tabel ini berfungsi sebagai knowledge base untuk merekomendasikan
-- dokter spesialis yang tepat berdasarkan jenis penyakit pasien
CREATE TABLE IF NOT EXISTS ref_penyakit_spesialis (
    id_penyakit INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID penyakit referensi',
    nama_penyakit VARCHAR(150) NOT NULL UNIQUE COMMENT 'Nama penyakit yang terdaftar (unik)',
    spesialisasi_yang_direkomendasikan VARCHAR(100) NOT NULL COMMENT 'Spesialisasi dokter yang seharusnya menangani',
    tingkat_urjensi ENUM('Ringan', 'Sedang', 'Darurat') DEFAULT 'Ringan' COMMENT 'Tingkat kegawatan penyakit',
    deskripsi TEXT COMMENT 'Deskripsi dan informasi penyakit',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Referensi penyakit dan rekomendasi dokter spesialis';

-- =============================================
-- 7. TABEL OBAT
-- =============================================
-- Penjelasan: Tabel ini menyimpan data master obat-obatan di apotek klinik
CREATE TABLE IF NOT EXISTS obat (
    id_obat INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID obat',
    kode_obat VARCHAR(20) UNIQUE NOT NULL COMMENT 'Kode unik obat',
    nama_obat VARCHAR(150) NOT NULL COMMENT 'Nama obat (generik/brand)',
    satuan ENUM('Tablet','Kapsul','Strip','Botol','Tube','Ampul','Lainnya') NOT NULL COMMENT 'Satuan obat',
    stok INT DEFAULT 0 COMMENT 'Jumlah stok obat tersedia',
    harga DECIMAL(12,2) NOT NULL COMMENT 'Harga obat per satuan',
    expired_date DATE COMMENT 'Tanggal kadaluarsa obat',
    deskripsi TEXT COMMENT 'Deskripsi obat (indikasi, efek samping)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Waktu data diupdate'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tabel master obat';

-- =============================================
-- 8. TABEL RESEP
-- =============================================
-- Penjelasan: Tabel ini mencatat resep obat yang diberikan dokter ke pasien
CREATE TABLE IF NOT EXISTS resep (
    id_resep INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID resep',
    id_pemeriksaan INT NOT NULL COMMENT 'ID pemeriksaan yang menghasilkan resep',
    tanggal_resep DATE DEFAULT (CURDATE()) COMMENT 'Tanggal pembuatan resep',
    catatan_dokter TEXT COMMENT 'Catatan dari dokter untuk pasien',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    -- CASCADE: jika pemeriksaan dihapus, resep ikut terhapus
    FOREIGN KEY (id_pemeriksaan) REFERENCES pemeriksaan(id_pemeriksaan) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tabel resep obat';

-- =============================================
-- 9. TABEL DETAIL RESEP
-- =============================================
-- Penjelasan: Tabel ini menyimpan detail item obat dalam setiap resep
CREATE TABLE IF NOT EXISTS resep_detail (
    id_resep_detail INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID detail resep',
    id_resep INT NOT NULL COMMENT 'ID resep induk',
    id_obat INT NOT NULL COMMENT 'ID obat yang diresepkan',
    jumlah INT NOT NULL COMMENT 'Jumlah obat yang diresepkan',
    aturan_pakai VARCHAR(100) NOT NULL COMMENT 'Aturan pakai (contoh: 3x1 setelah makan)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    -- CASCADE: jika resep dihapus, detail resep ikut terhapus
    FOREIGN KEY (id_resep) REFERENCES resep(id_resep) ON DELETE CASCADE ON UPDATE CASCADE,
    -- RESTRICT: tidak bisa hapus obat yang sedang diresepkan
    FOREIGN KEY (id_obat) REFERENCES obat(id_obat) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Detail item obat dalam resep';

-- =============================================
-- 10. TABEL PEMBAYARAN
-- =============================================
-- Penjelasan: Tabel ini mencatat transaksi pembayaran pasien
CREATE TABLE IF NOT EXISTS pembayaran (
    id_pembayaran INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID pembayaran',
    id_pemeriksaan INT NOT NULL COMMENT 'ID pemeriksaan yang dibayar',
    total_konsultasi DECIMAL(12,2) NOT NULL COMMENT 'Total biaya konsultasi',
    total_obat DECIMAL(12,2) DEFAULT 0.00 COMMENT 'Total biaya obat',
    total_bayar DECIMAL(12,2) NOT NULL COMMENT 'Total keseluruhan yang dibayar',
    metode_pembayaran ENUM('Tunai','Transfer','BPJS','Asuransi','Lainnya') NOT NULL COMMENT 'Metode pembayaran',
    status_pembayaran ENUM('Belum Lunas','Lunas','Batal') DEFAULT 'Belum Lunas' COMMENT 'Status pembayaran',
    tanggal_bayar DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Tanggal dan waktu pembayaran',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu data dibuat',
    -- RESTRICT: tidak bisa hapus pemeriksaan yang sudah dibayar
    FOREIGN KEY (id_pemeriksaan) REFERENCES pemeriksaan(id_pemeriksaan) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tabel transaksi pembayaran';

-- =============================================
-- INDEX (Mempercepat pencarian data)
-- =============================================
-- Penjelasan: Index membantu mempercepat query pencarian (SELECT) pada kolom tertentu
CREATE INDEX idx_no_rm ON pasien(no_rm);                    -- Index untuk pencarian nomor RM
CREATE INDEX idx_nama_pasien ON pasien(nama_pasien);        -- Index untuk pencarian nama pasien
CREATE INDEX idx_nama_dokter ON dokter(nama_dokter);        -- Index untuk pencarian nama dokter
CREATE INDEX idx_nama_penyakit ON riwayat_penyakit(nama_penyakit); -- Index untuk pencarian penyakit

-- =============================================
-- TRIGGER KURANGI STOK OBAT
-- =============================================
-- Penjelasan: Trigger ini berjalan otomatis setelah data dimasukkan ke resep_detail
-- Fungsinya: Mengurangi stok obat sesuai dengan jumlah yang diresepkan

DELIMITER //

CREATE TRIGGER trg_kurangi_stok
AFTER INSERT ON resep_detail          -- Trigger berjalan SETELAH data ditambahkan ke resep_detail
FOR EACH ROW                          -- Untuk setiap baris data yang ditambahkan
BEGIN
    -- Mengurangi stok obat secara otomatis
    -- Kondisi "AND stok >= NEW.jumlah" memastikan stok mencukupi
    UPDATE obat
    SET stok = stok - NEW.jumlah      -- Kurangi stok dengan jumlah yang diresepkan
    WHERE id_obat = NEW.id_obat       -- Cari obat yang sesuai
      AND stok >= NEW.jumlah;         -- Pastikan stok cukup
END //

DELIMITER ;

-- =============================================
-- DATA CONTOH (SAMPLE DATA)
-- =============================================
-- Penjelasan: Data contoh untuk menguji fungsionalitas database
-- INSERT IGNORE digunakan untuk mencegah error duplicate jika dijalankan ulang

-- 1. Data Dokter (3 dokter dengan spesialisasi berbeda)
INSERT IGNORE INTO dokter (nip, nama_dokter, spesialisasi, no_telepon, status) VALUES
('DOK001', 'Dr. Ahmad Santoso, Sp.PD', 'Penyakit Dalam', '081234567890', 'Aktif'),
('DOK002', 'Dr. Siti Nurhaliza, Sp.OG', 'Kandungan & Kebidanan', '081298765432', 'Aktif'),
('DOK003', 'Dr. Budi Prasetyo, Sp.A', 'Anak', '085712345678', 'Aktif');

-- 2. Data Pasien (3 pasien dengan nomor RM berbeda)
INSERT IGNORE INTO pasien (no_rm, nama_pasien, tanggal_lahir, jenis_kelamin, alamat, no_telepon) VALUES
('RM2026001', 'Rina Wijaya', '1995-03-15', 'P', 'Jl. Mangga No.45, Samarinda', '082345678901'),
('RM2026002', 'Andi Saputra', '1988-11-20', 'L', 'Jl. Pramuka No.12, Samarinda', '081987654321'),
('RM2026003', 'Siti Aminah', '2002-07-10', 'P', 'Jl. Slamet Riyadi No.78, Samarinda', '085678901234');

-- 3. Data Jadwal Dokter (setiap dokter memiliki jadwal praktik)
INSERT IGNORE INTO jadwal (id_dokter, hari, jam_mulai, jam_selesai, kuota) VALUES
(1, 'Senin', '08:00:00', '12:00:00', 25),   -- dr. Ahmad praktik Senin pagi
(1, 'Rabu', '08:00:00', '12:00:00', 20),    -- dr. Ahmad praktik Rabu pagi
(2, 'Selasa', '09:00:00', '14:00:00', 20),  -- dr. Siti praktik Selasa
(3, 'Kamis', '08:30:00', '13:00:00', 15);   -- dr. Budi praktik Kamis

-- 4. Data Referensi Penyakit & Spesialis
-- Penjelasan: Data ini menghubungkan jenis penyakit dengan spesialisasi dokter yang tepat
INSERT IGNORE INTO ref_penyakit_spesialis (nama_penyakit, spesialisasi_yang_direkomendasikan, tingkat_urjensi, deskripsi) VALUES
('ISPA', 'Penyakit Dalam', 'Ringan', 'Infeksi Saluran Pernapasan Akut'),
('ISPA Berat', 'Penyakit Dalam', 'Sedang', 'Infeksi Saluran Pernapasan dengan komplikasi'),
('Kehamilan normal', 'Kandungan & Kebidanan', 'Ringan', 'Pemeriksaan kehamilan rutin'),
('Demam dan Diare', 'Anak', 'Ringan', 'Gangguan pencernaan pada anak'),
('Hipertensi', 'Penyakit Dalam', 'Sedang', 'Tekanan darah tinggi'),
('Diabetes Melitus', 'Penyakit Dalam', 'Sedang', 'Kencing manis / gula darah tinggi');

-- 5. Data Riwayat Penyakit Pasien
-- Penjelasan: Mencatat penyakit yang pernah diderita pasien beserta dokter yang menangani
INSERT IGNORE INTO riwayat_penyakit (id_pasien, id_dokter, nama_penyakit, tanggal_konsultasi, hari, jam_konsultasi, keterangan) VALUES
(1, 1, 'ISPA Berat', '2026-05-20', 'Rabu', '09:00:00', 'Batuk dan demam tinggi, sudah 3 hari'),
(2, 2, 'Kehamilan normal', '2026-05-22', 'Selasa', '10:30:00', 'Kontrol rutin kehamilan bulan ke-4'),
(3, 3, 'Demam dan Diare', '2026-05-25', 'Kamis', '08:45:00', 'Anak usia 5 tahun dengan diare cair');

-- 6. Data Obat (master obat-obatan)
INSERT IGNORE INTO obat (kode_obat, nama_obat, satuan, stok, harga, expired_date) VALUES
('OBT001', 'Paracetamol 500mg', 'Strip', 450, 7500, '2027-12-31'),
('OBT002', 'Amoxicillin 500mg', 'Strip', 320, 12500, '2026-10-15'),
('OBT003', 'Omeprazole 20mg', 'Strip', 280, 9800, '2027-06-30'),
('OBT004', 'Cetirizine 10mg', 'Strip', 200, 6500, '2026-11-20');

-- 7. Data Pemeriksaan
INSERT IGNORE INTO pemeriksaan (id_pasien, id_dokter, keluhan, diagnosis, tindakan, biaya_konsultasi, status) VALUES
(1, 1, 'Demam dan batuk selama 3 hari', 'ISPA Berat', 'Pemberian obat dan istirahat', 50000, 'Selesai'),
(2, 2, 'Pemeriksaan kehamilan rutin', 'Kehamilan normal', 'USG dan suplemen', 150000, 'Selesai');

-- 8. Data Resep
INSERT IGNORE INTO resep (id_pemeriksaan, catatan_dokter) VALUES
(1, 'Minum obat setelah makan, perbanyak istirahat dan minum air putih'),
(2, 'Kontrol ulang 2 minggu lagi, konsumsi suplemen teratur');

-- 9. Data Detail Resep
INSERT IGNORE INTO resep_detail (id_resep, id_obat, jumlah, aturan_pakai) VALUES
(1, 1, 10, '3x1 setelah makan'),   -- Paracetamol untuk pasien 1
(1, 2, 15, '2x1 selama 5 hari'),  -- Amoxicillin untuk pasien 1
(2, 4, 10, '1x1 malam hari');     -- Cetirizine untuk pasien 2

-- 10. Data Pembayaran
INSERT IGNORE INTO pembayaran (id_pemeriksaan, total_konsultasi, total_obat, total_bayar, metode_pembayaran, status_pembayaran) VALUES
(1, 50000, 45000, 95000, 'Tunai', 'Lunas'),
(2, 150000, 65000, 215000, 'Transfer', 'Lunas');

-- =============================================
-- STORED PROCEDURE: REKOMENDASI DOKTER BERDASARKAN PENYAKIT
-- =============================================
-- Penjelasan: Prosedur ini digunakan untuk mencari rekomendasi dokter
-- berdasarkan nama penyakit yang dimasukkan oleh pengguna.
-- Cara penggunaan: CALL rekomendasi_dokter_untuk_penyakit('nama_penyakit');

-- =============================================
-- STORED PROCEDURE REKOMENDASI DOKTER\
-- =============================================

DELIMITER //

CREATE PROCEDURE rekomendasi_dokter_untuk_penyakit(
    IN p_nama_penyakit VARCHAR(150)
)
BEGIN
    SELECT 
        rps.nama_penyakit AS Penyakit,
        rps.spesialisasi_yang_direkomendasikan AS Spesialisasi_Dibutuhkan,
        rps.tingkat_urjensi AS Tingkat_Kegawatan,
        rps.deskripsi AS Deskripsi_Penyakit,
        d.id_dokter AS ID_Dokter,
        COALESCE(d.nama_dokter, 'TIDAK ADA DOKTER TERSEDIA') AS Nama_Dokter_Tersedia,
        COALESCE(d.no_telepon, '-') AS No_Telepon_Dokter,
        COALESCE(d.status, 'Tidak Tersedia') AS Status_Dokter,
        j.hari AS Jadwal_Hari,
        TIME_FORMAT(j.jam_mulai, '%H:%i') AS Jam_Mulai,
        TIME_FORMAT(j.jam_selesai, '%H:%i') AS Jam_Selesai,
        COALESCE(j.kuota, 0) AS Kuota_Tersedia
    FROM ref_penyakit_spesialis rps
    LEFT JOIN dokter d ON d.spesialisasi = rps.spesialisasi_yang_direkomendasikan 
        AND d.status = 'Aktif'
    LEFT JOIN jadwal j ON d.id_dokter = j.id_dokter
    WHERE rps.nama_penyakit = p_nama_penyakit;
END //

DELIMITER ;


-- =============================================
-- VIEW: LAPORAN PENYAKIT PASIEN
-- =============================================
-- Penjelasan: View ini menampilkan laporan lengkap riwayat penyakit pasien
-- beserta evaluasi apakah dokter yang menangani sudah sesuai spesialisasinya

CREATE OR REPLACE VIEW v_laporan_penyakit_pasien AS
SELECT 
    rp.id_riwayat,                                              -- ID riwayat penyakit
    p.no_rm,                                                    -- Nomor Rekam Medis pasien
    p.nama_pasien,                                              -- Nama pasien
    p.jenis_kelamin,                                            -- Jenis kelamin pasien
    TIMESTAMPDIFF(YEAR, p.tanggal_lahir, CURDATE()) AS usia,    -- Menghitung usia pasien
    rp.nama_penyakit,                                           -- Nama penyakit
    rps.spesialisasi_yang_direkomendasikan AS spesialisasi_dibutuhkan, -- Spesialisasi yang dibutuhkan
    rps.tingkat_urjensi,                                        -- Tingkat urgensi penyakit
    d.nama_dokter AS dokter_penanganan,                         -- Dokter yang menangani
    d.spesialisasi AS spesialisasi_dokter,                      -- Spesialisasi dokter yang menangani
    rp.tanggal_konsultasi,                                      -- Tanggal konsultasi
    rp.hari,                                                    -- Hari konsultasi
    TIME_FORMAT(rp.jam_konsultasi, '%H:%i') AS jam_konsultasi,  -- Jam konsultasi
    -- Evaluasi: apakah dokter yang menangani sudah sesuai?
    CASE 
        WHEN d.spesialisasi = rps.spesialisasi_yang_direkomendasikan THEN 'Penanganan Tepat'
        ELSE 'Penanganan Tidak Tepat'
    END AS evaluasi_penanganan
FROM riwayat_penyakit rp
JOIN pasien p ON rp.id_pasien = p.id_pasien
JOIN ref_penyakit_spesialis rps ON rp.nama_penyakit = rps.nama_penyakit
JOIN dokter d ON rp.id_dokter = d.id_dokter;

-- =============================================
-- OUTPUT / HASIL QUERY (RESULT GRID)
-- =============================================

-- RESULT 1: JADWAL DOKTER
-- Penjelasan: Menampilkan jadwal praktik semua dokter yang aktif
SELECT
    d.nama_dokter AS Nama_Dokter,
    j.hari,
    TIME_FORMAT(j.jam_mulai, '%H:%i') AS Jam_Mulai,
    TIME_FORMAT(j.jam_selesai, '%H:%i') AS Jam_Selesai,
    j.kuota AS Kuota_Pasien,
    d.spesialisasi AS Spesialisasi
FROM dokter d
JOIN jadwal j ON d.id_dokter = j.id_dokter
WHERE d.status = 'Aktif'
ORDER BY FIELD(j.hari, 'Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'), j.jam_mulai;

-- RESULT 2: DAFTAR PASIEN
-- Penjelasan: Menampilkan semua data pasien yang terdaftar
SELECT
    no_rm AS Nomor_RM,
    nama_pasien AS Nama_Pasien,
    tanggal_lahir AS Tanggal_Lahir,
    TIMESTAMPDIFF(YEAR, tanggal_lahir, CURDATE()) AS Usia,
    jenis_kelamin AS JK,
    no_telepon AS No_HP
FROM pasien
ORDER BY nama_pasien;

-- RESULT 3: RIWAYAT PENYAKIT DENGAN REKOMENDASI DOKTER
-- Penjelasan: Menampilkan riwayat penyakit pasien dan mengevaluasi kesesuaian dokter
SELECT 
    p.nama_pasien AS Nama_Pasien,
    p.no_rm AS Nomor_RM,
    rp.nama_penyakit AS Penyakit,
    rps.spesialisasi_yang_direkomendasikan AS Spesialisasi_Dibutuhkan,
    rps.tingkat_urjensi AS Tingkat_Urgensi,
    d.nama_dokter AS Dokter_Penanganan,
    CASE 
        WHEN d.spesialisasi = rps.spesialisasi_yang_direkomendasikan THEN '✓ SESUAI'
        ELSE '✗ TIDAK SESUAI'
    END AS Evaluasi,
    DATE_FORMAT(rp.tanggal_konsultasi, '%d-%m-%Y') AS Tanggal_Konsultasi
FROM riwayat_penyakit rp
JOIN pasien p ON rp.id_pasien = p.id_pasien
JOIN ref_penyakit_spesialis rps ON rp.nama_penyakit = rps.nama_penyakit
JOIN dokter d ON rp.id_dokter = d.id_dokter
ORDER BY rp.tanggal_konsultasi DESC;

-- RESULT 4: REKOMENDASI DOKTER PER JENIS PENYAKIT
-- Penjelasan: Menampilkan dokter yang tersedia untuk setiap jenis penyakit
SELECT 
    rps.nama_penyakit AS Penyakit,
    rps.spesialisasi_yang_direkomendasikan AS Spesialisasi_Dibutuhkan,
    rps.tingkat_urjensi AS Urgensi,
    COALESCE(d.nama_dokter, 'TIDAK ADA DOKTER') AS Dokter_Tersedia,
    COALESCE(d.no_telepon, '-') AS Kontak,
    CASE 
        WHEN d.id_dokter IS NOT NULL THEN 'Tersedia'
        ELSE 'Tidak Tersedia'
    END AS Ketersediaan
FROM ref_penyakit_spesialis rps
LEFT JOIN dokter d ON d.spesialisasi = rps.spesialisasi_yang_direkomendasikan AND d.status = 'Aktif'
ORDER BY FIELD(rps.tingkat_urjensi, 'Darurat', 'Sedang', 'Ringan'), rps.nama_penyakit;

-- RESULT 5: STATISTIK PENANGANAN PENYAKIT
-- Penjelasan: Menghitung persentase pasien yang ditangani oleh dokter yang tepat
SELECT 
    COUNT(*) AS Total_Riwayat,
    SUM(CASE WHEN d.spesialisasi = rps.spesialisasi_yang_direkomendasikan THEN 1 ELSE 0 END) AS Penanganan_Sesuai,
    SUM(CASE WHEN d.spesialisasi != rps.spesialisasi_yang_direkomendasikan THEN 1 ELSE 0 END) AS Penanganan_Tidak_Sesuai,
    CONCAT(
        ROUND(
            100.0 * SUM(CASE WHEN d.spesialisasi = rps.spesialisasi_yang_direkomendasikan THEN 1 ELSE 0 END) / COUNT(*), 
            2
        ), '%'
    ) AS Persentase_Kesesuaian
FROM riwayat_penyakit rp
JOIN ref_penyakit_spesialis rps ON rp.nama_penyakit = rps.nama_penyakit
JOIN dokter d ON rp.id_dokter = d.id_dokter;

-- RESULT 6: LAPORAN DARI VIEW
-- Penjelasan: Menampilkan data dari view v_laporan_penyakit_pasien
SELECT * FROM v_laporan_penyakit_pasien ORDER BY tanggal_konsultasi DESC;

-- RESULT 7: REKOMENDASI DOKTER UNTUK PENYAKIT ISPA
-- Penjelasan: Memanggil stored procedure untuk penyakit ISPA
CALL rekomendasi_dokter_untuk_penyakit('ISPA');

-- RESULT 8: REKOMENDASI DOKTER UNTUK PENYAKIT DEMAM DAN DIARE
CALL rekomendasi_dokter_untuk_penyakit('Demam dan Diare');

-- RESULT 9: REKOMENDASI DOKTER UNTUK PENYAKIT KEHAMILAN NORMAL
CALL rekomendasi_dokter_untuk_penyakit('Kehamilan normal');

-- RESULT 10: JUMLAH DATA PER TABEL
-- Penjelasan: Menampilkan jumlah total data di setiap tabel
SELECT
    (SELECT COUNT(*) FROM pasien) AS Jumlah_Pasien,
    (SELECT COUNT(*) FROM dokter) AS Jumlah_Dokter,
    (SELECT COUNT(*) FROM jadwal) AS Jumlah_Jadwal,
    (SELECT COUNT(*) FROM pemeriksaan) AS Jumlah_Pemeriksaan,
    (SELECT COUNT(*) FROM riwayat_penyakit) AS Jumlah_Riwayat_Penyakit,
    (SELECT COUNT(*) FROM ref_penyakit_spesialis) AS Jumlah_Referensi_Penyakit,
    (SELECT COUNT(*) FROM obat) AS Jumlah_Obat,
    (SELECT COUNT(*) FROM pembayaran) AS Jumlah_Pembayaran;

-- =============================================
-- PESAN SELESAI
-- =============================================