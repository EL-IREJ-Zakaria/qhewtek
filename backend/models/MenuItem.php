<?php

declare(strict_types=1);

class MenuItem extends BaseModel
{
    public function getAll(bool $includeUnavailable = false, ?string $category = null, ?string $search = null): array
    {
        $sql = 'SELECT id, name, description, price, image, category, available, created_at, updated_at
                FROM menu_items
                WHERE 1 = 1';
        $params = [];

        if (!$includeUnavailable) {
            $sql .= ' AND available = 1';
        }

        if ($category !== null && $category !== '') {
            $sql .= ' AND category = :category';
            $params['category'] = $category;
        }

        if ($search !== null && $search !== '') {
            $sql .= ' AND (name LIKE :search OR description LIKE :search)';
            $params['search'] = '%' . $search . '%';
        }

        $sql .= ' ORDER BY available DESC, category ASC, name ASC';

        $statement = $this->db->prepare($sql);
        $statement->execute($params);
        return $statement->fetchAll();
    }

    public function find(int $id): ?array
    {
        $statement = $this->db->prepare(
            'SELECT id, name, description, price, image, category, available, created_at, updated_at
             FROM menu_items
             WHERE id = :id
             LIMIT 1'
        );
        $statement->execute(['id' => $id]);

        $item = $statement->fetch();
        return $item ?: null;
    }

    public function findByIds(array $ids): array
    {
        if ($ids === []) {
            return [];
        }

        $placeholders = implode(', ', array_fill(0, count($ids), '?'));
        $statement = $this->db->prepare(
            "SELECT id, name, description, price, image, category, available
             FROM menu_items
             WHERE id IN ($placeholders)"
        );
        $statement->execute(array_values($ids));

        $items = [];
        foreach ($statement->fetchAll() as $item) {
            $items[(int) $item['id']] = $item;
        }

        return $items;
    }

    public function create(array $payload): int
    {
        $statement = $this->db->prepare(
            'INSERT INTO menu_items (name, description, price, image, category, available)
             VALUES (:name, :description, :price, :image, :category, :available)'
        );

        $statement->execute([
            'name' => $payload['name'],
            'description' => $payload['description'],
            'price' => $payload['price'],
            'image' => $payload['image'],
            'category' => $payload['category'],
            'available' => $payload['available'],
        ]);

        return (int) $this->db->lastInsertId();
    }

    public function update(int $id, array $payload): bool
    {
        $statement = $this->db->prepare(
            'UPDATE menu_items
             SET name = :name,
                 description = :description,
                 price = :price,
                 image = :image,
                 category = :category,
                 available = :available
             WHERE id = :id'
        );

        return $statement->execute([
            'id' => $id,
            'name' => $payload['name'],
            'description' => $payload['description'],
            'price' => $payload['price'],
            'image' => $payload['image'],
            'category' => $payload['category'],
            'available' => $payload['available'],
        ]);
    }

    public function softDelete(int $id): bool
    {
        $statement = $this->db->prepare(
            'UPDATE menu_items
             SET available = 0
             WHERE id = :id'
        );

        return $statement->execute(['id' => $id]);
    }
}
