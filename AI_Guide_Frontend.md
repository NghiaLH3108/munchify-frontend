# AI Agent & Developer Guidelines: Munchify Frontend (Flutter)

## 1. Document Purpose & Operational Mandate

This document serves as the single source of truth for **AI Coding Agents** (Cursor, Copilot, Claude, Gemini) and mobile developers building the **Munchify POS Mobile Application**.
Every Flutter widget, Bloc, use case, repository implementation, and entity must strictly follow Clean Architecture principles, UI/UX guidelines, and business constraints outlined below.

---

## 2. Tech Stack & Environment

- **Framework:** Flutter 3.x+ / Dart 3.x+
- **Target Platforms:** Android mobile (optimized for POS counter terminals)
- **Architecture Pattern:** Clean Architecture (Presentation -> Domain -> Data)
- **IDE:** Visual Studio Code (with official Flutter & Dart extensions)
- **State Management:** **flutter_bloc** — this project standardizes on the **Bloc pattern** using `Bloc`/`Cubit` classes, `BlocBuilder`, `BlocConsumer`, and `BlocListener` widgets. Do **NOT** use Riverpod, `StateNotifier`, or `ChangeNotifier`.
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
│   ├── constants/
│   │   ├── AppConstants.dart            # App-wide magic values & config
│   │   ├── ApiEndpoints.dart            # ← Centralized URL constants (see Section 3.1)
│   │   └── StorageKeys.dart             # Keys for SecureStorage & SharedPreferences
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
│   │       ├── bloc/                    # AuthBloc, AuthEvent, AuthState
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
│   │       ├── bloc/                    # CartBloc, PosCatalogBloc, OrderBloc
│   │       ├── screens/                 # PosHomeScreen.dart, CartModalSheet.dart, CheckoutScreen.dart
│   │       └── widgets/                 # ProductGridItem.dart, CartItemTile.dart, PaymentMethodSelector.dart
│   │
│   ├── customers/                       # Loyalty & Customer Lookup feature
│   │   ├── data/                        # CustomerRemoteDataSource, CustomerModel, CustomerRepositoryImpl
│   │   ├── domain/                      # CustomerEntity, SearchCustomerUseCase, RegisterCustomerUseCase
│   │   └── presentation/                # CustomerBloc, CustomerLookupDialog.dart, AddCustomerSheet.dart
│   │
│   ├── inventory/                       # Stock & Warehouse feature (Admin/Staff view)
│   │   ├── data/                        # StockRemoteDataSource, StockImportModel, StockRepositoryImpl
│   │   ├── domain/                      # StockImportEntity, StockMovementEntity, GetLowStockUseCase,
│   │   │                                # AdjustStockUseCase
│   │   └── presentation/                # InventoryBloc, InventoryScreen.dart,
│   │                                    # StockImportDetailScreen.dart, StockAdjustmentScreen.dart
│   │
│   ├── forecast/                        # AI Demand Forecasting feature (Admin)
│   │   ├── data/
│   │   │   ├── datasources/             # ForecastRemoteDataSource
│   │   │   │                            #   GET  /api/inventory/forecasting
│   │   │   │                            #   POST /api/stock-imports/generate-from-forecast
│   │   │   ├── models/                  # ForecastModel
│   │   │   └── repositories/            # ForecastRepositoryImpl.dart
│   │   ├── domain/
│   │   │   ├── entities/                # ForecastEntity
│   │   │   ├── repositories/            # ForecastRepository (Interface)
│   │   │   └── usecases/                # GetStockForecastUseCase, GenerateDraftImportUseCase
│   │   └── presentation/
│   │       ├── bloc/                    # ForecastBloc, ForecastEvent, ForecastState
│   │       ├── screens/                 # ForecastScreen.dart
│   │       └── widgets/                 # StockWarningCard.dart, ForecastTableRow.dart
│   │
│   └── reports/                         # Management & Analytics dashboard (Admin)
│       ├── data/                        # ReportRemoteDataSource, ReportModel, ReportRepositoryImpl
│       ├── domain/                      # RevenueEntity, TopSellingEntity, GetDashboardReportsUseCase
│       └── presentation/                # ReportBloc, DashboardScreen.dart, RevenueChartWidget.dart
│
└── main.dart                            # App initialization, BlocProviders, Router setup
```

### 3.1 ApiEndpoints Constants (core/constants/ApiEndpoints.dart)

All API URL strings MUST be declared as constants here. Never hardcode URL strings in DataSources.

```dart
class ApiEndpoints {
  // Auth
  static const String login           = '/api/auth/login';
  static const String me              = '/api/auth/me';

