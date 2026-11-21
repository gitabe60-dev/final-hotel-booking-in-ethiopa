# UML DIAGRAMS
## Hotel Reservation and Booking Management System in Ethiopia

---

## Table of Contents

1. Use Case Diagrams
   1.1 User (Customer) Use Case Diagram
   1.2 Hotel Manager Use Case Diagram
   1.3 Sub Admin Use Case Diagram
   1.4 Super Admin Use Case Diagram
2. Use Case Descriptions
   2.1 UC-01: Register Account
   2.2 UC-02: Search Hotels by City
   2.3 UC-03: Book a Room
   2.4 UC-04: Upload National ID/Passport
   2.5 UC-05: Make Payment
   2.6 UC-06: Verify Payment
   2.7 UC-07: Manage Hotels
   2.8 UC-08: Manage Rooms
   2.9 UC-09: Manage Cities
   2.10 UC-10: Assign Sub Admin to City
3. Sequence Diagrams
   3.1 Sequence Diagram: User Registration
   3.2 Sequence Diagram: Hotel Search
   3.3 Sequence Diagram: Room Booking with National ID
   3.4 Sequence Diagram: Payment Submission
   3.5 Sequence Diagram: Payment Verification by Manager
4. Analysis Class Diagram
5. Activity Diagrams
   5.1 Activity Diagram: Complete Booking Process
   5.2 Activity Diagram: Payment Verification Process
6. Design Class Diagram
7. ER Diagram (Physical Data Model)
8. Component Diagram
9. Deployment Diagram
10. Network Diagram

---

## 1. USE CASE DIAGRAMS

### 1.1 User (Customer) Use Case Diagram

```
                           +------------------------------------------+
                           |            HOTEL BOOKING SYSTEM          |
                           |                                          |
   +-------+               |  +------------+    +-----------------+   |
   |       |--(Register)-->|  | Register   |    | Search Hotels   |   |
   |       |               |  +------------+    +-----------------+   |
   |       |--(Login)----->|  +------------+    +-----------------+   |
   |       |               |  | Login      |    | View Hotel     |   |
   |       |--(OTP)------->|  +------------+    | Details        |   |
   |       |               |  +------------+    +-----------------+   |
   |       |--(Search)---->|  | OTP Login  |    +-----------------+   |
   |  USER |               |  +------------+    | View Room      |   |
   |(Custo-|               |  +------------+    | Availability   |   |
   |  mer) |--(View Hotel)->| | Search    |    +-----------------+   |
   |       |               |  +------------+    +-----------------+   |
   |       |--(View Room)->|  | View Hotel |    | Book Room       |   |
   |       |               |  +------------+    +-----------------+   |
   |       |--(Book Room)-->|                     +-----------------+ |
   |       |               |                     | Upload National | |
   |       |--(Upload ID)->|                     | ID (Required)   | |
   |       |               |                     +-----------------+ |
   |       |--(Pay)------->|                     +-----------------+ |
   |       |               |                     | Select Payment  | |
   |       |--(View History)->|                  | Method          | |
   |       |               |                     +-----------------+ |
   |       |--(Cancel)---->|                     +-----------------+ |
   |       |               |                     | View Booking    | |
   |       |--(Wishlist)-->|                     | History          | |
   |       |               |                     +-----------------+ |
   |       |--(Review)---->|                     +-----------------+ |
   |       |               |                     | Cancel Booking   | |
   |       |--(Profile)--->|                     +-----------------+ |
   |       |               |                     +-----------------+ |
   |       |--(Notif)----->|                     | Write Review     | |
   +-------+               |                     +-----------------+ |
                           |                     +-----------------+ |
                           |                     | Add to Wishlist  | |
                           |                     +-----------------+ |
                           |                     +-----------------+ |
                           |                     | View Profile     | |
                           |                     +-----------------+ |
                           |                     +-----------------+ |
                           |                     | View Notifications| |
                           |                     +-----------------+ |
                           |                     +-----------------+ |
                           |                     | Change Language   | |
                           |                     +-----------------+ |
                           +------------------------------------------+
                                          |
                                          | <<include>>
                                          v
                               +-------------------+
                               | Authentication     |
                               | (JWT Token)        |
                               +-------------------+
```

**Actors:** User (Customer)
**Use Cases:** Register, Login, OTP Login, Search Hotels, View Hotel Details, View Room Availability, Book Room, Upload National ID (Required), Select Payment Method, Upload Payment Screenshot, View Booking History, Cancel Booking, Add to Wishlist, Write Review, View Profile, Edit Profile, View Notifications, Change Language
**Include relationship:** All booking-related use cases include Authentication

---

### 1.2 Hotel Manager Use Case Diagram

```
                           +------------------------------------------+
                           |            HOTEL BOOKING SYSTEM          |
                           |                                          |
   +-------+               |  +------------+    +-----------------+   |
   |       |--(Login)----->|  | Login      |    | View Dashboard  |   |
   |       |               |  +------------+    +-----------------+   |
   |       |--(Dashboard)->|                                          |
   | HOTEL |               |  +-----------------+                     |
   |MANAGER|               |  | View All        |                     |
   |       |--(View Book)->|  | Bookings        |                     |
   |       |               |  +-----------------+                     |
   |       |--(View Pay)-> |  +-----------------+                     |
   |       |               |  | View Pending   |                     |
   |       |--(Verify Pay)->| | Payments       |                     |
   |       |               |  +-----------------+                     |
   |       |--(Accept Pay)->| +-----------------+                      |
   |       |               |  | Accept Payment  |                     |
   |       |--(Reject Pay)->| +-----------------+                      |
   |       |               |  +-----------------+                     |
   |       |--(View ID)--->|  | Reject Payment  |                     |
   |       |               |  +-----------------+                     |
   |       |--(Room Status>|  +-----------------+                      |
   |       |               |  | View Customer  |                      |
   |       |--(Check-in)-> |  | National ID    |                      |
   |       |               |  +-----------------+                     |
   |       |--(Check-out)->|  +-----------------+                      |
   |       |               |  | Update Room    |                      |
   |       |--(Reports)--->|  | Status         |                      |
   |       |               |  +-----------------+                     |
   |       |--(Notif)----->|  +-----------------+                      |
   |       |               |  | Check-in/      |                      |
   |       |--(Manage Room>|  | Check-out      |                      |
   |       |               |  +-----------------+                     |
   |       |--(Pay Methods>|  +-----------------+                      |
   |       |               |  | View Reports   |                      |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | View            |                     |
   |       |               |  | Notifications    |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | Manage Rooms   |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | Manage Payment |                     |
   |       |               |  | Methods        |                     |
   |       |               |  +-----------------+                     |
   +-------+               +------------------------------------------+
                                          |
                                          | <<include>>
                                          v
                               +-------------------+
                               | Admin Auth (JWT)  |
                               | Role: hotel_mgr   |
                               +-------------------+
```

**Actors:** Hotel Manager
**Use Cases:** Login, View Dashboard, View All Bookings, View Pending Payments, Accept Payment, Reject Payment, View Customer National ID, Update Room Status, Check-in, Check-out, View Reports, View Notifications, Manage Rooms, Manage Payment Methods
**Include relationship:** All use cases include Admin Authentication with role = hotel_manager

---

### 1.3 Sub Admin Use Case Diagram

```
                           +------------------------------------------+
                           |            HOTEL BOOKING SYSTEM          |
                           |                                          |
   +-------+               |  +------------+    +-----------------+   |
   |       |--(Login)----->|  | Login      |    | View City       |   |
   |       |               |  +------------+    | Dashboard       |   |
   |       |--(Dashboard)->|                    +-----------------+   |
   | SUB   |               |  +-----------------+                     |
   | ADMIN |               |  | Create Hotel   |                      |
   |       |--(Add Hotel)->|  +-----------------+                      |
   |       |               |  +-----------------+                      |
   |       |--(Edit Hotel)->| | Edit Hotel     |                      |
   |       |               |  +-----------------+                     |
   |       |--(Del Hotel)->|  +-----------------+                      |
   |       |               |  | Delete Hotel   |                     |
   |       |--(Upload Img)->| +-----------------+                      |
   |       |               |  +-----------------+                     |
   |       |--(Set Location>| | Upload Hotel   |                     |
   |       |               |  | Images         |                     |
   |       |--(Add Room)--->| +-----------------+                      |
   |       |               |  +-----------------+                      |
   |       |--(Edit Room)->|  | Set Google Maps|                     |
   |       |               |  | Location       |                     |
   |       |--(Del Room)--->| +-----------------+                      |
   |       |               |  +-----------------+                     |
   |       |--(Add Manager>|  | Add Room       |                     |
   |       |               |  +-----------------+                     |
   |       |--(Edit Manager>| +-----------------+                      |
   |       |               |  | Edit Room      |                     |
   |       |--(Del Manager>|  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |--(Reports)--->|  | Delete Room    |                     |
   |       |               |  +-----------------+                     |
   |       |--(Pay Methods>|  +-----------------+                      |
   |       |               |  | Assign Hotel   |                      |
   |       |               |  | Manager        |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | Edit/Delete    |                     |
   |       |               |  | Manager        |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | View City      |                     |
   |       |               |  | Reports        |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | Manage Payment |                     |
   |       |               |  | Methods        |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | View City      |                     |
   |       |               |  | Bookings       |                     |
   |       |               |  +-----------------+                     |
   +-------+               +------------------------------------------+
                                          |
                                          | <<include>>
                                          v
                               +-------------------+
                               | Admin Auth (JWT)  |
                               | Role: sub_admin    |
                               +-------------------+
```

