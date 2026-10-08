-- ====================================================================
-- DATABASE KASIR TOKO
-- FITUR: Manajemen produk, transaksi, user, supplier, dan laporan
-- BAGIAN 1: MANAJEMEN DATABASE
-- ====================================================================

DROP DATABASE IF EXISTS toko_kasir;

CREATE DATABASE toko_kasir;

USE toko_kasir;

-- ====================================================================
-- BAGIAN 2: MEMBUAT TABEL ROLES
-- ====================================================================

CREATE TABLE Roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    
    role_name VARCHAR(50) UNIQUE NOT NULL,
    
    level INT DEFAULT 1
);

-- ====================================================================
-- BAGIAN 3: MEMBUAT TABEL USERS
-- ====================================================================

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    
    username VARCHAR(50) UNIQUE NOT NULL,
    
    password VARCHAR(255) NOT NULL,
    
    full_name VARCHAR(100) NOT NULL,
    
    role_id INT NOT NULL,
    
    is_active BOOLEAN DEFAULT 1,
    
    last_login DATETIME,
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

-- ====================================================================
-- BAGIAN 4: MEMBUAT TABEL SUPPLIERS
-- ====================================================================

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_code VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ====================================================================
-- BAGIAN 5: MEMBUAT TABEL PRODUCTS
-- ====================================================================

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    barcode VARCHAR(50) UNIQUE,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    min_stock INT DEFAULT 5,
    supplier_id INT,
    created_by INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    FOREIGN KEY (created_by) REFERENCES Users(user_id)
);

-- ====================================================================
-- BAGIAN 6: MEMBUAT TABEL ORDERS
-- ====================================================================

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_no VARCHAR(20) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    customer_name VARCHAR(100) DEFAULT 'Umum',
    subtotal DECIMAL(15,2) NOT NULL,
    discount DECIMAL(15,2) DEFAULT 0,
    tax DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL,
    payment DECIMAL(15,2) NOT NULL,
    change_due DECIMAL(15,2) NOT NULL,
    status ENUM('completed', 'cancelled', 'refund') DEFAULT 'completed',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ====================================================================
-- BAGIAN 7: MEMBUAT TABEL ORDER_ITEMS
-- ====================================================================

CREATE TABLE Order_Items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    qty INT NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- ====================================================================
-- BAGIAN 8: MEMBUAT TABEL ACTIVITY_LOGS
-- ====================================================================

CREATE TABLE Activity_Logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ====================================================================
-- BAGIAN 9: MEMBUAT TRIGGER
-- ====================================================================

DELIMITER //

CREATE TRIGGER trg_reduce_stock
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
    UPDATE Products SET stock = stock - NEW.qty 
    WHERE product_id = NEW.product_id;
END//

CREATE TRIGGER trg_restore_stock
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
       IF NEW.status = 'cancelled' AND OLD.status = 'completed' THEN
        UPDATE Products p
        JOIN Order_Items oi ON p.product_id = oi.product_id
        SET p.stock = p.stock + oi.qty
        WHERE oi.order_id = NEW.order_id;
    END IF;
END//

DELIMITER ;

-- ====================================================================
-- BAGIAN 10: MEMBUAT INDEX 
-- ====================================================================

CREATE INDEX idx_orders_user_id ON Orders(user_id);
CREATE INDEX idx_orders_created_at ON Orders(created_at);
CREATE INDEX idx_products_barcode ON Products(barcode);
CREATE INDEX idx_products_supplier ON Products(supplier_id);
CREATE INDEX idx_order_items_order ON Order_Items(order_id);
CREATE INDEX idx_order_items_product ON Order_Items(product_id);

-- ====================================================================
-- BAGIAN 11: INSERT DATA ROLES
-- ====================================================================

INSERT INTO Roles (role_id, role_name, level) VALUES
(1, 'admin', 5),           -- Admin: akses penuh ke sistem
(2, 'manager', 4),         -- Manager: bisa laporan dan manajemen user
(3, 'senior_cashier', 3),  -- Kasir senior: bisa transaksi dan lihat laporan terbatas
(4, 'junior_cashier', 2),  -- Kasir junior: hanya bisa transaksi
(5, 'owner', 5);           -- Owner: akses penuh seperti admin

-- ====================================================================
-- BAGIAN 12: INSERT DATA USERS
-- ====================================================================

