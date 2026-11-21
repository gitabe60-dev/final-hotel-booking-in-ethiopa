# WORK BREAKDOWN STRUCTURE (WBS)
## Hotel Reservation and Booking Management System in Ethiopia

---

### Project Information

| Field | Value |
|-------|-------|
| **Project Title** | Hotel Reservation and Booking Management System in Ethiopia |
| **Team Members** | Abebe Mesfin (153689), Abrham Sema (153719), Yeshiwas Aschalew (154634), Yohanes Tesfa (154657) |
| **Supervisor** | Baye Atinafu |
| **University** | Debre Markos University, Institute of Technology |
| **Department** | Software Engineering |
| **Duration** | 12 Weeks (September 2026 – November 2026) |

---

## Phase 1: Project Planning and Requirements (Weeks 1-2)

### 1.1 Requirements Gathering
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 1.1.1 | Literature review | Study existing hotel booking systems (Booking.com, Expedia, Airbnb). Review academic papers on Ethiopian hospitality. Review Digital Ethiopia 2025 strategy. | 3 days | All members | Research notes |
| 1.1.2 | Stakeholder interviews | Interview 25 hotel managers and receptionists in Addis Ababa, Bahir Dar, Gondar, Hawassa, Mekelle, Debre Markos. | 3 days | Abebe, Yohanes | Interview transcripts |
| 1.1.3 | User questionnaires | Distribute 150 questionnaires to potential users (travelers, business people, tourists). | 2 days | Abrham, Yeshiwas | Survey results |
| 1.1.4 | Observation | Direct observation of hotel reception workflows at 15+ hotels. Document pain points and time spent per booking. | 2 days | All members | Observation notes |
| 1.1.5 | Focus group discussions | Hold 5 sessions with hotel staff (8-10 participants each). | 2 days | Abebe | Discussion summaries |

### 1.2 Feasibility Study
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 1.2.1 | Technical feasibility | Evaluate Flutter, React, Go, PostgreSQL. Assess team skills. Verify tool availability. | 1 day | Abebe | Feasibility report |
| 1.2.2 | Operational feasibility | Assess user readiness, training needs, change management. | 1 day | Yohanes | Feasibility report |
| 1.2.3 | Economic feasibility | Calculate development cost, operational cost, expected ROI. | 1 day | Abrham | Budget plan |
| 1.2.4 | Legal feasibility | Review Ethiopian data protection law, payment regulations, app store policies. | 1 day | Yeshiwas | Legal compliance checklist |

### 1.3 Project Proposal
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 1.3.1 | Write proposal | Write all 13 sections following university format. Include background, problem statement, objectives, scope, significance, requirements, methodology, feasibility, budget. | 3 days | All members | Proposal document |
| 1.3.2 | Review and submit | Internal review, corrections, submit to supervisor. | 2 days | All members | Approved proposal |

---

## Phase 2: System Analysis (Weeks 3-4)

### 2.1 Requirement Specification
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 2.1.1 | Functional requirements | Define FRs for all 4 roles: User (20 FRs), Hotel Manager (12 FRs), Sub Admin (12 FRs), Super Admin (9 FRs). | 2 days | All members | SRS document |
| 2.1.2 | Non-functional requirements | Define performance, security, usability, reliability, scalability, maintainability, portability, internationalization, accessibility, data integrity, auditability. | 1 day | Abebe | SRS document |
| 2.1.3 | Business rules | Define 10 business rules (city assignment, room capacity, max 2 rooms, date validation, National ID required, payment verification, etc.). | 1 day | Yohanes | SRS document |
| 2.1.4 | Change cases | Define 5 future change cases (additional payment methods, new cities, real API integration, additional languages, cloud storage migration). | 1 day | Abrham | SRS document |

### 2.2 UML Modeling
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 2.2.1 | Use case diagrams | Draw UC diagrams for User, Hotel Manager, Sub Admin, Super Admin. Write 10 use case descriptions. | 2 days | Yeshiwas | UML diagrams |
| 2.2.2 | Sequence diagrams | Draw 5 sequence diagrams: Registration, Hotel Search, Room Booking with National ID, Payment Submission, Payment Verification. | 2 days | Abebe | UML diagrams |
| 2.2.3 | Activity diagrams | Draw 2 activity diagrams: Complete Booking Process, Payment Verification Process. | 1 day | Yohanes | UML diagrams |
| 2.2.4 | Analysis class diagram | Identify 16 domain classes and their relationships. | 1 day | Abrham | UML diagrams |

