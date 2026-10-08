-- ===================================================================
-- PRAKTIKUM BASIS DATA - MYSQL WORKBENCH
-- STUDI KASUS: SISTEM INFORMASI AKADEMIK KAMPUS
-- ===================================================================
-- Tujuan Praktikum:
-- 1. Mahasiswa mampu mengubah ER Diagram menjadi tabel
-- 2. Mahasiswa mampu membuat skema basis data
-- 3. Mahasiswa mampu merancang skema sesuai kebutuhan sistem
-- ===================================================================

-- ===================================================================
-- BAGIAN 1: MEMBUAT DATABASE DAN TABEL (KONVERSI DARI ERD)
-- ===================================================================

-- 1.1 Membuat database utama
DROP DATABASE IF EXISTS akademik_kampus;
CREATE DATABASE akademik_kampus;
USE akademik_kampus;

-- ===================================================================
-- PENJELASAN ERD YANG DIGUNAKAN:
-- 
-- ENTITAS (TABEL):
-- 1. Mahasiswa (NIM, Nama, Alamat, Telepon, TglLahir)
-- 2. Dosen (ID_Dosen, Nama_Dosen, NIP, Keahlian)
-- 3. MataKuliah (KodeMK, NamaMK, SKS, Semester)
-- 4. Ruang (KodeRuang, NamaRuang, Kapasitas)
-- 5. Kelas (ID_Kelas, TahunAjaran, Periode)
--
-- RELASI:
-- - Mahasiswa mengontrak MataKuliah (many-to-many) via tabel Kontrak
-- - Dosen mengajar MataKuliah (one-to-many)
-- - MataKuliah dilaksanakan di Ruang (one-to-many)
-- - Kelas menampung banyak Mahasiswa (one-to-many)
-- ===================================================================

-- 1.2 Membuat tabel Mahasiswa (Entity)
CREATE TABLE Mahasiswa (
    NIM CHAR(10) PRIMARY KEY COMMENT 'Nomor Induk Mahasiswa, 10 digit',
    Nama VARCHAR(100) NOT NULL COMMENT 'Nama lengkap mahasiswa',
    Alamat TEXT COMMENT 'Alamat tempat tinggal',
    Telepon VARCHAR(15) COMMENT 'Nomor telepon/HP',
    TglLahir DATE COMMENT 'Tanggal lahir format YYYY-MM-DD',
    Email VARCHAR(100) UNIQUE COMMENT 'Email aktif mahasiswa',
    TglMasuk DATE DEFAULT (CURRENT_DATE) COMMENT 'Tanggal pertama kali masuk'
) COMMENT = 'Tabel menyimpan data mahasiswa';

-- 1.3 Membuat tabel Dosen (Entity)
CREATE TABLE Dosen (
    ID_Dosen INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID unik dosen (auto increment)',
    Nama_Dosen VARCHAR(100) NOT NULL COMMENT 'Nama lengkap dosen',
    NIP VARCHAR(20) UNIQUE COMMENT 'Nomor Induk Pegawai, unik',
    Keahlian VARCHAR(100) COMMENT 'Bidang keahlian dosen',
    Telepon VARCHAR(15) COMMENT 'Nomor telepon dosen'
) COMMENT = 'Tabel menyimpan data dosen';

-- 1.4 Membuat tabel MataKuliah (Entity)
CREATE TABLE MataKuliah (
    KodeMK CHAR(6) PRIMARY KEY COMMENT 'Kode mata kuliah, contoh: IF1234',
    NamaMK VARCHAR(100) NOT NULL COMMENT 'Nama mata kuliah',
    SKS INT NOT NULL CHECK (SKS IN (1,2,3,4,6)) COMMENT 'Jumlah SKS (1-6)',
    Semester INT CHECK (Semester BETWEEN 1 AND 8) COMMENT 'Semester minimal 1, maksimal 8',
    ID_Dosen INT COMMENT 'Dosen pengampu mata kuliah',
    FOREIGN KEY (ID_Dosen) REFERENCES Dosen(ID_Dosen) 
        ON DELETE SET NULL ON UPDATE CASCADE
) COMMENT = 'Tabel menyimpan data mata kuliah';

