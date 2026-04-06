<?php

declare(strict_types=1);

class Table extends BaseModel
{
    public function findByQrCode(string $qrCode): ?array
    {
        $statement = $this->db->prepare(
            'SELECT id, table_number, qr_code, status
             FROM tables
             WHERE qr_code = :qr_code
             LIMIT 1'
        );
        $statement->execute(['qr_code' => $qrCode]);

        $table = $statement->fetch();
        return $table ?: null;
    }

    public function findById(int $id): ?array
    {
        $statement = $this->db->prepare(
            'SELECT id, table_number, qr_code, status
             FROM tables
             WHERE id = :id
             LIMIT 1'
        );
        $statement->execute(['id' => $id]);

        $table = $statement->fetch();
        return $table ?: null;
    }

    public function setStatus(int $id, string $status): void
    {
        $statement = $this->db->prepare(
            'UPDATE tables
             SET status = :status
             WHERE id = :id'
        );
        $statement->execute([
            'status' => $status,
            'id' => $id,
        ]);
    }
}