### 2.3 System Design
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 2.3.1 | Design class diagram | Map classes to 3-layer architecture: Presentation (screens/pages), Business Logic (handlers/providers), Data Access (models/API). | 1 day | Abebe | Design document |
| 2.3.2 | Database design | Design 16 tables. Normalize to 3NF. Define PK, FK, UNIQUE, NOT NULL, DEFAULT, indexes. Write 24 migration files. | 2 days | Yohanes | ER diagram + migrations |
| 2.3.3 | UI design | Design mobile app screen hierarchy (22 screens). Design web app page hierarchy (33 pages). Design wireframes. | 2 days | Yeshiwas, Abrham | UI mockups |
| 2.3.4 | System architecture | Design component diagram, deployment diagram, network diagram. Define REST API endpoints. | 1 day | Abebe | Architecture document |

---

## Phase 3: Database Setup (Week 4-5)

### 3.1 Database Infrastructure
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 3.1.1 | Install PostgreSQL | Install PostgreSQL 14+ on development machine. Create database "dallolbook". Create user with password. | 0.5 day | Yohanes | Running database |
| 3.1.2 | Create migration files | Write 24 SQL migration files in order: users, otp_codes, cities, hotels, hotel_images, hotel_amenities, room_types, reviews, bookings, payments, wishlist, admin_users, admin_city_assignments, brokers, hotel_managers, broker_messages, admin_overview_view, payment_screenshot, notifications, hotel_payment_methods, national_id_columns, room_status, image_cleanup, allow_multiple_payment_methods. | 2 days | Yohanes | Migration files |
| 3.1.3 | Run migrations | Execute all migrations in order. Verify all 16 tables created with correct columns, constraints, and indexes. | 0.5 day | Yohanes | Database schema |
| 3.1.4 | Seed data | Write seed.sql with sample data: 13 Ethiopian cities, 14 hotels with images and amenities, room types, admin users (super_admin, sub_admin, hotel_manager), default payment methods. | 1 day | Abrham | Seed data |

---

## Phase 4: Backend Development (Weeks 5-7)

### 4.1 Backend Infrastructure
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 4.1.1 | Initialize Go project | Set up Go module, directory structure (cmd/, modules/, config/, middleware/, utils/, database/). Install Gin, bcrypt, jwt-go, pq driver. | 0.5 day | Abebe | Go project structure |
| 4.1.2 | Configuration | Create config.go for environment variables (APP_PORT, DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, JWT_SECRET). Create .env file. | 0.5 day | Abebe | Config module |
| 4.1.3 | Database connection | Set up database/sql connection pool in main.go. Test connection. Configure CORS middleware. | 0.5 day | Abebe | Working DB connection |
| 4.1.4 | Middleware | Implement AuthRequired middleware (JWT verification, role extraction). Implement CORS middleware. | 1 day | Abebe | Middleware module |

### 4.2 Auth Module
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 4.2.1 | User model | Implement: FindByEmail, FindByPhone, FindByID, Create, UpdateLastLogin. | 1 day | Yohanes | auth/model.go |
| 4.2.2 | Register handler | Validate input (name, email/phone, password). Hash password (bcrypt). Check duplicate. Create user. Generate JWT. | 1 day | Yohanes | auth/handler.go |
| 4.2.3 | Login handler | Find user by email/phone. Verify bcrypt password. Generate JWT. Update last_login. | 0.5 day | Yohanes | auth/handler.go |
| 4.2.4 | OTP handlers | SendOTP (generate 6-digit code, store in otp_codes, return code for demo). VerifyOTP (check code, mark used, generate JWT if valid). | 1 day | Yohanes | auth/handler.go |
| 4.2.5 | Password reset | ForgotPassword (generate reset token). ResetPassword (verify token, update password). | 1 day | Yohanes | auth/handler.go |
| 4.2.6 | Routes | Register all auth routes under /api/v1/auth/. | 0.5 day | Abebe | auth/routes.go |