-- 1.5 Membuat tabel Ruang (Entity)
CREATE TABLE Ruang (
    KodeRuang CHAR(5) PRIMARY KEY COMMENT 'Kode ruang, contoh: A101',
    NamaRuang VARCHAR(50) NOT NULL COMMENT 'Nama ruang perkuliahan',
    Kapasitas INT DEFAULT 30 CHECK (Kapasitas > 0) COMMENT 'Kapasitas maksimal mahasiswa',
    Gedung VARCHAR(20) COMMENT 'Lokasi gedung'
) COMMENT = 'Tabel menyimpan data ruang perkuliahan';

-- 1.6 Membuat tabel Kelas (Entity)
CREATE TABLE Kelas (
    ID_Kelas INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID unik kelas',
    NamaKelas VARCHAR(20) NOT NULL COMMENT 'Nama kelas, contoh: IF-A, SI-B',
    TahunAjaran VARCHAR(9) COMMENT 'Format: 2024/2025',
    Periode ENUM('Ganjil', 'Genap') DEFAULT 'Ganjil' COMMENT 'Periode semester',
    Kapasitas INT DEFAULT 40 COMMENT 'Kapasitas maksimal kelas'
) COMMENT = 'Tabel menyimpan data kelas perkuliahan';

-- ===================================================================
-- BAGIAN 2: MEMBUAT TABEL RELASI (MENGHUBUNGKAN ENTITAS)
-- ===================================================================

-- 2.1 Tabel Kontrak (relasi many-to-many antara Mahasiswa dan MataKuliah)
CREATE TABLE Kontrak (
    NIM CHAR(10) COMMENT 'NIM mahasiswa',
    KodeMK CHAR(6) COMMENT 'Kode mata kuliah',
    TahunAjaran VARCHAR(9) COMMENT 'Tahun ajaran kontrak',
    Nilai CHAR(2) COMMENT 'Nilai akhir: A, A-, B+, B, B-, C+, C, D, E',
    Status ENUM('Aktif', 'Lulus', 'Mengulang', 'Drop') DEFAULT 'Aktif',
    PRIMARY KEY (NIM, KodeMK, TahunAjaran),
    FOREIGN KEY (NIM) REFERENCES Mahasiswa(NIM) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (KodeMK) REFERENCES MataKuliah(KodeMK) 
        ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Tabel relasi many-to-many mahasiswa dan mata kuliah';

-- 2.2 Tabel Jadwal (relasi antara MataKuliah, Dosen, Ruang, dan Kelas)
CREATE TABLE Jadwal (
    ID_Jadwal INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID unik jadwal',
    KodeMK CHAR(6) NOT NULL COMMENT 'Mata kuliah yang dijadwalkan',
    ID_Dosen INT COMMENT 'Dosen pengajar (bisa berbeda dari dosen pengampu)',
    KodeRuang CHAR(5) NOT NULL COMMENT 'Ruang perkuliahan',
    ID_Kelas INT NOT NULL COMMENT 'Kelas yang mengambil',
    Hari ENUM('Senin','Selasa','Rabu','Kamis','Jumat','Sabtu') NOT NULL,
    JamMulai TIME NOT NULL COMMENT 'Jam mulai perkuliahan',
    JamSelesai TIME NOT NULL COMMENT 'Jam selesai perkuliahan',
    FOREIGN KEY (KodeMK) REFERENCES MataKuliah(KodeMK) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_Dosen) REFERENCES Dosen(ID_Dosen) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (KodeRuang) REFERENCES Ruang(KodeRuang) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_Kelas) REFERENCES Kelas(ID_Kelas) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- Cek agar jamMulai lebih awal dari jamSelesai
    CHECK (JamMulai < JamSelesai)
) COMMENT = 'Tabel jadwal perkuliahan';