INSERT INTO Users (user_id, username, password, full_name, role_id, is_active) VALUES
(1, 'admin', 'admin123', 'Budi Santoso', 1, 1),
(2, 'kasir_senior', 'senior123', 'Siti Aisyah', 3, 1),
(3, 'kasir_junior', 'junior123', 'Andi Wijaya', 4, 1),
(4, 'manager', 'manager123', 'Dian Permata', 2, 1),
(5, 'owner', 'owner123', 'Hendra Gunawan', 5, 1);

-- ====================================================================
-- BAGIAN 13: INSERT DATA SUPPLIERS
-- ====================================================================

INSERT INTO Suppliers (supplier_code, name, contact_person, phone, email, address) VALUES
('SP001', 'CV. Sumber Makmur', 'Budi Santoso', '081234567890', 'sumbermakmur@email.com', 'Jakarta'),
('SP002', 'PT. Indofood Sukses', 'Ani Wijaya', '081298765432', 'indofood@email.com', 'Surabaya'),
('SP003', 'Toko Aqua Sentosa', 'Cahyo P', '085678901234', 'aqua@email.com', 'Bandung'),
('SP004', 'Distro Roti Sari Roti', 'Dewi Lestari', '087812345678', 'sariroti@email.com', 'Medan');

-- ====================================================================
-- BAGIAN 14: INSERT DATA PRODUCTS
-- ====================================================================

INSERT INTO Products (product_id, barcode, name, price, stock, min_stock, supplier_id, created_by) VALUES
(1, '8991001100010', 'Indomie Goreng', 3500, 150, 10, 2, 1),
(2, '8991001100027', 'Indomie Kuah', 3500, 120, 10, 2, 1),
(3, '8998866201234', 'Aqua 600ml', 4000, 200, 20, 3, 1),
(4, '8998866201241', 'Teh Botol Sosro', 5000, 80, 5, 3, 1),
(5, '8999999123456', 'Pocky Stik', 8000, 45, 5, NULL, 1),
(6, '8991002100033', 'Mie Sedap Goreng', 3200, 100, 10, 2, 1),
(7, '8991002100040', 'Mie Sedap Kuah', 3200, 90, 10, 2, 1),
(8, '8998866201258', 'Fruit Tea', 4500, 60, 5, 3, 1),
(9, '8999999888888', 'Roti Tawar', 12000, 30, 3, 4, 1),
(10, '8991005000010', 'Gula Pasir 1kg', 15000, 50, 5, 1, 1),
(11, '8991006000020', 'Minyak Goreng 1L', 18000, 40, 5, 1, 1),
(12, '8991007000030', 'Telur Ayam 1kg', 28000, 25, 3, 1, 1);

-- ====================================================================
-- BAGIAN 15: INSERT DATA ORDERS
-- ====================================================================

INSERT INTO Orders (order_id, invoice_no, user_id, customer_name, subtotal, discount, tax, total, payment, change_due, status, created_at) VALUES
(1, 'INV-001', 2, 'Budi', 15000, 0, 0, 15000, 20000, 5000, 'completed', '2026-04-26 10:00:00'),
(2, 'INV-002', 3, 'Ani', 19400, 1000, 0, 18400, 20000, 1600, 'completed', '2026-04-26 11:00:00'),
(3, 'INV-003', 2, 'Caca', 33000, 2000, 0, 31000, 50000, 19000, 'completed', '2026-04-27 09:00:00'),
(4, 'INV-004', 3, 'Umum', 8500, 0, 0, 8500, 10000, 1500, 'completed', '2026-04-27 10:00:00'),
(5, 'INV-005', 2, 'Rina', 27000, 0, 0, 27000, 50000, 23000, 'completed', '2026-04-27 13:00:00'),
(6, 'INV-006', 3, 'Joko', 18000, 0, 0, 18000, 20000, 2000, 'completed', '2026-04-27 14:00:00'),
(7, 'INV-007', 2, 'Dewi', 61000, 2000, 0, 59000, 100000, 41000, 'completed', '2026-04-27 16:00:00'),
(8, 'INV-008', 3, 'Tono', 17600, 1000, 0, 16600, 20000, 3400, 'completed', '2026-04-28 08:00:00'),
(9, 'INV-009', 2, 'Sari', 35000, 2000, 0, 33000, 50000, 17000, 'completed', '2026-04-28 10:00:00');

-- ====================================================================
-- BAGIAN 16: INSERT DATA ORDER_ITEMS 
-- ====================================================================

