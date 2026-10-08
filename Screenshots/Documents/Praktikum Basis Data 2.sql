-- =========================================================
-- 1. DATABASE UNF (Unnormalized Form)
-- =========================================================
DROP DATABASE IF EXISTS tenaga_kerja_unf;
CREATE DATABASE tenaga_kerja_unf;
USE tenaga_kerja_unf;

CREATE TABLE karyawan_unf (
  id_karyawan VARCHAR(10),
  nama_karyawan VARCHAR(100),
  alamat TEXT,
  id_departemen VARCHAR(10),
  nama_departemen VARCHAR(100),
  lokasi_departemen VARCHAR(100),
  proyek_ikuti VARCHAR(200) 
);

INSERT INTO karyawan_unf VALUES
('K001','Budi Santoso','Jl. Merdeka No.1','D01','HRD','Lantai 2','P001,P002'),
('K002','Siti Aminah','Jl. Sudirman No.5','D02','IT','Lantai 3','P001,P003'),
('K003','Agus Wijaya','Jl. Thamrin No.10','D01','HRD','Lantai 2','P002');


-- =========================================================
-- 2. DATABASE 1NF (First Normal Form)
-- =========================================================
DROP DATABASE IF EXISTS tenaga_kerja_1nf;
CREATE DATABASE tenaga_kerja_1nf;
USE tenaga_kerja_1nf;

CREATE TABLE karyawan_1nf (
  id_karyawan VARCHAR(10),
  nama_karyawan VARCHAR(100),
  alamat TEXT,
  id_departemen VARCHAR(10),
  nama_departemen VARCHAR(100),
  lokasi_departemen VARCHAR(100),
  id_proyek VARCHAR(10),
  PRIMARY KEY (id_karyawan, id_proyek) 
);

INSERT INTO karyawan_1nf VALUES
('K001','Budi Santoso','Jl. Merdeka No.1','D01','HRD','Lantai 2','P001'),
('K001','Budi Santoso','Jl. Merdeka No.1','D01','HRD','Lantai 2','P002'),
('K002','Siti Aminah','Jl. Sudirman No.5','D02','IT','Lantai 3','P001'),
('K002','Siti Aminah','Jl. Sudirman No.5','D02','IT','Lantai 3','P003'),
('K003','Agus Wijaya','Jl. Thamrin No.10','D01','HRD','Lantai 2','P002');


-- =========================================================
-- 3. DATABASE 2NF (Second Normal Form)
-- =========================================================
DROP DATABASE IF EXISTS tenaga_kerja_2nf;
CREATE DATABASE tenaga_kerja_2nf;
USE tenaga_kerja_2nf;

CREATE TABLE departemen (
  id_departemen VARCHAR(10) PRIMARY KEY,
  nama_departemen VARCHAR(100) NOT NULL,
  lokasi_departemen VARCHAR(100)
);

CREATE TABLE karyawan (
  id_karyawan VARCHAR(10) PRIMARY KEY,
  nama_karyawan VARCHAR(100) NOT NULL,
  alamat TEXT,
  id_departemen VARCHAR(10)
);

CREATE TABLE karyawan_proyek (
  id_karyawan VARCHAR(10),
  id_proyek VARCHAR(10),
  PRIMARY KEY (id_karyawan, id_proyek)
);

INSERT INTO departemen VALUES
('D01','HRD','Lantai 2'),
('D02','IT','Lantai 3');

INSERT INTO karyawan VALUES
('K001','Budi Santoso','Jl. Merdeka No.1','D01'),
('K002','Siti Aminah','Jl. Sudirman No.5','D02'),
('K003','Agus Wijaya','Jl. Thamrin No.10','D01');

INSERT INTO karyawan_proyek VALUES
('K001','P001'),
('K001','P002'),
('K002','P001'),
('K002','P003'),
('K003','P002');


-- =========================================================
-- 4. DATABASE 3NF & BCNF
-- =========================================================
DROP DATABASE IF EXISTS tenaga_kerja_3nf_bcnf;
CREATE DATABASE tenaga_kerja_3nf_bcnf;
USE tenaga_kerja_3nf_bcnf;