-- 2.3 Tabel Presensi (mencatat kehadiran mahasiswa per pertemuan)
CREATE TABLE Presensi (
    ID_Presensi INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID unik presensi',
    NIM CHAR(10) NOT NULL COMMENT 'Mahasiswa yang hadir',
    ID_Jadwal INT NOT NULL COMMENT 'Jadwal perkuliahan',
    PertemuanKe INT NOT NULL COMMENT 'Pertemuan ke-berapa (1-14)',
    TglPresensi DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Waktu presensi dicatat',
    Status ENUM('Hadir', 'Izin', 'Sakit', 'Alpha', 'Terlambat') NOT NULL DEFAULT 'Alpha',
    Keterangan TEXT COMMENT 'Catatan tambahan',
    UNIQUE KEY unique_presensi (NIM, ID_Jadwal, PertemuanKe),
    FOREIGN KEY (NIM) REFERENCES Mahasiswa(NIM) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_Jadwal) REFERENCES Jadwal(ID_Jadwal) 
        ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Tabel presensi kehadiran mahasiswa';

-- ===================================================================
-- BAGIAN 3: MEMASUKKAN DATA DUMMY (SAMPLE DATA)
-- ===================================================================

-- 3.1 Data Mahasiswa
INSERT INTO Mahasiswa (NIM, Nama, Alamat, Telepon, TglLahir, Email) VALUES
('20230001', 'Andi Wijaya', 'Jl. Merdeka No.1, Jakarta', '081234567891', '2003-05-15', 'andi.wijaya@student.ac.id'),
('20230002', 'Budi Santoso', 'Jl. Diponegoro No.2, Bandung', '081234567892', '2003-08-22', 'budi.santoso@student.ac.id'),
('20230003', 'Citra Dewi', 'Jl. Sudirman No.3, Surabaya', '081234567893', '2004-01-10', 'citra.dewi@student.ac.id'),
('20230004', 'Dian Permata', 'Jl. Ahmad Yani No.4, Medan', '081234567894', '2003-12-05', 'dian.permatas@student.ac.id'),
('20230005', 'Eka Firmansyah', 'Jl. Gatot Subroto No.5, Semarang', '081234567895', '2004-03-18', 'eka.firmansyah@student.ac.id'),
('20230006', 'Fani Nurhaliza', 'Jl. Thamrin No.6, Makassar', '081234567896', '2003-07-25', 'fani.nurhaliza@student.ac.id'),
('20230007', 'Gilang Ramadhan', 'Jl. Kuningan No.7, Yogyakarta', '081234567897', '2004-02-14', 'gilang.ramadhan@student.ac.id'),
('20230008', 'Hana Kartika', 'Jl. Senopati No.8, Bali', '081234567898', '2003-11-30', 'hana.kartika@student.ac.id');

-- 3.2 Data Dosen
INSERT INTO Dosen (Nama_Dosen, NIP, Keahlian, Telepon) VALUES
('Dr. Budi Hartono, M.Kom.', '197001011999031001', 'Basis Data', '08111222333'),
('Prof. Dewi Lestari, Ph.D.', '197505152000122002', 'Kecerdasan Buatan', '08111222334'),
('Ir. Rizki Firmansyah, M.T.', '198003202005011003', 'Jaringan Komputer', '08111222335'),
('Dr. Siti Aisyah, M.Pd.', '197812152008012004', 'Pendidikan Teknik', '08111222336'),
('M. Reza Pahlevi, S.Kom., M.Kom.', '199005102019031007', 'Pemrograman Web', '08111222337');

-- 3.3 Data Mata Kuliah
INSERT INTO MataKuliah (KodeMK, NamaMK, SKS, Semester, ID_Dosen) VALUES
('IF1234', 'Basis Data', 3, 3, 1),
('IF1235', 'Pemrograman Web', 3, 4, 5),
('IF1236', 'Jaringan Komputer', 2, 3, 3),
('IF1237', 'Kecerdasan Buatan', 3, 6, 2),
('IF1238', 'Algoritma Pemrograman', 4, 1, 1),
('IF1239', 'Pemrograman Mobile', 3, 5, 5),
('IF1240', 'Keamanan Komputer', 3, 6, 3),
('SI1234', 'Sistem Informasi Manajemen', 3, 4, 4);

