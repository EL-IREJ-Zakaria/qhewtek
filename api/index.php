<?php

declare(strict_types=1);

ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

set_error_handler(static function (int $severity, string $message, string $file = '', int $line = 0): bool {
    if (!(error_reporting() & $severity)) {
        return false;
    }

    throw new ErrorException($message, 0, $severity, $file, $line);
});

final class HttpException extends RuntimeException
{
    public function __construct(
        private readonly int $statusCode,
        string $message,
        private readonly ?string $debugFile = null,
        private readonly ?int $debugLine = null,
        ?Throwable $previous = null
    ) {
        parent::__construct($message, 0, $previous);
    }

    public function statusCode(): int
    {
        return $this->statusCode;
    }

    public function debugFile(): string
    {
        return $this->debugFile ?? $this->getFile();
    }

    public function debugLine(): int
    {
        return $this->debugLine ?? $this->getLine();
    }
}

try {
    handleRequest();
} catch (Throwable $exception) {
    $statusCode = $exception instanceof HttpException ? $exception->statusCode() : 500;
    $file = $exception instanceof HttpException ? $exception->debugFile() : $exception->getFile();
    $line = $exception instanceof HttpException ? $exception->debugLine() : $exception->getLine();

    jsonResponse($statusCode, [
        'success' => false,
        'message' => $exception->getMessage(),
        'file' => $file,
        'line' => $line,
    ]);
}

function handleRequest(): never
{
    $method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
    $path = normalizePath(resolveRequestPath());

    if ($method === 'OPTIONS') {
        jsonResponse(200, [
            'success' => true,
            'data' => [],
        ]);
    }

    switch ($path) {
        case '/api/menu':
        case '/menu':
            if ($method !== 'GET') {
                throw new HttpException(405, sprintf('Method %s is not allowed for %s.', $method, $path));
            }

            jsonResponse(200, [
                'success' => true,
                'data' => fetchMenuItems(connectDatabase()),
            ]);

        case '/api/orders':
        case '/orders':
            if ($method !== 'GET') {
                throw new HttpException(405, sprintf('Method %s is not allowed for %s.', $method, $path));
            }

            jsonResponse(200, [
                'success' => true,
                'data' => fetchOrders(connectDatabase()),
            ]);

        default:
            if (shouldForwardToLegacyBackend($method, $path)) {
                forwardToLegacyBackend();
            }

            throw new HttpException(404, sprintf('Route not found: %s', $path));
    }
}

function resolveRequestPath(): string
{
    $candidates = [
        $_SERVER['REQUEST_URI'] ?? null,
        $_SERVER['REDIRECT_URL'] ?? null,
        $_SERVER['PATH_INFO'] ?? null,
        $_SERVER['ORIG_PATH_INFO'] ?? null,
        $_SERVER['UNENCODED_URL'] ?? null,
        $_SERVER['HTTP_X_ORIGINAL_URL'] ?? null,
        $_SERVER['HTTP_X_REWRITE_URL'] ?? null,
    ];

    foreach ($candidates as $candidate) {
        if (!is_string($candidate) || trim($candidate) === '') {
            continue;
        }

        $path = parse_url($candidate, PHP_URL_PATH);
        if (is_string($path) && $path !== '') {
            return $path;
        }
    }

    return '/';
}

function normalizePath(string $path): string
{
    $path = '/' . ltrim($path, '/');
    $path = preg_replace('#/+#', '/', $path) ?? $path;
    $path = str_replace('/index.php', '', $path);
    $path = rtrim($path, '/');

    return $path === '' ? '/' : $path;
}

function connectDatabase(): PDO
{
    $config = databaseConfig();
    $dsn = sprintf(
        'mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
        $config['host'],
        $config['port'],
        $config['name']
    );

    try {
        return new PDO(
            $dsn,
            $config['user'],
            $config['pass'],
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::ATTR_TIMEOUT => 10,
            ]
        );
    } catch (PDOException $exception) {
        throw new HttpException(
            500,
            'Database connection failed: ' . $exception->getMessage(),
            $exception->getFile(),
            $exception->getLine(),
            $exception
        );
    }
}

