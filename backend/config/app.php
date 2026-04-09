<?php

declare(strict_types=1);

$appUrl = getenv('APP_URL') ?: '';

if ($appUrl === '') {
    $vercelProductionUrl = getenv('VERCEL_PROJECT_PRODUCTION_URL') ?: '';
    $vercelDeploymentUrl = getenv('VERCEL_URL') ?: '';
    $appUrl = $vercelProductionUrl !== ''
        ? 'https://' . $vercelProductionUrl
        : ($vercelDeploymentUrl !== '' ? 'https://' . $vercelDeploymentUrl : 'http://127.0.0.1:8000');
}

return [
    'app_name' => 'QhewTek Coffee Shop',
    'debug' => filter_var(getenv('APP_DEBUG') ?: false, FILTER_VALIDATE_BOOL),
    'app_url' => rtrim($appUrl, '/'),
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
