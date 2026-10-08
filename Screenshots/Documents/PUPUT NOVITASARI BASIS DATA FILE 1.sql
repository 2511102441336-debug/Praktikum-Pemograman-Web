-- =====================================================
-- FILE 1 : KONEKSI_1.sql
-- =====================================================

-- =====================================================
-- LANGKAH 1 : BUAT DATABASE
-- =====================================================

DROP DATABASE IF EXISTS bioskop;

CREATE DATABASE bioskop;

USE bioskop;

-- =====================================================
-- MATIKAN SAFE UPDATE MODE
-- =====================================================

SET SQL_SAFE_UPDATES = 0;

SELECT @@SQL_SAFE_UPDATES;

-- =====================================================
-- TABEL FILM
-- =====================================================

CREATE TABLE film (
    id_film INT PRIMARY KEY AUTO_INCREMENT,
    judul VARCHAR(100) NOT NULL,
    durasi INT NOT NULL,
    harga_tiket DECIMAL(10,2) NOT NULL
);

-- =====================================================
-- TABEL STUDIO
-- =====================================================

CREATE TABLE studio (
    id_studio INT PRIMARY KEY AUTO_INCREMENT,
    nomor_studio VARCHAR(10) NOT NULL,
    kapasitas INT NOT NULL
);

-- =====================================================
-- TABEL KURSI
-- =====================================================

CREATE TABLE kursi (
    id_kursi INT PRIMARY KEY AUTO_INCREMENT,
    nomor_kursi VARCHAR(5) NOT NULL,
    id_studio INT NOT NULL,
    status VARCHAR(20) DEFAULT 'tersedia',

    FOREIGN KEY (id_studio)
    REFERENCES studio(id_studio)
);

-- =====================================================
-- TABEL PEMESANAN
-- =====================================================

CREATE TABLE pemesanan (
    id_pesan INT PRIMARY KEY AUTO_INCREMENT,
    id_user VARCHAR(50) NOT NULL,
    id_film INT NOT NULL,
    id_studio INT NOT NULL,
    tgl_pesan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    total_harga DECIMAL(10,2),

    FOREIGN KEY (id_film)
    REFERENCES film(id_film),

    FOREIGN KEY (id_studio)
    REFERENCES studio(id_studio)
);

-- =====================================================
-- TABEL DETAIL PEMESANAN
-- =====================================================

CREATE TABLE detail_pemesanan (
    id_detail INT PRIMARY KEY AUTO_INCREMENT,
    id_pesan INT NOT NULL,
    id_kursi INT NOT NULL,
    harga DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_pesan)
    REFERENCES pemesanan(id_pesan),

    FOREIGN KEY (id_kursi)
    REFERENCES kursi(id_kursi)
);

-- =====================================================
-- TABEL PEMBAYARAN
-- =====================================================

CREATE TABLE pembayaran (
    id_bayar INT PRIMARY KEY AUTO_INCREMENT,
    id_pesan INT NOT NULL,
    metode VARCHAR(30) NOT NULL,
    jumlah DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    tgl_bayar TIMESTAMP NULL,

    FOREIGN KEY (id_pesan)
    REFERENCES pemesanan(id_pesan)
);

-- =====================================================
-- INSERT DATA FILM
-- =====================================================

INSERT INTO film
(id_film, judul, durasi, harga_tiket)
VALUES
(1, 'Avengers', 181, 50000),
(2, 'Spider-Man', 148, 45000),
(3, 'Oppenheimer', 180, 55000),
(4, 'Barbie', 114, 50000);

-- =====================================================
-- INSERT DATA STUDIO
-- =====================================================

INSERT INTO studio
(id_studio, nomor_studio, kapasitas)
VALUES
(1, 'Studio A', 10);

-- =====================================================
-- INSERT DATA KURSI
-- =====================================================

INSERT INTO kursi
(nomor_kursi, id_studio, status)
VALUES
('A1', 1, 'tersedia'),
('A2', 1, 'tersedia'),
('A3', 1, 'tersedia'),
('A4', 1, 'tersedia'),
('A5', 1, 'tersedia'),
('A6', 1, 'tersedia'),
('A7', 1, 'tersedia'),
('A8', 1, 'tersedia'),
('A9', 1, 'tersedia'),
('A10', 1, 'tersedia');

-- =====================================================
-- LANGKAH 2 : RESET DATA
-- =====================================================

UPDATE kursi
SET status = 'tersedia'
WHERE id_kursi > 0;

DELETE FROM detail_pemesanan;

DELETE FROM pembayaran;

DELETE FROM pemesanan;

ALTER TABLE pemesanan AUTO_INCREMENT = 1;