**Actors:** Sub Admin
**Use Cases:** Login, View City Dashboard, Create Hotel, Edit Hotel, Delete Hotel, Upload Hotel Images, Set Google Maps Location, Add Room, Edit Room, Delete Room, Upload Room Images, Assign Hotel Manager, Edit/Delete Manager, View City Reports, Manage Payment Methods, View City Bookings
**Include relationship:** All use cases include Admin Authentication with role = sub_admin

---

### 1.4 Super Admin Use Case Diagram

```
                           +------------------------------------------+
                           |            HOTEL BOOKING SYSTEM          |
                           |                                          |
   +-------+               |  +------------+    +-----------------+   |
   |       |--(Login)----->|  | Login      |    | View National   |   |
   |       |               |  +------------+    | Dashboard       |   |
   |       |--(Dashboard)->|                    +-----------------+   |
   | SUPER |               |  +-----------------+                     |
   | ADMIN |               |  | Create City    |                      |
   |       |--(Add City)--->| +-----------------+                      |
   |       |               |  +-----------------+                      |
   |       |--(Edit City)->|  | Edit City      |                      |
   |       |               |  +-----------------+                     |
   |       |--(Del City)--->|  +-----------------+                     |
   |       |               |  | Delete City    |                     |
   |       |--(Add SubAdmin>| +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |--(Edit SubAdmin>| | Create Sub    |                     |
   |       |               |  | Admin          |                     |
   |       |--(Del SubAdmin>|  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |--(Assign)---->|  | Edit Sub Admin |                     |
   |       |               |  +-----------------+                     |
   |       |--(Settings)->|  +-----------------+                      |
   |       |               |  | Delete Sub    |                     |
   |       |--(View Reports>| | Admin          |                     |
   |       |               |  +-----------------+                     |
   |       |--(View Hotels)>| +-----------------+                     |
   |       |               |  | Assign Sub     |                     |
   |       |--(View Bookings>| | Admin to City |                     |
   |       |               |  +-----------------+                     |
   |       |--(View Users)->|  +-----------------+                     |
   |       |               |  | Revoke City    |                     |
   |       |               |  | Assignment     |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | System Settings |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | View All       |                     |
   |       |               |  | Bookings        |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | View All Users |                     |
   |       |               |  +-----------------+                     |
   |       |               |  +-----------------+                     |
   |       |               |  | View All       |                     |
   |       |               |  | Hotels         |                     |
   |       |               |  +-----------------+                     |
   +-------+               +------------------------------------------+
                                          |
                                          | <<include>>
                                          v
                               +-------------------+
                               | Admin Auth (JWT)  |
                               | Role: super_admin |
                               +-------------------+
```

**Actors:** Super Admin
**Use Cases:** Login, View National Dashboard, Create City, Edit City, Delete City, Create Sub Admin, Edit Sub Admin, Delete Sub Admin, Assign Sub Admin to City, Revoke City Assignment, System Settings, View All Bookings, View All Users, View All Hotels
**Include relationship:** All use cases include Admin Authentication with role = super_admin

---

## 2. USE CASE DESCRIPTIONS

### 2.1 UC-01: Register Account

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-01 |
| **Use Case Name** | Register Account |
| **Actor** | User (Customer) |
| **Description** | A new customer creates an account to access the booking system |
| **Preconditions** | User does not have an existing account. Backend server is running. |
| **Postconditions** | A new user account is created with status "active". User is logged in. |
| **Main Flow** | 1. User opens the app and taps "Register". 2. User enters first name (letters only). 3. User enters last name (letters only). 4. User enters email or phone. 5. User enters password (min 6 chars, letters + numbers). 6. User optionally enters nationality. 7. System validates all fields. 8. System checks for duplicate email/phone. 9. System hashes password with bcrypt. 10. System creates user record in database. 11. System generates JWT token. 12. System saves token in SharedPreferences. 13. User is redirected to home page. |
| **Alternative Flow** | A1: Invalid email format → System shows "Enter a valid email address". A2: Duplicate email → System shows "Account already exists". A3: Weak password → System shows "Password must contain at least one number". A4: OTP login → User selects OTP, enters phone, receives code, verifies. |

### 2.2 UC-02: Search Hotels by City

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-02 |
| **Use Case Name** | Search Hotels by City |
| **Actor** | User (Customer) |
| **Description** | User searches for hotels in a specific Ethiopian city |
| **Preconditions** | User is on the home page. Backend server is running. |
| **Postconditions** | List of hotels in the selected city is displayed with images, ratings, and prices. |
| **Main Flow** | 1. User views home page with city grid. 2. User taps a city card (e.g., "Addis Ababa"). 3. App sends GET /api/v1/hotels/search?city=Addis%20Ababa to backend. 4. Backend queries hotels table WHERE city = selected city AND is_active = true. 5. Backend returns hotel list with images, ratings, prices. 6. App displays hotel cards in a grid. 7. User can filter by price, rating, or amenities. |
| **Alternative Flow** | A1: No hotels in city → App shows "No hotels found". A2: Network error → App shows cached data or error message. |

### 2.3 UC-03: Book a Room

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-03 |
| **Use Case Name** | Book a Room |
| **Actor** | User (Customer) |
| **Description** | User selects a room, fills booking form, uploads National ID, and selects payment method |
| **Preconditions** | User is logged in. User has selected a hotel and room. |
| **Postconditions** | A booking record is created with status "pending". A payment record is auto-created. Hotel Manager receives notification. |
| **Main Flow** | 1. User selects a hotel from search results. 2. User selects check-in and check-out dates. 3. App sends GET /api/v1/hotels/:id/availability to check room availability. 4. User selects an available room. 5. User taps "Book Now". 6. App opens booking form (Step 1). 7. User fills: first name, last name, email/phone, nationality. 8. User sets adults and children count. 9. User uploads National ID front image (REQUIRED). 10. User uploads National ID back image (REQUIRED). 11. User taps "Continue to Payment". 12. System validates: form fields, email-or-phone present, guests within capacity, ID front uploaded, ID back uploaded. 13. If any validation fails → show error message and block. 14. App moves to Step 2 (Payment). 15. User selects payment method (Telebirr/CBE Birr/Bank Transfer/banks). 16. User enters transaction ID. 17. User uploads payment screenshot. 18. User taps "Confirm and Submit". 19. App sends POST /api/v1/bookings with all data including national_id_front, national_id_back. 20. Backend validates national ID is present (REQUIRED). 21. Backend creates booking (status=pending). 22. Backend auto-creates payment record. 23. Backend sends notification to Hotel Manager. 24. App sends POST /api/v1/payments/initiate. 25. App sends POST /api/v1/payments/:id/submit with transaction ID and screenshot. 26. App shows Payment Success screen with booking ID. |
| **Alternative Flow** | A1: National ID not uploaded → "Please upload your National ID / Passport (front side)". A2: Guests exceed capacity → "Total guests exceed room capacity". A3: Backend rejects (missing ID) → "National ID / Passport front and back images are required". A4: Backend rejects (past date) → "Check-in date cannot be in the past". |

### 2.4 UC-04: Upload National ID/Passport

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-04 |
| **Use Case Name** | Upload National ID/Passport |
| **Actor** | User (Customer) |
| **Description** | User uploads front and back images of their National ID or Passport as part of the booking process |
| **Preconditions** | User is on the booking form Step 1. |
| **Postconditions** | Two base64-encoded image strings are stored in memory (_idFrontB64, _idBackB64). |
| **Main Flow** | 1. User taps "Front *" upload box. 2. App opens image picker (gallery). 3. User selects an image. 4. App compresses image (quality 80, max 1200x1200). 5. App converts to base64 data URI: data:image/jpeg;base64,... 6. App stores in _idFrontB64. 7. App displays image preview with green border. 8. User taps "Back *" upload box. 9. Repeat steps 2-7 for back image. 10. Both boxes show green borders (uploaded). 11. Warning message disappears. 12. "Continue to Payment" button is now actionable. |
| **Alternative Flow** | A1: User cancels image picker → box stays empty with red border. A2: Image too large → app compresses automatically. A3: Image format unsupported → app shows error. |

### 2.5 UC-05: Make Payment

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-05 |
| **Use Case Name** | Make Payment |
| **Actor** | User (Customer) |
| **Description** | User selects a payment method and submits payment proof |
| **Preconditions** | User has completed Step 1 (guest details + National ID uploaded). Booking has been created. |
| **Postconditions** | Payment record status is "pending". Payment is sent to Hotel Manager for verification. |
| **Main Flow** | 1. User is on Step 2 (Payment). 2. App displays available payment methods for the hotel. 3. User selects a method (e.g., Telebirr). 4. App shows account details (account name, number, phone). 5. User makes payment externally (Telebirr app, bank transfer). 6. User enters transaction ID. 7. User uploads payment screenshot. 8. User taps "Confirm and Submit". 9. App sends POST /api/v1/payments/:id/submit. 10. Backend stores transaction_id and screenshot_url. 11. Backend sends notification to Hotel Manager. 12. App shows Payment Success screen. |
| **Alternative Flow** | A1: No payment method selected → "Select a payment method". A2: Invalid transaction ID → validation error. A3: No screenshot → "Payment screenshot is required". |

