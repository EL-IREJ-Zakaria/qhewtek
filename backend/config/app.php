<?php

declare(strict_types=1);

return [
    'app_name' => 'QhewTek Coffee Shop',
    'debug' => filter_var(getenv('APP_DEBUG') ?: false, FILTER_VALIDATE_BOOL),
    'app_url' => rtrim(getenv('APP_URL') ?: 'http://127.0.0.1:8000', '/'),
    'upload_dir' => __DIR__ . '/../uploads/menu',
    'db' => [
        'host' => getenv('DB_HOST') ?: '127.0.0.1',
        'port' => (int) (getenv('DB_PORT') ?: 3306),
        'name' => getenv('DB_NAME') ?: 'coffee_shop_order_management',
        'user' => getenv('DB_USER') ?: 'root',
        'pass' => getenv('DB_PASS') ?: '',
        'charset' => 'utf8mb4',
    ],
];
