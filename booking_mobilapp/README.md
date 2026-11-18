# 📱 Dallol Booking — Flutter Mobile App

Ethiopian multipurpose hotel booking platform.
Mobile companion to [booking.dalloltech.com](https://booking.dalloltech.com).
Backend: **PHP CodeIgniter REST API**

---

## 🗂 Project Structure

```
booking_multipurpose_platform/
├── lib/
│   ├── main.dart                               # App entry, MultiProvider setup
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart              # Cities, payment methods, hotel types
│   │   │   └── api_constants.dart              # All PHP CodeIgniter API endpoints
│   │   ├── services/
│   │   │   └── api_service.dart                # HTTP client (GET/POST/PUT/DELETE + auth token)
│   │   └── themes/
│   │       └── app_theme.dart                  # Colors, typography, button/input styles
│   ├── models/
│   │   ├── hotel.dart                          # Hotel model + sample fallback data
│   │   ├── user.dart                           # User model (email + phone)
│   │   ├── booking.dart                        # Booking model + BookingStatus enum
│   │   └── search_params.dart                  # Search filter parameters
│   ├── providers/
│   │   ├── auth_provider.dart                  # Login, register, OTP, logout — real API
│   │   ├── hotel_provider.dart                 # Search, featured, wishlist — real API
│   │   └── booking_provider.dart               # Create, list, cancel — real API
│   └── screens/
│       ├── splash_screen.dart                  # Splash + auth redirect
│       ├── auth/
│       │   ├── login_screen.dart               # Email + Phone tab login
│       │   ├── register_screen.dart            # Sign up (email or phone)
│       │   └── otp_screen.dart                 # 6-digit OTP verification
│       ├── home/
│       │   ├── home_screen.dart                # 5-tab bottom nav (Airbnb-style)
│       │   └── search_bar_widget.dart          # Location/date/guest search form
│       ├── hotels/
│       │   ├── hotel_list_screen.dart          # Search results + filters
│       │   └── hotel_detail_screen.dart        # Carousel, amenities, book now
│       ├── booking/
│       │   ├── booking_screen.dart             # Guest form + 4 payment methods
│       │   └── booking_confirmation_screen.dart # Booking ID + status
│       ├── wishlist/
│       │   └── wishlist_screen.dart            # Saved hotels grid
│       └── profile/
│           ├── profile_screen.dart             # User info + edit profile + menu
│           └── booking_history_screen.dart     # Upcoming/Completed/Cancelled tabs
├── assets/
│   ├── images/
│   └── icons/
├── pubspec.yaml
└── README.md
```

---

## ✅ Features

### 🔐 Authentication (API-connected)
- Login with **Email + Password**
- Login with **Phone Number + OTP** (6-digit)
- **Register** with name + email or phone
- Token stored in `shared_preferences`
- Auto-login on app restart
- Logout with confirmation

### 🏨 Hotel Search & Discovery (API-connected)
- Search by **city, check-in/out dates, guests, rooms**
- **Featured Hotels** auto-play carousel (Airbnb-style)
- **Browse by Type** category chips
- **Explore Ethiopia** city grid
- Hotel list with **filters** (type, price range, rating)
- Hotel detail with **image carousel**, amenities, rating, price
- **Wishlist** (save/unsave hotels with heart icon)

### 📅 Booking System (API-connected)
- Full booking form with guest detailshttps://github.com/Dallol-Tech-PLC/booking
- **4 Payment Methods:**
  - 💵 Pay at Hotel *(critical for Ethiopian market)*
  - 📱 Telebirr
  - 🏦 CBE Birr
  - 💳 International Card (Visa/Mastercard)
- Price summary (nights × rooms × price)
- Booking confirmation with **Booking ID**
- Cancel booking with confirmation dialog

### 👤 User Profile (API-connected)
- Profile header with avatar, name, email/phone, verified badge
- **Edit Profile** bottom sheet
- Stats: Bookings / Saved / Reviews
- Booking history: **Upcoming / Completed / Cancelled** tabs
- Full settings menu

---

## 🔌 Backend API (PHP CodeIgniter)

Set your backend URL in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://api.dalloltech.com/index.php/api';
```

### Expected API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login with email/password |
| POST | `/auth/register` | Register new user |
| POST | `/auth/send_otp` | Send OTP to phone |
| POST | `/auth/verify_otp` | Verify OTP + return token |
| GET | `/auth/profile` | Get current user profile |
| PUT | `/auth/update_profile` | Update user profile |
| POST | `/auth/logout` | Logout |
| GET | `/hotels` | List all hotels |
| GET | `/hotels/featured` | Featured hotels |
| GET | `/hotels/search?city=&check_in=&...` | Search hotels |
| GET | `/hotels/detail/{id}` | Hotel detail |
| POST | `/bookings/create` | Create booking |
| GET | `/bookings/user` | User's bookings |
| POST | `/bookings/cancel/{id}` | Cancel booking |
| GET | `/wishlist` | User wishlist |
| POST | `/wishlist/add` | Add to wishlist |
| DELETE | `/wishlist/remove/{id}` | Remove from wishlist |

### Expected JSON Response Format

```json
{
  "status": true,
  "message": "Success",
  "data": { ... },
  "token": "Bearer token here"
}
```

> **Note:** All providers have a **local fallback** using sample data so the app works fully even before the backend is ready.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.6.2`
- Android Studio / VS Code
- Android device or emulator

### Run the App

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build APK
flutter build apk --release
```

### Run on Your Phone (USB)
1. Enable **Developer Options** on your Android phone
2. Enable **USB Debugging**
3. Connect via USB
4. Run `flutter devices` to confirm device is detected
5. Run `flutter run`

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `http` | API calls to PHP CodeIgniter |
| `shared_preferences` | Token/session storage |
| `intl` | Date formatting |
| `cached_network_image` | Efficient image loading |
| `carousel_slider` | Hotel image carousel |

---

## 🌍 Ethiopian Localization

- All prices in **ETB (Ethiopian Birr)**
- Ethiopian cities: Addis Ababa, Hawassa, Bahir Dar, Gondar, Mekelle, etc.
- Phone numbers prefixed with **+251**
- **Telebirr** and **CBE Birr** payment options
- **Pay at Hotel** — critical for Ethiopian market

---

## 👥 Team Structure

| Group | Responsibility |
|-------|---------------|
| Group 1 | Frontend Web (HTML/CSS/JS) |
| Group 2 | **Flutter Mobile App** ← *this repo* |
| Group 3 | Backend API (PHP CodeIgniter) |

---

## 🔜 Next Steps

1. ✅ Connect all providers to real PHP CodeIgniter API
2. Implement real Telebirr SDK
3. Implement real CBE Birr payment gateway
4. Add FCM push notifications
5. Add WhatsApp booking notifications
6. Add Google Maps hotel map view
7. Add hotel partner dashboard screens
8. Add admin panel screens