### 2.6 UC-06: Verify Payment

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-06 |
| **Use Case Name** | Verify Payment |
| **Actor** | Hotel Manager |
| **Description** | Hotel Manager reviews payment proof and accepts or rejects it |
| **Preconditions** | A booking with pending payment exists for the manager's hotel. Manager is logged in. |
| **Postconditions** | Payment status updated. Booking status updated. Room status updated. User notified. |
| **Main Flow** | 1. Manager opens dashboard. 2. Manager sees pending payment count. 3. Manager taps "Pending Payments". 4. App displays list of pending payments with: customer name, amount, method, screenshot. 5. Manager taps a payment to view details. 6. Manager views: booking details, customer National ID images, payment screenshot. 7. Manager taps "Accept". 8. App sends POST /api/admin/manager/payments/:id/verify with action=accept. 9. Backend updates payment status to "completed". 10. Backend updates booking status to "confirmed". 11. Backend updates room status to "occupied". 12. Backend sends notification to user: "Payment confirmed". 13. Manager sees success message. |
| **Alternative Flow** | A1: Manager taps "Reject" → Payment status="failed", booking="cancelled", room="available", user notified "Payment rejected". A2: Manager not assigned to this hotel → access denied. |

### 2.7 UC-07: Manage Hotels

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-07 |
| **Use Case Name** | Manage Hotels |
| **Actor** | Sub Admin |
| **Description** | Sub Admin creates, edits, or deletes hotels in their assigned city |
| **Preconditions** | Sub Admin is logged in and assigned to a city. |
| **Postconditions** | Hotel record is created, updated, or deleted in the database. |
| **Main Flow** | 1. Sub Admin opens hotel management. 2. Sub Admin taps "Add Hotel". 3. Sub Admin fills form: name, city (auto-filled from assignment), address, description, type, price_per_night, amenities. 4. Sub Admin uploads hotel images. 5. Sub Admin sets Google Maps location (latitude, longitude). 6. Sub Admin taps "Save". 7. Backend creates hotel record. 8. Backend creates hotel_images records. 9. Backend creates hotel_amenities records. 10. Backend seeds default payment methods for the hotel. 11. Hotel appears in the hotel list. |
| **Alternative Flow** | A1: Invalid data → validation error. A2: Duplicate name → warning. A3: Delete hotel with bookings → blocked (FK constraint). |

### 2.8 UC-08: Manage Rooms

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-08 |
| **Use Case Name** | Manage Rooms |
| **Actor** | Sub Admin / Hotel Manager |
| **Description** | Creates, edits, or deletes room types within a hotel |
| **Preconditions** | A hotel exists. User is logged in with appropriate role. |
| **Postconditions** | Room type record is created, updated, or deleted. |
| **Main Flow** | 1. User opens room management for a hotel. 2. User taps "Add Room". 3. User fills form: name, bed_type, price_per_night, max_guests, size_sqm, image_url. 4. User taps "Save". 5. Backend creates room_types record. 6. Room appears in room list. |
| **Alternative Flow** | A1: Delete room with active bookings → blocked. A2: Edit room price → existing bookings keep old price. |

### 2.9 UC-09: Manage Cities

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-09 |
| **Use Case Name** | Manage Cities |
| **Actor** | Super Admin |
| **Description** | Super Admin creates, edits, or deletes Ethiopian cities |
| **Preconditions** | Super Admin is logged in. |
| **Postconditions** | City record is created, updated, or deleted. |
| **Main Flow** | 1. Super Admin opens city management. 2. Super Admin taps "Add City". 3. Super Admin fills form: name, region. 4. Super Admin taps "Save". 5. Backend creates cities record. 6. City appears in city list. |
| **Alternative Flow** | A1: Duplicate city name → error (UNIQUE constraint). A2: Delete city with hotels → blocked. |

### 2.10 UC-10: Assign Sub Admin to City

| Field | Description |
|-------|-------------|
| **Use Case ID** | UC-10 |
| **Use Case Name** | Assign Sub Admin to City |
| **Actor** | Super Admin |
| **Description** | Super Admin assigns a Sub Admin to manage a specific city |
| **Preconditions** | City exists. Sub Admin account exists. |
| **Postconditions** | admin_city_assignments record is created. |
| **Main Flow** | 1. Super Admin opens Sub Admin management. 2. Super Admin selects a Sub Admin. 3. Super Admin selects a city from dropdown. 4. Super Admin taps "Assign". 5. Backend creates admin_city_assignments record. 6. Sub Admin now has access to hotels in that city. |
| **Alternative Flow** | A1: City already has a Sub Admin → reassign (update record). A2: Revoke assignment → DELETE record. |

---

## 3. SEQUENCE DIAGRAMS

### 3.1 Sequence Diagram: User Registration

```
 User        Mobile App       API Service       Go Backend      PostgreSQL
  |               |                |                 |               |
  |--Tap Register>|                |                 |               |
  |               |--Show form---->|                 |               |
  |<--Display form-|               |                 |               |
  |--Fill form--->|                |                 |               |
  |--Tap Submit-->|                |                 |               |
  |               |--Validate----->|                 |               |
  |               |  (name,email,  |                 |               |
  |               |   phone,pwd)   |                 |               |
  |               |                |--POST /auth/register->|          |
  |               |                |                 |--Check email->|
  |               |                |                 |  duplicate    |
  |               |                |                 |<-no dup------|
  |               |                |                 |--Hash password|
  |               |                |                 |  (bcrypt)     |
  |               |                |                 |--INSERT user->|
  |               |                |                 |<-user_id------|
  |               |                |                 |--Generate JWT>|
  |               |                |<-user+token------|               |
  |               |<--Store token--|                 |               |
  |               |  in SharedPref  |                 |               |
  |<--Go to Home---|                |                 |               |
  |               |                |                 |               |
```

### 3.2 Sequence Diagram: Hotel Search

```
 User        Mobile App       API Service       Go Backend      PostgreSQL
  |               |                |                 |               |
  |--Tap City---->|                |                 |               |
  |  (Addis Ababa)|                |                 |               |
  |               |--GET /hotels/  |                 |               |
  |               |  search?city=  |                 |               |
  |               |  Addis+Ababa-->|                 |               |
  |               |                |--Send request--->|               |
  |               |                |                 |--SELECT hotels>|
  |               |                |                 |  WHERE city=  |
  |               |                |                 |  Addis Ababa  |
  |               |                |                 |  AND is_active|
  |               |                |                 |<-hotel rows---|
  |               |                |                 |--SELECT images>|
  |               |                |                 |  for each hotel|
  |               |                |                 |<-image rows---|
  |               |                |<-hotel list-----|               |
  |               |                |  + images        |               |
  |               |<--Display------|                 |               |
  |               |  hotel cards   |                 |               |
  |               |  with images   |                 |               |
  |<--Show hotels-|                |                 |               |
  |               |                |                 |               |
```

### 3.3 Sequence Diagram: Room Booking with National ID

```
 User        Mobile App       API Service       Go Backend      PostgreSQL
  |               |                |                 |               |
  |--Select room->|                |                 |               |
  |--Select dates>|                |                 |               |
  |               |--GET /hotels/   |                 |               |
  |               |  :id/availability|                 |               |
  |               |--------------->|--Send----------->|               |
  |               |                |                 |--Check rooms->|
  |               |                |                 |  for dates    |
  |               |                |<-available rooms-|               |
  |<--Show rooms--|                |                 |               |
  |--Tap Book--->|                 |                 |               |
  |               |--Show Step 1--|                 |               |
  |               |  (guest form)  |                 |               |
  |--Fill name-->|                |                 |               |
  |--Fill email->|                |                 |               |
  |--Fill phone->|                |                 |               |
  |--Upload ID   |                |                 |               |
  |  front------>| (base64)        |                 |               |
  |--Upload ID   |                |                 |               |
  |  back------->| (base64)        |                 |               |
  |--Tap Continue>|               |                 |               |
  |               |--Validate form-|                 |               |
  |               |  + check ID    |                 |               |
  |               |  front != null |                 |               |
  |               |  + check ID    |                 |               |
  |               |  back != null  |                 |               |
  |               |--Show Step 2--|                 |               |
  |               |  (payment)     |                 |               |
  |--Select pay->|                |                 |               |
  |  method      |                |                 |               |
  |--Enter txn-->|                |                 |               |
  |--Upload shot->| (base64)        |                 |               |
  |--Tap Submit->|                |                 |               |
  |               |--POST /bookings->|               |               |
  |               |  {hotel_id,    |                 |               |
  |               |   room_type_id,|                 |               |
  |               |   dates, guests,|                 |               |
  |               |   national_id_ |                 |               |
  |               |   front,       |                 |               |
  |               |   national_id_ |                 |               |
  |               |   back,        |                 |               |
  |               |   payment_method}|               |               |
  |               |                |--Send----------->|               |
  |               |                |                 |--Validate     |
  |               |                |                 |  required     |
  |               |                |                 |  fields       |
  |               |                |                 |--Validate     |
  |               |                |                 |  national_id  |
  |               |                |                 |  front+back   |
  |               |                |                 |  NOT empty    |
  |               |                |                 |--Calculate    |
  |               |                |                 |  total_price  |
  |               |                |                 |--INSERT       |
  |               |                |                 |  booking------>|
  |               |                |                 |<-booking_id----|
  |               |                |                 |--INSERT       |
  |               |                |                 |  payment------>|
  |               |                |                 |--INSERT       |
  |               |                |                 |  notification->|
  |               |                |<-booking_id----|               |
  |               |                |                 |               |
  |               |--POST /payments/|               |               |
  |               |  initiate------>|               |               |
  |               |                |--Send----------->|               |
  |               |                |                 |--Create pay   |
  |               |                |                 |  record------->|
  |               |                |<-payment_id----|               |
  |               |                |                 |               |
  |               |--POST /payments/|               |               |
  |               |  :id/submit---->|               |               |
  |               |  {txn_id,      |                 |               |
  |               |   screenshot}   |                 |               |
  |               |                |--Send----------->|               |
  |               |                |                 |--UPDATE pay   |
  |               |                |                 |  screenshot-->|
  |               |                |<-success--------|               |
  |               |                |                 |               |
  |<--Show Success|               |                 |               |
  |  (Booking ID) |               |                 |               |
  |               |                |                 |               |
```

