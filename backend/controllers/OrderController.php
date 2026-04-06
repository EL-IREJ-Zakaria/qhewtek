<?php

declare(strict_types=1);

class OrderController
{
    private Order $orders;
    private Table $tables;
    private MenuItem $menuItems;
    private array $config;

    public function __construct()
    {
        $this->orders = new Order();
        $this->tables = new Table();
        $this->menuItems = new MenuItem();
        $this->config = require __DIR__ . '/../config/app.php';
    }

    public function index(): never
    {
        $status = trim((string) Request::query('status', ''));
        $orders = $this->orders->getAll($status ?: null);
        $orderIds = array_map(
            static fn (array $order): int => (int) $order['id'],
            $orders
        );
        $itemsByOrder = $this->groupItemsByOrder($this->orders->getItemsForOrderIds($orderIds));

        $payload = array_map(function (array $order) use ($itemsByOrder): array {
            $orderId = (int) $order['id'];

            return [
                'id' => $orderId,
                'table_id' => (int) $order['table_id'],
                'table_number' => (int) $order['table_number'],
                'table_qr_code' => $order['qr_code'],
                'status' => $order['status'],
                'total_price' => (float) $order['total_price'],
                'created_at' => $order['created_at'],
                'updated_at' => $order['updated_at'],
                'items' => $itemsByOrder[$orderId] ?? [],
            ];
        }, $orders);

        Response::success([
            'orders' => $payload,
        ], 'Orders fetched successfully.');
    }

    public function create(): never
    {
        $items = Request::input('items', []);
        if (!is_array($items) || $items === []) {
            Response::error('Order must contain at least one item.', 422);
        }

        $tableId = (int) Request::input('table_id', 0);
        $tableQrCode = trim((string) Request::input('table_qr_code', ''));
        $table = $tableId > 0
            ? $this->tables->findById($tableId)
            : $this->tables->findByQrCode($tableQrCode);

        if ($table === null) {
            Response::error('The selected table could not be found.', 404);
        }

        $sanitizedItems = [];
        $menuItemIds = [];

        foreach ($items as $item) {
            $menuItemId = (int) ($item['menu_item_id'] ?? 0);
            $quantity = (int) ($item['quantity'] ?? 0);

            if ($menuItemId <= 0 || $quantity <= 0) {
                Response::error('Each order item must include a valid menu_item_id and quantity.', 422);
            }

            $sanitizedItems[] = [
                'menu_item_id' => $menuItemId,
                'quantity' => $quantity,
            ];
            $menuItemIds[] = $menuItemId;
        }

        $menuItems = $this->menuItems->findByIds(array_values(array_unique($menuItemIds)));

        foreach ($sanitizedItems as $item) {
            $menuItem = $menuItems[$item['menu_item_id']] ?? null;
            if ($menuItem === null || !(bool) $menuItem['available']) {
                Response::error('One or more selected menu items are unavailable.', 422);
            }
        }

        $created = $this->orders->createOrder((int) $table['id'], $sanitizedItems, $menuItems);
        $this->tables->setStatus((int) $table['id'], 'occupied');

        $order = $this->orders->find($created['order_id']);
        $itemsByOrder = $this->groupItemsByOrder($this->orders->getItemsForOrderIds([$created['order_id']]));

        Response::success([
            'order' => [
                'id' => (int) $created['order_id'],
                'table_id' => (int) $table['id'],
                'table_number' => (int) $table['table_number'],
                'table_qr_code' => $table['qr_code'],
                'status' => $order['status'] ?? 'pending',
                'total_price' => (float) $created['total_price'],
                'created_at' => $order['created_at'] ?? null,
                'items' => $itemsByOrder[(int) $created['order_id']] ?? [],
            ],
        ], 'Order created successfully.', 201);
    }

    public function confirm(): never
    {
        $this->updateOrderStatus('confirmed', 'Order confirmed successfully.');
    }

    public function serve(): never
    {
        $this->updateOrderStatus('served', 'Order marked as served.');
    }

    private function updateOrderStatus(string $status, string $message): never
    {
        $orderId = (int) Request::input('order_id', 0);
        if ($orderId <= 0) {
            Response::error('A valid order_id is required.');
        }

        $order = $this->orders->find($orderId);
        if ($order === null) {
            Response::error('Order not found.', 404);
        }

        $this->orders->updateStatus($orderId, $status);

        if ($status === 'served') {
            $openOrders = $this->orders->countOpenOrdersForTable((int) $order['table_id']);
            if ($openOrders === 0) {
                $this->tables->setStatus((int) $order['table_id'], 'available');
            }
        } else {
            $this->tables->setStatus((int) $order['table_id'], 'occupied');
        }

        Response::success([
            'order_id' => $orderId,
            'status' => $status,
        ], $message);
    }

    private function groupItemsByOrder(array $items): array
    {
        $grouped = [];

        foreach ($items as $item) {
            $orderId = (int) $item['order_id'];
            $grouped[$orderId][] = [
                'id' => (int) $item['id'],
                'menu_item_id' => $item['menu_item_id'] !== null ? (int) $item['menu_item_id'] : null,
                'name' => $item['name'] ?: 'Unavailable item',
                'category' => $item['category'],
                'image' => $item['image'],
                'image_url' => $this->resolveImageUrl($item['image'] ?? null),
                'quantity' => (int) $item['quantity'],
                'price' => (float) $item['price'],
                'subtotal' => (float) $item['price'] * (int) $item['quantity'],
            ];
        }

        return $grouped;
    }

    private function resolveImageUrl(?string $image): ?string
    {
        if ($image === null || trim($image) === '') {
            return null;
        }

        if (str_starts_with($image, 'http://') || str_starts_with($image, 'https://')) {
            return $image;
        }

        return $this->config['app_url'] . '/uploads/menu/' . ltrim($image, '/');
    }
}