-- 3.4 Data Ruang
INSERT INTO Ruang (KodeRuang, NamaRuang, Kapasitas, Gedung) VALUES
('A101', 'Ruang Aula 1', 100, 'Gedung A'),
('A102', 'Lab Komputer 1', 40, 'Gedung A'),
('B201', 'Ruang Kuliah B2', 50, 'Gedung B'),
('B202', 'Lab Jaringan', 30, 'Gedung B'),
('C301', 'Ruang Seminar', 80, 'Gedung C'),
('C302', 'Lab Mobile', 35, 'Gedung C');

-- 3.5 Data Kelas
INSERT INTO Kelas (NamaKelas, TahunAjaran, Periode, Kapasitas) VALUES
('IF-3A', '2025/2026', 'Ganjil', 40),
('IF-3B', '2025/2026', 'Ganjil', 40),
('IF-4A', '2025/2026', 'Ganjil', 35),
('SI-3A', '2025/2026', 'Ganjil', 38),
('SI-4A', '2025/2026', 'Ganjil', 35);

-- 3.6 Data Kontrak Mahasiswa
INSERT INTO Kontrak (NIM, KodeMK, TahunAjaran, Nilai, Status) VALUES
('20230001', 'IF1234', '2025/2026', 'A', 'Aktif'),
('20230001', 'IF1235', '2025/2026', 'B+', 'Aktif'),
('20230001', 'IF1236', '2025/2026', NULL, 'Aktif'),
('20230002', 'IF1234', '2025/2026', 'A-', 'Aktif'),
('20230002', 'IF1238', '2025/2026', 'B', 'Aktif'),
('20230003', 'IF1234', '2025/2026', 'B+', 'Aktif'),
('20230003', 'IF1236', '2025/2026', NULL, 'Aktif'),
('20230003', 'IF1239', '2025/2026', NULL, 'Aktif'),
('20230004', 'IF1235', '2025/2026', 'C+', 'Mengulang'),
('20230004', 'IF1234', '2025/2026', NULL, 'Aktif'),
('20230005', 'IF1237', '2025/2026', NULL, 'Aktif'),
('20230005', 'IF1234', '2025/2026', 'A', 'Aktif'),
('20230006', 'SI1234', '2025/2026', NULL, 'Aktif'),
('20230007', 'IF1234', '2025/2026', NULL, 'Aktif'),
('20230007', 'IF1236', '2025/2026', NULL, 'Aktif'),
('20230008', 'IF1235', '2025/2026', NULL, 'Aktif');

-- 3.7 Data Jadwal
INSERT INTO Jadwal (KodeMK, ID_Dosen, KodeRuang, ID_Kelas, Hari, JamMulai, JamSelesai) VALUES
('IF1234', 1, 'A102', 1, 'Senin', '08:00:00', '10:30:00'),
('IF1234', 1, 'A102', 2, 'Senin', '10:45:00', '13:15:00'),
('IF1235', 5, 'C302', 1, 'Selasa', '08:00:00', '10:30:00'),
('IF1235', 5, 'C302', 3, 'Selasa', '10:45:00', '13:15:00'),
('IF1236', 3, 'B202', 2, 'Rabu', '08:00:00', '09:40:00'),
('IF1237', 2, 'B201', 3, 'Rabu', '10:00:00', '12:30:00'),
('IF1238', 1, 'A101', 1, 'Kamis', '08:00:00', '11:30:00'),
('IF1239', 5, 'C302', 2, 'Jumat', '08:00:00', '10:30:00'),
('SI1234', 4, 'B201', 4, 'Selasa', '13:00:00', '15:30:00');