### 4.3 Hotels Module
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 4.3.1 | Hotel model | Implement: GetFeatured, Search (with filters: city, price, rating, amenities, limit, offset, sort), GetByID (with images, amenities, rooms), GetAvailability (check room status for dates), GetPaymentMethods, GetReviews, CreateReview. | 2 days | Abebe | hotels/model.go |
| 4.3.2 | Hotel handler | Featured (return featured hotels). Search (parse query params, call model). Show (return hotel detail with rooms). Availability (check dates). PaymentMethods (return hotel payment methods + manager contact). GetReviews. PostReview (auth required). | 2 days | Abebe | hotels/handler.go |
| 4.3.3 | Routes | Register hotel routes under /api/v1/hotels/. | 0.5 day | Abebe | hotels/routes.go |

### 4.4 Booking Module
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 4.4.1 | Booking model | Implement: Create (INSERT booking + auto-create payment + notify manager), GetByID, GetUserBookings, Cancel, CountByStatus, GetHotelPrice. | 2 days | Yohanes | booking/model.go |
| 4.4.2 | Booking handler | Create (validate required fields, validate National ID front+back REQUIRED, validate dates, validate payment method, validate max 2 rooms, validate guest capacity, calculate total price, create booking, create payment, send notification). Index (list user bookings). Show (booking detail). Cancel (status must be pending/confirmed). | 2 days | Yohanes | booking/handler.go |
| 4.4.3 | Routes | Register booking routes under /api/v1/bookings/. | 0.5 day | Yohanes | booking/routes.go |

### 4.5 Payment Module
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 4.5.1 | Payment model | Implement: GetByID, Create, UpdateStatus, Submit (store transaction_id + screenshot_url), GetPendingPayments (for manager). | 1.5 days | Abrham | payment/model.go |
| 4.5.2 | Payment handler | Initiate (create payment record, return payment_id). Submit (store txn_id + screenshot). Status (return payment status). Retry (for failed payments). | 1.5 days | Abrham | payment/handler.go |
| 4.5.3 | Routes | Register payment routes under /api/v1/payments/. | 0.5 day | Abrham | payment/routes.go |

### 4.6 Admin Module
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 4.6.1 | Admin login | Separate login endpoint for admin_users. Generate JWT with role. Verify bcrypt password. | 1 day | Yeshiwas | admin/handler.go |
| 4.6.2 | Super Admin | SuperDashboard (national overview). SubAdmins CRUD. AssignCity. RevokeCity. Cities CRUD. View all hotels, bookings, users. | 2 days | Yeshiwas | admin/handler.go |
| 4.6.3 | Sub Admin | SubDashboard (city KPIs). Hotels CRUD (create, edit, delete, toggle, upload images, set Google Maps location). Rooms CRUD. Managers CRUD. Payment methods. City bookings. Brokers. | 3 days | Yeshiwas | admin/handler.go |
| 4.6.4 | Hotel Manager | ManagerDashboard (hotel KPIs). View bookings. Update booking status. Verify payment (accept/reject with room status update + notification). Manage rooms. Manage payment methods. Inbox (notifications). | 2 days | Yeshiwas | admin/handler.go |
| 4.6.5 | Broker | BrokerDashboard. BrokerBookings. Inbox/Sent messages. SendMessage. | 1 day | Yeshiwas | admin/handler.go |
| 4.6.6 | Routes | Register all admin routes under /api/admin/ with role-based groups (super, sub, manager, broker). | 1 day | Yeshiwas | admin/routes.go |

### 4.7 Supporting Modules
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 4.7.1 | Wishlist module | Index (list user wishlist). Toggle (add/remove). Remove (delete by hotel_id). | 0.5 day | Abrham | wishlist/ |
| 4.7.2 | Guest module | Profile (get user profile). UpdateProfile. ChangePassword. | 0.5 day | Abrham | guest/ |
| 4.7.3 | Notifications module | ListUser/ListAdmin. ReadUser/ReadAdmin. ReadAllUser/ReadAllAdmin. | 1 day | Abrham | notifications/ |
| 4.7.4 | Public cities | GET /api/public/cities (no auth required, returns all active cities). | 0.5 day | Abebe | main.go |

### 4.8 Backend Testing
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 4.8.1 | API testing | Test all endpoints with curl/Postman. Verify: registration, login, hotel search, hotel detail, booking creation (with National ID validation), payment initiation, payment submission, payment verification, wishlist, notifications, admin CRUD. | 2 days | All members | Test results |

---

## Phase 5: Mobile App Development (Weeks 7-10)

