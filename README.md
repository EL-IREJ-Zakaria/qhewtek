# QhewTek Coffee Shop Order Management System

QhewTek is a QR-based ordering flow for a coffee shop:

- `web/` serves the customer menu, cart, and checkout flow
- `backend/` exposes a PHP 8 JSON API for menu and order management
- `database/` contains the MySQL schema and seed data
- `mobile_flutter/` is the waiter-facing Flutter app
- `docker-compose.yml` brings the site, API, uploads, and MySQL together for deployment

## Project flow

1. A customer scans a QR code and opens `web/pages/menu.html?table=TABLE-01`.
2. The site loads the live menu from `GET /api/menu?table=TABLE-01`.
3. Checkout sends the order to `POST /api/order/create`.
4. The waiter app polls `GET /api/orders`.
5. New orders appear in the mobile app and can be confirmed or served there.

This means the site and the mobile app only need to share the same production API base URL.

## API endpoints

- `GET /api/menu`
- `GET /api/orders`
- `POST /api/order/create`
- `POST /api/order/confirm`
- `POST /api/order/serve`
- `POST /api/menu/add`
- `POST /api/menu/update`
- `POST /api/menu/delete`

## Configuration

### Backend environment variables

The backend reads these variables from the environment:

- `APP_URL`
- `APP_DEBUG`
- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`

The production example file is [`.env.example`](./.env.example).

### Web app API base URL

The web app now behaves like this in [web/js/config.js](./web/js/config.js):

- local dev on `localhost` or port `8081` -> `http://<host>:8000/api`
- production on the same domain as the site -> `<current-origin>/api`
- optional override via `window.__QHEWTEK_CONFIG__.apiBaseUrl`

### Flutter app API base URL

The waiter app now supports build-time configuration in [mobile_flutter/lib/services/api_config.dart](./mobile_flutter/lib/services/api_config.dart).

For production, pass:

```powershell
--dart-define=API_BASE_URL=https://your-domain.com/api
```

If `API_BASE_URL` is not provided, the app keeps the current local-development defaults.

## Run locally

### 1. Database

Import [database/schema.sql](./database/schema.sql) into MySQL and make sure the database name is `coffee_shop_order_management`.

### 2. Backend

Set environment variables if needed:

```powershell
$env:APP_URL="http://127.0.0.1:8000"
$env:DB_HOST="127.0.0.1"
$env:DB_PORT="3306"
$env:DB_NAME="coffee_shop_order_management"
$env:DB_USER="root"
$env:DB_PASS=""
```

Start the API:

```powershell
php -S 127.0.0.1:8000 -t backend backend/router.php
```

### 3. Customer web app

Start the static site:

```powershell
php -S 127.0.0.1:8081 -t web
```

Open:

```text
http://127.0.0.1:8081/pages/menu.html?table=TABLE-01
```

### 4. Waiter mobile app

From [mobile_flutter/](./mobile_flutter):

```powershell
flutter pub get
flutter run
```

For a physical device on the same LAN:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_IP:8000/api
```

## Production deployment with Docker

This repository now includes a single-server deployment layout:

- `web` container: Nginx serves the static site and public uploads
- `app` container: PHP-FPM runs the API
- `db` container: MySQL stores tables, menu items, orders, and order items

Files involved:

- [docker-compose.yml](./docker-compose.yml)
- [deploy/nginx/default.conf](./deploy/nginx/default.conf)
- [deploy/nginx/Dockerfile](./deploy/nginx/Dockerfile)
- [deploy/php/Dockerfile](./deploy/php/Dockerfile)
- [deploy/php/entrypoint.sh](./deploy/php/entrypoint.sh)

### 1. Prepare the server

On your VPS:

1. Install Docker and Docker Compose.
2. Clone this repository.
3. Copy `.env.example` to `.env`.
4. Set `APP_URL` to your public domain or server IP.
5. Change `DB_PASS` and `MYSQL_ROOT_PASSWORD`.

Example:

```dotenv
APP_URL=http://YOUR_SERVER_IP
APP_DEBUG=false
DB_NAME=coffee_shop_order_management
DB_USER=qhewtek
DB_PASS=strong-db-password
MYSQL_ROOT_PASSWORD=strong-root-password
WEB_PORT=80
```

### 2. Start everything

Run from the project root:

```powershell
docker compose up -d --build
```

This starts:

- the customer site on port `80`
- the API on the same public host under `/api`
- uploaded menu images under `/uploads/menu/...`
- MySQL with the seed schema loaded on first boot

### 3. Test the production API

Open these URLs in the browser:

```text
http://YOUR_SERVER_IP/
http://YOUR_SERVER_IP/pages/menu.html?table=TABLE-01
http://YOUR_SERVER_IP/api/menu?table=TABLE-01
```

If the menu loads in the browser, the waiter app will be able to see new orders from the same backend.

### 4. Connect the Flutter app to production

For Android, desktop, or test devices:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_SERVER_IP/api
```

For release builds:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://YOUR_SERVER_IP/api
```

If you later attach a domain and TLS, switch the value to:

```powershell
--dart-define=API_BASE_URL=https://your-domain.com/api
```

## Important production notes

- The old hard-coded fallback DB credentials were removed from [backend/config/app.php](./backend/config/app.php). Use environment variables instead.
- The API already sends CORS headers from [backend/helpers/Response.php](./backend/helpers/Response.php), so you can still split frontend and backend later if needed.
- Uploaded menu images are persisted in a Docker volume shared between the PHP and Nginx containers.
- The mobile app polls the API, so new orders from the website should appear automatically as long as both point to the same backend.

## Mobile app quick notes

See [mobile_flutter/README.md](./mobile_flutter/README.md) for the app-specific commands.

## Vercel deployment notes

This repo can be deployed to Vercel with:

- static frontend routing from [vercel.json](./vercel.json)
- a PHP API entrypoint at [api/index.php](./api/index.php)
- the community PHP runtime `vercel-php@0.5.2`

Important constraints:

- Vercel PHP runs via a community runtime, not an official Vercel PHP runtime.
- The API still requires an external MySQL-compatible database through `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASS`.
- Local filesystem uploads are not durable on Vercel. Menu image upload should use image URLs unless you add external object storage.

For the site -> mobile app flow, the critical requirement is that both the website and the Flutter app point to the same public `/api` base URL.