-- =====================================================
-- EKSPERIMEN A : ATOMICITY
-- =====================================================

-- =====================================================
-- LANGKAH 3 : COMMIT
-- =====================================================

START TRANSACTION;

INSERT INTO pemesanan
(id_user, id_film, id_studio, status)
VALUES
('john', 1, 1, 'pending');

SET @last_id = LAST_INSERT_ID();

INSERT INTO detail_pemesanan
(id_pesan, id_kursi, harga)
VALUES
(@last_id, 1, 50000);

UPDATE kursi
SET status = 'dipesan'
WHERE id_kursi = 1;

UPDATE pemesanan
SET total_harga = 50000
WHERE id_pesan = @last_id;

COMMIT;

-- =====================================================
-- LANGKAH 4 : ROLLBACK
-- =====================================================

START TRANSACTION;

INSERT INTO pemesanan
(id_user, id_film, id_studio, status)
VALUES
('john', 2, 1, 'pending');

SET @last_id = LAST_INSERT_ID();

INSERT INTO detail_pemesanan
(id_pesan, id_kursi, harga)
VALUES
(@last_id, 2, 45000);

UPDATE kursi
SET status = 'dipesan'
WHERE id_kursi = 2;

UPDATE pemesanan
SET total_harga = 45000
WHERE id_pesan = @last_id;

ROLLBACK;

-- =====================================================
-- EKSPERIMEN C : CONSISTENCY
-- =====================================================

-- =====================================================
-- LANGKAH 5 : RESET DATA ULANG
-- =====================================================

UPDATE kursi
SET status = 'tersedia'
WHERE id_kursi > 0;

DELETE FROM detail_pemesanan;

DELETE FROM pembayaran;

DELETE FROM pemesanan;

ALTER TABLE pemesanan AUTO_INCREMENT = 1;

-- =====================================================
-- LANGKAH 6 : CONSISTENCY
-- =====================================================

START TRANSACTION;

SELECT status
FROM kursi
WHERE nomor_kursi = 'A3'
FOR UPDATE;

INSERT INTO pemesanan
(id_user, id_film, id_studio, status)
VALUES
('john', 1, 1, 'pending');

SET @last_id = LAST_INSERT_ID();

INSERT INTO detail_pemesanan
(id_pesan, id_kursi, harga)
VALUES
(@last_id, 3, 50000);

UPDATE kursi
SET status = 'dipesan'
WHERE id_kursi = 3;

-- JANGAN COMMIT DULU

-- =====================================================
-- LANGKAH 7 : COMMIT
-- =====================================================

COMMIT;

-- =====================================================
-- EKSPERIMEN I : ISOLATION
-- =====================================================

-- =====================================================
-- LANGKAH 8 : READ UNCOMMITTED
-- =====================================================

SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

UPDATE kursi
SET status = 'dipesan'
WHERE id_kursi = 4;

-- JANGAN COMMIT DULU

-- =====================================================
-- LANGKAH 9 : ROLLBACK
-- =====================================================

ROLLBACK;

-- =====================================================
-- LANGKAH 10 : READ COMMITTED
-- =====================================================

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

UPDATE kursi
SET status = 'dipesan'
WHERE id_kursi = 5;

-- =====================================================
-- LANGKAH 11 : COMMIT
-- =====================================================

COMMIT;

-- =====================================================
-- LANGKAH 12 : REPEATABLE READ
-- =====================================================

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION;

SELECT status
FROM kursi
WHERE nomor_kursi = 'A6';

-- =====================================================
-- LANGKAH 13 : BACA ULANG
-- =====================================================

SELECT status
FROM kursi
WHERE nomor_kursi = 'A6';

COMMIT;

-- =====================================================
-- EKSPERIMEN D : DURABILITY
-- =====================================================

UPDATE kursi
SET status = 'tersedia'
WHERE id_kursi IN (9,10);

START TRANSACTION;

INSERT INTO pemesanan
(id_user, id_film, id_studio, status, total_harga)
VALUES
('user_dura', 3, 1, 'confirmed', 110000);

SET @last_id = LAST_INSERT_ID();

INSERT INTO detail_pemesanan
(id_pesan, id_kursi, harga)
VALUES
(@last_id, 9, 55000),
(@last_id, 10, 55000);

UPDATE kursi
SET status = 'dibeli'
WHERE id_kursi IN (9,10);

COMMIT;

-- =====================================================
-- CEK ID PEMESANAN
-- =====================================================

SELECT @last_id AS simpan_id_pesanan_ini;

-- =====================================================
-- LANGKAH 15 : CEK HASIL AKHIR
-- =====================================================

SELECT * FROM pemesanan;

SELECT nomor_kursi, status
FROM kursi
ORDER BY nomor_kursi;