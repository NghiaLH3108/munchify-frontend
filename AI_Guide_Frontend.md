# AI Agent & Developer Guidelines: Munchify Frontend (Flutter)

## 1. Document Purpose & Operational Mandate

This document serves as the single source of truth for **AI Coding Agents** (Cursor, Copilot, Claude, Gemini) and mobile developers building the **Munchify POS Mobile Application**.
Every Flutter widget, provider/bloc, use case, repository implementation, and entity must strictly follow Clean Architecture principles, UI/UX guidelines, and business constraints outlined below.

---

## 2. Tech Stack & Environment

- **Framework:** Flutter 3.x+ / Dart 3.x+
- **Target Platforms:** Android mobile (optimized for POS counter terminals)
- **Architecture Pattern:** Clean Architecture (Presentation -> Domain -> Data)
- **IDE:** Visual Studio Code (with official Flutter & Dart extensions)
- **State Management:** Bloc - standardizing on StateNotifier
- **Networking & HTTP Client:** Dio (with Interceptors for JWT authorization, logging, and token refresh)
- **Local Storage / Persistence:** Flutter Secure Storage (JWT tokens) & SharedPreferences (user preferences/offline cache)
- **JSON Serialization:** `json_annotation`, `json_serializable`, `build_runner`

---

## 3. Clean Architecture Folder Structure

The project strictly isolates Business Rules from Framework UI code.
Dependencies strictly point inward:
`Presentation Layer` -> `Domain Layer` <- `Data Layer`.

```
lib/
├── core/                                # Shared modules across features
│   ├── constants/                       # AppConstants, ApiEndpoints, StorageKeys
│   ├── errors/                          # Failures, Exceptions, ErrorHandler
│   ├── network/                         # DioClient, ApiInterceptors, NetworkInfo
│   ├── theme/                           # ColorPalette, Typography, AppTheme
│   ├── utils/                           # CurrencyFormatter (VNĐ), DateFormatter, Validators
│   └── widgets/                         # Reusable UI (CustomButton, CustomTextField, LoadingDialog)
│
├── features/                            # Feature-Driven Clean Architecture modules
│   │
│   ├── auth/                            # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/             # AuthRemoteDataSource, AuthLocalDataSource
│   │   │   ├── models/                  # UserModel, LoginRequestModel, TokenModel
│   │   │   └── repositories/            # AuthRepositoryImpl.dart
│   │   ├── domain/
│   │   │   ├── entities/                # UserEntity
│   │   │   ├── repositories/            # AuthRepository (Interface / Contract)
│   │   │   └── usecases/                # LoginUseCase, GetCurrentUserUseCase, LogoutUseCase
│   │   └── presentation/
│   │       ├── providers/ / controllers/# AuthNotifier, AuthState
│   │       ├── screens/                 # LoginScreen.dart
│   │       └── widgets/                 # LoginFormWidget.dart
│   │
│   ├── pos/                             # Core Point-of-Sale & Ordering feature
│   │   ├── data/
│   │   │   ├── datasources/             # PosRemoteDataSource (Dio API calls)
│   │   │   ├── models/                  # OrderRequestModel, OrderResponseModel, ProductModel
│   │   │   └── repositories/            # PosRepositoryImpl.dart
│   │   ├── domain/
│   │   │   ├── entities/                # CartItemEntity, OrderEntity, ProductEntity, ComboEntity
│   │   │   ├── repositories/            # PosRepository (Interface)
│   │   │   └── usecases/                # GetProductsUseCase, CreateOrderUseCase, ApplyPromoUseCase
│   │   └── presentation/
│   │       ├── providers/               # CartNotifier, PosCatalogNotifier, OrderNotifier
│   │       ├── screens/                 # PosHomeScreen.dart, CartModalSheet.dart, CheckoutScreen.dart
│   │       └── widgets/                 # ProductGridItem.dart, CartItemTile.dart, PaymentMethodSelector.dart
│   │
│   ├── customers/                       # Loyalty & Customer Lookup feature
│   │   ├── data/                        # CustomerRemoteDataSource, CustomerModel, CustomerRepositoryImpl
│   │   ├── domain/                      # CustomerEntity, SearchCustomerUseCase, RegisterCustomerUseCase
│   │   └── presentation/                # CustomerNotifier, CustomerLookupDialog.dart, AddCustomerSheet.dart
│   │
│   ├── inventory/                       # Stock & Warehouse feature (Admin/Staff view)
│   │   ├── data/                        # StockRemoteDataSource, StockImportModel, StockRepositoryImpl
│   │   ├── domain/                      # StockImportEntity, StockMovementEntity, GetLowStockUseCase
│   │   └── presentation/                # InventoryScreen.dart, StockImportDetailScreen.dart
│   │
│   └── reports/                         # Management & Analytics dashboard (Admin)
│       ├── data/                        # ReportRemoteDataSource, ReportModel, ReportRepositoryImpl
│       ├── domain/                      # RevenueEntity, TopSellingEntity, GetDashboardReportsUseCase
│       └── presentation/                # DashboardScreen.dart, RevenueChartWidget.dart
│
└── main.dart                            # App initialization, ProviderScope, Router setup
```

---

## 4. Master Feature List & Screen Flow

