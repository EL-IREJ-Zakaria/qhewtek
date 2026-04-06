<?php

declare(strict_types=1);

class Order extends BaseModel
{
    public function getAll(?string $status = null): array
    {
        $sql = 'SELECT o.id, o.table_id, o.status, o.total_price, o.created_at, o.updated_at,
                       t.table_number, t.qr_code
                FROM orders o
                INNER JOIN tables t ON t.id = o.table_id';
        $params = [];

        if ($status !== null && $status !== '') {
            $sql .= ' WHERE o.status = :status';
            $params['status'] = $status;
        }

        $sql .= " ORDER BY FIELD(o.status, 'pending', 'confirmed', 'served'), o.created_at DESC";

        $statement = $this->db->prepare($sql);
        $statement->execute($params);
        return $statement->fetchAll();
    }

    public function find(int $id): ?array
    {
        $statement = $this->db->prepare(
            'SELECT id, table_id, status, total_price, created_at, updated_at
             FROM orders
             WHERE id = :id
             LIMIT 1'
        );
        $statement->execute(['id' => $id]);

        $order = $statement->fetch();
        return $order ?: null;
    }

    public function getItemsForOrderIds(array $orderIds): array
    {
        if ($orderIds === []) {
            return [];
        }

        $placeholders = implode(', ', array_fill(0, count($orderIds), '?'));
        $statement = $this->db->prepare(
            "SELECT oi.id, oi.order_id, oi.menu_item_id, oi.quantity, oi.price,
                    mi.name, mi.category, mi.image
             FROM order_items oi
             LEFT JOIN menu_items mi ON mi.id = oi.menu_item_id
             WHERE oi.order_id IN ($placeholders)
             ORDER BY oi.id ASC"
        );
        $statement->execute(array_values($orderIds));

        return $statement->fetchAll();
    }

    public function createOrder(int $tableId, array $items, array $menuItems): array
    {
        $this->db->beginTransaction();

        try {
            $total = 0.0;
            foreach ($items as $item) {
                $menuItem = $menuItems[(int) $item['menu_item_id']];
                $total += ((float) $menuItem['price']) * (int) $item['quantity'];
            }

            $orderStatement = $this->db->prepare(
                'INSERT INTO orders (table_id, status, total_price)
                 VALUES (:table_id, :status, :total_price)'
            );
            $orderStatement->execute([
                'table_id' => $tableId,
                'status' => 'pending',
                'total_price' => number_format($total, 2, '.', ''),
            ]);

            $orderId = (int) $this->db->lastInsertId();

            $itemStatement = $this->db->prepare(
                'INSERT INTO order_items (order_id, menu_item_id, quantity, price)
                 VALUES (:order_id, :menu_item_id, :quantity, :price)'
            );

            foreach ($items as $item) {
                $menuItem = $menuItems[(int) $item['menu_item_id']];
                $itemStatement->execute([
                    'order_id' => $orderId,
                    'menu_item_id' => (int) $item['menu_item_id'],
                    'quantity' => (int) $item['quantity'],
                    'price' => number_format((float) $menuItem['price'], 2, '.', ''),
                ]);
            }

            $this->db->commit();

            return [
                'order_id' => $orderId,
                'total_price' => number_format($total, 2, '.', ''),
            ];
        } catch (Throwable $exception) {
            $this->db->rollBack();
            throw $exception;
        }
    }

    public function updateStatus(int $orderId, string $status): bool
    {
        $statement = $this->db->prepare(
            'UPDATE orders
             SET status = :status
             WHERE id = :id'
        );

        return $statement->execute([
            'id' => $orderId,
            'status' => $status,
        ]);
    }

    public function countOpenOrdersForTable(int $tableId): int
    {
        $statement = $this->db->prepare(
            "SELECT COUNT(*) AS open_orders
             FROM orders
             WHERE table_id = :table_id
               AND status <> 'served'"
        );
        $statement->execute(['table_id' => $tableId]);

        return (int) $statement->fetchColumn();
    }
}
