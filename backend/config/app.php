<?php

declare(strict_types=1);

return [
    'app_name' => 'QhewTek Coffee Shop',
    'debug' => filter_var(getenv('APP_DEBUG') ?: false, FILTER_VALIDATE_BOOL),
    'app_url' => rtrim(getenv('APP_URL') ?: 'http://127.0.0.1:8000', '/'),
    'upload_dir' => __DIR__ . '/../uploads/menu',
    'db' => [
        'host' => getenv('DB_HOST') ?: 'sql204.infinityfree.com',
        'port' => (int) (getenv('DB_PORT') ?: 3306),
        'name' => getenv('DB_NAME') ?: 'if0_41602092_XXX',
        'user' => getenv('DB_USER') ?: 'if0_41602092',
        'pass' => getenv('DB_PASS') ?: 'hC0zDE0w7M9X',
        'charset' => 'utf8mb4',
    ],
];
