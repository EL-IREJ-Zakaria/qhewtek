<?php

header('Content-Type: application/json; charset=utf-8');

echo json_encode([
    'DB_HOST' => getenv('DB_HOST') ?: null,
    'DB_PORT' => getenv('DB_PORT') ?: null,
    'DB_NAME' => getenv('DB_NAME') ?: null,
    'DB_USER' => getenv('DB_USER') ?: null,
    'DB_PASS_EXISTS' => getenv('DB_PASS') ? true : false,
], JSON_PRETTY_PRINT);