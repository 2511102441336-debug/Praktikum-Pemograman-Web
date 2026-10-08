CREATE DATABASE db_krs_2511102441336;
USE db_krs_2511102441336;
CREATE TABLE mahasiswa (
    nim VARCHAR(15) PRIMARY KEY,
    nama VARCHAR(50),
    prodi VARCHAR(50)
);

INSERT INTO mahasiswa VALUES 
('2511102441336', 'Puput Novitasari', 'Informatika');
CREATE TABLE mata_kuliah (
    kode_mk VARCHAR(10) PRIMARY KEY,
    nama_mk VARCHAR(50),
    sks INT
);

INSERT INTO mata_kuliah VALUES
('MK001', 'Basis Data', 3),
('MK002', 'Pemrograman', 4),
('MK003', 'Jaringan Komputer', 3),
('MK004', 'Sistem Operasi', 3),
('MK005', 'Algoritma', 3);
CREATE TABLE krs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nim VARCHAR(15),
    kode_mk VARCHAR(10),
    FOREIGN KEY (nim) REFERENCES mahasiswa(nim),
    FOREIGN KEY (kode_mk) REFERENCES mata_kuliah(kode_mk)
);

-- Ambil 3 mata kuliah
INSERT INTO krs (nim, kode_mk) VALUES
('2511102441336', 'MK001'),
('2511102441336', 'MK002'),
('2511102441336', 'MK003');
SELECT m.nim, m.nama, mk.nama_mk, mk.sks
FROM krs k
JOIN mahasiswa m ON k.nim = m.nim
JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk;
SELECT m.nim, m.nama, SUM(mk.sks) AS total_sks
FROM krs k
JOIN mahasiswa m ON k.nim = m.nim
JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
GROUP BY m.nim, m.nama;
DELETE FROM krs 
WHERE kode_mk = 'MK003' 
AND nim = '2511102441336';
SELECT m.nim, m.nama, mk.nama_mk, mk.sks
FROM krs k
JOIN mahasiswa m ON k.nim = m.nim
JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk;


