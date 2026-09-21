# Admin Dashboard (React)

React + Vite port of the Filament admin panel — Dashboard, Analytics, and all 14 sections (Properties, Tenants, Contracts, Owners, Users, Payments, Notifications, Projects, Maintenance, Calendar, Tasks, Conversations, Mobile Requests, Reports), each with list/search/sort, create, and edit, backed by the existing `/api/v1` REST API (Sanctum bearer-token auth). The original Filament panel at `/admin` still exists unchanged and is available in parallel.

## Local development

```bash
cd admin-dashboard
npm install
cp .env.example .env   # set VITE_API_URL to your local Laravel backend URL
npm run dev
```

Requires the Laravel backend running (`php artisan serve`) and reachable at `VITE_API_URL`.

## Production build (served by Laravel)

`npm run build` outputs directly into `backend/public/dashboard` (see `vite.config.js`), so the app deploys as part of the existing Laravel server — no separate host, container, or CORS setup needed.

```bash
cd admin-dashboard
npm install
npm run build
```

Then, on the server:
- Don't set `VITE_API_URL` for the production build — the app falls back to same-origin API requests (`/api/v1/...`), matching wherever Laravel is served from.
- The app is reachable at `https://your-domain/dashboard`. `backend/routes/web.php` has an SPA fallback route (`/dashboard/{any?}`) so deep links and page refreshes work correctly with client-side routing.
- Re-run `npm run build` and redeploy whenever the frontend changes — `backend/public/dashboard` is a generated build artifact (gitignored), not committed source.