### 3.4 Sequence Diagram: Payment Submission

```
 User        Mobile App       API Service       Go Backend      PostgreSQL
  |               |                |                 |               |
  |--Enter txn-->|                |                 |               |
  |  ID           |                |                 |               |
  |--Upload shot->|                |                 |               |
  |--Tap Submit->|                |                 |               |
  |               |--Validate:     |                 |               |
  |               |  txn_id format |                 |               |
  |               |  screenshot    |                 |               |
  |               |  not null      |                 |               |
  |               |--POST /payments/|               |               |
  |               |  :id/submit---->|               |               |
  |               |                |--Auth check----->|               |
  |               |                |                 |  (JWT token)  |
  |               |                |                 |--Verify token |
  |               |                |                 |--Get payment->|
  |               |                |                 |  record by ID |
  |               |                |                 |<-payment row--|
  |               |                |                 |--UPDATE       |
  |               |                |                 |  transaction_id|
  |               |                |                 |  screenshot_url|
  |               |                |                 |  status=pending|
  |               |                |                 |--INSERT       |
  |               |                |                 |  notification->|
  |               |                |                 |  (to manager)  |
  |               |                |<-success-------|               |
  |               |<--Show success-|                |               |
  |<--Booking ID--|                |                 |               |
  |               |                |                 |               |
```

### 3.5 Sequence Diagram: Payment Verification by Manager

```
 Manager      Manager App      API Service       Go Backend     PostgreSQL    User
  |               |                |                 |             |          |
  |--Login------->|                |                 |             |          |
  |               |--POST /admin/  |                 |             |          |
  |               |  login-------->|                  |             |          |
  |               |                |--Verify creds--->|             |          |
  |               |                |<-admin JWT------|             |          |
  |<--Dashboard---|                |                 |             |          |
  |               |                |                 |             |          |
  |--Tap Pending->|                |                 |             |          |
  |  Payments     |                |                 |             |          |
  |               |--GET /manager/ |                 |             |          |
  |               |  payments----->|--Send----------->|             |          |
  |               |                |                 |--SELECT     |          |
  |               |                |                 |  payments---->|          |
  |               |                |                 |  WHERE status|          |
  |               |                |                 |  =pending    |          |
  |               |                |                 |  AND hotel_id|          |
  |               |                |                 |  =manager's  |          |
  |               |                |                 |<-pay rows----|          |
  |               |                |<-payment list---|             |          |
  |<--Show list---|                |                 |             |          |
  |               |                |                 |             |          |
  |--Tap payment->|                |                 |             |          |
  |               |--GET payment   |                 |             |          |
  |               |  details------->|--Send---------->|             |          |
  |               |                |                 |--SELECT book>|          |
  |               |                |                 |  + national  |          |
  |               |                |                 |  ID images   |          |
  |               |                |                 |<-details----|          |
  |               |                |<-payment+ID----|             |          |
  |<--Show proof--|                |                 |             |          |
  |  + ID images  |                |                 |             |          |
  |               |                |                 |             |          |
  |--Tap Accept->|                |                 |             |          |
  |               |--POST /manager/|                 |             |          |
  |               |  payments/:id/ |                 |             |          |
  |               |  verify-------->|                  |             |          |
  |               |  {action:      |                 |             |          |
  |               |   accept}      |                 |             |          |
  |               |                |--Auth+Role check>|             |          |
  |               |                |                 |  (hotel_mgr) |          |
  |               |                |                 |--UPDATE pay  |          |
  |               |                |                 |  status=     |          |
  |               |                |                 |  completed---->|          |
  |               |                |                 |--UPDATE book  |          |
  |               |                |                 |  status=      |          |
  |               |                |                 |  confirmed---->|          |
  |               |                |                 |--UPDATE room  |          |
  |               |                |                 |  status=      |          |
  |               |                |                 |  occupied----->|          |
  |               |                |                 |--INSERT notif |          |
  |               |                |                 |  (to user)---->|          |
  |               |                |                 |             |          |
  |               |                |                 |             |----Notif->|
  |               |                |                 |             | "Payment   |
  |               |                |                 |             |  Confirmed"|
  |               |                |<-success-------|             |          |
  |<--Done--------|                |                 |             |          |
  |               |                |                 |             |          |

  ALTERNATIVE: Manager taps Reject
  |--Tap Reject->|                |                 |             |          |
  |               |--POST verify   |                 |             |          |
  |               |  {action:     |                 |             |          |
  |               |   reject}------>|               |             |          |
  |               |                |                 |--UPDATE pay  |          |
  |               |                |                 |  status=failed|
  |               |                |                 |--UPDATE book  |          |
  |               |                |                 |  status=cancelled|
  |               |                |                 |--UPDATE room  |          |
  |               |                |                 |  status=available|
  |               |                |                 |--INSERT notif |          |
  |               |                |                 |  "Payment    |          |
  |               |                |                 |   Rejected"  |          |
  |               |                |                 |             |----Notif->|
  |               |                |<-success-------|             |          |
  |<--Done--------|                |                 |             |          |
```

---

## 4. ANALYSIS CLASS DIAGRAM

```
+-----------------------------------------------------------+
|                        User                                |
+-----------------------------------------------------------+
| - id: int                                                  |
| - firstName: String                                         |
| - lastName: String                                          |
| - email: String                                            |
| - phone: String                                            |
| - passwordHash: String                                     |
| - nationality: String                                      |
| - status: String                                           |
| - isVerified: boolean                                       |
| - registeredDate: DateTime                                  |
+-----------------------------------------------------------+
| + register()                                                |
| + login()                                                   |
| + updateProfile()                                           |
| + changePassword()                                          |
+-----------------------------------------------------------+
       |1                    |1                         |1
       |                     |                          |
       |0..N                  |0..N                      |0..N
       v                     v                          v
+--------------+   +------------------+   +------------------+
|  Booking     |   |    Wishlist      |   |    Review        |
+--------------+   +------------------+   +------------------+
| - id: int    |   | - id: int        |   | - id: int        |
| - checkIn    |   | - createdAt      |   | - rating: double  |
| - checkOut   |   +------------------+   | - comment: String |
| - adults: int|          |0..N          +------------------+
| - children   |          |                     |0..N
| - rooms: int |          v                     |
| - totalPrice |   +------------------+          |
| - status     |   |     Hotel         |          |
| - guestName  |   +------------------+          |
| - guestEmail |   | - id: int         |          |
| - guestPhone |   | - name: String     |          |
| - nationalIdFront| | - city: String    |          |
| - nationalIdBack | - address: String  |          |
| - paymentMethod | - type: String      |          |
+--------------+   | - rating: double   |          |
       |1          | - pricePerNight    |          |
       |           | - latitude: double  |          |
       |1          | - longitude: double |          |
       v          | - isFeatured: bool   |          |
+--------------+   | - isActive: bool    |          |
|  Payment     |   +------------------+          |
+--------------+          |1                       |
| - id: int    |          |                        |
| - amount     |          |0..N                    |
| - currency   |          v                        |
| - method     |   +------------------+   +------------------+
| - status     |   |   RoomType        |   | HotelImage       |
| - txnId      |   +------------------+   +------------------+
| - screenshot |   | - id: int         |   | - id: int        |
| - verifiedBy |   | - name: String     |   | - imageUrl: String|
| - verifiedAt |   | - bedType: String  |   | - sortOrder: int  |
+--------------+   | - pricePerNight    |   | - isPrimary: bool|
                   | - maxGuests: int   |   +------------------+
                   | - roomStatus       |          |0..N
                   +------------------+          |
                          |0..N                  v
                          v                +------------------+
                   +------------------+   | HotelAmenity     |
                   | HotelPaymentMethod|   +------------------+
                   +------------------+   | - id: int        |
                   | - id: int         |   | - amenity: String|
                   | - method: String   |   +------------------+
                   | - accountName     |
                   | - accountNumber   |
                   | - phone           |
                   | - instructions    |
                   | - isActive        |
                   +------------------+

+-----------------------------------------------------------+
|                    AdminUser                               |
+-----------------------------------------------------------+
| - id: int                                                  |
| - fullName: String                                         |
| - email: String                                            |
| - phone: String                                            |
| - passwordHash: String                                     |
| - role: String (super_admin / sub_admin / hotel_manager)   |
| - status: String                                           |
| - createdAt: DateTime                                      |
| - createdBy: int                                           |
+-----------------------------------------------------------+
| + login()                                                   |
| + updateProfile()                                           |
+-----------------------------------------------------------+
       |1
       |
       |0..N
       v
+------------------+          +----------------------+
| HotelManager     |          | AdminCityAssignment  |
+------------------+          +----------------------+
| - id: int        |          | - id: int            |
| - adminId: int    |          | - adminId: int        |
| - hotelId: int    |          | - city: String        |
| - subAdminId: int |          | - assignedBy: int     |
+------------------+          +----------------------+

+-----------------------------------------------------------+
|                     City                                   |
+-----------------------------------------------------------+
| - id: int                                                  |
| - name: String                                             |
| - region: String                                           |
| - isActive: boolean                                        |
+-----------------------------------------------------------+

+-----------------------------------------------------------+
|                 Notification                               |
+-----------------------------------------------------------+
| - id: int                                                  |
| - userId: int                                              |
| - adminId: int                                             |
| - type: String (booking_new / payment_approved /          |
|         payment_rejected)                                  |
| - title: String                                            |
| - message: String                                          |
| - isRead: boolean                                          |
| - bookingId: int                                           |
| - createdAt: DateTime                                      |
+-----------------------------------------------------------+

+-----------------------------------------------------------+
|                   OtpCode                                  |
+-----------------------------------------------------------+
| - id: int                                                  |
| - phone: String                                            |
| - code: String                                             |
| - purpose: String                                          |
| - used: boolean                                            |
| - expiresAt: DateTime                                      |
+-----------------------------------------------------------+
```