  // Catalog
  static const String categories      = '/api/categories';
  static const String products        = '/api/products';
  static const String units           = '/api/units';

  // Orders & POS
  static const String orders          = '/api/orders';

  // Customers
  static const String customers       = '/api/customers';

  // Promotions
  static const String promotions      = '/api/promotions';

  // Inventory & Stock
  static const String stockImports    = '/api/stock-imports';
  static const String stockMovements  = '/api/stock-movements';
  static const String suppliers       = '/api/suppliers';

  // AI Forecasting
  static const String forecasting             = '/api/inventory/forecasting';
  static const String generateFromForecast    = '/api/stock-imports/generate-from-forecast';

  // Reports
  static const String reports         = '/api/reports';
}
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
    > **Note (Client-Side Only):** Receipt/thermal printing is a **client-side only** feature. There is no backend API call for receipt generation. The receipt data is derived entirely from the `OrderResponse` returned by `POST /api/orders`.

### Feature 5: Inventory & Warehouse Monitoring

- **Screen: Stock Overview** (`GET /api/products` with low-stock filter):
  List of items with real-time stock levels, filtering for items below `MinStockLevel`.

- **Screen: Stock Import Detail** (Admin):
  Form to select supplier, add imported products with unit import price.
  - `POST /api/stock-imports` → Create DRAFT import.
  - `PUT /api/stock-imports/{id}/complete` → Finalize and increment stock (Admin only).
  - `DELETE /api/stock-imports/{id}` → Cancel DRAFT import.

- **Screen: Manual Stock Adjustment** (Admin — maps to F-03.4):
  Allow Admin to record stock corrections and damage write-offs.
  - Reason input (free text), adjustment type selector (`ADJUSTMENT` / `DAMAGE`), quantity delta field (positive = addition, negative = deduction).
  - Calls `POST /api/stock-movements` with `MovementType` = `'ADJUSTMENT'` or `'DAMAGE'`.
  - **Access:** Admin role only. Hide entry point from `STAFF` navigation.

### Feature 6: Dashboard & Reports (Admin)

- **Screen: Analytics Dashboard:**
  - Metric cards: Today's Sales (VNĐ), Order Count, Average Bill Value.
  - **Top-Selling Products — Two separate views:**
    - **By Revenue:** Products ranked by total sales amount (VNĐ) — sourced from `TopSellingProductDto.TotalRevenue`.
    - **By Volume:** Products ranked by units sold — sourced from `TopSellingProductDto.TotalQuantity`.
  - Payment method breakdown (CASH / QR_CODE / BANK_TRANSFER split).

### Feature 7: AI Demand Forecasting & Low-Stock Alerts (Admin)

- **Architectural Layers:**
  - `Domain`: `ForecastEntity`, `GetStockForecastUseCase`, `GenerateDraftImportUseCase`.
  - `Data`: `ForecastModel`, `ForecastRemoteDataSource`:
    - `GET /api/inventory/forecasting` → used by `GetStockForecastUseCase`
    - `POST /api/stock-imports/generate-from-forecast` → used by `GenerateDraftImportUseCase`
  - `Presentation`: `ForecastBloc`, `StockWarningCard`, `ForecastScreen`.

- **UI/UX & Screen Flow:**
  - **Alert Badges (POS & Inventory):** Prominent warning chips displayed next to stock quantities: Red (`Risk of stockout within 24–48h`), Orange (`Below minimum threshold`), Green (`Safe stock level`).
  - **Forecast Dashboard Table:**
    - Lists products requiring restocking, including: Current stock, Daily consumption rate ($V_{avg}$), Projected days remaining, and Suggested import quantity ($\text{SuggestedQty}$).
    - Input field allowing managers to quickly adjust quantities before approval.
  - **"Create Auto-Import Order" CTA:** One-click action that calls `POST /api/stock-imports/generate-from-forecast`. The backend automatically groups items by supplier and creates `DRAFT` `StockImport` records. On success, navigate to `StockImportDetailScreen` for Admin review and approval.

---

## 5. Role-to-Screen Access Matrix

AI agents generating navigation guards or permission checks MUST reference this table.