### 5.1 Flutter Infrastructure
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.1.1 | Initialize Flutter project | Create Flutter project. Set up directory structure (core/, models/, providers/, screens/, widgets/). Configure pubspec.yaml with dependencies (provider, dio, shared_preferences, cached_network_image, image_picker, flutter_svg, carousel_slider, url_launcher, intl). | 0.5 day | Abebe | Flutter project |
| 5.1.2 | API constants | Create api_constants.dart with environment switching (dev, android, device, prod). Set LAN IP for real device testing. | 0.5 day | Abebe | api_constants.dart |
| 5.1.3 | API service | Create api_service.dart with Dio setup. JWT interceptor (reads token from SharedPreferences, adds Authorization header). Error handling (ApiException with human-readable messages). Two Dio instances: guest API (/api/v1) and admin API (/api/admin). | 1 day | Abebe | api_service.dart |
| 5.1.4 | Validators | Create validators.dart: name (letters only, min 2 chars, Amharic support), email (valid format), phone (Ethiopian format), password (min 6 chars, letters + numbers), transactionId. | 0.5 day | Yohanes | validators.dart |
| 5.1.5 | App theme | Create app_colors.dart with EthioStay color palette (primary blue, accent gold, surface, text). | 0.5 day | Yeshiwas | app_colors.dart |

### 5.2 Data Models
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.2.1 | Hotel model | Create hotel.dart: Hotel (id, name, city, rating, price, images, amenities, isFeatured, isWishlisted), Room (id, name, bedType, maxGuests, price, imageUrl, roomStatus, canBook), City (id, name, region), PaymentMethod (id, method, accountName, accountNumber, phone, instructions). All with fromJson factories. | 1 day | Yohanes | hotel.dart |
| 5.2.2 | Other models | Create booking.dart (Booking with all fields including nationalIdFront/Back, nights getter). Create user.dart (User with role). Create review.dart (Review with rating, comment). Create search_params.dart (HotelSearchParams with toQueryParams). | 1 day | Yohanes | models/ |

### 5.3 State Management (Providers)
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.3.1 | AuthProvider | login (admin-first fallback to guest), register, sendOtp, verifyOtp, logout, restoreSession (from SharedPreferences), extractRoleFromJwt, persistGuestSession, persistAdminSession. | 2 days | Abebe | auth_provider.dart |
| 5.3.2 | HotelProvider | loadHome (3 parallel API calls with 5-min cache), search (with params), loadHotel (detail + rooms), loadAvailability (for dates), postReview, loadPaymentMethods. _hotelList, _cityList helpers. | 2 days | Abebe | hotel_provider.dart |
| 5.3.3 | BookingProvider | createBooking (with nationalIdFront/Back), initiatePayment, submitPayment, loadUserBookings, cancelBooking. | 1.5 days | Abrham | booking_provider.dart |
| 5.3.4 | WishlistProvider | load, toggle (optimistic), remove, isWishlisted check. | 0.5 day | Abrham | wishlist_provider.dart |
| 5.3.5 | LanguageProvider | switch between English/Amharic, save to SharedPreferences, appLocalizations integration. | 0.5 day | Yeshiwas | language_provider.dart |

### 5.4 Auth Screens
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.4.1 | Login screen | Guest tab + Admin tab. Email/password fields with validation. Password visibility toggle. "Forgot password" link. OTP login option. Form validation (email format, password min 6). Error display. | 1.5 days | Yohanes | login_screen.dart |
| 5.4.2 | Register screen | First name, last name, email/phone, password, nationality. Password strength indicator (weak/fair/good/strong/veryStrong). Form validation on all fields. National ID optional upload at registration. | 1.5 days | Yohanes | register_screen.dart |
| 5.4.3 | OTP screen | Phone input, 6-digit code input, resend timer, verify button. | 1 day | Yohanes | otp_screen.dart |
| 5.4.4 | Forgot password | Email input, reset link/code, new password input. | 1 day | Yohanes | forgot_password_screen.dart |

