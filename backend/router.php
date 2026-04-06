<?php

declare(strict_types=1);

$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$fullPath = __DIR__ . $path;

if ($path !== '/' && file_exists($fullPath) && !is_dir($fullPath)) {
    return false;
}

require __DIR__ . '/api/index.php';
