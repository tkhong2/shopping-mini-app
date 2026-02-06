# Shopping Mini App 🛍️

**Ứng dụng mua sắm di động đầy đủ chức năng**

---

### Tổng Quan

Shopping Mini App là một ứng dụng mua sắm di động toàn diện được xây dựng với **Flutter** và hỗ trợ bởi **Firebase**. Ứng dụng cung cấp trải nghiệm thương mại điện tử hoàn chỉnh với các tính năng như duyệt sản phẩm, quản lý giỏ hàng, theo dõi đơn hàng và xác thực người dùng.

### Tính Năng

✨ **Các Tính Năng Chính:**

- 🔐 **Xác Thực Người Dùng** - Tích hợp Firebase Auth với email/mật khẩu
- 🏠 **Màn Hình Chính** - Sản phẩm nổi bật, danh mục và ưu đãi đặc biệt
- 🔍 **Danh Mục Sản Phẩm** - Duyệt sản phẩm trên 19+ danh mục
- 💳 **Giỏ Hàng** - Thêm/xóa mặt hàng, quản lý số lượng và theo dõi tổng cộng
- ❤️ **Danh Sách Yêu Thích** - Lưu sản phẩm yêu thích để sử dụng sau
- 📦 **Quản Lý Đơn Hàng** - Theo dõi lịch sử đơn hàng
- 👤 **Hồ Sơ Người Dùng** - Quản lý thông tin tài khoản và địa chỉ
- 🔔 **Thông Báo** - Cập nhật đơn hàng theo thời gian thực qua Firebase
- ⚙️ **Cài Đặt** - Tùy chọn ứng dụng và quản lý tài khoản
- 🎨 **Chế Độ Tối/Sáng** - Hỗ trợ chuyển đổi giao diện
- 📦 **Điều Hướng Danh Mục** - 19 danh mục sản phẩm bao gồm:
  - Điện tử (Điện thoại, Laptop, Thiết bị âm thanh)
  - Thời trang (Quần áo, Giày dép, Phụ kiện cho nam nữ)
  - Nhà cửa & Đời sống
  - Đồ chơi & Sản phẩm mẹ bé
  - Sách & Tạp chí
  - Thể thao & Dã ngoại
  - Và nhiều hơn nữa...

### Công Nghệ Sử Dụng

**Frontend:**

- **Flutter** - Framework UI
- **Provider** - Quản lý trạng thái
- **BLoC** - Thành phần logic kinh doanh
- **GoRouter** - Điều hướng và định tuyến

**Backend & Dịch Vụ:**

- **Firebase Core** - Cơ sở hạ tầng backend
- **Firebase Auth** - Xác thực người dùng
- **Cloud Firestore** - Cơ sở dữ liệu
- **Firebase Storage** - Lưu trữ tập tin
- **Firebase Messaging** - Thông báo đẩy
- **Firebase Analytics** - Phân tích người dùng

**Tiện Ích:**

- **GetIt** - Tiêm phụ thuộc
- **Dartz** - Lập trình hàm
- **Formz** - Xác thực biểu mẫu
- **Cached Network Image** - Lưu vào bộ nhớ đệm hình ảnh
- **Intl** - Quốc tế hóa

### Cấu Trúc Dự Án

```
lib/
├── core/
│   ├── constants/        # Các hằng số và màu sắc ứng dụng
│   ├── data/            # Dữ liệu giả và tiện ích
│   ├── errors/          # Xử lý lỗi
│   ├── network/         # Tiện ích mạng
│   ├── routes/          # Định nghĩa tuyến đường
│   ├── usecases/        # Các lớp usecase cơ sở
│   └── utils/           # Các hàm tiện ích
├── features/
│   ├── auth/            # Xác thực
│   ├── cart/            # Giỏ hàng
│   ├── category/        # Danh mục sản phẩm
│   ├── help/            # Trợ giúp & hỗ trợ
│   ├── home/            # Màn hình chính
│   ├── notifications/   # Thông báo đẩy
│   ├── order/           # Quản lý đơn hàng
│   ├── product/         # Chi tiết và danh sách sản phẩm
│   ├── profile/         # Hồ sơ người dùng
│   ├── settings/        # Cài đặt ứng dụng
│   └── wishlist/        # Quản lý danh sách yêu thích
├── shared/
│   ├── providers/       # Các provider được chia sẻ
│   ├── services/        # Các dịch vụ được chia sẻ
│   └── widgets/         # Các widget tái sử dụng
├── main.dart            # Điểm vào ứng dụng
├── app.dart             # Cấu hình ứng dụng
├── firebase_options.dart # Cấu hình Firebase
└── injection_container.dart # Thiết lập tiêm phụ thuộc
```

### Bắt Đầu

#### Yêu Cầu Trước

- Flutter SDK (phiên bản 3.10.4 hoặc cao hơn)
- Dart SDK
- Cài đặt dự án Firebase
- Git

#### Cài Đặt

1. **Clone kho lưu trữ:**

```bash
git clone https://github.com/tkhong2/shopping-mini-app.git
cd shopping-mini-app
```

2. **Cài đặt các phụ thuộc:**

```bash
flutter pub get
```

3. **Cấu hình Firebase:**

- Thiết lập dự án Firebase tại [Firebase Console](https://console.firebase.google.com)
- Tải xuống `google-services.json` và đặt nó trong `android/app/`
- Đối với iOS, hãy làm theo hướng dẫn cài đặt Firebase

4. **Chạy ứng dụng:**

```bash
flutter run
```

### Các Phụ Thuộc

Các gói chính được sử dụng trong dự án này:

- `firebase_core: ^3.15.2`
- `firebase_auth: ^5.0.0`
- `cloud_firestore: ^5.6.12`
- `flutter_bloc: ^8.1.6`
- `provider: ^6.1.2`
- `go_router: ^14.6.2`
- `get_it: ^8.0.2`
- Và nhiều hơn nữa... (xem [pubspec.yaml](pubspec.yaml))

### Kiến Trúc

Ứng dụng tuân theo các nguyên tắc **Kiến Trúc Sạch** với:

- **Data Layer** - Tích hợp Firebase và lưu trữ cục bộ
- **Domain Layer** - Logic kinh doanh và thực thể
- **Presentation Layer** - Các thành phần UI, BLoCs và Providers

### Thử Nghiệm

Chạy các bài kiểm tra bằng:

```bash
flutter test
```

Các gói thử nghiệm bao gồm:

- `bloc_test: ^9.1.7`
- `mocktail: ^1.0.4`