### 5.5 Home and Hotel Screens
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.5.1 | Splash screen | App logo display, auto-transition to home. | 0.5 day | Yeshiwas | splash_screen.dart |
| 5.5.2 | Home screen | 4-tab bottom navigation (Home, Search, Saved, Profile). Auth check on tabs 2-3 (redirect to login if not authenticated). PageView with NeverScrollableScrollPhysics. | 2 days | Yeshiwas | home_screen.dart |
| 5.5.3 | Home tab content | SliverAppBar with hero section (search bar, animated badge, stats). City grid (2-column, local images, hotel count per city). Featured hotels (horizontal scroll, HotelCard). FAQ section. Pull-to-refresh. | 2 days | Yeshiwas | home_screen.dart |
| 5.5.4 | Hotel list screen | Search results with filters (city, price, rating, sort). Hotel cards in grid. Pagination. Empty state. | 1.5 days | Yeshiwas | hotel_list_screen.dart |
| 5.5.5 | Hotel detail screen | Image gallery (PageView with thumbnails). Hotel info header (name, rating, location, amenities). Tab bar (Rooms, Details, Reviews). Room list with availability. Booking bar. Wishlist toggle. Reviews list + form. | 3 days | Yeshiwas | hotel_detail_screen.dart |
| 5.5.6 | City hotels screen | Hotels filtered by city. Same layout as hotel list. | 0.5 day | Yeshiwas | city_hotels_screen.dart |

### 5.6 Booking and Payment Screens
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.6.1 | Booking confirm screen | 2-step wizard. Step 1: Personal info (name, email, phone, nationality) with validation. Stay details (adults/children steppers, capacity bar). National ID upload (front + back, REQUIRED, red border if empty, image picker). Step 2: Payment method grid, account details, transaction ID, screenshot upload. Submit (3 API calls: booking, initiate, submit). Success redirect. | 3 days | Abebe | booking_confirm_screen.dart |
| 5.6.2 | Payment success screen | Booking ID display, success animation, "View My Bookings" button. | 0.5 day | Abrham | payment_success_screen.dart |

### 5.7 Dashboard Screens
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.7.1 | Dashboard screen | User dashboard with booking stats (pending, confirmed, cancelled, completed). Quick links. Profile access. | 1 day | Abrham | dashboard_screen.dart |
| 5.7.2 | Bookings list screen | User's bookings with status badges. Filter by status. Cancel button. Booking detail expansion. | 1.5 days | Abrham | bookings_list_screen.dart |
| 5.7.3 | Profile screen | User profile (name, email, phone, nationality, avatar). Edit profile. Change password. Logout. | 1 day | Abrham | profile_screen.dart |
| 5.7.4 | Wishlist screen | Saved hotels list. Remove from wishlist. Tap to view hotel detail. | 0.5 day | Abrham | wishlist_screen.dart |
| 5.7.5 | Notifications screen | List of notifications (booking confirmed, payment accepted/rejected). Mark as read. Mark all as read. | 1 day | Yohanes | notifications_screen.dart |

### 5.8 Admin Screens
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.8.1 | Admin dashboard screen | Role detection (super_admin, sub_admin, hotel_manager, broker). Route to appropriate dashboard. | 1 day | Yeshiwas | admin_dashboard_screen.dart |
| 5.8.2 | Super admin screen | City CRUD (add, edit, delete). Sub Admin CRUD (add, edit, delete). Assign Sub Admin to city. National overview dashboard. View all hotels, bookings, users. | 2 days | Yeshiwas | super_admin_screen.dart |
| 5.8.3 | Sub admin screen | City dashboard. Hotel CRUD (add, edit, delete, images, Google Maps location). Room CRUD. Manager CRUD + assign. Payment methods. City reports. | 3 days | Yeshiwas | sub_admin_screen.dart |
| 5.8.4 | Hotel manager screen | Hotel dashboard (KPIs). Pending payments list with proof viewer. Accept/Reject payment buttons. View customer National ID images. All bookings with filters. Room status management. Check-in/check-out. Reports. | 3 days | Yeshiwas | hotel_manager_screen.dart |
| 5.8.5 | Admin profile screen | Admin profile view and edit. Change password. | 0.5 day | Yeshiwas | admin_profile_screen.dart |
| 5.8.6 | Broker screen | Broker dashboard. Broker bookings. Inbox/Sent messages. Send message. | 1 day | Yeshiwas | broker_screen.dart |

### 5.9 Widgets and Utilities
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.9.1 | Hotel card widget | Grid card (3:2 image, badges, info section). List card (4:3 image, compact info). Press animation. | 1 day | Yeshiwas | hotel_card.dart |
| 5.9.2 | Image widgets | LocalOrNetworkImage (local asset → network URL → placeholder). HotelImage (network, base64, Google CDN, placeholder). | 1 day | Abebe | local_or_network_image.dart, hotel_image.dart |
| 5.9.3 | Other widgets | StarRating, AppLogo, AppSpinner, LangToggle, AppBarWidgets. | 1 day | Various | widgets/ |
| 5.9.4 | App images | Create app_images.dart with 13 city asset paths, 13 hotel cover paths, network fallback URLs. Download 26 high-quality images (800px). | 1 day | Abrham | app_images.dart + assets |