function databaseConfig(): array
{
    $requiredVariables = [
        'DB_HOST' => false,
        'DB_PORT' => false,
        'DB_NAME' => false,
        'DB_USER' => false,
        'DB_PASS' => true,
    ];

    $missing = [];
    $values = [];

    foreach ($requiredVariables as $name => $allowEmpty) {
        $value = getenv($name);

        if ($value === false || (!$allowEmpty && trim((string) $value) === '')) {
            $missing[] = $name;
            continue;
        }

        $values[$name] = (string) $value;
    }

    if ($missing !== []) {
        throw new HttpException(
            500,
            'Missing database environment variable(s): ' . implode(', ', $missing)
        );
    }

    if (!ctype_digit($values['DB_PORT'])) {
        throw new HttpException(500, 'DB_PORT must be a valid integer.');
    }

    return [
        'host' => $values['DB_HOST'],
        'port' => (int) $values['DB_PORT'],
        'name' => $values['DB_NAME'],
        'user' => $values['DB_USER'],
        'pass' => $values['DB_PASS'],
    ];
}

function fetchMenuItems(PDO $pdo): array
{
    $includeUnavailable = filter_var(
        $_GET['include_unavailable'] ?? false,
        FILTER_VALIDATE_BOOL,
        FILTER_NULL_ON_FAILURE
    ) ?? false;
    $category = trim((string) ($_GET['category'] ?? ''));
    $search = trim((string) ($_GET['search'] ?? ''));

    $sql = 'SELECT id, name, description, price, image, category, available, created_at, updated_at
            FROM menu_items';
    $conditions = [];
    $params = [];

    if (!$includeUnavailable) {
        $conditions[] = 'available = 1';
    }

    if ($category !== '') {
        $conditions[] = 'category = :category';
        $params['category'] = $category;
    }

    if ($search !== '') {
        $conditions[] = '(name LIKE :search OR description LIKE :search)';
        $params['search'] = '%' . $search . '%';
    }

    if ($conditions !== []) {
        $sql .= ' WHERE ' . implode(' AND ', $conditions);
    }

    $sql .= ' ORDER BY available DESC, category ASC, name ASC';

    $statement = $pdo->prepare($sql);
    $statement->execute($params);

    return array_map(static function (array $item): array {
        return [
            'id' => (int) $item['id'],
            'name' => $item['name'],
            'description' => $item['description'],
            'price' => (float) $item['price'],
            'image' => $item['image'],
            'image_url' => resolveImageUrl($item['image'] ?? null),
            'category' => $item['category'],
            'available' => (bool) $item['available'],
            'created_at' => $item['created_at'],
            'updated_at' => $item['updated_at'],
        ];
    }, $statement->fetchAll());
}

function fetchOrders(PDO $pdo): array
{
    $status = trim((string) ($_GET['status'] ?? ''));
    $sql = 'SELECT o.id, o.table_id, o.status, o.total_price, o.created_at, o.updated_at,
                   t.table_number, t.qr_code
            FROM orders o
            LEFT JOIN tables t ON t.id = o.table_id';
    $params = [];

    if ($status !== '') {
        $sql .= ' WHERE o.status = :status';
        $params['status'] = $status;
    }

    $sql .= " ORDER BY FIELD(o.status, 'pending', 'confirmed', 'served'), o.created_at DESC, o.id DESC";

    $statement = $pdo->prepare($sql);
    $statement->execute($params);

    $orders = $statement->fetchAll();
    $orderIds = array_map(static fn (array $order): int => (int) $order['id'], $orders);
    $itemsByOrder = fetchOrderItems($pdo, $orderIds);

    return array_map(static function (array $order) use ($itemsByOrder): array {
        $orderId = (int) $order['id'];

        return [
            'id' => $orderId,
            'table_id' => (int) $order['table_id'],
            'table_number' => $order['table_number'] !== null ? (int) $order['table_number'] : 0,
            'table_qr_code' => (string) ($order['qr_code'] ?? ''),
            'status' => $order['status'],
            'total_price' => (float) $order['total_price'],
            'created_at' => $order['created_at'],
            'updated_at' => $order['updated_at'],
            'items' => $itemsByOrder[$orderId] ?? [],
        ];
    }, $orders);
}