-- 3.8 Data Presensi (contoh untuk 3 pertemuan)
INSERT INTO Presensi (NIM, ID_Jadwal, PertemuanKe, TglPresensi, Status) VALUES
-- Jadwal 1 (IF1234 - Kelas IF-3A)
('20230001', 1, 1, '2026-03-10 08:05:00', 'Hadir'),
('20230002', 1, 1, '2026-03-10 08:10:00', 'Hadir'),
('20230003', 1, 1, '2026-03-10 08:00:00', 'Hadir'),
('20230004', 1, 1, '2026-03-10 08:20:00', 'Terlambat'),
('20230005', 1, 1, '2026-03-10 08:00:00', 'Hadir'),
('20230001', 1, 2, '2026-03-17 08:03:00', 'Hadir'),
('20230002', 1, 2, '2026-03-17 08:00:00', 'Hadir'),
('20230003', 1, 2, '2026-03-17 08:15:00', 'Hadir'),
('20230004', 1, 2, '2026-03-17 08:00:00', 'Sakit'),
('20230001', 1, 3, '2026-03-24 08:05:00', 'Hadir'),
('20230002', 1, 3, '2026-03-24 08:00:00', 'Hadir'),
('20230003', 1, 3, '2026-03-24 08:00:00', 'Izin');

-- ===================================================================
-- BAGIAN 4: QUERY JOIN DAN LAPORAN (IMPLEMENTASI SKEMA)
-- ===================================================================

-- 4.1 Laporan: Menampilkan semua mahasiswa dengan mata kuliah yang dikontrak
SELECT 
    m.NIM,
    m.Nama AS Mahasiswa,
    mk.KodeMK,
    mk.NamaMK AS MataKuliah,
    mk.SKS,
    k.Nilai,
    k.Status AS StatusKontrak,
    d.Nama_Dosen AS DosenPengampu
FROM Mahasiswa m
JOIN Kontrak k ON m.NIM = k.NIM
JOIN MataKuliah mk ON k.KodeMK = mk.KodeMK
LEFT JOIN Dosen d ON mk.ID_Dosen = d.ID_Dosen
ORDER BY m.Nama, mk.NamaMK;

-- 4.2 Laporan: Jadwal perkuliahan lengkap
SELECT 
    j.Hari,
    j.JamMulai,
    j.JamSelesai,
    mk.NamaMK AS MataKuliah,
    mk.SKS,
    d.Nama_Dosen AS Dosen,
    r.NamaRuang AS Ruang,
    r.Gedung,
    kls.NamaKelas AS Kelas
FROM Jadwal j
JOIN MataKuliah mk ON j.KodeMK = mk.KodeMK
LEFT JOIN Dosen d ON j.ID_Dosen = d.ID_Dosen
JOIN Ruang r ON j.KodeRuang = r.KodeRuang
JOIN Kelas kls ON j.ID_Kelas = kls.ID_Kelas
ORDER BY FIELD(j.Hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), j.JamMulai;

-- 4.3 Laporan: Rekap Presensi per Mahasiswa
SELECT 
    m.NIM,
    m.Nama AS Mahasiswa,
    mk.NamaMK AS MataKuliah,
    COUNT(p.ID_Presensi) AS Total_Pertemuan,
    SUM(CASE WHEN p.Status = 'Hadir' THEN 1 ELSE 0 END) AS Hadir,
    SUM(CASE WHEN p.Status = 'Izin' THEN 1 ELSE 0 END) AS Izin,
    SUM(CASE WHEN p.Status = 'Sakit' THEN 1 ELSE 0 END) AS Sakit,
    SUM(CASE WHEN p.Status = 'Alpha' THEN 1 ELSE 0 END) AS Alpha,
    SUM(CASE WHEN p.Status = 'Terlambat' THEN 1 ELSE 0 END) AS Terlambat,
    ROUND(SUM(CASE WHEN p.Status = 'Hadir' THEN 1 ELSE 0 END) / COUNT(p.ID_Presensi) * 100, 2) AS PersenKehadiran
