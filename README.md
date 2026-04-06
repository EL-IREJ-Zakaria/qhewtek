# QhewTek Coffee Shop Order Management System

Production-ready starter for a QR-driven coffee shop ordering workflow with:

- `database/` MySQL schema and seed data
- `backend/` PHP 8 REST API using PDO prepared statements and JSON responses
- `web/` customer-facing mobile-first ordering experience
- `mobile_flutter/` waiter operations app built with Flutter and Provider

## 1. MySQL Database Schema

The schema lives in [database/schema.sql](/C:/Users/ellei/Documents/Downloads/qhewtek/database/schema.sql).

It creates and seeds:

- `tables`
- `menu_items`
- `orders`
- `order_items`

Highlights:

- `tables.qr_code` is unique and is used by the customer web app to resolve table context
- `orders.status` supports `pending`, `confirmed`, and `served`
- `menu_items.available` supports soft-archiving instead of destructive deletes
- seed data includes 10 tables and a starter menu

## 2. Backend API (PHP 8 + MySQL)

The backend uses a lightweight router plus controllers and models:

- [backend/api/index.php](/C:/Users/ellei/Documents/Downloads/qhewtek/backend/api/index.php)
- [backend/router.php](/C:/Users/ellei/Documents/Downloads/qhewtek/backend/router.php)
- [backend/controllers/MenuController.php](/C:/Users/ellei/Documents/Downloads/qhewtek/backend/controllers/MenuController.php)
- [backend/controllers/OrderController.php](/C:/Users/ellei/Documents/Downloads/qhewtek/backend/controllers/OrderController.php)
- [backend/models/MenuItem.php](/C:/Users/ellei/Documents/Downloads/qhewtek/backend/models/MenuItem.php)
- [backend/models/Order.php](/C:/Users/ellei/Documents/Downloads/qhewtek/backend/models/Order.php)
- [backend/models/Table.php](/C:/Users/ellei/Documents/Downloads/qhewtek/backend/models/Table.php)

Supported JSON endpoints:

- `GET /api/menu`
- `GET /api/orders`
- `POST /api/order/create`
- `POST /api/order/confirm`
- `POST /api/order/serve`
- `POST /api/menu/add`
- `POST /api/menu/update`
- `POST /api/menu/delete`

Behavior notes:

- `GET /api/menu?table=TABLE-01` resolves the table and returns the live menu
- `GET /api/menu?include_unavailable=1` exposes archived/unavailable items for the waiter app
- `POST /api/order/create` recalculates totals on the server from database prices
- menu add/update endpoints accept `multipart/form-data` for image upload or an `image` URL string
- menu delete is implemented as soft archive by setting `available = 0`

Environment variables supported by the backend:

- `APP_URL`
- `APP_DEBUG`
- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`

## 3. Customer Web Interface

The customer web app lives under [web/](/C:/Users/ellei/Documents/Downloads/qhewtek/web) and is organized as requested:

- [web/pages/menu.html](/C:/Users/ellei/Documents/Downloads/qhewtek/web/pages/menu.html)
- [web/pages/cart.html](/C:/Users/ellei/Documents/Downloads/qhewtek/web/pages/cart.html)
- [web/pages/checkout.html](/C:/Users/ellei/Documents/Downloads/qhewtek/web/pages/checkout.html)
- [web/css/styles.css](/C:/Users/ellei/Documents/Downloads/qhewtek/web/css/styles.css)
- [web/js/menu.js](/C:/Users/ellei/Documents/Downloads/qhewtek/web/js/menu.js)
- [web/js/cart.js](/C:/Users/ellei/Documents/Downloads/qhewtek/web/js/cart.js)
- [web/js/checkout.js](/C:/Users/ellei/Documents/Downloads/qhewtek/web/js/checkout.js)

Features included:

- mobile-first responsive layout
- menu cards with image, price, category, and add-to-cart actions
- category filters and menu search
- localStorage-backed cart per table QR token
- checkout linked automatically to the table QR code
- modern glass-card UI with rounded corners, soft shadows, and dark mode

QR flow example:

- `http://127.0.0.1:8081/pages/menu.html?table=TABLE-01`