### 5.10 Localization
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.10.1 | English translations | Create app_localizations.dart with all UI strings in English. | 1 day | Yeshiwas | app_localizations.dart |
| 5.10.2 | Amharic translations | Translate all UI strings to Amharic. | 1 day | Yeshiwas | app_localizations.dart |

### 5.11 Android Configuration
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 5.11.1 | Android config | Set namespace (com.ethiostay.booking). Set minSdk=21, targetSdk, Java 17. Configure gradle.properties (org.gradle.java.home). Set network security config for cleartext traffic. | 0.5 day | Abebe | Android config files |
| 5.11.2 | App icon | Generate EthioStay app icon at 5 sizes (48, 72, 96, 144, 192 px). Create ic_launcher.png and ic_launcher_round.png for all mipmap folders. Create branded splash screen (blue background + logo). | 1 day | Abrham | App icons + splash |
| 5.11.3 | Manifest | Configure AndroidManifest.xml: permissions (INTERNET, CAMERA, storage), cleartext traffic, network security config, enableOnBackInvokedCallback, app icon references. | 0.5 day | Abebe | AndroidManifest.xml |

---

## Phase 6: Web App Development (Weeks 8-10)

### 6.1 React Infrastructure
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 6.1.1 | Initialize React project | Set up Vite + React + TypeScript. Install dependencies (react-router-dom, axios, react-i18next, tailwindcss, lucide-react, framer-motion). Configure tailwind.config. | 0.5 day | Yohanes | React project |
| 6.1.2 | API service | Create api.ts with Axios instance. JWT interceptor. BaseURL configuration. Error handling. | 0.5 day | Yohanes | api.ts |
| 6.1.3 | Auth context | Create AuthContext with login, register, logout, restoreSession (from localStorage). Role detection. | 1 day | Yohanes | AuthContext |
| 6.1.4 | Router | Set up routes.tsx with all page routes. Protected routes (auth required). Admin routes (role-based). | 0.5 day | Yohanes | routes.tsx |

### 6.2 Shared Components
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 6.2.1 | Navbar | Responsive navigation bar. User/admin tabs. Language toggle. User avatar dropdown. | 1 day | Yeshiwas | Navbar.tsx |
| 6.2.2 | Footer | Brand section. Quick links. Contact. Social media. Mobile app download section (Play Store, App Store, QR code, features). | 1 day | Yeshiwas | Footer.tsx |
| 6.2.3 | Common components | Button, Input, Modal, Spinner, Badge, Card, Table, Pagination, Toast, ErrorBoundary. | 2 days | Yeshiwas | components/shared/ |

### 6.3 Guest Pages
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 6.3.1 | Home page | Hero section with search. Featured hotels. City browse. FAQ. Footer. | 1.5 days | Abrham | Home.tsx |
| 6.3.2 | Hotel list page | Search results with filters (city, price, rating, amenities, sort). Hotel cards grid. Pagination. Empty state. | 1.5 days | Abrham | HotelList.tsx |
| 6.3.3 | Hotel detail page | Image gallery. Hotel info. Amenities. Room list with availability. Reviews. Booking button. Google Maps embed. | 2 days | Abrham | HotelDetail.tsx |
| 6.3.4 | Auth pages | Login (guest + admin). Register with validation. OTP. Forgot password. | 2 days | Yohanes | auth/ |
| 6.3.5 | Booking page | Booking form (guest details, dates, guests, National ID upload). Payment method selection. Payment proof upload. | 2 days | Abebe | BookingConfirm.tsx |
| 6.3.6 | Payment pages | Payment page (method selection, proof upload). Payment success page. | 1 day | Abebe | Payment.tsx, PaymentSuccess.tsx |
| 6.3.7 | Dashboard pages | User dashboard (bookings stats). Bookings list (with status, cancel). Profile (edit, change password). Wishlist. | 2 days | Abrham | dashboard/ |