FROM Mahasiswa m
JOIN Presensi p ON m.NIM = p.NIM
JOIN Jadwal j ON p.ID_Jadwal = j.ID_Jadwal
JOIN MataKuliah mk ON j.KodeMK = mk.KodeMK
GROUP BY m.NIM, m.Nama, mk.NamaMK
ORDER BY PersenKehadiran DESC;

-- 4.4 Laporan: Statistik Mata Kuliah (jumlah mahasiswa per mata kuliah)
SELECT 
    mk.KodeMK,
    mk.NamaMK,
    mk.SKS,
    d.Nama_Dosen AS DosenPengampu,
    COUNT(DISTINCT k.NIM) AS JmlMahasiswa,
    COUNT(DISTINCT j.ID_Jadwal) AS JmlKelas
FROM MataKuliah mk
LEFT JOIN Kontrak k ON mk.KodeMK = k.KodeMK
LEFT JOIN Dosen d ON mk.ID_Dosen = d.ID_Dosen
LEFT JOIN Jadwal j ON mk.KodeMK = j.KodeMK
GROUP BY mk.KodeMK, mk.NamaMK, mk.SKS, d.Nama_Dosen
ORDER BY JmlMahasiswa DESC;

-- 4.5 Laporan: Rekap nilai per mahasiswa (IP semester)
SELECT 
    m.NIM,
    m.Nama,
    COUNT(k.KodeMK) AS JumlahMK,
    SUM(mk.SKS) AS TotalSKS,
    SUM(CASE 
        WHEN k.Nilai = 'A' THEN mk.SKS * 4.0
        WHEN k.Nilai = 'A-' THEN mk.SKS * 3.7
        WHEN k.Nilai = 'B+' THEN mk.SKS * 3.3
        WHEN k.Nilai = 'B' THEN mk.SKS * 3.0
        WHEN k.Nilai = 'B-' THEN mk.SKS * 2.7
        WHEN k.Nilai = 'C+' THEN mk.SKS * 2.3
        WHEN k.Nilai = 'C' THEN mk.SKS * 2.0
        WHEN k.Nilai = 'D' THEN mk.SKS * 1.0
        WHEN k.Nilai = 'E' THEN mk.SKS * 0.0
        ELSE 0
    END) AS TotalNilai,
    ROUND(SUM(CASE 
        WHEN k.Nilai IN ('A','A-','B+','B','B-','C+','C','D','E') 
        THEN mk.SKS * (
            CASE k.Nilai
                WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
                WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
                WHEN 'C' THEN 2.0 WHEN 'D' THEN 1.0 WHEN 'E' THEN 0.0
            END)
        ELSE 0
    END) / NULLIF(SUM(CASE WHEN k.Nilai IS NOT NULL THEN mk.SKS ELSE 0 END), 0), 2) AS IPS
FROM Mahasiswa m
JOIN Kontrak k ON m.NIM = k.NIM
JOIN MataKuliah mk ON k.KodeMK = mk.KodeMK
WHERE k.Nilai IS NOT NULL
GROUP BY m.NIM, m.Nama
ORDER BY IPS DESC;

-- ===================================================================
-- BAGIAN 5: VIEW (MEMUDAHKAN AKSES DATA)
-- ===================================================================

-- 5.1 View untuk Kartu Rencana Studi (KRS) Mahasiswa
CREATE VIEW v_krs_mahasiswa AS
SELECT 
    m.NIM,
    m.Nama,
    mk.KodeMK,
    mk.NamaMK,
    mk.SKS,
    d.Nama_Dosen AS DosenPengampu,
    j.Hari,
    j.JamMulai,
    j.JamSelesai,
    r.NamaRuang,
    r.Gedung
FROM Mahasiswa m
JOIN Kontrak k ON m.NIM = k.NIM
JOIN MataKuliah mk ON k.KodeMK = mk.KodeMK
LEFT JOIN Dosen d ON mk.ID_Dosen = d.ID_Dosen
LEFT JOIN Jadwal j ON mk.KodeMK = j.KodeMK
LEFT JOIN Ruang r ON j.KodeRuang = r.KodeRuang
WHERE k.Status = 'Aktif'
ORDER BY m.NIM, j.Hari, j.JamMulai;