### Feature 1: Authentication & Session Management

- **Screen: Login Screen:** Username/Password inputs, validation, animated login button, error banner.
- **Logic:** Secure token storage via `flutter_secure_storage`. Auto-redirect based on JWT role (`ADMIN` sees management tabs, `STAFF` lands directly on POS).
- **Logout / Expiry:** Interceptor catches 401 Unauthorized, wipes tokens, and pushes back to Login.

### Feature 2: Counter POS (Point-of-Sale) Core Screen

- **Screen: POS Home (Catalog & Order Bar):**
  - **Header:** Current Staff name, shift details, Quick Customer Search bar, Cart badge.
  - **Category Filter Bar:** Horizontal scrollable chips (`All`, `Bánh Tráng & Snacks`, `Thịt Khô`, `Nước Đóng Chai`, `Trà Sữa`, `Combo`).
  - **Product Grid:** Responsive 2-column or 3-column cards showing image, code, name, price (VNĐ), stock badge (`Out of Stock`, `Low Stock`, `Available`).
  - **Combo Highlight:** Special badge indicating bundled savings and component items.
  - **Cart Drawer / Bottom Sheet:** Displays selected items, quantity (+ / -), subtotal, discount, customer loyalty points, and Checkout CTA.

### Feature 3: Customer Lookup & Loyalty Modal

- **Screen / Dialog: Customer Lookup:**
  - Quick search input by phone number (`090...`).
  - Real-time search debounce (300ms).
  - If found: Display customer name, tier, and available loyalty points with an option to toggle "Redeem Points".
  - If not found: One-click "Add New Customer" modal without interrupting the current cart.

### Feature 4: Checkout & Payment Modal

- **Screen: Checkout Screen:**
  - **Bill Summary:** Subtotal, Applied Promotions, Redeemed Point Discount, Final Amount Payable.
  - **Payment Methods:** Toggle between `CASH`, `QR_CODE` (VietQR instant display), and `BANK_TRANSFER`.
  - **Cash Tendered Helper:** Quick currency buttons (50k, 100k, 200k, 500k) with automatic Change Returned calculation.
  - **Receipt Preview / Print:** Success screen with option to trigger thermal printer or digital receipt.

### Feature 5: Inventory & Warehouse Monitoring

- **Screen: Stock Overview:** List of items with real-time stock levels, filtering for items below `MinStockLevel`.
- **Screen: Stock Import (Admin):** Form to select supplier, select imported products, set unit import price, and trigger complete import.

### Feature 6: Dashboard & Reports (Admin)

- **Screen: Analytics Dashboard:** Metric cards (Today's Sales, Orders count, Average Bill value), Bar chart for top-selling items, Payment method breakdown.

---

## 5. UI/UX & Design Rules for F&B POS

- **Primary Palette:** Warm, food-appetizing colors (Appetizing Orange `#E65100`, Amber `#FFB300`, Warm Dark Grey `#212121`, Light Warm Cream `#FFFDF9`).
- **Currency Formatting:** Strict Vietnamese Dong format: `100.000 ₫` using `NumberFormat.currency(locale: 'vi_VN', symbol: '₫')`.
- **Speed & Touch Target:** POS requires rapid tapping. All interactive buttons must have a minimum touch target of `48x48 dp`.
- **No Blocking Spinners:** Use optimistic UI updates for cart modifications. Use subtle skeleton loaders for catalog loading.
- **Offline Awareness:** Detect network drops; disable checkout submission button when offline to prevent duplicate transactions.

---

## 6. Business Rules Enforcement on Frontend

1. **Client Calculation Rule:** The frontend calculates provisional cart totals for instant UI feedback, but **ALWAYS** treats backend totals returned during order creation as authoritative.
2. **Combo Stock Constraint:**
   - Disable "Add to Cart" button if single item `StockQuantity <= 0`.
   - For Combos: Verify local stock of all component items; if any component has zero stock, render "Out of Stock" overlay on the Combo card.
3. **Loyalty Point Deduction:** Points can only be redeemed up to the allowed maximum discount threshold set by the store.
4. **Active State Verification:** Products marked inactive (`isActive == false`) must be automatically hidden from the catalog.

---

## 7. Mandatory Coding Standards for AI Agents

1. **Clean Architecture Isolation:**
   - **Domain Layer:** Pure Dart code. ZERO imports of Flutter UI packages (`flutter/material.dart`), Dio, or SharedPreferences.
   - **Data Layer:** Handles serialization (`fromJson`, `toJson`), network requests, and implements Domain repository contracts.
   - **Presentation Layer:** Widgets consume Providers/StateNotifiers. Widgets must NEVER make direct network calls.
2. **Failure & Error Representation:**
   - Use `Either<Failure, T>` (from `dartz` or `fpdart`) in Use Cases and Repositories to ensure exhaustive error handling:
   ```dart
   Future<Either<Failure, OrderEntity>> execute(CreateOrderParams params);
   ```
3. **Immutability:** Use `const` constructors wherever possible and immutable entity state models (`freezed` or equatable classes).
4. **Code Generation:** Models requiring JSON parsing must use `@JsonSerializable()` annotations and follow the generated `.g.dart` pattern.