**Relationships:**
- User (1) -- (0..N) Booking
- User (1) -- (0..N) Wishlist
- User (1) -- (0..N) Review
- Hotel (1) -- (0..N) RoomType
- Hotel (1) -- (0..N) HotelImage
- Hotel (1) -- (0..N) HotelAmenity
- Hotel (1) -- (0..N) HotelPaymentMethod
- Booking (1) -- (1) Payment
- Booking (0..N) -- (1) RoomType
- Booking (0..N) -- (1) Hotel
- AdminUser (1) -- (0..N) HotelManager
- Hotel (1) -- (0..N) HotelManager
- AdminUser (1) -- (0..N) AdminCityAssignment
- User (1) -- (0..N) Notification
- AdminUser (1) -- (0..N) Notification

---

## 5. ACTIVITY DIAGRAMS

### 5.1 Activity Diagram: Complete Booking Process

```
                        [Start]
                           |
                           v
                    +--------------+
                    | User opens   |
                    | app/website  |
                    +--------------+
                           |
                           v
                    +--------------+
                    | View home    |
                    | page         |
                    +--------------+
                           |
                     +-----+-----+
                     |           |
                     v           v
              +----------+ +-----------+
              | Browse   | | Search by |
              | all hot. | | city      |
              +----------+ +-----------+
                     |           |
                     +-----+-----+
                           |
                           v
                    +--------------+
                    | Select hotel |
                    +--------------+
                           |
                           v
                    +--------------+
                    | View hotel   |
                    | details      |
                    | (images,     |
                    | rooms, map)  |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Select dates |
                    | (check-in,   |
                    |  check-out)  |
                    +--------------+
                           |
                           v
                    +--------------+
                    | View room    |
                    | availability |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Select room  |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Fill booking |
                    | form Step 1: |
                    | - Name       |
                    | - Email/Phone|
                    | - Guests     |
                    +--------------+
                           |
                           v
                    +--------------+     NO
                    | Upload       |----------+
                    | National ID  |          |
                    | front + back |          |
                    | (REQUIRED)   |          |
                    +--------------+          |
                           |                 v
                      +----+----+    +--------------+
                      |         |    | Show error:  |
                      | ID      |    | "Upload both |
                      | uploaded?    | sides of ID" |
                      +----+----+    +--------------+
                           |YES              |
                           |                 |
                           v                 |
                    +--------------+         |
                    | Continue to  |<--------+
                    | Payment      |
                    | (Step 2)     |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Select pay   |
                    | method       |
                    | (Telebirr/   |
                    |  CBE/Bank)   |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Enter trans- |
                    | action ID    |
                    +--------------+
                           |
                           v
                    +--------------+     NO
                    | Upload       |----------+
                    | payment      |          |
                    | screenshot   |          |
                    +--------------+          |
                           |                 v
                      +----+----+    +--------------+
                      |         |    | Show error:  |
                      | Upload  |    | "Payment     |
                      | done?   |    | screenshot   |
                      +----+----+    | required"    |
                           |YES    +--------------+
                           |            |
                           v            |
                    +--------------+    |
                    | Submit       |<---+
                    | booking      |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Backend      |
                    | validates:   |
                    | - Required   |
                    |   fields     |
                    | - National ID|
                    |   front+back|
                    | - Dates valid|
                    | - Guests <=  |
                    |   capacity   |
                    | - Max 2 rooms|
                    +--------------+
                           |
                     +-----+-----+
                     |           |
                     v NO       v YES
              +----------+  +--------------+
              | Return   |  | Create booking|
              | error    |  | (status=      |
              | message  |  |  pending)     |
              +----------+  +--------------+
                               |
                               v
                        +--------------+
                        | Create       |
                        | payment      |
                        | record       |
                        +--------------+
                               |
                               v
                        +--------------+
                        | Send notif   |
                        | to Hotel     |
                        | Manager      |
                        +--------------+
                               |
                               v
                        +--------------+
                        | Show Payment |
                        | Success      |
                        | screen       |
                        +--------------+
                               |
                               v
                          [End: User]
                               |
                               v
                    +--------------+
                    | Hotel Manager|
                    | reviews      |
                    | payment      |
                    +--------------+
                               |
                        +------+------+
                        |             |
                        v             v
                  +---------+   +---------+
                  | ACCEPT  |   | REJECT  |
                  +---------+   +---------+
                       |             |
                       v             v
                +-----------+  +-----------+
                | Payment   |  | Payment   |
                | =completed|  | =failed  |
                +-----------+  +-----------+
                       |             |
                       v             v
                +-----------+  +-----------+
                | Booking   |  | Booking   |
                | =confirmed|  | =cancelled|
                +-----------+  +-----------+
                       |             |
                       v             v
                +-----------+  +-----------+
                | Room      |  | Room      |
                | =occupied |  | =available|
                +-----------+  +-----------+
                       |             |
                       v             v
                +-----------+  +-----------+
                | Notify    |  | Notify    |
                | user:     |  | user:     |
                | "Confirmed"|  | "Rejected"|
                +-----------+  +-----------+
                       |             |
                       v             v
                    [End: Manager side]
```

### 5.2 Activity Diagram: Payment Verification Process

```
                        [Start]
                           |
                           v
                    +--------------+
                    | Manager     |
                    | logs in     |
                    +--------------+
                           |
                           v
                    +--------------+
                    | View        |
                    | dashboard   |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Tap "Pending|
                    | Payments"   |
                    +--------------+
                           |
                           v
                    +--------------+
                    | View list   |
                    | of pending  |
                    | payments    |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Select a    |
                    | payment     |
                    +--------------+
                           |
                           v
                    +--------------+
                    | Review:     |
                    | - Amount    |
                    | - Method    |
                    | - Screenshot|
                    | - National  |
                    |   ID images |
                    +--------------+
                           |
                     +-----+-----+
                     |           |
                     v           v
              +----------+  +----------+
              | ACCEPT   |  | REJECT   |
              +----------+  +----------+
                   |             |
                   v             v
            +-----------+  +-----------+
            | Update    |  | Update    |
            | payment    |  | payment   |
            | status=    |  | status=   |
            | completed  |  | failed    |
            +-----------+  +-----------+
                   |             |
                   v             v
            +-----------+  +-----------+
            | Update    |  | Update    |
            | booking   |  | booking   |
            | status=   |  | status=   |
            | confirmed |  | cancelled |
            +-----------+  +-----------+
                   |             |
                   v             v
            +-----------+  +-----------+
            | Update    |  | Update    |
            | room      |  | room      |
            | status=   |  | status=   |
            | occupied  |  | available |
            +-----------+  +-----------+
                   |             |
                   v             v
            +-----------+  +-----------+
            | Send      |  | Send      |
            | notif to  |  | notif to  |
            | user:     |  | user:     |
            | "Payment  |  | "Payment  |
            |  Confirmed"|  |  Rejected"|
            +-----------+  +-----------+
                   |             |
                   v             v
              [End: Accept]  [End: Reject]
```

---

## 6. DESIGN CLASS DIAGRAM