INSERT INTO Order_Items (item_id, order_id, product_id, qty, price, total) VALUES
-- Transaksi INV-001 (order_id=1): 2 Indomie Goreng + 2 Aqua
(1, 1, 1, 2, 3500, 7000),
(2, 1, 3, 2, 4000, 8000),

-- Transaksi INV-002 (order_id=2): 1 Indomie Kuah + 2 Teh Botol + 2 Mie Sedap
(3, 2, 2, 1, 3500, 3500),
(4, 2, 4, 2, 5000, 10000),
(5, 2, 6, 2, 3200, 6400),

-- Transaksi INV-003 (order_id=3): 5 Indomie Goreng + 1 Gula
(6, 3, 1, 5, 3500, 17500),
(7, 3, 10, 1, 15000, 15000),

-- Transaksi INV-004 (order_id=4): 1 Aqua + 1 Fruit Tea
(8, 4, 3, 1, 4000, 4000),
(9, 4, 8, 1, 4500, 4500),

-- Transaksi INV-005 (order_id=5): 2 Indomie + 2 Aqua + 1 Roti
(10, 5, 1, 2, 3500, 7000),
(11, 5, 3, 2, 4000, 8000),
(12, 5, 9, 1, 12000, 12000),

-- Transaksi INV-006 (order_id=6): 1 Indomie Kuah + 2 Teh + 1 Fruit Tea
(13, 6, 2, 1, 3500, 3500),
(14, 6, 4, 2, 5000, 10000),
(15, 6, 8, 1, 4500, 4500),

-- Transaksi INV-007 (order_id=7): 1 Gula + 1 Minyak + 1 Telur
(16, 7, 10, 1, 15000, 15000),
(17, 7, 11, 1, 18000, 18000),
(18, 7, 12, 1, 28000, 28000),

-- Transaksi INV-008 (order_id=8): 2 Mie Sedap + 1 Mie Sedap Kuah + 1 Pocky
(19, 8, 6, 2, 3200, 6400),
(20, 8, 7, 1, 3200, 3200),
(21, 8, 5, 1, 8000, 8000),

-- Transaksi INV-009 (order_id=9): 3 Indomie + 2 Aqua + 1 Roti + 1 Fruit Tea
(22, 9, 1, 3, 3500, 10500),
(23, 9, 3, 2, 4000, 8000),
(24, 9, 9, 1, 12000, 12000),
(25, 9, 8, 1, 4500, 4500);

-- ====================================================================
-- BAGIAN 17: INSERT DATA ACTIVITY_LOGS
-- ====================================================================

INSERT INTO Activity_Logs (user_id, action, description, ip_address) VALUES
(1, 'login', 'Admin login', '192.168.1.10'),
(2, 'add_transaction', 'Transaksi INV-001', '192.168.1.12'),
(3, 'add_transaction', 'Transaksi INV-002', '192.168.1.14');

-- ====================================================================
-- BAGIAN 18: CRUD (CREATE, READ, UPDATE, DELETE)
-- ====================================================================

INSERT INTO Suppliers (supplier_code, name, contact_person, phone, email, address) 
VALUES ('SP005', 'UD. Sumber Rezeki', 'Wahyu Putra', '081377788899', 'sumberrezeki@email.com', 'Semarang');

INSERT INTO Products (barcode, name, price, stock, min_stock, supplier_id, created_by) 
VALUES ('8999999999999', 'Cokelat Batang', 12000, 50, 5, 5, 1);

INSERT INTO Users (username, password, full_name, role_id, is_active) 
VALUES ('kasir_baru', 'baru123', 'Rina Febrianti', 4, 1);

SELECT product_id, name, stock, min_stock, price 
FROM Products 
WHERE stock <= min_stock;

SELECT invoice_no, customer_name, total, created_at 
FROM Orders 
WHERE DATE(created_at) = '2026-04-27';

UPDATE Products SET price = 16000 WHERE product_id = 10;
UPDATE Products SET stock = stock + 10 WHERE product_id = 5;
UPDATE Users SET last_login = NOW() WHERE user_id = 1;

START TRANSACTION;
    INSERT INTO Suppliers (supplier_code, name, phone) VALUES ('SP999', 'Toko Dummy', '08123456789');
    SET @test_id = LAST_INSERT_ID();
    DELETE FROM Suppliers WHERE supplier_id = @test_id;
ROLLBACK;

-- ====================================================================
-- BAGIAN 19: JOIN
-- ====================================================================

SELECT 
    o.invoice_no,
    u.full_name AS cashier,
    o.customer_name,
    o.total,
    o.created_at