### 6.4 Admin Pages
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 6.4.1 | Admin login | Separate login page for admin users. | 0.5 day | Yohanes | AdminLogin.tsx |
| 6.4.2 | Super admin pages | SuperDashboard (national overview with charts). CitiesPage (CRUD). SubAdminsPage (CRUD). HotelsPage (view all). BookingsPage (view all). UsersPage (view all). | 3 days | Yohanes | super/ |
| 6.4.3 | Sub admin pages | SubAdminDashboard (city KPIs). HotelsPage (CRUD with images + Google Maps). ManagersPage (CRUD + assign). BookingsPage (city bookings). BrokersPage. | 3 days | Yohanes | subadmin/ |
| 6.4.4 | Manager pages | ManagerDashboard (hotel KPIs). BookingsPage (with filters). PaymentsPage (pending payments with accept/reject + proof viewer + National ID viewer). RoomsPage (CRUD + status). PaymentMethodsPage (manage). | 3 days | Yohanes | manager/ |
| 6.4.5 | Settings page | System settings form (app name, contact, payment keys, language, maintenance mode). | 1 day | Yohanes | SettingsPage.tsx |

### 6.5 Web Localization
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 6.5.1 | i18n setup | Configure react-i18next. Create en.ts and am.ts with all UI strings. | 1.5 days | Yeshiwas | i18n/ |
| 6.5.2 | Language toggle | Add language toggle to navbar. Persist choice in localStorage. | 0.5 day | Yeshiwas | LanguageContext |

---

## Phase 7: Integration and Testing (Weeks 10-11)

### 7.1 Integration
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 7.1.1 | Mobile-Backend integration | Connect Flutter app to Go backend. Test all API endpoints from mobile. Fix IP configuration. Verify JWT auth flow. | 1 day | Abebe | Working integration |
| 7.1.2 | Web-Backend integration | Connect React app to Go backend. Test all API endpoints from web. Verify JWT auth flow. | 1 day | Yohanes | Working integration |
| 7.1.3 | Cross-platform consistency | Verify data consistency between mobile and web (same booking shows same status on both). | 0.5 day | All members | Verified |

### 7.2 Testing
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 7.2.1 | Functional testing | Test all use cases: registration, login, OTP, hotel search, hotel detail, room booking with National ID (required), payment submission, payment verification (accept/reject), wishlist, reviews, notifications, admin CRUD for all roles. | 2 days | All members | Test results |
| 7.2.2 | Form validation testing | Test all validators: name (letters only, min 2), email (format), phone (Ethiopian format), password (min 6, letters + numbers), National ID (required front + back), transaction ID. | 1 day | Yohanes | Test results |
| 7.2.3 | Real device testing | Test on TECNO KN3 (Android 15, API 35). Verify: app launch, splash screen, icon, all screens, API connectivity, image loading (local + network), booking flow, payment flow. | 1 day | Abebe | Test results |
| 7.2.4 | Web browser testing | Test on Chrome, Firefox, Edge. Verify: responsive design, all pages, admin dashboards, booking flow, payment flow. | 1 day | Yohanes | Test results |
| 7.2.5 | Security testing | Verify: JWT required on protected endpoints, role-based access (manager cannot access super admin endpoints), SQL injection prevention (parameterized queries), password hashing (bcrypt), National ID protection (only assigned manager can view). | 1 day | Abebe | Security report |
| 7.2.6 | Performance testing | Measure: API response times (<2s), home page load (<3s), booking submission (<3s). Verify 5-minute cache works. | 0.5 day | Abrham | Performance report |

---

## Phase 8: Documentation and Deployment (Weeks 11-12)

### 8.1 Documentation
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 8.1.1 | SRS document | Write full SRS following Debre Markos University format. Include: cover page, abstract, acknowledgement, TOC, list of tables/figures/acronyms, 6 chapters (Introduction, System Analysis, System Design, Implementation, Testing, Conclusion), references, appendices. | 3 days | All members | SRS_Documentation.md |
| 8.1.2 | UML diagrams | Create all 18 UML diagrams: 4 use case diagrams, 10 use case descriptions, 5 sequence diagrams, analysis class diagram, 2 activity diagrams, design class diagram, ER diagram, component diagram, deployment diagram, network diagram. | 2 days | Abebe | UML_Diagrams.md |
| 8.1.3 | WBS document | Write work breakdown structure with all phases, tasks, durations, assignments. | 0.5 day | Yohanes | Work_Breakdown_Structure.md |
| 8.1.4 | Non-functional requirements | Document all 11 NFR categories: performance, usability, security, reliability, scalability, maintainability, portability, internationalization, accessibility, data integrity, auditability. | 0.5 day | Yeshiwas | NFR document |