```
+================================================================+
|                   PRESENTATION LAYER                            |
+================================================================+
|                                                                |
|  +-------------------+  +-------------------+                 |
|  | HomeScreen        |  | HotelDetailScreen |                 |
|  +-------------------+  +-------------------+                 |
|  | - _navIdx: int    |  | - _tabCtrl        |                 |
|  | - _pageCtrl       |  | - _imgIdx: int    |                 |
|  +-------------------+  +-------------------+                 |
|  | + build()         |  | + build()         |                 |
|  | + _onNav()        |  | + _pickDate()     |                 |
|  +-------------------+  +-------------------+                 |
|                                                                |
|  +-------------------+  +-------------------+                 |
|  | BookingConfirm    |  | LoginScreen       |                 |
|  | Screen            |  +-------------------+                 |
|  +-------------------+  | - _emailCtrl       |                 |
|  | - _step: int      |  | - _passwordCtrl    |                 |
|  | - _firstCtrl       |  +-------------------+                 |
|  | - _idFrontB64     |  | + _login()        |                 |
|  | - _idBackB64      |  | + _register()     |                 |
|  | - _screenshotB64  |  +-------------------+                 |
|  +-------------------+                                        |
|  | + _goStep2()      |  +-------------------+                 |
|  | + _submit()       |  | RegisterScreen    |                 |
|  | + _pickFront()    |  +-------------------+                 |
|  | + _pickBack()     |  | + _register()     |                 |
|  +-------------------+  +-------------------+                 |
|                                                                |
|  +-------------------+  +-------------------+                 |
|  | AdminDashboard    |  | HotelManagerScreen|                |
|  | Screen            |  +-------------------+                 |
|  +-------------------+  | + _verifyPayment() |                |
|  | + _buildRoleUI()  |  | + _acceptPay()    |                 |
|  +-------------------+  | + _rejectPay()     |                 |
|                         +-------------------+                 |
+================================================================+
|                   BUSINESS LOGIC LAYER                         |
+================================================================+
|                                                                |
|  +-------------------+  +-------------------+                 |
|  | AuthProvider      |  | HotelProvider     |                 |
|  +-------------------+  +-------------------+                 |
|  | - _user: User?    |  | - _allHotels: List |                |
|  | - _isLoading      |  | - _cities: List    |                 |
|  | - _error: String? |  | - _hotel: Hotel?  |                 |
|  +-------------------+  +-------------------+                 |
|  | + login()         |  | + loadHome()      |                 |
|  | + register()      |  | + search()        |                 |
|  | + logout()        |  | + loadHotel()     |                 |
|  | + sendOtp()       |  | + loadAvailability|                 |
|  +-------------------+  +-------------------+                 |
|                                                                |
|  +-------------------+  +-------------------+                 |
|  | BookingProvider   |  | WishlistProvider  |                 |
|  +-------------------+  +-------------------+                 |
|  | + createBooking() |  | + toggle()        |                 |
|  | + initiatePayment()|  | + load()         |                 |
|  | + submitPayment() |  | + remove()       |                 |
|  +-------------------+  +-------------------+                 |
+================================================================+
|                   DATA ACCESS LAYER                            |
+================================================================+
|                                                                |
|  +----------------------------------------------------------+  |
|  |                    ApiService (Dio)                       |  |
|  +----------------------------------------------------------+  |
|  | - _api: Dio (baseUrl: /api/v1)                            |  |
|  | - _adminApi: Dio (baseUrl: /api/admin)                    |  |
|  +----------------------------------------------------------+  |
|  | + get(path, params)                                      |  |
|  | + post(path, data)                                       |  |
|  | + put(path, data)                                        |  |
|  | + delete(path)                                           |  |
|  | + adminGet(path, params)                                  |  |
|  | + adminPost(path, data)                                   |  |
|  | + adminPut(path, data)                                   |  |
|  | + adminDelete(path)                                      |  |
|  | - _check(body) → validates success field                 |  |
|  | - _parse(error) → converts DioException to ApiException  |  |
|  +----------------------------------------------------------+  |
|                                                                |
|  +----------------------------------------------------------+  |
|  |              Go Backend Handlers                          |  |
|  +----------------------------------------------------------+  |
|  | AuthHandler    | HotelHandler   | BookingHandler         |  |
|  | - Register()   | - Featured()   | - Create()             |  |
|  | - Login()      | - Search()     | - Index()              |  |
|  | - SendOTP()    | - Show()       | - Show()               |  |
|  | - VerifyOTP()  | - Availability()| - Cancel()            |  |
|  |               | - PaymentMethods||                       |  |
|  |               | - GetReviews() | PaymentHandler          |  |
|  |               | - PostReview() | - Initiate()            |  |
|  | AdminHandler  |                | - Submit()             |  |
|  | - SuperDash() |                | - Status()             |  |
|  | - SubDash()   |                | - VerifyPayment()      |  |
|  | - ManagerDash()|               |                        |  |
|  +----------------------------------------------------------+  |
|                                                                |
|  +----------------------------------------------------------+  |
|  |              Go Backend Models                           |  |
|  +----------------------------------------------------------+  |
|  | UserModel      | HotelModel    | BookingModel            |  |
|  | - FindByEmail()| - GetFeatured| - Create()              |  |
|  | - FindByPhone()| - Search()   | - GetDetail()           |  |
|  | - FindByID()   | - GetByID()  | - GetUserBookings()     |  |
|  | - Create()     | - GetRooms() | - Cancel()              |  |
|  | - UpdateLogin()| - GetPrice()  | - CountByStatus()      |  |
|  |               |               |                        |  |
|  | PaymentModel   | WishlistModel | NotificationModel       |  |
|  | - GetByID()    | - Toggle()    | - ListUser()           |  |
|  | - Create()     | - Remove()    | - ReadUser()           |  |
|  | - UpdateStatus()| - Index()    | - Create()             |  |
|  | - Submit()     |               |                        |  |
|  +----------------------------------------------------------+  |
+================================================================+
|                   DATABASE LAYER (PostgreSQL)                  |
+================================================================+
|                                                                |
|  users | admin_users | cities | hotels | hotel_images          |
|  hotel_amenities | room_types | bookings | payments           |
|  reviews | wishlist | notifications | hotel_managers           |
|  admin_city_assignments | hotel_payment_methods | otp_codes    |
|  brokers | broker_hotel_links | broker_messages               |
|                                                                |
+================================================================+
```

---

## 7. ER DIAGRAM (PHYSICAL DATA MODEL)

```
+----------------------------------+
|           users                   |
+----------------------------------+
| PK  id              SERIAL       |
|     first_name       VARCHAR(100)|
|     last_name        VARCHAR(100)|
|     email            VARCHAR(255) | UNIQUE
|     phone            VARCHAR(30)  | UNIQUE
|     password_hash    TEXT         |
|     nationality      VARCHAR(100) |
|     status           VARCHAR(20)  |
|     is_verified      BOOLEAN      |
|     last_login       TIMESTAMPTZ  |
|     registered_date  TIMESTAMPTZ  |
+----------------------------------+
         ||                    ||              ||
         || 0..N               || 0..N         || 0..N
         vv                    vv              vv
+-----------------+  +-------------+    +-------------+
|   bookings      |  |  wishlist   |    |  reviews    |
+-----------------+  +-------------+    +-------------+
| PK id      SERIAL|  | PK id       |    | PK id       |
| FK user_id ------+  | FK user_id  |    | FK user_id  |
| FK hotel_id -----+  | FK hotel_id |    | FK hotel_id |
| FK room_type_id -+  | created_at  |    | rating      |
|    check_in  DATE |  +-------------+    | comment     |
|    check_out DATE |                    | created_at  |
|    adults    INT  |                    +-------------+
|    children  INT  |
|    rooms     INT  |
|    total_price NUM|
|    payment_method |
|    status    VARCHAR|
|    special_requests|
|    guest_full_name|
|    guest_email    |
|    guest_phone    |
|    national_id_front TEXT|
|    national_id_back  TEXT|
|    created_at      |
+-----------------+
         || 1
         ||
         || 1
         vv
+-----------------+
|   payments      |
+-----------------+
| PK id      SERIAL|
| FK booking_id    |
| FK user_id       |
|    amount   NUM  |
|    currency  VARCHAR|
|    method   VARCHAR|
|    status   VARCHAR|
|    transaction_id  |
|    screenshot_url  |
| FK verified_by    |
|    verified_at    |
|    paid_at        |
|    created_at     |
+-----------------+

+----------------------------------+
|         admin_users               |
+----------------------------------+
| PK  id              SERIAL       |
|     full_name        VARCHAR(255) |
|     email            VARCHAR(255) | UNIQUE
|     phone            VARCHAR(30)  |
|     password_hash    TEXT         |
|     role             VARCHAR(30)  | -- super_admin/sub_admin/hotel_manager/broker
|     status           VARCHAR(20)  |
|     avatar_url       TEXT         |
|     last_login       TIMESTAMPTZ  |
|     created_at       TIMESTAMPTZ  |
| FK  created_by       INT          |
+----------------------------------+
         ||                    ||              ||
         || 0..N               || 0..N         || 0..N
         vv                    vv              vv
+-----------------+  +-------------------+  +-----------------+
| hotel_managers   |  |admin_city_assigns |  |  notifications  |
+-----------------+  +-------------------+  +-----------------+
| PK id      SERIAL|  | PK id      SERIAL  |  | PK id      SERIAL|
| FK admin_id      |  | FK admin_id        |  | FK user_id      |
| FK hotel_id      |  |    city  VARCHAR   |  | FK admin_id     |
| FK sub_admin_id  |  | FK assigned_by    |  |    type  VARCHAR|
+-----------------+  +-------------------+  |    title VARCHAR|
                                               |    message TEXT  |
                                               |    is_read BOOL  |
                                               | FK booking_id   |
                                               |    created_at    |
                                               +-----------------+

+----------------------------------+
|           cities                   |
+----------------------------------+
| PK  id              SERIAL       |
|     name             VARCHAR(100) | UNIQUE
|     region           VARCHAR(100) |
|     is_active        BOOLEAN      |
+----------------------------------+

+----------------------------------+
|           hotels                  |
+----------------------------------+
| PK  id              SERIAL       |
|     name            VARCHAR(255) |
|     city            VARCHAR(100) |
|     address         TEXT         |
|     description     TEXT         |
|     type            VARCHAR(50)  |
|     rating          NUMERIC(3,2) |
|     review_count    INT          |
|     price_per_night NUMERIC(12,2)|
|     latitude        DOUBLE PREC |
|     longitude       DOUBLE PREC |
|     is_featured     BOOLEAN      |
|     is_active       BOOLEAN      |
|     created_at      TIMESTAMPTZ  |
+----------------------------------+
         || 1                    || 1           || 1         || 1
         ||                      ||             ||           ||
         || 0..N                 || 0..N        || 0..N      || 0..N
         vv                      vv             vv           vv
+----------------+  +----------------+  +-------------+  +-------------------+
| hotel_images   |  | hotel_amenities|  | room_types  |  |hotel_payment_methods|
+----------------+  +----------------+  +-------------+  +-------------------+
| PK id     SERIAL|  | PK id    SERIAL|  | PK id  SERIAL| | PK id      SERIAL  |
| FK hotel_id    |  | FK hotel_id   |  | FK hotel_id | | FK hotel_id        |
|    image_url    |  |    amenity     |  |    name     | |    method  VARCHAR  |
|    sort_order   |  +----------------+  |    bed_type  | |    account_name     |
|    is_primary   |                      |    image_url | |    account_number   |
+----------------+                      |    price     | |    phone_number     |
                                        |    size_sqm  | |    instructions     |
                                        |    max_guests| |    is_active        |
                                        |    is_avail  | |    created_at       |
                                        |    room_status| +-------------------+
                                        +-------------+

+----------------------------------+
|          otp_codes                |
+----------------------------------+
| PK  id              SERIAL       |
|     phone            VARCHAR(30) |
|     code             VARCHAR(6)  |
|     purpose          VARCHAR(30) |
|     used             BOOLEAN      |
|     expires_at       TIMESTAMPTZ  |
|     created_at       TIMESTAMPTZ  |
+----------------------------------+
```