function fetchOrderItems(PDO $pdo, array $orderIds): array
{
    if ($orderIds === []) {
        return [];
    }

    $placeholders = implode(', ', array_fill(0, count($orderIds), '?'));
    $statement = $pdo->prepare(
        "SELECT oi.id, oi.order_id, oi.menu_item_id, oi.quantity, oi.price,
                mi.name, mi.category, mi.image
         FROM order_items oi
         LEFT JOIN menu_items mi ON mi.id = oi.menu_item_id
         WHERE oi.order_id IN ($placeholders)
         ORDER BY oi.id ASC"
    );
    $statement->execute(array_values($orderIds));

    $itemsByOrder = [];

    foreach ($statement->fetchAll() as $item) {
        $orderId = (int) $item['order_id'];
        $price = (float) $item['price'];
        $quantity = (int) $item['quantity'];

        $itemsByOrder[$orderId][] = [
            'id' => (int) $item['id'],
            'menu_item_id' => $item['menu_item_id'] !== null ? (int) $item['menu_item_id'] : null,
            'name' => $item['name'] ?: 'Unavailable item',
            'category' => $item['category'],
            'image' => $item['image'],
            'image_url' => resolveImageUrl($item['image'] ?? null),
            'quantity' => $quantity,
            'price' => $price,
            'subtotal' => $price * $quantity,
        ];
    }

    return $itemsByOrder;
}

function resolveImageUrl(?string $image): ?string
{
    if ($image === null || trim($image) === '') {
        return null;
    }

    if (str_starts_with($image, 'http://') || str_starts_with($image, 'https://')) {
        return $image;
    }

    $appUrl = resolveAppUrl();
    $path = '/uploads/menu/' . ltrim($image, '/');

    return $appUrl !== '' ? $appUrl . $path : $path;
}

function resolveAppUrl(): string
{
    static $appUrl;

    if (is_string($appUrl)) {
        return $appUrl;
    }

    $candidates = [
        getenv('APP_URL'),
        getenv('VERCEL_PROJECT_PRODUCTION_URL'),
        getenv('VERCEL_URL'),
    ];

    foreach ($candidates as $candidate) {
        if (!is_string($candidate) || trim($candidate) === '') {
            continue;
        }

        $appUrl = trim($candidate);

        if (!str_starts_with($appUrl, 'http://') && !str_starts_with($appUrl, 'https://')) {
            $appUrl = 'https://' . $appUrl;
        }

        $appUrl = rtrim($appUrl, '/');
        return $appUrl;
    }

    $appUrl = '';
    return $appUrl;
}

function shouldForwardToLegacyBackend(string $method, string $path): bool
{
    $legacyRoutes = [
        'POST' => [
            '/api/order/create',
            '/api/order/confirm',
            '/api/order/serve',
            '/api/menu/add',
            '/api/menu/update',
            '/api/menu/delete',
        ],
    ];

    return in_array($path, $legacyRoutes[$method] ?? [], true);
}

function forwardToLegacyBackend(): never
{
    $legacyEntryPoint = __DIR__ . '/../backend/api/index.php';

    if (!is_file($legacyEntryPoint)) {
        throw new HttpException(500, 'Legacy backend entrypoint not found.', __FILE__, __LINE__);
    }

    require $legacyEntryPoint;
    exit;
}

function jsonResponse(int $statusCode, array $payload): never
{
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Access-Control-Allow-Methods: GET, OPTIONS');

    echo json_encode(
        $payload,
        JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
    );

    exit;
}
