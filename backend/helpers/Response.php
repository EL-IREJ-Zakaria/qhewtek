<?php

declare(strict_types=1);

class Response
{
    public static function json(int $statusCode, array $payload): never
    {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
        header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

        echo json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        exit;
    }

    public static function success(array $data = [], string $message = 'OK', int $statusCode = 200): never
    {
        self::json($statusCode, [
            'success' => true,
            'message' => $message,
            'data' => $data,
        ]);
    }

    public static function error(string $message, int $statusCode = 400, array $errors = []): never
    {
        self::json($statusCode, [
            'success' => false,
            'message' => $message,
            'errors' => $errors,
        ]);
    }
}
