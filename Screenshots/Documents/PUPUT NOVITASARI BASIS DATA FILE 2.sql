-- =====================================================
-- FILE 2: KONEKSI_2.sql
-- EKSEKUSI DI: JENDELA 2 (KONEKSI 2)
-- =====================================================

USE bioskop;

-- Tambahkan ini untuk memperbaiki Error 1175
SET SQL_SAFE_UPDATES = 0; -- Mematikan mode safe update agar bisa update menggunakan nomor_kursi

-- =====================================================
-- EKSPERIMEN C: CONSISTENCY (LANJUTAN)
-- =====================================================

-- LANGKAH 1: CONSISTENCY - Sesi 2 coba pesan kursi A3
-- ⚡ PILIH KODE DI BAWAH INI, KLIK EXECUTE
-- JALANKAN SETELAH FILE 1 LANGKAH 6

START TRANSACTION; -- Memulai transaksi kedua
SELECT status FROM kursi WHERE nomor_kursi = 'A3' FOR UPDATE; -- Mencoba mengunci baris yang sama dengan Sesi 1 (Akan menunggu/antre)
INSERT INTO pemesanan (id_user, id_film, id_studio, status) VALUES ('jane', 1, 1, 'pending');
SET @id = LAST_INSERT_ID(); -- Mengambil ID pesan untuk Jane
INSERT INTO detail_pemesanan (id_pesan, id_kursi, harga) VALUES (@id, 3, 50000);
COMMIT; -- Menyimpan data jika Sesi 1 sudah melepas kunci
-- HASIL: Data konsisten karena database mengatur antrean akses data yang sama

-- =====================================================
-- EKSPERIMEN I: ISOLATION (LANJUTAN)
-- =====================================================

-- LANGKAH 2: ISOLATION - DIRTY READ (Sesi 2 baca data belum commit)
-- ⚡ PILIH KODE DI BAWAH INI, KLIK EXECUTE
-- JALANKAN SETELAH FILE 1 LANGKAH 8

SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- Mengatur isolasi paling rendah
SELECT status FROM kursi WHERE nomor_kursi = 'A4'; -- Melihat perubahan yang dibuat Sesi 1 meski belum di-COMMIT
-- HASIL: akan terbaca 'dipesan' (DIRTY READ terjadi karena isolasi rendah)

-- LANGKAH 3: ISOLATION - READ COMMITTED (Sesi 2 baca data sudah commit)
-- ⚡ PILIH KODE DI BAWAH INI, KLIK EXECUTE
-- JALANKAN SETELAH FILE 1 LANGKAH 10

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; -- Mengatur agar hanya membaca data yang sudah sah (COMMIT)
SELECT status FROM kursi WHERE nomor_kursi = 'A5'; -- Mengecek kursi A5
-- HASIL: akan terbaca 'tersedia' (DIRTY READ tercegah karena Sesi 1 belum COMMIT)

-- LANGKAH 4: ISOLATION - REPEATABLE READ (Sesi 2 ubah data)
-- ⚡ PILIH KODE DI BAWAH INI, KLIK EXECUTE
-- JALANKAN SETELAH FILE 1 LANGKAH 12

UPDATE kursi SET status = 'dipesan' WHERE nomor_kursi = 'A6'; -- Mengubah status kursi A6 dari sesi ini
COMMIT; -- Simpan perubahan secara permanen
-- HASIL: Meskipun di sini sudah 'dipesan', Sesi 1 tetap melihat 'tersedia' sampai transaksinya selesai

-- =====================================================
-- LANGKAH 5: CEK HASIL AKHIR
-- ⚡ PILIH KODE DI BAWAH INI, KLIK EXECUTE
-- =====================================================

SELECT * FROM pemesanan; -- Melihat semua daftar pemesanan dari semua sesi
SELECT nomor_kursi, status FROM kursi ORDER BY nomor_kursi; -- Melihat status akhir ketersediaan kursi