**ER Relationship Summary:**

| Relationship | Cardinality | FK |
|-------------|-----------|-----|
| users → bookings | 1 : 0..N | bookings.user_id |
| hotels → bookings | 1 : 0..N | bookings.hotel_id |
| room_types → bookings | 1 : 0..N | bookings.room_type_id |
| bookings → payments | 1 : 1 | payments.booking_id |
| users → payments | 1 : 0..N | payments.user_id |
| admin_users → payments | 1 : 0..N | payments.verified_by |
| hotels → room_types | 1 : 0..N | room_types.hotel_id |
| hotels → hotel_images | 1 : 0..N | hotel_images.hotel_id |
| hotels → hotel_amenities | 1 : 0..N | hotel_amenities.hotel_id |
| hotels → hotel_payment_methods | 1 : 0..N | hotel_payment_methods.hotel_id |
| users → wishlist | 1 : 0..N | wishlist.user_id |
| hotels → wishlist | 1 : 0..N | wishlist.hotel_id |
| users → reviews | 1 : 0..N | reviews.user_id |
| hotels → reviews | 1 : 0..N | reviews.hotel_id |
| admin_users → hotel_managers | 1 : 0..N | hotel_managers.admin_id |
| hotels → hotel_managers | 1 : 0..N | hotel_managers.hotel_id |
| admin_users → admin_city_assignments | 1 : 0..N | admin_city_assignments.admin_id |
| users → notifications | 1 : 0..N | notifications.user_id |
| admin_users → notifications | 1 : 0..N | notifications.admin_id |
| bookings → notifications | 1 : 0..N | notifications.booking_id |
| admin_users → admin_users | 1 : 0..N | admin_users.created_by |

---

## 8. COMPONENT DIAGRAM

```
+=====================================================================+
|                        SYSTEM COMPONENTS                              |
+=====================================================================+
|                                                                     |
|  +-----------------------+    +-----------------------+            |
|  |  Mobile App (Flutter) |    |  Web App (React.js)   |            |
|  +-----------------------+    +-----------------------+            |
|  |                       |    |                       |            |
|  | [Presentation Layer]  |    | [Presentation Layer]  |            |
|  | - Screens (22)         |    | - Pages (33)          |            |
|  | - Widgets (10)         |    | - Components (15+)    |            |
|  |                       |    |                       |            |
|  | [State Management]    |    | [State Management]    |            |
|  | - AuthProvider         |    | - AuthContext         |            |
|  | - HotelProvider        |    | - LanguageContext     |            |
|  | - BookingProvider      |    |                       |            |
|  | - WishlistProvider     |    | [HTTP Client]        |            |
|  | - LanguageProvider     |    | - Axios               |            |
|  |                       |    |                       |            |
|  | [HTTP Client]         |    | [i18n]                |            |
|  | - Dio                  |    | - en.ts, am.ts        |            |
|  |                       |    |                       |            |
|  | [Local Storage]       |    | [Local Storage]       |            |
|  | - SharedPrefs (token)  |    | - localStorage (token)|           |
|  |                       |    |                       |            |
|  | [Image Picker]         |    | [Google Maps JS API]  |            |
|  | - gallery/camera       |    | - hotel location      |            |
|  |                       |    |                       |            |
|  | [CachedNetworkImage]  |    |                       |            |
|  | - image caching        |    |                       |            |
|  +-----------+-----------+    +-----------+-----------+            |
|              |                            |                        |
|              |  REST API (JSON)           |  REST API (JSON)       |
|              |  Bearer JWT Auth           |  Bearer JWT Auth       |
|              v                            v                        |
|  +----------------------------------------------------------+    |
|  |                   GO BACKEND (Gin)                        |    |
|  +----------------------------------------------------------+    |
|  |                                                          |    |
|  |  [Auth Module]          [Hotels Module]                   |    |
|  |  - Register()           - Featured()                      |    |
|  |  - Login()             - Search()                         |    |
|  |  - SendOTP()           - Show()                           |    |
|  |  - VerifyOTP()         - Availability()                   |    |
|  |  - ForgotPassword()    - PaymentMethods()                |    |
|  |  - ResetPassword()     - GetReviews()                    |    |
|  |                        - PostReview()                    |    |
|  |  [Booking Module]       [Payment Module]                 |    |
|  |  - Create()            - Initiate()                       |    |
|  |  - Index()             - Submit()                        |    |
|  |  - Show()              - Status()                        |    |
|  |  - Cancel()            - VerifyPayment()                 |    |
|  |                        - Retry()                         |    |
|  |  [Wishlist Module]      [Guest Module]                   |    |
|  |  - Index()             - Profile()                       |    |
|  |  - Toggle()            - UpdateProfile()                 |    |
|  |  - Remove()            - ChangePassword()                |    |
|  |                                                          |    |
|  |  [Notifications Module]  [Admin Module]                   |    |
|  |  - ListUser()          - SuperAdmin (cities, subadmins)  |    |
|  |  - ReadUser()          - SubAdmin (hotels, rooms, mgrs)   |    |
|  |  - ReadAllUser()       - HotelManager (bookings, payments)|   |
|  |  - ListAdmin()         - Broker (messages, bookings)      |    |
|  |                                                          |    |
|  |  [Middleware]                                            |    |
|  |  - AuthRequired (JWT verify)                             |    |
|  |  - CORS (cross-origin)                                   |    |
|  |  - Role-based access control                             |    |
|  |                                                          |    |
|  |  [Database Access]                                       |    |
|  |  - database/sql (parameterized queries)                   |    |
|  |  - bcrypt (password hashing)                             |    |
|  |  - JWT (token generation/verification)                   |    |
|  +---------------------------+------------------------------+    |
|                              |                                  |
|                              | SQL (parameterized)              |
|                              v                                  |
|  +----------------------------------------------------------+    |
|  |              POSTGRESQL DATABASE                         |    |
|  +----------------------------------------------------------+    |
|  |                                                          |    |
|  |  users | admin_users | cities | hotels                    |    |
|  |  hotel_images | hotel_amenities | room_types             |    |
|  |  bookings | payments | reviews | wishlist                |    |
|  |  notifications | hotel_managers                           |    |
|  |  admin_city_assignments | hotel_payment_methods          |    |
|  |  otp_codes | brokers | broker_hotel_links                |    |
|  |  broker_messages                                         |    |
|  |                                                          |    |
|  |  [Constraints]                                           |    |
|  |  - Primary Keys (SERIAL)                                 |    |
|  |  - Foreign Keys (REFERENCES)                             |    |
|  |  - UNIQUE constraints (email, phone, city name)          |    |
|  |  - NOT NULL constraints                                  |    |
|  |  - DEFAULT values                                        |    |
|  |  - CASCADE deletes (hotel_images, room_types)            |    |
|  |  - Indexes (email, phone, city, status, hotel_id)         |    |
|  |                                                          |    |
|  +----------------------------------------------------------+    |
+=====================================================================+
```

---

## 9. DEPLOYMENT DIAGRAM

