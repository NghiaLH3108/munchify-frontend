# Munchify POS - Frontend Web

Giao diện Web điều hành và quản trị điểm bán hàng F&B **Munchify POS (Admin Executive Analytics & Management Portal)**, được phát triển trên nền tảng **Flutter Web** tuân thủ nghiêm ngặt mô hình **Clean Architecture** kết hợp cùng mô hình quản lý trạng thái **BLoC (Business Logic Component)**.

---

## 📌 Mục lục
- [Kiến trúc Clean Architecture](#-kiến-trúc-clean-architecture)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Tính năng triển khai](#-tính-năng-triển-khai)
  - [1. Admin Executive Analytics Dashboard](#1-admin-executive-analytics-dashboard)
  - [2. Quản lý Nhân sự & Phân quyền (Staff Management)](#2-quản-lý-nhân-sự--phân-quyền-staff-management)
- [Thiết kế & Trải nghiệm người dùng](#-thiết-kế--trải-nghiệm-người-dùng)
- [Quy chuẩn Git & Phân nhánh (Branching Strategy)](#-quy-chuẩn-git--phân-nhánh-branching-strategy)
- [Bộ kiểm thử tự động (Testing Suite)](#-bộ-kiểm-thử-tự-động-testing-suite)
- [Hướng dẫn cài đặt & Khởi chạy](#-hướng-dẫn-cài-đặt--khởi-chạy)

---

## 🏛 Kiến trúc Clean Architecture

Cấu trúc dự án được phân tách thành 3 tầng độc lập theo tiêu chuẩn Clean Architecture:

```
munchify_frontend/lib/
├── core/                                 # Cấu hình dùng chung
│   ├── constants/                        # ApiEndpoints, AppConstants
│   ├── error/                            # Failures & Exceptions
│   ├── network/                          # DioClient (kết nối Backend API)
│   ├── theme/                            # ColorPalette, AppTypography, AppTheme
│   └── utils/                            # Validators (Kiểm tra dữ liệu đầu vào chuẩn)
└── features/
    ├── admin/                            # Khung điều hành Admin Portal
    │   └── presentation/
    │       ├── pages/                    # AdminShellScreen (Sidebar + Dynamic Body)
    │       └── widgets/                  # AnalyticsDashboardView (KPI cards, Charts preview)
    └── staff/                            # Module Quản lý Nhân sự
        ├── data/
        │   ├── datasources/              # StaffRemoteDataSource (Gọi API người dùng)
        │   ├── models/                   # StaffModel, PagedStaffResult
        │   └── repositories/             # StaffRepositoryImpl
        ├── domain/
        │   ├── entities/                 # StaffEntity
        │   ├── repositories/             # StaffRepository (Interface)
        │   └── usecases/                 # GetStaffList, CreateStaff, UpdateStaff, ToggleStaffStatus
        └── presentation/
            ├── bloc/                     # StaffBloc, StaffEvent, StaffState
            ├── pages/                    # StaffManagementScreen (Bảng dữ liệu, KPI cards, Toolbar)
            └── widgets/                  # StaffFormDialog (Thêm/Sửa nhân viên, mặc định role STAFF)
```

---

## ⚡ Công nghệ sử dụng

- **Framework**: Flutter 3.29+ / Dart 3.7+
- **State Management**: `flutter_bloc` 8.1+ & `bloc`
- **Network / HTTP**: `dio` 5.4+
- **Lưu trữ an toàn**: `flutter_secure_storage`
- **Typography & Font**: Google Fonts (`Inter` & `Plus Jakarta Sans`)
- **Responsive Layout**: Hỗ trợ tối ưu trên đa dạng độ phân giải màn hình máy tính bảng và desktop

---

## 🚀 Tính năng triển khai

### 1. Admin Executive Analytics Dashboard
- **Executive Metric Cards**: Theo dõi doanh thu thực, số đơn hoàn thành, giá trị trung bình/đơn và khách hàng mới.
- **Biểu đồ & Phân tích trực quan**: Xu hướng doanh thu tuần, phân bổ doanh số theo danh mục đồ uống / món ăn, cảnh báo hàng tồn kho thấp và danh sách đơn hàng trực tiếp.
- **Admin Navigation Shell**: Sidebar chuyên nghiệp với phông màu Navy tối (`#263143`), hỗ trợ chuyển đổi mượt mà giữa các phân hệ: *Dashboard*, *Đơn hàng*, *Thực đơn*, *Bàn & Phòng*, *Nhân viên*, *Khách hàng*, *Báo cáo*.

### 2. Quản lý Nhân sự & Phân quyền (Staff Management)
- **Bảng dữ liệu nhân viên chuyên nghiệp**:
  - Cột số thứ tự (`#`) tự động tính toán chính xác theo từng trang.
  - Hiển thị đầy đủ thông tin: Tên đăng nhập `@username`, Họ và tên, Số điện thoại, Email.
  - Badge phân quyền trực quan (`STAFF` xanh dương, `ADMIN` vàng hổ phách).
  - Badge trạng thái hoạt động (*Đang hoạt động* / *Đã khóa*).
  - Cột thao tác tiện lợi: Chỉnh sửa thông tin và Khóa/Mở khóa tài khoản.
- **Bộ lọc & Tìm kiếm tức thì**:
  - Tìm kiếm theo từ khóa họ tên / username với debounce.
  - Thanh lọc Pill Tabs: *Tất cả*, *Đang hoạt động*, *Đã khóa*.
  - Bộ lọc Dropdown theo vai trò (*Tất cả*, *ADMIN*, *STAFF*).
- **Hộp thoại Thêm nhân viên mới (Modal Dialog)**:
  - **Mặc định cố định vai trò `STAFF`**: Không cho phép tạo bừa quyền Admin nhằm đảm bảo an toàn dữ liệu và tuân thủ phân quyền POS.
  - Hiển thị thông tin vai trò trực quan kèm biểu tượng khóa bảo mật.
  - Kiểm tra tính hợp lệ dữ liệu chặt chẽ:
    - Tên đăng nhập tối thiểu 3 ký tự.
    - Mật khẩu tối thiểu 6 ký tự, hỗ trợ ẩn/hiện mật khẩu.
    - Họ tên bắt buộc.
    - Số điện thoại định dạng chuẩn Việt Nam (10 chữ số, đầu 03/05/07/08/09).
    - Email hợp lệ.
- **Thẻ thống kê KPI Nhân sự**:
  - Tổng số nhân sự.
  - Nhân sự đang hoạt động.
  - Tài khoản đang bị khóa.
  - Tỷ lệ hoạt động (`%`).

---

## 🎨 Thiết kế & Trải nghiệm người dùng

Giao diện được thiết kế theo phong cách hiện đại (Clean Executive Slate), lấy cảm hứng từ các hệ thống POS hàng đầu:
- **Tone màu chủ đạo**:
  - Nền hệ thống: `#F8F9FA` (Sạch sẽ, dịu mắt, tiết kiệm tài nguyên hiển thị).
  - Sidebar: `#263143` (Navy than sang trọng).
  - Điểm nhấn thương hiệu (Accent): `#F27A24` (Cam F&B ấm áp, bắt mắt).
- **Phản hồi người dùng**: SnackBar thông báo kết quả thành công/thất bại dạng Floating với góc bo tròn hiện đại; Dialog xác nhận rõ ràng trước khi khóa tài khoản.

---

## 🌿 Quy chuẩn Git & Phân nhánh (Branching Strategy)

> [!IMPORTANT]
> **Tuyệt đối không push trực tiếp lên nhánh `main`**. Nhánh `main` được bảo vệ và chỉ phục vụ phát hành chính thức.

1. **Nhánh gốc phát triển**: `dev`
2. **Nhánh tính năng (Feature Branch)**: `manage-staff-HuyCG` (hoặc `<feature-name>-<DeveloperName>`)
3. **Quy trình làm việc**:
   - Nhánh tính năng được tạo từ `dev`: `git checkout -b manage-staff-HuyCG dev`
   - Commit code theo quy chuẩn **Conventional Commits**:
     - `feat: ...` : Thêm giao diện, tính năng hoặc usecase mới
     - `fix: ...` : Khắc phục lỗi hiển thị hoặc logic
     - `docs: ...` : Cập nhật tài liệu
     - `test: ...` : Bổ sung hoặc cập nhật unit / widget tests
     - `chore: ...` : Dọn dẹp cấu hình hoặc dependencies
   - Tạo Pull Request hướng vào nhánh `dev`.

---

## 🧪 Bộ kiểm thử tự động (Testing Suite)

Dự án có độ phủ kiểm thử đầy đủ từ tầng Core đến Presentation:

```bash
cd munchify_frontend
flutter test
```

### Các nhóm test đã triển khai:
- **Core Validators Test** (`test/core/utils/validators_test.dart`): 14 test cases kiểm tra username, mật khẩu, số điện thoại VN, email, tiền khách đưa.
- **Staff Model & Serialization Test** (`test/features/staff/data/models/staff_model_test.dart`): 3 test cases xác thực mapping JSON sang Dart Object và ngược lại.
- **Staff UseCases Test** (`test/features/staff/domain/usecases/staff_usecases_test.dart`): 5 test cases mô phỏng Mockito cho GetList, Create, Update, ToggleStatus.
- **Widget Integration Test** (`test/widget_test.dart`): Kiểm tra hiển thị giao diện bảng nhân viên, nút thêm nhân viên và danh sách dữ liệu.

Kết quả kiểm thử: **24/24 tests passed (100%)**.

---

## 🚀 Hướng dẫn cài đặt & Khởi chạy

### 1. Yêu cầu môi trường
- Flutter SDK 3.24+ trở lên
- Trình duyệt Google Chrome (cho môi trường Web)

### 2. Cài đặt thư viện
```bash
cd munchify_frontend
flutter pub get
```

### 3. Khởi chạy trên Web
```bash
# Khởi chạy ứng dụng Web với cổng mặc định 5195
flutter run -d chrome --web-port 5195
```

Ứng dụng sẽ mở tại `http://localhost:5195/` và tự động kết nối tới Backend API tại `http://localhost:5194/`.
