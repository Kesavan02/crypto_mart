# 🚀 CryptoMart

> A modern, high-performance, cross-platform cryptocurrency market tracking and analysis application built with Flutter, Clean Architecture, and BLoC state management.

---

## 📌 Executive Summary

**CryptoMart** is an enterprise-grade cryptocurrency tracking application supporting **Android, iOS, Web (WebAssembly), Windows, macOS, and Linux**. It delivers real-time market data, interactive financial charts, search with debouncing, customizable sorting, local watchlist persistence, responsive multi-column desktop split views, and a custom 3D animated navigation drawer.

---

## ✨ Key Features

* **📈 Live Crypto Market Listing:** Real-time prices, 24h percentage changes, 7-day sparkline charts, and market cap rankings.
* **🔍 Real-Time Search & Smart Filtering:** Instant coin lookup with 350ms input debouncing and sorting options (Market Cap, Price, and 24h Change).
* **📊 Interactive Financial Charts:** Historical price trend charts powered by `fl_chart` with multi-timeframe analysis and high/low markers.
* **⭐ Local Watchlist (Bookmarks):** Instant asset bookmarking persisted locally across app sessions.
* **🌐 Global Market Overview:** Real-time global market capitalization, 24h volume, BTC/ETH market dominance, and active crypto asset counters.
* **🎨 Responsive Design & 3D Drawer:**
  * Fluid 3D perspective sliding drawer for mobile and tablet views.
  * Desktop split-screen master-detail layout with an interactive draggable column divider.
  * System-aware Dark & Light theme switching.
* **📡 Offline Detection & Status Banner:** Automatic connectivity monitoring with animated top notification banners when offline.

---

## ⚡ Extra Advanced Capabilities Implemented

Beyond standard mobile development, **CryptoMart** incorporates production-grade tooling and edge deployment optimizations:

### 1. 🚀 Shorebird Code Push (Over-The-Air Live Updates)
* Integrated `shorebird_code_push` to deliver instant bug fixes, UI adjustments, and feature patches directly to installed mobile apps without waiting for app store review cycles.
* Encapsulated in an `AppUpdateGate` that automatically handles update checks on supported native platforms while gracefully bypassing unsupported environments (e.g. Web).

### 2. ⚡ WebAssembly (WASM) & Cloudflare Pages Edge Deployment
* **Next-Gen Web Performance:** Compiled using Flutter's WebAssembly toolchain (`flutter build web --wasm`) for near-native rendering speeds and reduced bundle execution times.
* **WASM Security Headers (`web/_headers`):** Pre-configured with Cross-Origin Opener Policy (`COOP: same-origin`) and Cross-Origin Embedder Policy (`COEP: credentialless`) for Skwasm graphics execution.
* **SPA Routing (`web/_redirects`):** Configured with single-page application fallback rules (`/* /index.html 200`) to enable smooth deep linking and direct page refreshes.
* **Zero-Bandwidth-Cap Hosting:** Ready for immediate, high-availability deployment to Cloudflare Pages edge network.

### 3. 🛡️ Firebase Suite Integration
* **`firebase_core` & `firebase_analytics`:** Integrated for app initialization and user telemetry.
* **`firebase_crashlytics`:** Platform-guarded error reporting for Android/iOS with fallback console reporting on Web and Desktop.

### 4. 🔄 Resilient Pull-to-Refresh & Backend Cold-Start Handling
* **Cold-Start Resilience:** Network timeouts configured to 35 seconds to gracefully accommodate server spin-downs and container cold starts on hosting providers like Render.
* **Completer-Based Pull-to-Refresh:** Built with `Completer` callbacks and 15s fallback timeouts so the refresh indicator never hangs or freezes.
* **Full Reset Behavior:** Pulling to refresh automatically refreshes the price list, clears active search queries, and resets the sort dropdown back to default.

---

## 🏗️ Architecture & Technology Stack