## 4. Flutter Waiter Mobile App

The waiter app lives in [mobile_flutter/](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter).

Key files:

- [mobile_flutter/lib/main.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/main.dart)
- [mobile_flutter/lib/screens/home_shell.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/screens/home_shell.dart)
- [mobile_flutter/lib/screens/orders_screen.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/screens/orders_screen.dart)
- [mobile_flutter/lib/screens/menu_management_screen.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/screens/menu_management_screen.dart)
- [mobile_flutter/lib/providers/order_provider.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/providers/order_provider.dart)
- [mobile_flutter/lib/providers/menu_provider.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/providers/menu_provider.dart)
- [mobile_flutter/lib/services/order_service.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/services/order_service.dart)
- [mobile_flutter/lib/services/menu_service.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/services/menu_service.dart)

Features included:

- live orders screen with polling
- order status actions: confirm and mark served
- order status color indicators
- notification sound via `SystemSound.alert` when new pending orders arrive
- menu management screen with add, edit, archive, price update, availability toggle, and image upload
- Provider-based state management and clean service/model separation
- dark mode toggle

## 5. API Integration

Integration contract across the three layers:

- customer web menu fetches from `GET /api/menu?table={qr_code}`
- checkout sends `{ table_qr_code, items[] }` to `POST /api/order/create`
- waiter app polls `GET /api/orders`
- waiter app sends `POST /api/order/confirm` and `POST /api/order/serve`
- waiter app menu management uses `GET /api/menu?include_unavailable=1`, `POST /api/menu/add`, `POST /api/menu/update`, and `POST /api/menu/delete`

Config entry points:

- web API base URL: [web/js/config.js](/C:/Users/ellei/Documents/Downloads/qhewtek/web/js/config.js)
- Flutter API base URL: [mobile_flutter/lib/services/api_config.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/services/api_config.dart)
- backend DB and app URL config: [backend/config/app.php](/C:/Users/ellei/Documents/Downloads/qhewtek/backend/config/app.php)

## 6. Folder Structure

```text
qhewtek/
├── backend/
│   ├── api/
│   ├── config/
│   ├── controllers/
│   ├── helpers/
│   ├── models/
│   ├── uploads/
│   └── router.php
├── database/
│   └── schema.sql
├── mobile_flutter/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── test/
├── web/
│   ├── css/
│   ├── js/
│   ├── pages/
│   └── index.html
└── README.md
```

## 7. Run Locally

### Database

1. Create the database by importing [database/schema.sql](/C:/Users/ellei/Documents/Downloads/qhewtek/database/schema.sql) into MySQL.
2. Confirm the database name is `coffee_shop_order_management`.

### Backend

1. Set database credentials and URL as environment variables if needed:

```powershell
$env:APP_URL="http://127.0.0.1:8000"
$env:DB_HOST="127.0.0.1"
$env:DB_PORT="3306"
$env:DB_NAME="coffee_shop_order_management"
$env:DB_USER="root"
$env:DB_PASS=""
```

2. Start the PHP API from the project root:

```powershell
php -S 127.0.0.1:8000 -t backend backend/router.php
```

### Customer Web App

1. Start a simple static server:

```powershell
php -S 127.0.0.1:8081 -t web
```

2. Open a QR-style menu URL in the browser:

```text
http://127.0.0.1:8081/pages/menu.html?table=TABLE-01
```

3. Use one of the seeded QR codes:

- `TABLE-01`
- `TABLE-02`
- `TABLE-03`
- `TABLE-04`
- `TABLE-05`

### Flutter Waiter App

1. From [mobile_flutter/](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter):

```powershell
flutter pub get
flutter run
```

2. If you run on:

- Android emulator: default config already points to `http://10.0.2.2:8000/api`
- iOS simulator, desktop, or Flutter web: update [mobile_flutter/lib/services/api_config.dart](/C:/Users/ellei/Documents/Downloads/qhewtek/mobile_flutter/lib/services/api_config.dart) if your backend host differs
- physical device: replace localhost with your machine’s LAN IP in both the Flutter and web config files

## Verification

Completed locally:

- PHP syntax check on all backend files
- `flutter analyze`
- `flutter test`