CREATE TABLE departemen (
  id_departemen VARCHAR(10) PRIMARY KEY,
  nama_departemen VARCHAR(100) NOT NULL UNIQUE,
  lokasi_departemen VARCHAR(100) NOT NULL
);

CREATE TABLE karyawan (
  id_karyawan VARCHAR(10) PRIMARY KEY,
  nama_karyawan VARCHAR(100) NOT NULL,
  alamat TEXT,
  id_departemen VARCHAR(10),
  FOREIGN KEY (id_departemen) REFERENCES departemen(id_departemen)
  ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE proyek (
  id_proyek VARCHAR(10) PRIMARY KEY,
  nama_proyek VARCHAR(100) NOT NULL,
  anggaran DECIMAL(15,2) DEFAULT 0,
  tanggal_mulai DATE,
  tanggal_selesai DATE
);

CREATE TABLE penugasan (
  id_karyawan VARCHAR(10),
  id_proyek VARCHAR(10),
  peran VARCHAR(50),
  jam_kerja INT DEFAULT 0,
  PRIMARY KEY (id_karyawan, id_proyek),
  FOREIGN KEY (id_karyawan) REFERENCES karyawan(id_karyawan)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (id_proyek) REFERENCES proyek(id_proyek)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Input Data 3NF
INSERT INTO departemen VALUES
('D01', 'Sumber Daya Manusia', 'Lantai 2, Gedung A'),
('D02', 'Teknologi Informasi', 'Lantai 3, Gedung A'),
('D03', 'Keuangan', 'Lantai 4, Gedung B'),
('D04', 'Pemasaran', 'Lantai 2, Gedung B');

INSERT INTO karyawan VALUES
('K001', 'Budi Santoso', 'Jl. Merdeka No.1, Jakarta', 'D01'),
('K002', 'Siti Aminah', 'Jl. Sudirman No.5, Jakarta', 'D02'),
('K003', 'Agus Wijaya', 'Jl. Thamrin No.10, Jakarta', 'D01'),
('K004', 'Dewi Lestari', 'Jl. Gatot Subroto No.8, Jakarta', 'D03'),
('K005', 'Rizki Ramadhan', 'Jl. MH Thamrin No.15, Jakarta', 'D02'),
('K006', 'Mega Putri', 'Jl. Rasuna Said No.3, Jakarta', 'D04');

INSERT INTO proyek VALUES
('P001', 'Sistem Informasi Absensi', 750000000, '2024-01-01', '2024-06-30'),
('P002', 'Rekrutasi Massal 2024', 250000000, '2024-02-01', '2024-05-31'),
('P003', 'Migrasi Server Cloud', 1250000000, '2024-03-01', '2024-08-31'),
('P004', 'Digital Marketing Campaign', 500000000, '2024-04-01', '2024-07-31'),
('P005', 'Audit Keuangan Tahunan', 300000000, '2024-05-01', '2024-06-30');

INSERT INTO penugasan VALUES
('K001', 'P001', 'Project Manager', 40),
('K001', 'P002', 'Koordinator HR', 30),
('K002', 'P001', 'Lead Developer', 45),
('K002', 'P003', 'System Architect', 50),
('K003', 'P002', 'Rekrutasi Staff', 35),
('K004', 'P005', 'Auditor', 40),
('K005', 'P003', 'Cloud Engineer', 45),
('K005', 'P001', 'Database Admin', 25),
('K006', 'P004', 'Digital Marketing Specialist', 40);

-- Query Laporan
SELECT
  k.id_karyawan,
  k.nama_karyawan,
  d.nama_departemen AS departemen,
  p.id_proyek,
  p.nama_proyek,
  pg.peran,
  pg.jam_kerja,
  p.anggaran
FROM penugasan pg
JOIN karyawan k ON pg.id_karyawan = k.id_karyawan
JOIN departemen d ON k.id_departemen = d.id_departemen
JOIN proyek p ON pg.id_proyek = p.id_proyek
ORDER BY k.nama_karyawan, p.tanggal_mulai;

SELECT d.nama_departemen, COUNT(k.id_karyawan) AS jumlah_karyawan
FROM departemen d
LEFT JOIN karyawan k ON d.id_departemen = k.id_departemen
GROUP BY d.id_departemen;