-- 5.2 View untuk Rekap Presensi per Mata Kuliah
CREATE VIEW v_rekap_presensi_mk AS
SELECT 
    mk.KodeMK,
    mk.NamaMK,
    COUNT(DISTINCT p.NIM) AS TotalMahasiswa,
    COUNT(p.ID_Presensi) AS TotalPresensi,
    SUM(CASE WHEN p.Status = 'Hadir' THEN 1 ELSE 0 END) AS Hadir,
    SUM(CASE WHEN p.Status = 'Izin' THEN 1 ELSE 0 END) AS Izin,
    SUM(CASE WHEN p.Status = 'Sakit' THEN 1 ELSE 0 END) AS Sakit,
    SUM(CASE WHEN p.Status = 'Alpha' THEN 1 ELSE 0 END) AS Alpha,
    ROUND(SUM(CASE WHEN p.Status = 'Hadir' THEN 1 ELSE 0 END) / COUNT(p.ID_Presensi) * 100, 2) AS PersenKehadiran
FROM MataKuliah mk
JOIN Jadwal j ON mk.KodeMK = j.KodeMK
JOIN Presensi p ON j.ID_Jadwal = p.ID_Jadwal
GROUP BY mk.KodeMK, mk.NamaMK;

-- ===================================================================
-- BAGIAN 6: STORED PROCEDURE (UNTUK TUGAS BONUS)
-- ===================================================================

-- 6.1 Procedure untuk menghitung kehadiran mahasiswa
DELIMITER //
CREATE PROCEDURE HitungKehadiranMahasiswa(IN nim_mahasiswa CHAR(10))
BEGIN
    SELECT 
        m.NIM,
        m.Nama,
        mk.NamaMK,
        COUNT(p.ID_Presensi) AS TotalPertemuan,
        SUM(CASE WHEN p.Status = 'Hadir' THEN 1 ELSE 0 END) AS Hadir,
        ROUND(SUM(CASE WHEN p.Status = 'Hadir' THEN 1 ELSE 0 END) / COUNT(p.ID_Presensi) * 100, 2) AS PersenHadir
    FROM Mahasiswa m
    JOIN Presensi p ON m.NIM = p.NIM
    JOIN Jadwal j ON p.ID_Jadwal = j.ID_Jadwal
    JOIN MataKuliah mk ON j.KodeMK = mk.KodeMK
    WHERE m.NIM = nim_mahasiswa
    GROUP BY m.NIM, m.Nama, mk.NamaMK;
END //
DELIMITER ;

-- Contoh pemanggilan procedure:
-- CALL HitungKehadiranMahasiswa('20230001');

-- ===================================================================
-- BAGIAN 7: CEK HASIL (VERIFIKASI DATA)
-- ===================================================================

-- 7.1 Menampilkan semua data dari setiap tabel
SELECT '=== DATA MAHASISWA ===' AS '';
SELECT * FROM Mahasiswa;

SELECT '=== DATA DOSEN ===' AS '';
SELECT * FROM Dosen;

SELECT '=== DATA MATA KULIAH ===' AS '';
SELECT * FROM MataKuliah;

SELECT '=== DATA RUANG ===' AS '';
SELECT * FROM Ruang;

SELECT '=== DATA KELAS ===' AS '';
SELECT * FROM Kelas;

SELECT '=== DATA KONTRAK ===' AS '';
SELECT * FROM Kontrak;

SELECT '=== DATA JADWAL ===' AS '';
SELECT * FROM Jadwal;

SELECT '=== DATA PRESENSI ===' AS '';
SELECT * FROM Presensi;

-- 7.2 Menampilkan View yang sudah dibuat
SELECT '=== VIEW KRS MAHASISWA ===' AS '';
SELECT * FROM v_krs_mahasiswa LIMIT 10;

SELECT '=== VIEW REKAP PRESENSI MK ===' AS '';
SELECT * FROM v_rekap_presensi_mk;