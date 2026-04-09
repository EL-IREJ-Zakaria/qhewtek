<?php

declare(strict_types=1);

class MenuController
{
    private MenuItem $menuItems;
    private Table $tables;
    private array $config;

    public function __construct()
    {
        $this->menuItems = new MenuItem();
        $this->tables = new Table();
        $this->config = require __DIR__ . '/../config/app.php';
    }

    public function index(): never
    {
        $includeUnavailable = Request::boolFrom(Request::query('include_unavailable'), false);
        $category = trim((string) Request::query('category', ''));
        $search = trim((string) Request::query('search', ''));
        $tableQrCode = trim((string) Request::query('table', ''));

        $table = null;
        if ($tableQrCode !== '') {
            $table = $this->tables->findByQrCode($tableQrCode);
            if ($table === null) {
                Response::error('Table not found for the provided QR code.', 404);
            }
        }

        $items = array_map(
            fn (array $item): array => $this->formatMenuItem($item),
            $this->menuItems->getAll($includeUnavailable, $category ?: null, $search ?: null)
        );

        $categories = array_values(array_unique(array_map(
            static fn (array $item): string => $item['category'],
            $items
        )));
        sort($categories);

        Response::success([
            'table' => $table,
            'items' => $items,
            'filters' => [
                'categories' => $categories,
                'selected_category' => $category,
                'search' => $search,
            ],
        ], 'Menu fetched successfully.');
    }

    public function create(): never
    {
        $payload = $this->validatePayload();
        $payload['image'] = $this->resolveImageInput();

        $id = $this->menuItems->create($payload);
        $item = $this->menuItems->find($id);

        Response::success([
            'item' => $this->formatMenuItem($item ?: []),
        ], 'Menu item created successfully.', 201);
    }

    public function update(): never
    {
        $id = (int) Request::input('id', 0);
        if ($id <= 0) {
            Response::error('A valid menu item id is required.');
        }

        $existing = $this->menuItems->find($id);
        if ($existing === null) {
            Response::error('Menu item not found.', 404);
        }

        $payload = $this->validatePayload();
        $payload['image'] = $this->resolveImageInput($existing['image']);

        $this->menuItems->update($id, $payload);
        $item = $this->menuItems->find($id);

        Response::success([
            'item' => $this->formatMenuItem($item ?: []),
        ], 'Menu item updated successfully.');
    }

    public function delete(): never
    {
        $id = (int) Request::input('id', 0);
        if ($id <= 0) {
            Response::error('A valid menu item id is required.');
        }

        $existing = $this->menuItems->find($id);
        if ($existing === null) {
            Response::error('Menu item not found.', 404);
        }

        $this->menuItems->softDelete($id);

        Response::success([
            'id' => $id,
        ], 'Menu item archived successfully.');
    }

    private function validatePayload(): array
    {
        $name = trim((string) Request::input('name', ''));
        $description = trim((string) Request::input('description', ''));
        $category = trim((string) Request::input('category', ''));
        $price = Request::input('price');
        $available = Request::boolFrom(Request::input('available'), true);

        $errors = [];

        if ($name === '') {
            $errors['name'] = 'Name is required.';
        }

        if ($category === '') {
            $errors['category'] = 'Category is required.';
        }

        if (!is_numeric($price) || (float) $price < 0) {
            $errors['price'] = 'Price must be a positive number.';
        }

        if ($errors !== []) {
            Response::error('Validation failed.', 422, $errors);
        }

        return [
            'name' => $name,
            'description' => $description,
            'price' => number_format((float) $price, 2, '.', ''),
            'category' => strtolower($category),
            'available' => $available ? 1 : 0,
        ];
    }

    private function resolveImageInput(?string $fallback = null): ?string
    {
        $uploaded = Request::file('image');
        if ($uploaded !== null) {
            return $this->storeUploadedImage($uploaded);
        }

        $image = trim((string) Request::input('image', ''));
        return $image !== '' ? $image : $fallback;
    }

    private function storeUploadedImage(array $file): string
    {
        if (getenv('VERCEL') || getenv('VERCEL_ENV')) {
            Response::error(
                'Direct file uploads are not supported by this deployment. Use an image URL or external object storage.',
                422
            );
        }

        if (($file['error'] ?? UPLOAD_ERR_OK) !== UPLOAD_ERR_OK) {
            Response::error('Image upload failed.', 422);
        }

        $mimeType = mime_content_type($file['tmp_name']);
        $allowedTypes = [
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/webp' => 'webp',
        ];

        if (!isset($allowedTypes[$mimeType])) {
            Response::error('Unsupported image type. Use JPG, PNG, or WEBP.', 422);
        }

        if (($file['size'] ?? 0) > 5 * 1024 * 1024) {
            Response::error('Image must be 5MB or smaller.', 422);
        }

        if (!is_dir($this->config['upload_dir'])) {
            mkdir($this->config['upload_dir'], 0777, true);
        }

        $filename = uniqid('menu_', true) . '.' . $allowedTypes[$mimeType];
        $destination = $this->config['upload_dir'] . '/' . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            Response::error('Unable to save the uploaded image.', 500);
        }

        return $filename;
    }

    private function formatMenuItem(array $item): array
    {
        if ($item === []) {
            return [];
        }

        return [
            'id' => (int) $item['id'],
            'name' => $item['name'],
            'description' => $item['description'],
            'price' => (float) $item['price'],
            'image' => $item['image'],
            'image_url' => $this->resolveImageUrl($item['image'] ?? null),
            'category' => $item['category'],
            'available' => (bool) $item['available'],
            'created_at' => $item['created_at'] ?? null,
            'updated_at' => $item['updated_at'] ?? null,
        ];
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
