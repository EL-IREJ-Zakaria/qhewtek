<?php

declare(strict_types=1);

spl_autoload_register(static function (string $class): void {
    $directories = [
        __DIR__ . '/../config/',
        __DIR__ . '/../helpers/',
        __DIR__ . '/../models/',
        __DIR__ . '/../controllers/',
    ];

    foreach ($directories as $directory) {
        $file = $directory . $class . '.php';
        if (file_exists($file)) {
            require_once $file;
            return;
        }
    }
});

if (Request::method() === 'OPTIONS') {
    Response::json(200, [
        'success' => true,
        'message' => 'Preflight request successful.',
        'data' => [],
    ]);
}

$routes = [
    'GET' => [
        '/api/menu' => [MenuController::class, 'index'],
        '/api/orders' => [OrderController::class, 'index'],
    ],
    'POST' => [
        '/api/order/create' => [OrderController::class, 'create'],
        '/api/order/confirm' => [OrderController::class, 'confirm'],
        '/api/order/serve' => [OrderController::class, 'serve'],
        '/api/menu/add' => [MenuController::class, 'create'],
        '/api/menu/update' => [MenuController::class, 'update'],
        '/api/menu/delete' => [MenuController::class, 'delete'],
    ],
];

$method = Request::method();
$path = Request::path();
$handler = $routes[$method][$path] ?? null;

if ($handler === null) {
    Response::error('Endpoint not found.', 404);
}

try {
    [$controllerClass, $action] = $handler;
    $controller = new $controllerClass();
    $controller->{$action}();
} catch (Throwable $exception) {
    $config = require __DIR__ . '/../config/app.php';

    if ($config['debug']) {
        Response::error($exception->getMessage(), 500, [
            'trace' => $exception->getTrace(),
        ]);
    }

    Response::error('An unexpected server error occurred.', 500);
}