FROM Orders o              -- o adalah alias untuk Orders
INNER JOIN Users u ON o.user_id = u.user_id;

SELECT 
    p.product_id,
    p.name AS product_name,
    p.price,
    s.name AS supplier_name,
    CASE 
        WHEN s.supplier_id IS NULL THEN 'Tidak ada supplier'
        ELSE 'Ada supplier'
    END AS status
FROM Products p
LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id;

SELECT 
    s.supplier_code,
    s.name AS supplier_name,
    COUNT(p.product_id) AS total_product,
    
    GROUP_CONCAT(p.name SEPARATOR ', ') AS list_products
    
FROM Products p
RIGHT JOIN Suppliers s ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.supplier_code, s.name;

SELECT 
    o.invoice_no,
    u.full_name AS cashier,
    o.customer_name,
    p.name AS product_name,
    oi.qty,
    oi.price,
    s.name AS supplier_name
FROM Order_Items oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Users u ON o.user_id = u.user_id
JOIN Products p ON oi.product_id = p.product_id
LEFT JOIN Suppliers s ON p.supplier_id = s.supplier_id
LIMIT 10;

SELECT 
    u.user_id,
    u.full_name AS cashier,
    COUNT(o.order_id) AS total_transaksi,
    SUM(o.total) AS total_omzet,
    ROUND(AVG(o.total), 2) AS rata_rata_transaksi,
    MAX(o.total) AS transaksi_terbesar,
    MIN(o.total) AS transaksi_terkecil

FROM Orders o
JOIN Users u ON o.user_id = u.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_omzet DESC;

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.qty) AS total_terjual,
    SUM(oi.total) AS total_penjualan,
    COUNT(DISTINCT oi.order_id) AS jumlah_transaksi
    
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY total_terjual DESC
LIMIT 5;

-- ====================================================================
-- BAGIAN 20: SUBQUERY
-- ====================================================================

SELECT name, price 
FROM Products 
WHERE price > (SELECT AVG(price) FROM Products);
SELECT 
    p.name,
    p.price,
    (SELECT SUM(oi.qty) FROM Order_Items oi WHERE oi.product_id = p.product_id) AS total_terjual
    
FROM Products p
LIMIT 5;

SELECT name, price, stock
FROM Products p
WHERE EXISTS (SELECT 1 FROM Order_Items oi WHERE oi.product_id = p.product_id);

-- ====================================================================
-- BAGIAN 21: QUERY DENGAN CASE
-- ====================================================================

SELECT 
    name,
    stock,
    CASE 
        WHEN stock <= min_stock THEN 'Stok Menipis!'
        WHEN stock <= min_stock * 2 THEN 'Stok Sedang'
        ELSE 'Stok Aman'
    END AS status_stok,
    
    CASE
        WHEN price < 5000 THEN 'Murah'
        WHEN price BETWEEN 5000 AND 15000 THEN 'Sedang'
        ELSE 'Mahal'
    END AS kategori_harga
FROM Products;

-- ====================================================================
-- BAGIAN 22: UNION
-- ====================================================================

SELECT name AS nama, 'Supplier' AS tipe FROM Suppliers
UNION

SELECT full_name AS nama, 'User' AS tipe FROM Users
LIMIT 10;

-- ====================================================================
-- BAGIAN 23: LAPORAN AKHIR
-- ====================================================================

SELECT '========================================' AS 'HASIL DATABASE';
SELECT 'Jumlah Transaksi:' AS 'INFORMASI', COUNT(*) AS 'TOTAL' FROM Orders;
SELECT 'Jumlah Produk:' AS 'INFORMASI', COUNT(*) AS 'TOTAL' FROM Products;
SELECT 'Jumlah User:' AS 'INFORMASI', COUNT(*) AS 'TOTAL' FROM Users;
SELECT 'Jumlah Supplier:' AS 'INFORMASI', COUNT(*) AS 'TOTAL' FROM Suppliers;

SELECT '========================================' AS '';
SELECT '5 Transaksi Terbaru:' AS '';
SELECT order_id, invoice_no, customer_name, total, created_at 
FROM Orders 
ORDER BY order_id DESC 
LIMIT 5;

SELECT '========================================' AS '';
SELECT 'Total Pendapatan:' AS '', SUM(total) AS 'Rp' FROM Orders;

SELECT '========================================' AS '';
SELECT 'DATABASE BERHASIL' AS 'STATUS';
SELECT '========================================' AS '';