# Dallol Booking Website

A full-stack hotel booking platform built with **CodeIgniter 4 + PHP + PostgreSQL**, mirroring the Flutter mobile app.

## Quick Start

### 1. Install dependencies
```bash
cd booking_website
composer install
```

### 2. Set up PostgreSQL database
```bash
psql -U postgres -c "CREATE DATABASE dallol_booking;"
psql -U postgres -d dallol_booking -f database/schema.sql
```

### 3. Configure environment
Edit `.env`:
```
database.default.password = your_postgres_password
jwt.secret                 = your_long_random_secret_key
app.baseURL                = http://localhost:8080/
```

### 4. Generate encryption key
```bash
php spark key:generate
```

### 5. Run the dev server
```bash
php spark serve
```

Visit **http://localhost:8080**

---

## Project Structure

```
booking_website/
├── app/
│   ├── Config/           # App, Database, Jwt, Routes, Filters
│   ├── Controllers/
│   │   ├── Api/          # AuthController, HotelController, BookingController,
│   │   │                 # GuestController, WishlistController, PaymentController
│   │   └── Web/          # HomeController, HotelWebController, AuthWebController,
│   │                     # DashboardController, BookingWebController
│   ├── Filters/          # JwtFilter, SessionFilter
│   ├── Helpers/          # jwt_helper, api_helper
│   ├── Models/           # UserModel, HotelModel, BookingModel, ReviewModel,
│   │                     # WishlistModel, PaymentModel, OtpModel
│   └── Views/
│       ├── layouts/      # main.php, dashboard.php
│       ├── home/         # index.php
│       ├── hotels/       # list.php, detail.php
│       ├── auth/         # login.php, register.php, otp.php, forgot.php
│       ├── dashboard/    # index.php, bookings.php, booking_detail.php,
│       │                 # wishlist.php, profile.php
│       ├── booking/      # confirm.php, payment.php
│       └── errors/       # 404.php
├── database/
│   └── schema.sql        # Full PostgreSQL schema + seed data
├── public/
│   ├── index.php
│   ├── .htaccess
│   └── assets/
│       ├── css/app.css
│       └── js/app.js
└── .env
```

## API Endpoints (for Flutter Mobile App)

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | `/api/v1/auth/guest/register` | No |
| POST | `/api/v1/auth/guest/login` | No |
| POST | `/api/v1/auth/otp/send` | No |
| POST | `/api/v1/auth/otp/verify` | No |
| POST | `/api/v1/auth/refresh` | No |
| GET  | `/api/v1/hotels/featured` | No |
| GET  | `/api/v1/hotels/search` | No |
| GET  | `/api/v1/hotels/{id}` | No |
| GET  | `/api/v1/hotels/{id}/reviews` | No |
| GET  | `/api/v1/bookings` | JWT |
| POST | `/api/v1/bookings` | JWT |
| GET  | `/api/v1/bookings/{id}` | JWT |
| POST | `/api/v1/bookings/{id}/cancel` | JWT |
| GET  | `/api/v1/guest/profile` | JWT |
| PUT  | `/api/v1/guest/profile` | JWT |
| GET  | `/api/v1/wishlist` | JWT |
| POST | `/api/v1/wishlist` | JWT |
| POST | `/api/v1/payments/initiate` | JWT |

## Tech Stack

- **Backend**: CodeIgniter 4, PHP 8.1+
- **Database**: PostgreSQL 14+
- **Auth**: JWT (firebase/php-jwt) for API, Sessions for web
- **Frontend**: Bootstrap 5.3, Bootstrap Icons, Google Fonts (Inter)
- **Images**: Unsplash (online images, no local storage needed)
# hotel-booking
