DROP DATABASE IF EXISTS coffee_shop_order_management;
CREATE DATABASE coffee_shop_order_management
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE coffee_shop_order_management;

CREATE TABLE tables (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  table_number INT UNSIGNED NOT NULL,
  qr_code VARCHAR(100) NOT NULL,
  status ENUM('available', 'occupied', 'reserved') NOT NULL DEFAULT 'available',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tables_table_number (table_number),
  UNIQUE KEY uq_tables_qr_code (qr_code)
);

CREATE TABLE menu_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  price DECIMAL(10, 2) NOT NULL,
  image VARCHAR(255) NULL,
  category VARCHAR(100) NOT NULL,
  available TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_menu_category (category),
  KEY idx_menu_available (available)
);

CREATE TABLE orders (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  table_id INT UNSIGNED NOT NULL,
  status ENUM('pending', 'confirmed', 'served') NOT NULL DEFAULT 'pending',
  total_price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_table
    FOREIGN KEY (table_id) REFERENCES tables(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  KEY idx_orders_status (status),
  KEY idx_orders_table_created (table_id, created_at)
);

CREATE TABLE order_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id INT UNSIGNED NOT NULL,
  menu_item_id INT UNSIGNED NULL,
  quantity INT UNSIGNED NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_order_items_menu_item
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  KEY idx_order_items_order (order_id)
);

INSERT INTO tables (table_number, qr_code, status) VALUES
  (1, 'TABLE-01', 'available'),
  (2, 'TABLE-02', 'available'),
  (3, 'TABLE-03', 'available'),
  (4, 'TABLE-04', 'available'),
  (5, 'TABLE-05', 'available'),
  (6, 'TABLE-06', 'available'),
  (7, 'TABLE-07', 'available'),
  (8, 'TABLE-08', 'available'),
  (9, 'TABLE-09', 'available'),
  (10, 'TABLE-10', 'available');

INSERT INTO menu_items (name, description, price, image, category, available) VALUES
  ('Espresso', 'A bold single-shot espresso with a deep crema finish.', 2.80, 'https://images.unsplash.com/photo-1510707577719-ae7c14805e18?auto=format&fit=crop&w=900&q=80', 'coffee', 1),
  ('Cappuccino', 'Velvety milk foam layered over rich espresso and steamed milk.', 4.50, 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=900&q=80', 'coffee', 1),
  ('Latte', 'A mellow espresso drink with steamed milk and a silky finish.', 4.70, 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?auto=format&fit=crop&w=900&q=80', 'coffee', 1),
  ('Americano', 'Smooth espresso diluted with hot water for a longer cup.', 3.60, 'https://images.unsplash.com/photo-1497636577773-f1231844b336?auto=format&fit=crop&w=900&q=80', 'coffee', 1),
  ('Iced Latte', 'A chilled espresso latte served over ice with creamy whole milk.', 4.90, 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=900&q=80', 'drinks', 1),
  ('Green Tea', 'Fresh green tea with light vegetal notes and a clean finish.', 3.10, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=900&q=80', 'tea', 1),
  ('Black Tea', 'Classic full-bodied black tea served hot.', 3.20, 'https://images.unsplash.com/photo-1594631661960-7f3f5b06b8e8?auto=format&fit=crop&w=900&q=80', 'tea', 1),
  ('Matcha Tonic', 'Sparkling tonic layered with ceremonial matcha for a bright finish.', 5.40, 'https://images.unsplash.com/photo-1515823662972-da6a2e4d3002?auto=format&fit=crop&w=900&q=80', 'drinks', 1),
  ('Red Bull', 'Classic chilled energy drink served can-cold.', 4.20, 'https://images.unsplash.com/photo-1622543925917-763c34d1a86e?auto=format&fit=crop&w=900&q=80', 'energy drinks', 1),
  ('Monster', 'Large-format energy drink with a sweet citrus finish.', 4.60, 'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=900&q=80', 'energy drinks', 1),
  ('Coca-Cola', 'Ice-cold sparkling cola served by the bottle.', 2.90, 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?auto=format&fit=crop&w=900&q=80', 'soft drinks', 1),
  ('Pepsi', 'Refreshing sparkling cola served chilled.', 2.90, 'https://images.unsplash.com/photo-1622484212850-eb596d769edc?auto=format&fit=crop&w=900&q=80', 'soft drinks', 1),
  ('Orange Juice', 'Fresh orange juice with no caffeine.', 3.40, 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=900&q=80', 'juice', 1),
  ('Apple Juice', 'Pressed apple juice served cold.', 3.20, 'https://images.unsplash.com/photo-1577234286642-fc512a5f8f11?auto=format&fit=crop&w=900&q=80', 'juice', 1),
  ('Blueberry Cheesecake', 'Creamy baked cheesecake topped with slow-cooked blueberries.', 6.20, 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=900&q=80', 'desserts', 1),
  ('Chocolate Croissant', 'Buttery laminated pastry filled with dark chocolate.', 3.70, 'https://images.unsplash.com/photo-1549903072-7e6e0bedb7fb?auto=format&fit=crop&w=900&q=80', 'desserts', 1),
  ('Cold Brew', 'Slow-steeped cold brew with smooth body and chocolate notes.', 4.20, 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=900&q=80', 'coffee', 1),
  ('Sparkling Citrus', 'House sparkling citrus cooler with mint and orange zest.', 4.10, 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=900&q=80', 'drinks', 1);