```
lib/
├── core/
│   ├── constants/       # App colors, endpoints, styles
│   ├── errors/          # Exceptions and Failure models
│   ├── network/         # Dio HTTP client configuration & interceptors
│   ├── theme/           # Light & Dark theme definitions
│   ├── utils/           # Responsive layout helpers
│   └── widgets/         # App update gate, shared UI components
└── features/
    ├── crypto_market/
    │   ├── data/        # Models, Local/Remote DataSources, Repository Impls
    │   ├── domain/      # Entities, Repositories contracts, UseCases
    │   └── presentation/# BLoC / Cubits, Pages, and Custom Widgets
    └── settings/
        └── presentation/# Settings Page and Theme Cubit
```

* **Framework:** Flutter (Dart SDK ^3.9.0)
* **State Management:** `flutter_bloc` / `cubit` + `equatable`
* **Networking:** `dio` with logging and custom timeouts
* **Local Storage:** `shared_preferences`
* **Charts:** `fl_chart`
* **Code Push:** `shorebird_code_push`
* **Backend:** REST API on Render (`crypto-mart.onrender.com`)

---

## 🌐 Backend Architecture & Responsibilities

The application is powered by a dedicated Node.js REST API service hosted on Render (`https://crypto-mart.onrender.com`), responsible for:

* **Data Aggregation & Normalization:** Ingests live market data from upstream cryptocurrency providers, cleans and normalizes raw values, and packages them into lightweight JSON schemas tailored for high-speed client rendering.
* **Server-Side Search & Sorting Engine:** Handles dynamic query parameters (`?search=...`, `?sortBy=market_cap|price|change`, `?order=asc|desc`) to return indexed, filtered, and sorted asset lists directly from the backend.
* **Historical Chart Data Formatting:** Normalizes complex timestamp-price raw arrays (`/api/coins/:id/chart`) into streamlined coordinate data points structured for instant plotting with Flutter's `fl_chart`.
* **Global Market Metrics Processing:** Aggregates and serves macro market statistics (`/api/market-stats`), including Total Market Cap USD, 24h Volume, BTC/ETH dominance ratios, and active currency counts.
* **CORS & Edge Compatibility:** Configured with CORS headers to support cross-origin API requests from both native mobile platforms and sandboxed Flutter WebAssembly (WASM) clients.

### API Endpoints Summary

| Endpoint | Method | Description |
| :--- | :---: | :--- |
| `/api/coins` | `GET` | Fetches live coin listings with prices, 24h change %, 7d sparklines, and query filters (`search`, `sortBy`, `order`). |
| `/api/coins/:id` | `GET` | Retrieves comprehensive coin profiles, descriptions, supply metrics, and ATH/ATL data. |
| `/api/coins/:id/chart` | `GET` | Returns formatted historical price data for trend charting (`?days=7`). |
| `/api/market-stats` | `GET` | Delivers global macroeconomic crypto statistics and market dominance metrics. |

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.24.0 or higher recommended)
* Android Studio / Xcode / VS Code with Flutter extension
* Optional: [Shorebird CLI](https://shorebird.dev/) & [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)

### 1. Installation
```powershell
# Clone the repository
git clone https://github.com/Kesavan02/crypto_mart.git

# Navigate to project directory
cd crypto_mart

# Fetch dependencies
flutter pub get
```

### 2. Run Locally
```powershell
# Run on connected Android / iOS device or Emulator
flutter run

# Run on Web (Chrome)
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows
```

### 3. Quality & Testing
```powershell
# Static analysis
flutter analyze

# Run unit and widget test suite
flutter test
```

---

## 📦 Deployment Guides

### 🌐 Deploy WebApp to Cloudflare Pages (WASM)

1. **Build the WASM bundle:**
   ```powershell
   flutter build web --wasm --release
   ```

2. **Deploy to Cloudflare Pages:**
   ```powershell
   npx wrangler pages deploy build/web --project-name=crypto-mart
   ```

---

### 📱 Release & Patch with Shorebird (Mobile)

1. **Build a fresh release:**
   ```powershell
   shorebird release android
   ```

2. **Publish an instant Over-The-Air (OTA) patch:**
   ```powershell
   shorebird patch android
   ```

---
