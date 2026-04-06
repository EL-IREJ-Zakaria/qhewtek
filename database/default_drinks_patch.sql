USE coffee_shop_order_management;

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Latte', 'A mellow espresso drink with steamed milk and a silky finish.', 4.70, 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?auto=format&fit=crop&w=900&q=80', 'coffee', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Latte' AND category = 'coffee'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Americano', 'Smooth espresso diluted with hot water for a longer cup.', 3.60, 'https://images.unsplash.com/photo-1497636577773-f1231844b336?auto=format&fit=crop&w=900&q=80', 'coffee', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Americano' AND category = 'coffee'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Green Tea', 'Fresh green tea with light vegetal notes and a clean finish.', 3.10, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=900&q=80', 'tea', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Green Tea' AND category = 'tea'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Black Tea', 'Classic full-bodied black tea served hot.', 3.20, 'https://images.unsplash.com/photo-1594631661960-7f3f5b06b8e8?auto=format&fit=crop&w=900&q=80', 'tea', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Black Tea' AND category = 'tea'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Red Bull', 'Classic chilled energy drink served can-cold.', 4.20, 'https://images.unsplash.com/photo-1622543925917-763c34d1a86e?auto=format&fit=crop&w=900&q=80', 'energy drinks', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Red Bull' AND category = 'energy drinks'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Monster', 'Large-format energy drink with a sweet citrus finish.', 4.60, 'https://images.unsplash.com/photo-1580910051074-3eb694886505?auto=format&fit=crop&w=900&q=80', 'energy drinks', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Monster' AND category = 'energy drinks'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Coca-Cola', 'Ice-cold sparkling cola served by the bottle.', 2.90, 'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?auto=format&fit=crop&w=900&q=80', 'soft drinks', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Coca-Cola' AND category = 'soft drinks'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Pepsi', 'Refreshing sparkling cola served chilled.', 2.90, 'https://images.unsplash.com/photo-1622484212850-eb596d769edc?auto=format&fit=crop&w=900&q=80', 'soft drinks', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Pepsi' AND category = 'soft drinks'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Orange Juice', 'Fresh orange juice with no caffeine.', 3.40, 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=900&q=80', 'juice', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Orange Juice' AND category = 'juice'
);

INSERT INTO menu_items (name, description, price, image, category, available)
SELECT * FROM (
  SELECT 'Apple Juice', 'Pressed apple juice served cold.', 3.20, 'https://images.unsplash.com/photo-1577234286642-fc512a5f8f11?auto=format&fit=crop&w=900&q=80', 'juice', 1
) AS candidate
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items WHERE name = 'Apple Juice' AND category = 'juice'
);