```
+=====================================================================+
|                      DEPLOYMENT ARCHITECTURE                          |
+=====================================================================+

  +---------------------+         +---------------------+
  |  Android Phone      |         |  iOS Phone           |
  |  (TECNO KN3)        |         |  (iPhone)            |
  |  Android 15 (API35)|         |  iOS 12+             |
  |                     |         |                     |
  |  [EthioStay APK]    |         |  [EthioStay IPA]     |
  |  Flutter App        |         |  Flutter App         |
  |  - Dart compiled    |         |  - Dart compiled     |
  |  - Local assets     |         |  - Local assets      |
  |  - SharedPreferences|         |  - SharedPreferences |
  |  - Dio HTTP client  |         |  - Dio HTTP client   |
  +---------+-----------+         +---------+-----------+
            |                                |
            | WiFi (same network)            | WiFi
            | HTTP (port 8080)               | HTTP (port 8080)
            | JSON REST API                  | JSON REST API
            | Bearer JWT                     | Bearer JWT
            |                                |
            v                                v
  +----------------------------------------------------------------+
  |                    CLOUD SERVER (VPS)                           |
  |                    Ubuntu 22.04 LTS                             |
  |                                                                 |
  |  +----------------------------------------------------------+   |
  |  |              Nginx (Reverse Proxy)                       |   |
  |  |              Port 80/443 (HTTPS)                         |   |
  |  |              SSL: Let's Encrypt                          |   |
  |  +-----+---------------------------+----------------------+   |
  |        |                           |                      |   |
  |        v                           v                      v   |
  |  +-----------+          +----------------+    +----------+ | |
  |  | Go Binary |          | React Build    |    | PostgreSQL| | |
  |  | (port 8080)|          | (static files) |    | (port 5432)|| |
  |  +-----------+          +----------------+    +----------+ | |
  |  | Gin server|          | index.html     |    | Database: | | |
  |  | Modules:   |          | assets/        |    |dallolbook | | |
  |  | - auth     |          | (JS, CSS, img) |    |           | | |
  |  | - hotels   |          +----------------+    | Tables:   | | |
  |  | - booking  |                              | | 16 tables | | |
  |  | - payment  |                              | | + indexes | | |
  |  | - wishlist |                              | | + views   | | |
  |  | - guest    |                              | +----------+ | |
  |  | - admin    |                              |       ^      | |
  |  | - notif    |                              |       |      | |
  |  +-----+------+                              |  SQL  |      | |
  |        |                                     +-------+      | |
  |        |  database/sql                       |              | |
  |        +-------------------------------------+              | |
  |                                                                 |
  |  +----------------------------------------------------------+   |
  |  |              Environment Configuration                   |   |
  |  +----------------------------------------------------------+   |
  |  | .env file                                                 |   |
  |  | - APP_PORT=8080                                           |   |
  |  | - DB_HOST=127.0.0.1                                       |   |
  |  | - DB_PORT=5432                                            |   |
  |  | - DB_USER=postgres                                        |   |
  |  | - DB_PASSWORD=*****                                       |   |
  |  | - DB_NAME=dallolbook                                      |   |
  |  | - JWT_SECRET=*****                                        |   |
  |  | - DB_SSLMODE=disable                                      |   |
  |  +----------------------------------------------------------+   |
  +----------------------------------------------------------------+

  +---------------------+
  |  Desktop/Laptop     |
  |  (Web Browser)      |
  |  Chrome/Firefox/    |
  |  Edge/Safari        |
  |                     |
  |  [React Web App]    |
  |  - JavaScript       |
  |  - Tailwind CSS     |
  |  - localStorage     |
  |  - Axios HTTP       |
  +---------+-----------+
            |
            | HTTPS (port 443)
            | JSON REST API
            | Bearer JWT
            |
            v
  +----------------------------------------------------------------+
  |              Nginx → Go Backend (same server)                   |
  +----------------------------------------------------------------+

  +---------------------+
  |  Google Play Store  |
  |  + Apple App Store  |
  |                     |
  |  Distribution:      |
  |  - APK → Play Store |
  |  - IPA → App Store  |
  +---------------------+
```

---

## 10. NETWORK DIAGRAM

```
+=====================================================================+
|                      NETWORK ARCHITECTURE                             |
+=====================================================================+

                    Internet (TCP/IP)
                         |
           +-------------+-------------+
           |                           |
           v                           v
  +-----------------+         +------------------+
  |   WiFi Router    |         |   ISP Gateway    |
  |   (Campus/Office)|         |                   |
  +--------+--------+         +------------------+
           |
    +------+------+
    |             |
    v             v
+--------+   +----------+
| Phone  |   | PC/Laptop|
| (WiFi) |   | (WiFi/Eth)|
| TECNO  |   | Ubuntu    |
| KN3    |   | 26.04     |
+---+----+   +-----+----+
    |              |
    |  LAN         | LAN
    |  10.x.x.x    | 10.x.x.x
    |              |
    +------+-------+
           |
           v
  +------------------+
  |  Backend Server  |
  |  (Same PC)       |
  |  Go: port 8080   |
  |  PostgreSQL:5432 |
  |  IP: 10.x.x.x    |
  +--------+---------+
           |
           v
  +------------------+
  |  PostgreSQL DB   |
  |  localhost:5432  |
  |  Database:       |
  |  dallolbook       |
  +------------------+

  Network Flow:
  ============

  [Phone] --WiFi--> [Router] --LAN--> [PC:8080]
                                         |
                                         v
                                    [PostgreSQL:5432]

  [Browser] --HTTPS--> [Nginx:443] --> [Go:8080] --> [PostgreSQL:5432]
                                         |
                                         v
                                    [React static files]
                                         |
                                         v
                                    [Browser receives HTML/JS/CSS]

  Security Layers:
  ===============

  Layer 1: Network — WiFi encryption (WPA2/WPA3)
  Layer 2: Transport — HTTPS/TLS (in production)
  Layer 3: Application — JWT Bearer token
  Layer 4: Role — RBAC (4 roles, endpoint-level checks)
  Layer 5: Data — bcrypt password hashing, parameterized SQL
  Layer 6: Database — FK constraints, UNIQUE, NOT NULL

  API Communication:
  ==================

  Mobile App                    Web App
      |                              |
      | Dio HTTP Client              | Axios HTTP Client
      | BaseURL: http://IP:8080      | BaseURL: /api/v1
      |                              |     /api/admin
      |                              |
      +------>+<---------------------+
              |
              v
      +---------------+
      | Go Backend     |
      | Gin Framework  |
      +---------------+
      | /api/v1/*      | Guest API (JWT user token)
      | /api/admin/*   | Admin API (JWT admin token)
      | /api/public/*  | Public API (no auth)
      | /health        | Health check (no auth)
      +---------------+
              |
              v
      +---------------+
      | PostgreSQL    |
      | database/sql  |
      | Parameterized |
      | Queries       |
      +---------------+

  Data Flow Example (Booking):
  ============================

  Phone/Web
    |
    | 1. POST /api/v1/bookings
    |    Headers: Authorization: Bearer <JWT>
    |    Body: {hotel_id, dates, guests, national_id_front, national_id_back, ...}
    |
    v
  Go Backend
    |
    | 2. Middleware: AuthRequired → Verify JWT → Extract user_id
    | 3. Handler: Create → Validate fields → Validate National ID present
    | 4. Model: INSERT INTO bookings (...) VALUES ($1, $2, ...)
    | 5. Model: INSERT INTO payments (...) VALUES (...)
    | 6. Model: INSERT INTO notifications (...) VALUES (...)
    | 7. Response: {success: true, data: {id: booking_id, ...}}
    |
    v
  PostgreSQL
    |
    | 8. Execute parameterized query
    | 9. Return inserted row ID
    |
    v
  Response flows back: PostgreSQL → Go → HTTP → Phone/Web
```

---

## SUMMARY OF ALL DIAGRAMS

| No. | Diagram | Chapter | Purpose |
|-----|---------|---------|---------|
| 1 | Use Case Diagram — User | 2.3.1 | Shows customer interactions |
| 2 | Use Case Diagram — Hotel Manager | 2.3.1 | Shows manager interactions |
| 3 | Use Case Diagram — Sub Admin | 2.3.1 | Shows sub admin interactions |
| 4 | Use Case Diagram — Super Admin | 2.3.1 | Shows super admin interactions |
| 5 | Use Case Descriptions (10) | 2.3.1 | Detailed UC specifications |
| 6 | Sequence — Registration | 2.3.2 | Registration flow |
| 7 | Sequence — Hotel Search | 2.3.2 | Search flow |
| 8 | Sequence — Booking with National ID | 2.3.2 | Complete booking flow |
| 9 | Sequence — Payment Submission | 2.3.2 | Payment flow |
| 10 | Sequence — Payment Verification | 2.3.2 | Manager verification flow |
| 11 | Analysis Class Diagram | 2.3.3 | Domain model classes |
| 12 | Activity — Booking Process | 2.3.4 | Complete booking activity |
| 13 | Activity — Payment Verification | 2.3.4 | Verification activity |
| 14 | Design Class Diagram | 3.1 | Implementation classes |
| 15 | ER Diagram | 3.2.2 | Physical data model |
| 16 | Component Diagram | 3.4 | System components |
| 17 | Deployment Diagram | 3.4 | Deployment architecture |
| 18 | Network Diagram | 3.4 | Network topology |

---

**Notes for drawing in UML tools:**

These text-based diagrams are designed to be recreated in proper UML tools for your printed report:

1. **Use Case Diagrams** → Draw in draw.io or StarUML using stick figures for actors, ovals for use cases, and boxes for system boundaries
2. **Sequence Diagrams** → Draw using lifelines (vertical lines), arrows for messages, and activation boxes
3. **Class Diagrams** → Draw using rectangles with three sections (class name, attributes, methods), lines with cardinality notation
4. **Activity Diagrams** → Draw using diamonds for decisions, rectangles for activities, circles for start/end
5. **ER Diagram** → Draw using rectangles for tables, lines with crow's foot notation for relationships
6. **Component Diagram** → Draw using boxes with component icons, interfaces (lollipops), and dependency arrows
7. **Deployment Diagram** → Draw using node boxes (servers), component boxes inside, and connection arrows
8. **Network Diagram** → Draw using network topology icons (router, phone, server, database)

---

*This document contains all UML diagrams required by Debre Markos University format for Chapter 2 (System Analysis) and Chapter 3 (System Design).*