### 8.2 Deployment Preparation
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 8.2.1 | Build release APK | Build Flutter app in release mode. Verify APK size and functionality. | 0.5 day | Abebe | app-release.apk |
| 8.2.2 | Build web production | Build React app for production (npm run build). Verify dist/ output. | 0.5 day | Yohanes | dist/ |
| 8.2.3 | GitHub repository | Push all code to GitHub. Organize repository structure. Write README with setup instructions. | 0.5 day | All members | GitHub repo |
| 8.2.4 | Deployment guide | Write deployment instructions: Go binary, PostgreSQL, Nginx, SSL, React static files, mobile app to Play Store/App Store. | 0.5 day | Abebe | Deployment guide |

### 8.3 Final Review and Submission
| ID | Task | Sub-Tasks | Duration | Assigned To | Deliverable |
|----|------|----------|----------|------------|-------------|
| 8.3.1 | Internal review | Review all documentation for completeness, accuracy, formatting. Cross-check with university format requirements. | 1 day | All members | Reviewed docs |
| 8.3.2 | Supervisor review | Submit to supervisor for feedback. Make corrections. | 2 days | All members | Approved docs |
| 8.3.3 | Print and bind | Print 3 copies in A4, bind with thick white art paper covers. | 0.5 day | All members | Printed reports |
| 8.3.4 | Final submission | Submit printed reports to department. Submit digital copies. | 0.5 day | All members | Submitted |

---

## GANTT CHART SUMMARY

```
Week:   1   2   3   4   5   6   7   8   9   10  11  12
        |---|---|---|---|---|---|---|---|---|---|---|---|
P1:     |=======|                                           Planning & Requirements
P2:         |=======|                                       System Analysis
P3:             |===|                                       Database Setup
P4:                 |=======|                               Backend Development
P5:                     |=======|                           Mobile App Development
P6:                         |=======|                       Web App Development
P7:                                 |===|                   Integration & Testing
P8:                                     |===|               Documentation & Deployment
```

## EFFORT SUMMARY

| Phase | Duration | Tasks | Main Assignee |
|-------|----------|-------|---------------|
| Phase 1: Planning & Requirements | 2 weeks | 8 | All members |
| Phase 2: System Analysis | 2 weeks | 8 | All members |
| Phase 3: Database Setup | 1 week | 4 | Yohanes |
| Phase 4: Backend Development | 2.5 weeks | 20 | Abebe, Yohanes, Abrham, Yeshiwas |
| Phase 5: Mobile App Development | 3.5 weeks | 30 | Abebe, Yeshiwas, Abrham, Yohanes |
| Phase 6: Web App Development | 2.5 weeks | 15 | Yohanes, Abrham, Yeshiwas |
| Phase 7: Integration & Testing | 1 week | 6 | All members |
| Phase 8: Documentation & Deployment | 1.5 weeks | 10 | All members |
| **Total** | **12 weeks** | **101 tasks** | |

## TEAM RESPONSIBILITY MATRIX (RACI)

| Task | Abebe | Abrham | Yeshiwas | Yohanes |
|------|-------|--------|----------|---------|
| Requirements | R | R | R | R |
| System Analysis | R | R | R | R |
| Database Design | C | C | C | A |
| Backend Auth | C | C | C | R |
| Backend Hotels | R | C | C | C |
| Backend Booking | C | R | C | C |
| Backend Admin | C | C | R | C |
| Flutter Infrastructure | R | C | C | C |
| Flutter Auth Screens | C | C | C | R |
| Flutter Home/Hotel | C | C | R | C |
| Flutter Booking | R | C | C | C |
| Flutter Admin | C | C | R | C |
| Flutter Dashboard | C | R | C | C |
| React Infrastructure | C | C | C | R |
| React Guest Pages | C | R | C | C |
| React Admin Pages | C | C | C | R |
| React Components | C | C | R | C |
| Localization | C | C | R | C |
| Testing | R | R | R | R |
| Documentation | R | R | R | R |
| Deployment | R | C | C | C |

R = Responsible (does the work)
A = Accountable (final approval)
C = Consulted (provides input)

---

*This Work Breakdown Structure follows the Debre Markos University format for Section 1.13 of the Project Proposal.*