| Screen / Feature | ADMIN | STAFF |
|---|:---:|:---:|
| Login | ✅ | ✅ |
| POS Home (Catalog & Cart) | ✅ | ✅ |
| Customer Lookup & Registration | ✅ | ✅ |
| Checkout & Payment | ✅ | ✅ |
| Stock Overview (read-only) | ✅ | ✅ |
| Stock Import — Create DRAFT | ✅ | ✅ |
| Stock Import — Complete / Finalize | ✅ | ❌ |
| Manual Stock Adjustment | ✅ | ❌ |
| AI Forecast Dashboard | ✅ | ❌ |
| Generate Auto-Import from Forecast | ✅ | ❌ |
| Analytics Dashboard & Reports | ✅ | ❌ |
| User Management | ✅ | ❌ |

---

## 6. UI/UX & Design Rules for F&B POS

- **Primary Palette:** Warm, food-appetizing colors (Appetizing Orange `#E65100`, Amber `#FFB300`, Warm Dark Grey `#212121`, Light Warm Cream `#FFFDF9`).
- **Currency Formatting:** Strict Vietnamese Dong format: `100.000 ₫` using `NumberFormat.currency(locale: 'vi_VN', symbol: '₫')`.
- **Speed & Touch Target:** POS requires rapid tapping. All interactive buttons must have a minimum touch target of `48x48 dp`.
- **No Blocking Spinners:** Use optimistic UI updates for cart modifications. Use subtle skeleton loaders for catalog loading.
- **Offline Awareness:** Detect network drops; disable checkout submission button when offline to prevent duplicate transactions.

---

## 7. Business Rules Enforcement on Frontend

1. **Client Calculation Rule:** The frontend calculates provisional cart totals for instant UI feedback, but **ALWAYS** treats backend totals returned during order creation as authoritative.

2. **Combo Stock Constraint:**
   - For **single items**: Disable "Add to Cart" button if `StockQuantity <= 0`.
   - For **Combos**: A Combo product's own `StockQuantity` is **always 0** (no physical stock) and must **never** be used as an availability indicator. Derive Combo availability exclusively from the aggregated stock of its **component products** as provided in the product catalog response (component stock data is returned alongside Combo definitions). Render "Out of Stock" overlay on the Combo card if **any** component has `StockQuantity <= 0`.

3. **Loyalty Point Deduction:**
   - Display redemption preview using the exchange rate: **1 point = 1,000 VNĐ discount**.
   - Points can only be redeemed up to the allowed maximum discount threshold set by the store.
   - The backend is the authoritative source for the final redeemed discount (BR-03); always reconcile UI preview with the `DiscountAmount` returned in the order response.

4. **Active State Verification:** Products marked inactive (`isActive == false`) must be automatically hidden from the catalog.

---

## 8. Mandatory Coding Standards for AI Agents

1. **Clean Architecture Isolation:**
   - **Domain Layer:** Pure Dart code. ZERO imports of Flutter UI packages (`flutter/material.dart`), Dio, or SharedPreferences.
   - **Data Layer:** Handles serialization (`fromJson`, `toJson`), network requests, and implements Domain repository contracts.
   - **Presentation Layer:** Widgets consume Blocs via `BlocBuilder` / `BlocConsumer`. Widgets must **NEVER** make direct network calls.

2. **State Management — flutter_bloc:**
   - Every feature's presentation logic lives in a dedicated `*Bloc` or `*Cubit` class.
   - Use `BlocBuilder` for pure UI rebuilds, `BlocListener` for side effects (navigation, snackbars), and `BlocConsumer` when both are needed.
   - States must be immutable sealed classes (use `freezed` or manual `copyWith`).
   - **Example pattern:**
   ```dart
   // Bloc
   class OrderBloc extends Bloc<OrderEvent, OrderState> { ... }

   // Widget
   BlocBuilder<OrderBloc, OrderState>(
     builder: (context, state) { ... },
   )
   ```

3. **Failure & Error Representation:**
   - Use `Either<Failure, T>` (from `dartz` or `fpdart`) in Use Cases and Repositories to ensure exhaustive error handling:
   ```dart
   Future<Either<Failure, OrderEntity>> execute(CreateOrderParams params);
   ```

4. **Immutability:** Use `const` constructors wherever possible and immutable entity/state models (`freezed` or equatable classes).

5. **Code Generation:** Models requiring JSON parsing must use `@JsonSerializable()` annotations and follow the generated `.g.dart` pattern.

6. **API Endpoints:** Always reference `ApiEndpoints.*` constants. Never hardcode URL strings in DataSource classes.
