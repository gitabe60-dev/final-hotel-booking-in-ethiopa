# DEBRE MARKOS UNIVERSITY  
## INSTITUTE OF TECHNOLOGY  
### DEPARTMENT OF SOFTWARE ENGINEERING  

---

# HOTEL RESERVATION AND BOOKING MANAGEMENT SYSTEM IN ETHIOPIA  
### (Mobile App with Flutter + Web with React + Backend with Go + PostgreSQL)

---

**A PROJECT REPORT**

Submitted by:

| No. | Name of the Student | ID No. |
|-----|---------------------|--------|
| 1 | ABEBE MESFIN | 153689 |
| 2 | ABRHAM SEMA | 153719 |
| 3 | YESHIWAS ASCHALEW | 154634 |
| 4 | YOHANES TESFA | 154657 |

in partial fulfilment for the award of the degree of

**BACHELOR OF SCIENCE IN SOFTWARE ENGINEERING**

Under the guidance of

**Baye Atinafu (Advisor)**

---

DEPARTMENT OF SOFTWARE ENGINEERING  
COLLEGE OF TECHNOLOGY  
DEBRE MARKOS UNIVERSITY  
DEBRE MARKOS  

**November 2026**

---

## ABSTRACT

The hospitality industry in Ethiopia is experiencing rapid growth, driven by expanding tourism and business travel across cities such as Addis Ababa, Bahir Dar, Gondar, Hawassa, Mekelle, Adama, Jimma, Dire Dawa, and Debre Markos. Despite this growth, the majority of hotels still rely on manual, telephone-based, or walk-in reservation systems that are inefficient, error-prone, and lack transparency. This project presents the design, development, and implementation of a Hotel Reservation and Booking Management System — a dual-platform, multi-city, role-based solution that connects customers with hotels through a centralized online platform. The system consists of four integrated components: a Flutter mobile application for Android and iOS, a React.js web application for desktop-based management, a Go (Golang) backend using the Gin framework serving a shared REST API, and a PostgreSQL database for reliable, ACID-compliant data storage. The system defines four user roles — Super Admin, Sub Admin, Hotel Manager, and User — each with clearly separated responsibilities reflecting real hotel operations. The platform supports multi-city hotel search, real-time room availability, multiple Ethiopian payment methods (Telebirr, CBE Birr, and bank transfer with screenshot proof), mandatory National ID/Passport upload for booking verification, and end-to-end booking and payment verification workflows. The system was successfully implemented, tested, and deployed on real Android devices, demonstrating a scalable, secure, and user-friendly platform for the Ethiopian hospitality sector.

---

## ACKNOWLEDGEMENT

First and foremost, we would like to express our deepest gratitude to our advisor, Baye Atinafu, for his invaluable guidance, continuous support, and constructive feedback throughout this project. His insights and encouragement were instrumental in shaping the direction and quality of this work.

We extend our sincere thanks to the Department of Software Engineering at Debre Markos University, Institute of Technology, for providing the academic environment and resources that made this project possible.

We are also grateful to the hotel managers and staff in Addis Ababa, Bahir Dar, Gondar, Hawassa, and Debre Markos who participated in interviews and shared their operational challenges, which directly informed the requirements and design of this system.

Finally, we thank our families and friends for their unwavering patience and support during the development of this project.

---

## TABLE OF CONTENTS

| Title | Page |
|-------|------|
| Abstract | ii |
| Acknowledgement | iii |
| Table of Contents | iv |
| List of Tables | vii |
| List of Figures | viii |
| List of Acronyms | ix |
| **CHAPTER 1: INTRODUCTION** | |
| 1.1 Introduction | 1 |
| 1.2 Background of the Project | 4 |
| 1.3 Overview of the Existing System | 7 |
| 1.4 Problem Statement | 8 |
| 1.5 Overview of the Proposed System | 9 |
| 1.6 Objective of the Project | 20 |
| 1.7 Scope of the Project | 21 |
| 1.8 Limitation of the Project | 23 |
| 1.9 Significance of the Project | 23 |
| 1.10 System Requirements | 25 |
| 1.11 Data Collection Methodology | 28 |
| 1.12 Feasibility Study | 29 |
| **CHAPTER 2: SYSTEM ANALYSIS** | |
| 2.1 Overview of the Existing System | 33 |
| 2.2 System Requirement Specification | 34 |
| 2.3 System Requirement Analysis | 40 |
| **CHAPTER 3: SYSTEM DESIGN** | |
| 3.1 Design Class Diagram | 50 |
| 3.2 Database Design | 53 |
| 3.3 User Interface Design | 60 |
| 3.4 System Architecture | 65 |
| **CHAPTER 4: IMPLEMENTATION** | |
| 4.1 Overview of Programming Languages Used | 70 |
| 4.2 Algorithms Used | 73 |
| 4.3 Sample Codes | 75 |
| **CHAPTER 5: TESTING** | |
| 5.1 Sample Tests | 85 |
| **CHAPTER 6: CONCLUSION AND RECOMMENDATIONS** | |
| 6.1 Conclusion | 90 |
| 6.2 Recommendations and Future Enhancement | 91 |
| **REFERENCES** | 93 |
| **APPENDICES** | 95 |

---

## LIST OF TABLES

| Table No. | Title | Page |
|-----------|-------|------|
| Table 1.1 | Hardware Requirements — Development Environment | 25 |
| Table 1.2 | Hardware Requirements — Production Server | 25 |
| Table 1.3 | Software Requirements — Development Tools | 26 |
| Table 1.4 | Programming Languages and Frameworks | 27 |
| Table 1.5 | Mobile App vs Web App Feature Comparison | 18 |
| Table 1.6 | Budget Plan | 32 |
| Table 2.1 | Functional Requirements — User (Customer) | 34 |
| Table 2.2 | Functional Requirements — Hotel Manager | 36 |
| Table 2.3 | Functional Requirements — Sub Admin | 37 |
| Table 2.4 | Functional Requirements — Super Admin | 38 |
| Table 2.5 | Non-Functional Requirements | 39 |
| Table 3.1 | Database Tables and Descriptions | 53 |
| Table 5.1 | Test Case — User Registration | 85 |
| Table 5.2 | Test Case — Hotel Search by City | 86 |
| Table 5.3 | Test Case — Room Booking with National ID | 86 |
| Table 5.4 | Test Case — Payment Verification by Manager | 87 |
| Table 5.5 | Test Case — Manager Accept Payment | 87 |
| Table 5.6 | Test Case — Manager Reject Payment | 88 |

---

## LIST OF FIGURES

| Figure No. | Title | Page |
|------------|-------|------|
| Figure 1.1 | Multi-City Architecture Diagram | 19 |
| Figure 1.2 | Customer Booking Flow | 15 |
| Figure 1.3 | Hotel Manager Flow | 16 |
| Figure 1.4 | Sub Admin Flow | 17 |
| Figure 1.5 | Super Admin Flow | 18 |
| Figure 2.1 | Use Case Diagram — User | 41 |
| Figure 2.2 | Use Case Diagram — Hotel Manager | 42 |
| Figure 2.3 | Use Case Diagram — Sub Admin | 43 |
| Figure 2.4 | Use Case Diagram — Super Admin | 44 |
| Figure 2.5 | Sequence Diagram — Booking Flow | 45 |
| Figure 2.6 | Sequence Diagram — Payment Verification | 46 |
| Figure 2.7 | Activity Diagram — Complete Booking Process | 47 |
| Figure 2.8 | Analysis Class Diagram | 48 |
| Figure 3.1 | Design Class Diagram | 50 |
| Figure 3.2 | ER Diagram (Physical Data Model) | 59 |
| Figure 3.3 | System Architecture Diagram | 65 |
| Figure 3.4 | Deployment Diagram | 66 |
| Figure 3.5 | Mobile App Screen Hierarchy | 60 |
| Figure 3.6 | Web App Page Hierarchy | 62 |

---

## LIST OF ACRONYMS

| Acronym | Full Form |
|---------|-----------|
| API | Application Programming Interface |
| CRUD | Create, Read, Update, Delete |
| ETB | Ethiopian Birr |
| GUI | Graphical User Interface |
| JWT | JSON Web Token |
| ORM | Object-Relational Mapping |
| RBAC | Role-Based Access Control |
| REST | Representational State Transfer |
| SRS | Software Requirements Specification |
| UML | Unified Modeling Language |
| UI | User Interface |
| URL | Uniform Resource Locator |
| OTP | One-Time Password |
| SDK | Software Development Kit |
| CDN | Content Delivery Network |
| JSON | JavaScript Object Notation |
| SQL | Structured Query Language |
| ACID | Atomicity, Consistency, Isolation, Durability |
| NBE | National Bank of Ethiopia |
| WTTC | World Travel & Tourism Council |

---

# CHAPTER 1: INTRODUCTION

## 1.1 Introduction

The hospitality industry in Ethiopia is experiencing rapid growth, driven by the country's expanding economy, increasing tourism, and rising business travel. Cities such as Addis Ababa, Bahir Dar, Gondar, Hawassa, Mekelle, Adama, Jimma, Dire Dawa, and Debre Markos are witnessing a steady increase in hotel infrastructure. From international hotel chains to small local guesthouses, the number of accommodation options available to travelers has grown significantly over the past decade. Despite this growth, however, the majority of hotels in Ethiopia still rely on manual, telephone-based, or walk-in reservation systems that are inefficient, error-prone, and lack transparency for customers. Receptionists record bookings in paper registers, availability is confirmed only by phone or in person, and payments are almost always made in cash. This outdated approach creates serious problems for both hotel operators and customers, including double bookings, lost records, unclear pricing, and a poor overall customer experience.

This project proposes the development of a Hotel Reservation and Booking Management System — a modern, digital, dual-platform solution that connects customers with hotels through a centralized online platform. The system allows users to search for hotels by city, view real-time room availability, book rooms, and process payments online from their smartphones or computers. It also provides hotel managers with tools to verify payments, manage bookings, and track room occupancy, while giving city-level and national-level administrators complete control over hotels, cities, and users.

The proposed system consists of four integrated components:

1. **Mobile Application** — built with Flutter for Android and iOS, designed for customers, hotel managers, sub admins, and super admins who need to access the system on the go.
2. **Web Application** — built with React.js, designed for desktop users, hotel managers, sub admins, and super admins who prefer a larger screen for management tasks such as adding hotels, managing rooms, and viewing reports.
3. **Backend API** — built with Go (Golang) using the Gin framework, serving both the mobile and web clients with a single, high-performance REST API.
4. **Database** — powered by PostgreSQL, providing reliable, ACID-compliant data storage for all users, hotels, rooms, bookings, and payments.

The system is designed around four distinct user roles, each with clearly separated responsibilities that reflect how real hotels operate:

1. **Super Admin** — the top-level system administrator. The Super Admin manages cities (full CRUD), manages Sub Admins (full CRUD), assigns Sub Admins to cities, and configures system settings. The Super Admin does not manage hotels, rooms, bookings, or payments directly — those responsibilities belong to Sub Admins and Hotel Managers.
2. **Sub Admin** — the city-level administrator. Each Sub Admin is assigned to a specific Ethiopian city and manages all hotels in that city. This includes full CRUD on hotels, uploading hotel images, setting the Google Maps location for each hotel, managing rooms within each hotel, assigning Hotel Managers to hotels, and viewing city-level reports.
3. **Hotel Manager** — the hotel-level manager. Each Hotel Manager is assigned to a specific hotel and is responsible for managing bookings, verifying payments (accepting or rejecting them based on proof), updating room occupancy status, handling check-in and check-out, and viewing hotel-level reports.
4. **User (Customer)** — the end customer. Users can register, search for hotels by city, view available rooms with real-time availability, make bookings, choose a payment method (Telebirr, CBE Birr, or Bank Transfer), submit payment, and track their booking history. A mandatory National ID or Passport upload (front and back) is required during the booking process for identity verification.

**Why Both Mobile and Web?**

A key design decision of this project is to build both a mobile app and a web app, rather than choosing one. This decision is based on the realities of how people in Ethiopia access the internet and how hotels operate:

- **Mobile-First for Customers:** Over 70% of Ethiopian internet users access the internet through mobile devices. Smartphone penetration continues to grow rapidly, and mobile money services such as Telebirr and CBE Birr have become the dominant payment methods. Customers prefer the convenience of booking a hotel room from their phone.
- **Web-First for Administrators:** Hotel managers, Sub Admins, and Super Admins often need to perform bulk management tasks — adding multiple rooms at once, uploading batches of images, reviewing long lists of bookings, generating reports, and managing users. These tasks are far more efficient on a larger screen with a keyboard and mouse.
- **Shared Go Backend for Consistency:** Both the mobile app and the web app communicate with the same Go backend via a shared REST API. This ensures that business logic is written once and used everywhere, data is always consistent between mobile and web, and security rules are enforced uniformly.

## 1.2 Background of the Project

### 1.2.1 The Ethiopian Hospitality Sector

Ethiopia is home to a diverse range of tourism attractions — from the rock-hewn churches of Lalibela and the ancient obelisks of Axum, to the stunning landscapes of the Simien Mountains and the vibrant cultural festivals of Bahir Dar and Gondar. The capital, Addis Ababa, serves as the diplomatic hub of Africa, hosting the African Union headquarters and numerous international organizations.

According to the World Travel & Tourism Council (WTTC), Ethiopia's travel and tourism sector contributed approximately 5.7% of the country's GDP in recent years, and this figure is expected to grow significantly. The country welcomed over 800,000 international tourists pre-pandemic and has seen steady recovery, with government initiatives targeting 2 million tourists annually by 2030.

### 1.2.2 Digital Transformation in Ethiopia

Ethiopia is undergoing a significant digital transformation, driven by telecom liberalization and the expansion of mobile internet coverage, mobile money adoption (Telebirr launched in 2021 with over 40 million users, CBE Birr, Amole, M-Pesa), government digital initiatives (Digital Ethiopia 2025 strategy), growing smartphone penetration (estimated 25-30% and rising), and national ID program and digital payment infrastructure development.

### 1.2.3 The Technology Stack

The proposed system leverages modern, high-performance technologies:

- **Flutter** for the mobile app — Google's UI toolkit for building natively compiled applications for mobile from a single codebase.
- **React.js** for the web application — a JavaScript library for building user interfaces with reusable components, virtual DOM, and a rich ecosystem.
- **Go (Golang)** for the backend — chosen for its compiled performance, goroutine-based concurrency, low memory footprint, and strong standard library.
- **PostgreSQL** for the database — a mature, ACID-compliant, open-source relational database with excellent support for JSON, arrays, and UUIDs.

## 1.3 Overview of the Existing System

Currently, hotel booking in Ethiopia is predominantly handled through:

1. **Walk-in Customers:** Guests physically visit the hotel to check room availability and make reservations.
2. **Telephone Bookings:** Customers call the hotel receptionist, who manually checks availability in a register book.
3. **Third-Party Booking Sites:** A few hotels list on international platforms (Booking.com, Expedia) — but these are expensive for local hotels and cover only a fraction of Ethiopian establishments.
4. **Manual Registers:** Reservations are recorded in physical logbooks.
5. **Cash-Based Payments:** Payments are made in person, with receipts issued manually.

**Weaknesses of the Existing System:**

1. No centralized database — each hotel operates independently
2. No real-time availability — customers must call to check
3. High risk of double bookings — manual records increase errors
4. Cash dependency — no online payments or digital receipts
5. Limited visibility — hotels cannot advertise beyond local word-of-mouth
6. No booking history — customers cannot track past bookings
7. Poor reporting — managers spend hours compiling reports manually
8. No scalability — adding more hotels or cities is not possible
9. No national oversight — no way to monitor hotel operations across cities
10. Language barriers — international booking platforms do not support Amharic
11. No mobile solution — no mobile app exists for Ethiopians to book hotels conveniently
12. No web dashboard — no web-based management dashboard for administrators

## 1.4 Problem Statement

The current hotel booking process in Ethiopia faces several critical problems:

1. **Inefficiency:** Manual reservation processes are time-consuming and error-prone.
2. **Lack of Real-Time Information:** Customers cannot check room availability without physically visiting or calling the hotel.
3. **Double Bookings:** Without a centralized system, the same room may be booked by multiple customers.
4. **Limited Payment Options:** Cash-only payments restrict flexibility and convenience.
5. **No Centralized Oversight:** There is no way for national or regional authorities to monitor hotel operations.
6. **Poor Customer Experience:** Customers face long wait times, unclear pricing, and lack of booking confirmation.
7. **No Digital Records:** Loss of paper records leads to loss of booking history and financial data.
8. **Fragmented Market:** Each hotel operates in isolation, making it hard for travelers to compare options across cities.
9. **No Mobile Solution:** No mobile app exists for convenient smartphone-based booking.
10. **No Web Dashboard:** No web-based management dashboard for administrators.
11. **Missed Tourism Revenue:** Inefficient booking systems discourage both domestic and international tourists.

Therefore, there is a critical need for a centralized, national, dual-platform (mobile + web), role-based hotel reservation system that connects customers, hotels, and administrators across all Ethiopian cities in an efficient, transparent, and secure manner.

## 1.5 Overview of the Proposed System

The proposed Hotel Reservation and Booking Management System is a dual-platform solution consisting of a Mobile App (Flutter) for Android + iOS, a Web Application (React.js) for desktop browsers, a shared Go Backend (Gin framework), and a PostgreSQL Database. It has four distinct user roles with clearly defined responsibilities.

### 1.5.1 System Roles and Responsibilities

**Role 1: Super Admin (National Level)**

The Super Admin is the top-level system administrator with four core responsibilities:

1. Full CRUD on Cities — create, read, update, and delete Ethiopian cities
2. Full CRUD on Sub Admins — create, read, update, and delete Sub Admin accounts
3. Assign Sub Admin to City — each city has exactly one Sub Admin
4. System Settings — configure app name, logo, contact information, payment gateway keys, bank account details, default language, and maintenance mode

**Role 2: Sub Admin (City Level)**

The Sub Admin is assigned to a specific city by the Super Admin and manages all hotels in that city:

- Manage Hotels in City (Full CRUD): Create, Read, Update, Delete hotels
- Upload Hotel Images: Multiple images per hotel
- Set Google Maps Location: Capture or enter latitude/longitude for each hotel
- Manage Rooms in Each Hotel (Full CRUD): Create, Read, Update, Delete rooms
- Upload Room Images
- Assign Hotel Manager to Each Hotel
- View City-Level Reports: Occupancy, revenue, and bookings for their city
- Manage Hotel Managers: View, edit, or delete managers in their city

**Role 3: Hotel Manager (Hotel Level)**

The Hotel Manager is assigned to a specific hotel by the Sub Admin:

- View All Bookings: See all bookings for their hotel with details
- Verify Payments: Review payment proof (bank transfer screenshot, Telebirr/CBE Birr confirmation)
- Accept or Reject Payments: Accept confirms booking and occupies room; Reject cancels booking and frees room
- Manage Room Occupancy: Mark rooms as occupied/available/maintenance
- Check-in / Check-out: Update booking status when guests arrive/depart
- View Hotel Reports: Daily, weekly, monthly reports
- Receive Notifications: New bookings, new payments to verify
- View National ID: Access customer's uploaded National ID/Passport images for verification

**Role 4: User (Customer)**

The User is the end customer:

- Register / Login: Create an account and log in
- Home Page: See all available hotels (featured, popular cities)
- Search Hotels by City: Select a city and optionally filter
- Select Hotel: View hotel details (images, rating, amenities, Google Maps location)
- View Available Rooms: See all rooms with real-time availability
- Select Room and Book: Enter check-in date, check-out date, guest count, special requests
- Upload National ID/Passport: Mandatory upload of front and back of ID (required to proceed)
- Payment Method: Choose from Telebirr, CBE Birr, or Bank Transfer (upload screenshot for bank)
- Submit Payment: Payment goes to Hotel Manager for verification
- View Booking History: See all past and upcoming bookings with status
- Receive Notifications: Booking confirmation, payment acceptance/rejection

### 1.5.2 User Journey (Customer Flow)

```
STEP 1: User opens the app (mobile) or website (web)
   |
STEP 2: Home Page shows all available hotels + Search bar
   |
STEP 3: User optionally selects a city (e.g., Addis Ababa)
   |
STEP 4: App shows all hotels in that city
   |
STEP 5: User selects a hotel
   |
STEP 6: App shows hotel details (images, rating, amenities, Google Maps, rooms)
   |
STEP 7: User selects a room
   |
STEP 8: User fills the booking form (check-in, check-out, guest count, special requests)
   |
STEP 9: App shows total price (ETB) calculated automatically
   |
STEP 10: User uploads National ID/Passport (front and back) — REQUIRED
   |
STEP 11: User selects payment method (Telebirr / CBE Birr / Bank Transfer)
   |
STEP 12: User completes payment and submits
   |
STEP 13: Payment sent to Hotel Manager dashboard for verification
   |
STEP 14: Hotel Manager reviews:
    If ACCEPT -> Booking confirmed -> Room occupied -> User notified
    If REJECT -> Booking cancelled -> Room available -> User notified
   |
STEP 15: User sees the result in "My Bookings"
```

### 1.5.3 Hotel Manager Flow

```
STEP 1: Hotel Manager logs in (mobile or web)
   |
STEP 2: Dashboard shows new bookings, pending payments, room status
   |
STEP 3: Manager clicks "Pending Payments"
   |
STEP 4: Sees list of pending payments with customer details and proof
   |
STEP 5: Manager opens a payment and reviews proof
   |
STEP 6: Manager clicks ACCEPT or REJECT
   |
STEP 7: Manager views all bookings with filters
   |
STEP 8: Manager performs check-in/check-out
   |
STEP 9: Manager views hotel reports
```

### 1.5.4 Sub Admin Flow

```
STEP 1: Sub Admin logs in (mobile or web)
   |
STEP 2: City dashboard shows city-level KPIs
   |
STEP 3: Sub Admin manages hotels (add, edit, delete, images, Google Maps)
   |
STEP 4: Sub Admin manages rooms per hotel (add, edit, delete, images)
   |
STEP 5: Sub Admin assigns Hotel Managers to hotels
   |
STEP 6: Sub Admin views city reports
```

### 1.5.5 Super Admin Flow

```
STEP 1: Super Admin logs in (mobile or web)
   |
STEP 2: Super Admin manages cities (CRUD)
   |
STEP 3: Super Admin manages Sub Admins (CRUD)
   |
STEP 4: Super Admin assigns Sub Admin to city
   |
STEP 5: Super Admin manages system settings
```

### 1.5.6 Multi-City Architecture

```
+-----------------------------------------------------------+
|           SUPER ADMIN (National Level)                     |
|  1. Full CRUD on Cities                                    |
|  2. Full CRUD on Sub Admins                                |
|  3. Assign Sub Admin to City                               |
|  4. System Settings                                        |
+--------------------------+----------------------------------+
                           | assigns
                           v
    +----------+    +----------+    +----------+    +----------+
    |Addis     |    |Bahir Dar |    |Hawassa   |    |Gondar    |
    |Ababa     |    |Sub Admin |    |Sub Admin |    |Sub Admin |
    |Sub Admin |    +----+-----+    +----+-----+    +----+-----+
    +----+-----+         |               |               |
         |                v               v               v
    +----+-----+    +----------+    +----------+    +----------+
    |Hotels in |    |Hotels in |    |Hotels in |    |Hotels in |
    |Addis     |    |Bahir Dar |    |Hawassa   |    |Gondar    |
    +----------+    +----------+    +----------+    +----------+
```

### 1.5.7 Mobile App vs Web App Feature Comparison

| Feature | Mobile App (Flutter) | Web App (React) |
|---------|---------------------|-----------------|
| Super Admin: CRUD Cities | Optimized | Table view + bulk |
| Super Admin: CRUD Sub Admins | Optimized | Table view + bulk |
| Sub Admin: Manage Hotels | Basic CRUD | Bulk CRUD + bulk image upload |
| Sub Admin: Google Maps | Location picker | Map embed + picker |
| Hotel Manager: Verify Payments | Quick accept/reject | Bulk operations |
| Hotel Manager: View Bookings | List view | Table view with filters |
| Hotel Manager: Reports | Simple charts | Rich charts + PDF/Excel |
| User: Search & Book | Optimized | Available |
| User: Payment | Optimized | Available |
| Offline city images | Cached assets | Requires internet |
| App store distribution | Google Play + App Store | Browser only |

## 1.6 Objective of the Project

### 1.6.1 General Objective

To design and develop a dual-platform, national, multi-city Hotel Reservation and Booking Management System — using Flutter for the mobile app, React.js for the web app, Go (Golang) for the backend, and PostgreSQL for the database — that automates hotel discovery, booking, and payment processes across Ethiopian cities, providing a centralized, role-based platform for users, hotel managers, and administrators.

### 1.6.2 Specific Objectives

1. To develop a cross-platform mobile app using Flutter (Android + iOS) for all user roles.
2. To develop a responsive web app using React.js for desktop-based management and reporting.
3. To build a high-performance Go backend using the Gin framework with RESTful APIs shared by both mobile and web.
4. To implement a user registration and authentication system with role-based access control.
5. To implement multi-city hotel search and filtering across Ethiopian cities.
6. To design a real-time room availability display for each hotel.
7. To develop a room booking module with date selection, guest details, pricing calculation in ETB, and mandatory National ID/Passport upload.
8. To integrate multiple Ethiopian payment methods (Telebirr, CBE Birr, Bank Transfer with screenshot upload, and 12 Ethiopian bank options).
9. To develop a payment verification workflow for hotel managers (Accept/Reject).
10. To implement booking history and confirmation for users.
11. To develop a hotel management module for Sub Admins (hotels + rooms + managers + Google Maps location).
12. To develop a city management module for Super Admins (cities + Sub Admins + settings).
13. To generate reports and analytics at hotel, city, and national levels.
14. To ensure secure data storage using PostgreSQL and JWT authentication.
15. To implement form validation on all forms (name, email, phone, password, National ID upload) across the application.

## 1.7 Scope of the Project

**In Scope:**

- Mobile Application (Flutter for Android + iOS)
- Web Application (React.js for desktop browsers)
- Shared Backend API (Go + Gin framework)
- PostgreSQL Database
- Four user roles: Super Admin, Sub Admin, Hotel Manager, User
- Multi-city support: All major Ethiopian cities (Addis Ababa, Bahir Dar, Gondar, Hawassa, Mekelle, Adama, Jimma, Dire Dawa, Harar, Arba Minch, Dessie, Debre Berhan, Debre Markos)
- Super Admin: CRUD on cities, CRUD on Sub Admins, city assignments, system settings
- Sub Admin: CRUD on hotels, Google Maps location, CRUD on rooms, assign managers, city reports
- Hotel Manager: View bookings, verify payments, room occupancy, check-in/check-out, reports, view customer National ID
- User: Register/login, home page, search by city, hotel details, book rooms, National ID upload (required), payment (Telebirr/CBE Birr/Bank Transfer + 12 banks), booking history, notifications
- Payment methods: Telebirr, CBE Birr, Chapa, Bank Transfer, Awash Bank, Bank of Abyssinia, Dashen Bank, Oromia Bank, United Bank, NIB Bank, Wegagen Bank, Bunna Bank, Cooperative Bank
- Google Maps integration for hotel location
- English and Amharic language support
- Form validation on all forms (name, email, phone, password, National ID)
- Role-based access control (RBAC) with JWT authentication
- Push notifications (in-app)
- Mobile app app icon and branded splash screen (EthioStay branding)

**Out of Scope:**

- Real integration with Telebirr/CBE Birr payment APIs (simulated for demonstration)
- Multi-currency support (ETB only)
- Loyalty programs and discount systems
- Third-party tour packages
- Chat support between users and hotels
- Advanced revenue management algorithms
- Blockchain booking records
- Physical payment terminals
- Desktop native apps (web app covers desktop)

## 1.8 Limitation of the Project

1. The payment system is simulated — real integration with Telebirr and CBE Birr APIs requires official merchant accounts and compliance with National Bank of Ethiopia regulations.
2. The system requires internet connectivity to fetch hotel data, process bookings, and verify payments. Offline mode is limited to cached city images and user session persistence.
3. Google Maps integration uses the free tier API, which has usage limits.
4. The system has been tested on a TECNO KN3 (Android 15) real device and Linux desktop. iOS testing was not conducted due to hardware constraints.
5. The system currently stores National ID images and payment screenshots as base64-encoded strings in the database. For production, a cloud storage service (e.g., AWS S3, Cloudinary) should be used.

## 1.9 Significance of the Project

**For Customers (Users):**

- Convenience: Book rooms from anywhere in Ethiopia, anytime
- Transparency: View real prices, photos, Google Maps location, and availability
- Multiple Payment Options: Telebirr, CBE Birr, Bank Transfer, and 12 Ethiopian bank options
- Booking History: Track past and upcoming bookings
- Time Savings: No need to physically visit or call hotels
- Amharic Support: Use the app in the local language
- Choice of Platform: Use mobile app or web

**For Hotel Managers:**

- Efficient Booking Management: View all bookings in one place
- Payment Verification: Easily verify and accept/reject payments with one tap (mobile) or bulk actions (web)
- Real-Time Room Status: Track occupied/available rooms
- Reports: Generate occupancy and revenue reports
- Customer Verification: View uploaded National ID/Passport images for identity verification
- Reduced Errors: Eliminate manual double bookings

**For Sub Admins:**

- Centralized Hotel Management: Manage multiple hotels in a city
- Room Management: Add/edit rooms with images and pricing
- Google Maps Location: Set precise hotel locations
- Manager Assignment: Assign hotel managers efficiently

**For Super Admins:**

- Simple, Focused Role: Only four core functions
- Clear Separation of Duties
- System-Wide Configuration
- Scalability: Expand to new cities easily

**For Ethiopia:**

- Economic Growth: Boosts tourism and business
- Digital Transformation: Modernizes the hospitality industry
- Job Creation: Creates tech-related jobs
- National Data: Provides centralized data for tourism planning
- International Competitiveness: Positions Ethiopia as a modern tourism destination

## 1.10 System Requirements

### 1.10.1 Hardware Requirement

**Table 1.1: Hardware Requirements — Development Environment**

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Processor | Intel Core i3 | Intel Core i5 or higher |
| RAM | 8 GB | 16 GB |
| Storage | 256 GB SSD | 512 GB SSD |
| Display | 1366 x 768 | 1920 x 1080 |
| Internet | 5 Mbps | 10 Mbps or higher |

**Table 1.2: Hardware Requirements — Production Server**

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Processor | 2 vCPU | 4 vCPU |
| RAM | 4 GB | 8 GB |
| Storage | 50 GB SSD | 100 GB SSD |
| Bandwidth | 10 Mbps | 100 Mbps |

**Mobile Device (End User):** Android 8.0+ / iOS 12+, 2 GB RAM, 100 MB free storage, 1 Mbps internet

**Desktop/Laptop (End User — Web):** Chrome/Firefox/Edge/Safari (latest), 2 GB RAM, 1 Mbps internet

### 1.10.2 Software Requirement

**Table 1.3: Software Requirements — Development Tools**

| Category | Software |
|----------|----------|
| Operating System | Windows 10/11, Ubuntu 20.04+, macOS |
| Code Editor | Visual Studio Code / Android Studio |
| Mobile Framework | Flutter 3.x (Dart) |
| Web Framework | React.js 18+ |
| Backend Language | Go (Golang) 1.21+ |
| Backend Framework | Gin Gonic |
| Database | PostgreSQL 14+ |
| API Testing | Postman |
| Version Control | Git & GitHub |
| Design Tools | Figma / Draw.io |
| Google Maps | Google Maps SDK for Flutter + JavaScript API |

### 1.10.3 Programming Languages & Frameworks

**Table 1.4: Programming Languages and Frameworks**

| Language / Framework | Usage |
|---------------------|-------|
| Dart | Flutter mobile app |
| Flutter | Cross-platform mobile UI (Android + iOS) |
| JavaScript (ES6+) | React web app |
| React.js | Web UI framework |
| Tailwind CSS | Web styling |
| Go (Golang) | Backend API, business logic |
| Gin | Go web framework |
| SQL | Database queries |
| JSON | Data exchange format |

## 1.11 Data Collection Methodology

**Primary Data Collection:**

1. Interviews: Conducted with hotel managers and receptionists in Addis Ababa, Bahir Dar, Gondar, Hawassa, Mekelle, and Debre Markos (25 interviews).
2. Questionnaires: Distributed to potential users (travelers, business people, tourists) — 150 responses collected.
3. Observation: Direct observation of hotel reception workflows at 15+ hotels.
4. Focus Group Discussions: Held with hotel staff (5 sessions, 8-10 participants each).

**Secondary Data Collection:**

1. Literature Review: Studied existing hotel reservation systems (Booking.com, Expedia, Airbnb, local Ethiopian platforms).
2. Documentation Review: Analyzed hotel record books, receipts, and reports from partner hotels.
3. Online Research: Reviewed academic papers and industry reports on Ethiopian hospitality.
4. Government Reports: Reviewed reports from the Ministry of Tourism and Ethiopian Tourism Organization.

## 1.12 Feasibility Study

### 1.12.1 Technical Feasibility — HIGHLY FEASIBLE

All technologies (Flutter, React.js, Go, PostgreSQL) are mature, well-documented, and stable. The development team has training in mobile development, web development, Go, and Flutter. Cloud hosting is accessible and affordable. Payment APIs are available for future integration. Google Maps SDK is available with a free tier.

### 1.12.2 Operational Feasibility — FEASIBLE

Ethiopian users are mobile-first and familiar with mobile apps and mobile money. Hotel staff have basic smartphone and computer skills. A short training session (2-3 days) is sufficient. The system simplifies existing processes, reducing resistance to change. Amharic language support reduces barriers.

### 1.12.3 Economic Feasibility — ECONOMICALLY VIABLE

Development cost (academic project): ~43,500 ETB. Annual operational cost: ~62,500 ETB/year. Expected annual benefit: 2,350,000+ ETB/year. Return on Investment (ROI): Positive within the first year.

### 1.12.4 Legal Feasibility — LEGALLY FEASIBLE

The system complies with Ethiopian data protection guidelines (Personal Data Protection Proclamation No. 1321/2024). Payment integration follows National Bank of Ethiopia regulations. Open-source libraries are used under appropriate licenses (MIT, Apache 2.0, BSD). Mobile app will comply with Google Play and Apple App Store policies.

**Table 1.6: Budget Plan**

| No. | Item | Quantity | Unit Cost (ETB) | Total Cost (ETB) |
|-----|------|----------|-----------------|-------------------|
| 1 | Domain Name (.com) | 1 year | 2,500 | 2,500 |
| 2 | Cloud Hosting (VPS) | 12 months | 833 | 10,000 |
| 3 | Web Hosting (Vercel) | 12 months | 0 (free tier) | 0 |
| 4 | Google Play Developer Account | 1 | 4,500 | 4,500 |
| 5 | Apple Developer Account (optional) | 1 year | 18,000 | 18,000 |
| 6 | SSL Certificate | 1 | 0 (Let's Encrypt) | 0 |
| 7 | Google Maps API | 1 year | 0 (free tier) | 0 |
| 8 | Internet & Utilities | 6 months | 833 | 5,000 |
| 9 | Printing & Binding | 3 copies | 500 | 1,500 |
| 10 | Miscellaneous | — | — | 2,000 |
| | | | **Total** | **~43,500 ETB** |

---

# CHAPTER 2: SYSTEM ANALYSIS

## 2.1 Overview of the Existing System

The existing hotel booking system in Ethiopia operates entirely through manual processes. The primary users of the existing system are:

**Users of the Existing System:**
- **Receptionists:** Handle walk-in and telephone bookings using paper registers
- **Hotel Managers:** Oversee operations but lack digital tools for monitoring
- **Customers:** Must call or visit hotels in person to check availability and make reservations

The existing system has no digital infrastructure, no centralized database, no real-time availability, no online payment options, and no reporting capabilities. Double bookings are common, records are easily lost, and there is no way for customers to compare hotels across different cities.

## 2.2 System Requirement Specification

### 2.2.1 Functional Requirements

**Table 2.1: Functional Requirements — User (Customer)**

| ID | Requirement | Priority |
|----|-------------|---------|
| FR-U01 | The system shall allow users to register with first name, last name, email/phone, password, and nationality. | High |
| FR-U02 | The system shall allow users to log in with email/phone and password. | High |
| FR-U03 | The system shall allow users to log in using OTP (One-Time Password). | Medium |
| FR-U04 | The system shall display a home page showing all featured hotels and city grid. | High |
| FR-U05 | The system shall allow users to search for hotels by city name. | High |
| FR-U06 | The system shall allow users to filter hotels by price, rating, and amenities. | Medium |
| FR-U07 | The system shall display hotel details including images, rating, amenities, Google Maps location, and available rooms. | High |
| FR-U08 | The system shall display real-time room availability for selected check-in and check-out dates. | High |
| FR-U09 | The system shall allow users to select a room and fill a booking form with check-in date, check-out date, adults, children, and special requests. | High |
| FR-U10 | The system shall require users to upload National ID/Passport front and back images before proceeding to payment. | High |
| FR-U11 | The system shall calculate the total price automatically based on nights, room rate, and number of rooms. | High |
| FR-U12 | The system shall allow users to select a payment method from Telebirr, CBE Birr, Chapa, Bank Transfer, and 12 Ethiopian bank options. | High |
| FR-U13 | The system shall allow users to upload a payment screenshot for bank transfer payments. | High |
| FR-U14 | The system shall allow users to view their booking history with status (pending, confirmed, cancelled, completed). | High |
| FR-U15 | The system shall allow users to cancel a booking (if status is pending or confirmed). | Medium |
| FR-U16 | The system shall allow users to add/remove hotels from their wishlist. | Medium |
| FR-U17 | The system shall allow users to write and submit reviews for hotels. | Medium |
| FR-U18 | The system shall send notifications to users for booking confirmation, payment acceptance, and payment rejection. | High |
| FR-U19 | The system shall allow users to view and edit their profile. | Medium |
| FR-U20 | The system shall support both English and Amharic languages. | Medium |

**Table 2.2: Functional Requirements — Hotel Manager**

| ID | Requirement | Priority |
|----|-------------|---------|
| FR-M01 | The system shall allow hotel managers to log in with admin credentials. | High |
| FR-M02 | The system shall display a hotel manager dashboard showing new bookings count, pending payments count, and room status. | High |
| FR-M03 | The system shall allow managers to view all bookings for their hotel with full details including customer National ID images. | High |
| FR-M04 | The system shall display pending payments with customer name, amount, payment method, and payment proof (screenshot). | High |
| FR-M05 | The system shall allow managers to accept a payment, which confirms the booking and marks the room as occupied. | High |
| FR-M06 | The system shall allow managers to reject a payment, which cancels the booking and returns the room to available status. | High |
| FR-M07 | The system shall allow managers to update room status (available, occupied, maintenance). | High |
| FR-M08 | The system shall allow managers to perform check-in and check-out operations. | Medium |
| FR-M09 | The system shall allow managers to view hotel reports (daily, weekly, monthly). | Medium |
| FR-M10 | The system shall allow managers to manage rooms (add, edit, delete). | Medium |
| FR-M11 | The system shall allow managers to manage hotel-specific payment methods. | Medium |
| FR-M12 | The system shall send notifications to managers for new bookings and new payments. | High |

**Table 2.3: Functional Requirements — Sub Admin**

| ID | Requirement | Priority |
|----|-------------|---------|
| FR-S01 | The system shall allow sub admins to log in with admin credentials. | High |
| FR-S02 | The system shall display a city dashboard with city-level KPIs. | High |
| FR-S03 | The system shall allow sub admins to create hotels in their assigned city. | High |
| FR-S04 | The system shall allow sub admins to edit and delete hotels. | High |
| FR-S05 | The system shall allow sub admins to upload multiple images per hotel. | High |
| FR-S06 | The system shall allow sub admins to set Google Maps location (latitude/longitude) for each hotel. | High |
| FR-S07 | The system shall allow sub admins to create, edit, and delete rooms within each hotel. | High |
| FR-S08 | The system shall allow sub admins to upload room images. | Medium |
| FR-S09 | The system shall allow sub admins to create Hotel Manager accounts and assign them to hotels. | High |
| FR-S10 | The system shall allow sub admins to view city-level reports. | Medium |
| FR-S11 | The system shall allow sub admins to manage hotel payment methods. | Medium |
| FR-S12 | The system shall allow sub admins to view all bookings in their city. | Medium |

**Table 2.4: Functional Requirements — Super Admin**

| ID | Requirement | Priority |
|----|-------------|---------|
| FR-A01 | The system shall allow super admins to log in with admin credentials. | High |
| FR-A02 | The system shall display a super admin dashboard with national-level overview. | High |
| FR-A03 | The system shall allow super admins to create, read, update, and delete cities. | High |
| FR-A04 | The system shall allow super admins to create, read, update, and delete Sub Admin accounts. | High |
| FR-A05 | The system shall allow super admins to assign Sub Admins to cities. | High |
| FR-A06 | The system shall allow super admins to revoke Sub Admin city assignments. | High |
| FR-A07 | The system shall allow super admins to configure system settings. | Medium |
| FR-A08 | The system shall allow super admins to view national-level reports. | Medium |
| FR-A09 | The system shall allow super admins to view all users, hotels, and bookings. | Medium |

### 2.2.2 Non-Functional Requirements

**Business Rules:**

- BR01: Each city has exactly one Sub Admin assigned to it.
- BR02: Each hotel has exactly one Hotel Manager assigned to it.
- BR03: A maximum of 2 rooms can be booked per transaction.
- BR04: Check-out date must be after check-in date.
- BR05: Check-in date cannot be in the past.
- BR06: National ID/Passport front and back images are required for every booking.
- BR07: Payment must be verified by a Hotel Manager before a booking is confirmed.
- BR08: Only active hotels and available rooms can be booked.
- BR09: Guest count (adults + children) must not exceed room capacity.
- BR10: All forms must be validated (name: letters only, email: valid format, phone: Ethiopian format, password: min 6 chars with letters and numbers).

**Technical Requirements:**

- TR01: The system shall use JWT (JSON Web Token) for authentication.
- TR02: The system shall enforce role-based access control (RBAC) with four roles.
- TR03: The system shall use HTTPS in production with SSL certificates.
- TR04: The system shall respond to API requests within 2 seconds under normal load.
- TR05: The system shall support at least 1000 concurrent users.
- TR06: The mobile app shall run on Android 8.0+ (API 26+) and iOS 12+.
- TR07: The web app shall be responsive and work on Chrome, Firefox, Edge, and Safari.
- TR08: The system shall store passwords using bcrypt hashing.
- TR09: The system shall validate all input data on both client and server sides.
- TR10: The system shall use PostgreSQL with ACID-compliant transactions.

**Change Cases:**

- CC01: The system should be designed to support additional payment methods in the future.
- CC02: The system should be able to add new cities without code changes.
- CC03: The system should be able to integrate real Telebirr and CBE Birr APIs when available.
- CC04: The system should be able to support additional languages beyond English and Amharic.
- CC05: The system should be able to migrate image storage to cloud services (AWS S3, Cloudinary) for production.

## 2.3 System Requirement Analysis

### 2.3.1 Actor and Use Case Identification

**Actors:**

1. **User (Customer)** — searches, books, and pays for hotel rooms
2. **Hotel Manager** — manages bookings and verifies payments for their hotel
3. **Sub Admin** — manages hotels, rooms, and managers in their city
4. **Super Admin** — manages cities, sub admins, and system settings
5. **System (Automated)** — sends notifications, calculates prices, auto-creates payment records

**Use Case Descriptions:**

**UC-01: Register Account**
- Actor: User
- Description: A new user creates an account by providing first name, last name, email/phone, password, and nationality.
- Precondition: The user does not have an existing account.
- Postcondition: A new user account is created with status "active".
- Main Flow: User opens register page → fills form → system validates input → system checks for duplicate email/phone → system hashes password → system creates account → system logs in user.

**UC-02: Search Hotels by City**
- Actor: User
- Description: A user searches for hotels in a specific city.
- Precondition: The user is on the home page.
- Postcondition: A list of hotels in the selected city is displayed.
- Main Flow: User selects a city → system queries database for active hotels in that city → system displays hotel cards with images, ratings, prices, and availability.

**UC-03: Book a Room**
- Actor: User
- Description: A user books a room by filling the booking form, uploading National ID, and selecting a payment method.
- Precondition: The user is logged in and has selected a hotel and room.
- Postcondition: A booking record is created with status "pending" and a payment record is auto-created.
- Main Flow: User selects dates → user enters guest details → user uploads National ID front (required) → user uploads National ID back (required) → system validates all fields → user selects payment method → user uploads payment proof → system creates booking → system creates payment record → system sends notification to Hotel Manager.

**UC-04: Verify Payment**
- Actor: Hotel Manager
- Description: A hotel manager reviews payment proof and accepts or rejects it.
- Precondition: A booking with pending payment exists for the manager's hotel.
- Postcondition: Payment status is updated (completed/failed), booking status is updated (confirmed/cancelled), room status is updated (occupied/available), user is notified.
- Main Flow: Manager opens pending payments → manager reviews payment proof and customer National ID → manager clicks Accept or Reject → system updates payment status → system updates booking status → system updates room status → system sends notification to user.

**UC-05: Manage Hotels**
- Actor: Sub Admin
- Description: A sub admin creates, edits, or deletes hotels in their assigned city.
- Precondition: The sub admin is logged in and assigned to a city.
- Postcondition: Hotel records are created, updated, or deleted.
- Main Flow: Sub Admin opens hotel management → sub admin fills hotel form (name, city, address, description, type, price, amenities, images, Google Maps location) → system validates → system creates/updates hotel record.

**UC-06: Manage Cities**
- Actor: Super Admin
- Description: A super admin creates, edits, or deletes cities.
- Precondition: The super admin is logged in.
- Postcondition: City records are created, updated, or deleted.
- Main Flow: Super Admin opens city management → super admin fills city form (name, region) → system validates → system creates/updates city record.

**Use Case Diagrams:**

*(The use case diagrams for each actor — User, Hotel Manager, Sub Admin, Super Admin — would be inserted here as figures. Each diagram shows the actor and their associated use cases connected by associations.)*

### 2.3.2 Sequence Diagrams

**Sequence: Booking Flow**

```
User          Mobile App       Go Backend        PostgreSQL
  |               |                 |                 |
  |--Select Hotel->|               |                 |
  |               |--GET /hotels/:id->|              |
  |               |                 |--SELECT hotel-->|
  |               |                 |<--hotel data---|
  |               |<--hotel detail--|                 |
  |<--display------|                |                 |
  |--Select Room-->|                |                 |
  |--Fill Form---->|                |                 |
  |--Upload ID---->|                |                 |
  |               |--POST /bookings->|               |
  |               |                 |--INSERT booking->|
  |               |                 |--INSERT payment->|
  |               |                 |--INSERT notif--->|
  |               |<--booking created-|               |
  |               |--POST /payments/initiate->|      |
  |               |<--payment initiated-|             |
  |               |--POST /payments/:id/submit->|    |
  |               |<--payment submitted-|             |
  |<--success-----|                 |                 |
```

**Sequence: Payment Verification**

```
Manager        Manager App       Go Backend        PostgreSQL        User
  |               |                 |                 |              |
  |--View Pending->|               |                 |              |
  |               |--GET /payments->|               |              |
  |               |                 |--SELECT pending->|            |
  |               |<--payment list--|               |              |
  |<--display-----|                |                 |              |
  |--Review Proof->|               |                 |              |
  |--Accept/Reject>|               |                 |              |
  |               |--POST /payments/:id/verify->|   |              |
  |               |                 |--UPDATE payment->|            |
  |               |                 |--UPDATE booking->|            |
  |               |                 |--UPDATE room--->|            |
  |               |                 |--INSERT notif-->|            |
  |               |<--verified------|               |              |
  |<--done--------|                 |                 |--notif----->|
```

### 2.3.3 Analysis Class Diagram

**Classes identified:**

1. **User** — id, firstName, lastName, email, phone, passwordHash, nationality, status, isVerified
2. **AdminUser** — id, fullName, email, phone, passwordHash, role, status, avatarUrl
3. **City** — id, name, region, isActive
4. **Hotel** — id, name, city, address, description, type, rating, pricePerNight, latitude, longitude, isFeatured, isActive
5. **HotelImage** — id, hotelId, imageUrl, sortOrder, isPrimary
6. **HotelAmenity** — id, hotelId, amenity
7. **RoomType** — id, hotelId, name, bedType, imageUrl, pricePerNight, sizeSqm, maxGuests, roomStatus
8. **Booking** — id, userId, hotelId, roomTypeId, checkIn, checkOut, adults, children, rooms, totalPrice, paymentMethod, status, specialRequests, guestFullName, guestEmail, guestPhone, nationalIdFront, nationalIdBack
9. **Payment** — id, bookingId, userId, amount, currency, method, status, transactionId, screenshotUrl, verifiedBy, verifiedAt
10. **Review** — id, hotelId, userId, rating, comment
11. **Wishlist** — id, userId, hotelId
12. **Notification** — id, userId, adminId, type, title, message, isRead, bookingId
13. **HotelManager** — id, adminId, hotelId, subAdminId
14. **AdminCityAssignment** — id, adminId, city
15. **HotelPaymentMethod** — id, hotelId, method, accountName, accountNumber, phoneNumber, instructions, isActive
16. **OtpCode** — id, phone, code, purpose, used, expiresAt

### 2.3.4 Activity Diagram

**Complete Booking Process:**

```
[Start] -> User opens app -> View home page -> Select city -> View hotels
  -> Select hotel -> View hotel details -> Select room -> Fill booking form
  -> Upload National ID front (required) -> Upload National ID back (required)
  -> [ID uploaded?] 
    -> No: Show error "Upload both sides" -> (return to upload)
    -> Yes: Select payment method -> Upload payment proof
  -> Submit booking -> System creates booking (pending) -> System creates payment
  -> System notifies Hotel Manager -> [Manager reviews]
    -> Accept: Confirm booking -> Occupy room -> Notify user (confirmed)
    -> Reject: Cancel booking -> Free room -> Notify user (rejected)
  -> User views result in My Bookings -> [End]
```

---

# CHAPTER 3: SYSTEM DESIGN

## 3.1 Design Class Diagram

The design class diagram represents the implementation-level classes with their attributes, methods, and relationships. The system follows a layered architecture:

**Presentation Layer (Mobile):**
- Screens: HomeScreen, HotelDetailScreen, BookingConfirmScreen, PaymentSuccessScreen, LoginScreen, RegisterScreen, DashboardScreen, AdminDashboardScreen, SubAdminScreen, SuperAdminScreen, HotelManagerScreen, WishlistScreen, BookingsListScreen, ProfileScreen, NotificationsScreen
- Widgets: HotelCard, LocalOrNetworkImage, HotelImage, StarRating, AppLogo, AppSpinner
- Providers: AuthProvider, HotelProvider, BookingProvider, WishlistProvider, LanguageProvider

**Presentation Layer (Web):**
- Pages: Home, HotelDetail, HotelList, BookingConfirm, Payment, PaymentSuccess, BookingsList, Dashboard, Profile, Wishlist, Login, Register, AdminLogin, SuperDashboard, SubAdminDashboard, ManagerDashboard, CitiesPage, HotelsPage, SubAdminsPage, ManagersPage, RoomsPage, BookingsPage, PaymentsPage, PaymentMethodsPage, SettingsPage

**Business Logic Layer (Backend):**
- Modules: Auth, Hotels, Booking, Payment, Wishlist, Guest, Notifications, Review, Admin
- Handlers: Register, Login, SendOTP, VerifyOTP, Search, Show, Create, Initiate, Submit, VerifyPayment, AddHotel, EditHotel, AddRoom, EditRoom, CreateSubAdmin, AssignCity, AddCity

**Data Access Layer (Backend):**
- Models: UserModel, HotelModel, RoomTypeModel, BookingModel, PaymentModel, ReviewModel, WishlistModel, NotificationModel, AdminModel, HotelManagerModel, CityModel

**Database Layer (PostgreSQL):**
- 16 tables: users, admin_users, cities, hotels, hotel_images, hotel_amenities, room_types, bookings, payments, reviews, wishlist, notifications, hotel_managers, admin_city_assignments, hotel_payment_methods, otp_codes

### 3.1.1 Class Diagram Description

Each class maps to a database table. The relationships are:

- User (1) -- (N) Booking
- Hotel (1) -- (N) RoomType
- Hotel (1) -- (N) HotelImage
- Hotel (1) -- (N) HotelAmenity
- Hotel (1) -- (N) HotelPaymentMethod
- Booking (1) -- (1) Payment
- Booking (N) -- (1) RoomType
- Booking (N) -- (1) Hotel
- Booking (N) -- (1) User
- AdminUser (1) -- (N) HotelManager (as admin_id)
- Hotel (1) -- (N) HotelManager
- AdminUser (1) -- (N) AdminCityAssignment
- User (1) -- (N) Wishlist
- User (1) -- (N) Review
- User (1) -- (N) Notification
- AdminUser (1) -- (N) Notification

## 3.2 Database Design

### 3.2.1 Normalization

The database is normalized to Third Normal Form (3NF):

- **1NF:** All tables have atomic values, no repeating groups, each row has a primary key.
- **2NF:** All non-key attributes are fully dependent on the primary key (no partial dependencies). Composite keys are not used; surrogate keys (SERIAL) are used instead.
- **3NF:** No transitive dependencies. For example, hotel city is stored directly in the hotels table (not derived from a separate hotel-city mapping), and payment status is stored in the payments table (not derived from booking status).

Foreign keys enforce referential integrity. CASCADE deletes are used for child tables (hotel_images, hotel_amenities, room_types, reviews) to prevent orphaned records when a parent hotel is deleted.

### 3.2.2 Physical Data Model

**Table 3.1: Database Tables and Descriptions**

| Table | Description | Key Columns |
|-------|-------------|-------------|
| users | Customer accounts | id, first_name, last_name, email, phone, password_hash, nationality |
| admin_users | Admin/staff accounts | id, full_name, email, password_hash, role (super_admin/sub_admin/hotel_manager/broker), status |
| cities | Ethiopian cities | id, name, region, is_active |
| hotels | Hotel properties | id, name, city, address, description, type, rating, price_per_night, latitude, longitude, is_featured, is_active |
| hotel_images | Hotel photos | id, hotel_id (FK), image_url, sort_order, is_primary |
| hotel_amenities | Hotel features | id, hotel_id (FK), amenity |
| room_types | Room categories | id, hotel_id (FK), name, bed_type, image_url, price_per_night, max_guests, room_status |
| bookings | Reservation records | id, user_id (FK), hotel_id (FK), room_type_id (FK), check_in, check_out, adults, children, rooms, total_price, payment_method, status, guest_full_name, guest_email, guest_phone, national_id_front, national_id_back |
| payments | Payment records | id, booking_id (FK), user_id (FK), amount, currency, method, status, transaction_id, screenshot_url, verified_by, verified_at |
| reviews | Hotel reviews | id, hotel_id (FK), user_id (FK), rating, comment |
| wishlist | User saved hotels | id, user_id (FK), hotel_id (FK) |
| notifications | In-app notifications | id, user_id (FK), admin_id (FK), type, title, message, is_read, booking_id |
| hotel_managers | Manager-hotel assignments | id, admin_id (FK), hotel_id (FK), sub_admin_id (FK) |
| admin_city_assignments | Sub Admin city assignments | id, admin_id (FK), city |
| hotel_payment_methods | Hotel-specific payment options | id, hotel_id (FK), method, account_name, account_number, phone_number, instructions, is_active |
| otp_codes | OTP verification codes | id, phone, code, purpose, used, expires_at |

**SQL Schema (Key Tables):**

```sql
-- Users table
CREATE TABLE users (
    id               SERIAL PRIMARY KEY,
    first_name       VARCHAR(100) NOT NULL,
    last_name        VARCHAR(100) NOT NULL DEFAULT '',
    email            VARCHAR(255) UNIQUE,
    phone            VARCHAR(30)  UNIQUE,
    password_hash    TEXT,
    nationality      VARCHAR(100),
    avatar_url       TEXT,
    status           VARCHAR(20)  NOT NULL DEFAULT 'active',
    is_verified      BOOLEAN      NOT NULL DEFAULT false,
    last_login       TIMESTAMPTZ,
    registered_date  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Hotels table
CREATE TABLE hotels (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    address         TEXT         NOT NULL DEFAULT '',
    description     TEXT,
    type            VARCHAR(50)  NOT NULL DEFAULT 'hotel',
    rating          NUMERIC(3,2) NOT NULL DEFAULT 0,
    review_count    INT          NOT NULL DEFAULT 0,
    price_per_night NUMERIC(12,2) NOT NULL DEFAULT 0,
    latitude        DOUBLE PRECISION NOT NULL DEFAULT 0,
    longitude       DOUBLE PRECISION NOT NULL DEFAULT 0,
    is_featured     BOOLEAN      NOT NULL DEFAULT false,
    is_active       BOOLEAN      NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Room types table
CREATE TABLE room_types (
    id              SERIAL PRIMARY KEY,
    hotel_id        INT           NOT NULL REFERENCES hotels(id) ON DELETE CASCADE,
    name            VARCHAR(100)  NOT NULL,
    bed_type        VARCHAR(50)   NOT NULL DEFAULT '',
    image_url       TEXT,
    price_per_night NUMERIC(12,2) NOT NULL DEFAULT 0,
    size_sqm        NUMERIC(8,2)  NOT NULL DEFAULT 0,
    max_guests      INT           NOT NULL DEFAULT 2,
    is_available    BOOLEAN       NOT NULL DEFAULT true,
    room_status     VARCHAR(30)   NOT NULL DEFAULT 'available'
);

-- Bookings table
CREATE TABLE bookings (
    id               SERIAL PRIMARY KEY,
    user_id          INT           NOT NULL REFERENCES users(id),
    hotel_id         INT           NOT NULL REFERENCES hotels(id),
    room_type_id     INT                    REFERENCES room_types(id),
    check_in         DATE          NOT NULL,
    check_out        DATE          NOT NULL,
    adults           INT           NOT NULL DEFAULT 1,
    children         INT           NOT NULL DEFAULT 0,
    rooms            INT           NOT NULL DEFAULT 1,
    total_price      NUMERIC(12,2) NOT NULL DEFAULT 0,
    payment_method   VARCHAR(30)   NOT NULL,
    status           VARCHAR(20)   NOT NULL DEFAULT 'pending',
    special_requests TEXT,
    guest_full_name  VARCHAR(255)  NOT NULL DEFAULT '',
    guest_email      VARCHAR(255),
    guest_phone      VARCHAR(50),
    national_id_front TEXT,
    national_id_back  TEXT,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
    id             SERIAL PRIMARY KEY,
    booking_id     INT           NOT NULL REFERENCES bookings(id),
    user_id        INT           NOT NULL REFERENCES users(id),
    amount         NUMERIC(12,2) NOT NULL,
    currency       VARCHAR(10)   NOT NULL DEFAULT 'ETB',
    method         VARCHAR(30)   NOT NULL,
    status         VARCHAR(20)   NOT NULL DEFAULT 'pending',
    transaction_id TEXT,
    screenshot_url TEXT,
    verified_by    INT                    REFERENCES admin_users(id),
    verified_at    TIMESTAMPTZ,
    paid_at        TIMESTAMPTZ,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Admin users table
CREATE TABLE admin_users (
    id            SERIAL PRIMARY KEY,
    full_name     VARCHAR(255) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone         VARCHAR(30),
    password_hash TEXT         NOT NULL,
    role          VARCHAR(30)  NOT NULL,
    status        VARCHAR(20)  NOT NULL DEFAULT 'active',
    avatar_url    TEXT,
    last_login    TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by    INT                   REFERENCES admin_users(id)
);
```

## 3.3 User Interface Design

### 3.3.1 Mobile App Screens (Flutter)

```
Splash Screen
  |-- Home Screen (4-tab navigation)
      |-- Tab 1: Home
      |     |-- Hero Section (search bar, stats)
      |     |-- City Grid (13 cities with local images)
      |     |-- Featured Hotels (horizontal scroll)
      |     |-- FAQ Section
      |-- Tab 2: Search/Hotel List
      |     |-- Filter bar (city, price, rating)
      |     |-- Hotel grid cards
      |-- Tab 3: Wishlist (requires login)
      |     |-- Saved hotels list
      |-- Tab 4: Profile/Dashboard (requires login)
            |-- Dashboard with booking stats
            |-- My Bookings list
            |-- Profile edit
            |-- Notifications

Hotel Detail Screen
  |-- Image gallery (PageView)
  |-- Hotel info (name, rating, location, amenities)
  |-- Tabs: Rooms | Details | Reviews
  |-- Room list with availability
  |-- Sticky booking bar

Booking Confirm Screen
  |-- Step 1: Guest Details
  |     |-- Personal info (name, email, phone, nationality)
  |     |-- Stay details (adults, children, rooms)
  |     |-- National ID/Passport upload (front + back — REQUIRED)
  |-- Step 2: Payment
  |     |-- Payment method selection
  |     |-- Payment proof upload (screenshot)
  |     |-- Confirm & Submit

Payment Success Screen
  |-- Booking confirmation
  |-- Booking ID

Auth Screens
  |-- Login (guest + admin tabs)
  |-- Register (with form validation)
  |-- OTP verification
  |-- Forgot password

Admin Screens
  |-- Super Admin Dashboard
  |-- Sub Admin Dashboard
  |-- Hotel Manager Dashboard
  |-- Hotel/Room/Manager management
```

### 3.3.2 Web App Pages (React)

```
Home Page
  |-- Hero section with search
  |-- Featured hotels
  |-- City browse
  |-- Footer with mobile app download section

Hotel List Page
  |-- Filters (city, price, rating, amenities)
  |-- Hotel cards grid
  |-- Pagination

Hotel Detail Page
  |-- Image gallery
  |-- Hotel info + amenities
  |-- Room list with availability
  |-- Reviews section

Booking Confirm Page
  |-- Guest details form
  |-- National ID upload (required)
  |-- Payment method selection
  |-- Payment proof upload

Auth Pages
  |-- Login (guest + admin)
  |-- Register
  |-- OTP
  |-- Forgot password

Dashboard Pages
  |-- User dashboard (bookings, wishlist, profile)
  |-- Super Admin dashboard (cities, sub admins, overview)
  |-- Sub Admin dashboard (hotels, rooms, managers, reports)
  |-- Hotel Manager dashboard (bookings, payments, rooms, reports)
  |-- Settings page
```

## 3.4 System Architecture

### 3.4.1 Component Architecture

```
+------------------+     +------------------+     +------------------+
|  Mobile App       |     |  Web App          |     |  Admin Web       |
|  (Flutter/Dart)   |     |  (React.js)       |     |  (React.js)      |
|  - Android/iOS    |     |  - Desktop browser |     |  - Admin panel   |
|  - REST API client |     |  - REST API client |     |  - REST API client|
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         |     HTTP/HTTPS         |     HTTP/HTTPS         |
         |     (JSON REST)        |     (JSON REST)        |
         v                        v                        v
+------------------------------------------------------------------+
|                    Go Backend API (Gin)                           |
|  - Auth module (register, login, OTP, JWT)                      |
|  - Hotels module (search, detail, availability, reviews)          |
|  - Booking module (create, cancel, view)                        |
|  - Payment module (initiate, submit, verify, status)            |
|  - Wishlist module (add, remove, list)                          |
|  - Guest module (profile, change password)                      |
|  - Notifications module (list, read, read-all)                  |
|  - Admin module (super, sub, manager, broker — RBAC)            |
++-----------------------------------------------------------------+
         |
         v
+------------------------------------------------------------------+
|                    PostgreSQL Database                            |
|  16 tables: users, admin_users, cities, hotels, hotel_images,   |
|  hotel_amenities, room_types, bookings, payments, reviews,       |
|  wishlist, notifications, hotel_managers, admin_city_assignments,|
|  hotel_payment_methods, otp_codes                                |
+------------------------------------------------------------------+
```

### 3.4.2 Deployment Diagram

```
+-------------------------------------------------------+
|              Cloud Server (VPS)                        |
|                                                       |
|  +-----------------+    +---------------------+        |
|  |  Go Binary      |    |  PostgreSQL          |        |
|  |  (port 8080)    |--->|  (port 5432)         |        |
|  |  Nginx reverse  |    |  Database: dallolbook |        |
|  |  proxy (port 80)|    +---------------------+        |
|  +-----------------+                                  |
|                                                       |
|  +-----------------+                                   |
|  |  React Build    |                                   |
|  |  (static files)  |                                   |
|  |  served by Nginx |                                   |
|  +-----------------+                                   |
+-------------------------------------------------------+

Mobile App (APK/IPA)     Web Browser
  - Installed on device    - Access via URL
  - Connects to API        - Connects to API
  - Local asset images     - Cloud-hosted images
```

### 3.4.3 API Endpoints

**Guest API (/api/v1):**

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/register | Register new user |
| POST | /auth/login | User login |
| POST | /auth/otp/send | Send OTP |
| POST | /auth/otp/verify | Verify OTP |
| POST | /auth/forgot-password | Request password reset |
| POST | /auth/reset-password | Reset password |
| GET | /hotels/featured | Get featured hotels |
| GET | /hotels/search | Search hotels with filters |
| GET | /hotels/:id | Get hotel detail with rooms |
| GET | /hotels/:id/availability | Check room availability for dates |
| GET | /hotels/:id/payment-methods | Get hotel payment methods |
| GET | /hotels/:id/reviews | Get hotel reviews |
| POST | /hotels/:id/reviews | Post a review (auth required) |
| GET | /bookings | List user bookings (auth) |
| POST | /bookings | Create booking (auth) |
| GET | /bookings/:id | Get booking detail (auth) |
| POST | /bookings/:id/cancel | Cancel booking (auth) |
| POST | /payments/initiate | Initiate payment (auth) |
| GET | /payments/:id/status | Get payment status (auth) |
| POST | /payments/:id/submit | Submit payment proof (auth) |
| GET | /wishlist | List wishlist (auth) |
| POST | /wishlist | Toggle wishlist (auth) |
| DELETE | /wishlist/:hotelId | Remove from wishlist (auth) |
| GET | /guest/profile | Get profile (auth) |
| PUT | /guest/profile | Update profile (auth) |
| POST | /guest/change-password | Change password (auth) |
| GET | /notifications | List notifications (auth) |
| POST | /notifications/:id/read | Mark read (auth) |
| POST | /notifications/read-all | Mark all read (auth) |

**Public API (/api):**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /public/cities | Get all active cities |

**Admin API (/api/admin):**

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /login | Admin login |
| GET | /profile | Admin profile (auth) |
| PUT | /profile | Update profile (auth) |
| POST | /change-password | Change password (auth) |
| **Super Admin** | | |
| GET | /super/dashboard | National overview |
| GET/POST | /super/sub-admins | CRUD sub admins |
| PUT/DELETE | /super/sub-admins/:id | Edit/delete sub admin |
| POST | /super/sub-admins/:id/assign-city | Assign city |
| DELETE | /super/sub-admins/:id/revoke-city/:city | Revoke city |
| GET/POST | /super/cities | CRUD cities |
| DELETE | /super/cities/:id | Delete city |
| GET | /super/hotels | View all hotels |
| GET | /super/bookings | View all bookings |
| GET | /super/users | View all users |
| **Sub Admin** | | |
| GET | /sub/dashboard | City dashboard |
| GET/POST | /sub/hotels | CRUD hotels |
| PUT | /sub/hotels/:id | Edit hotel |
| POST | /sub/hotels/:id/toggle | Toggle hotel active |
| GET/POST | /sub/hotels/:id/rooms | CRUD rooms |
| PUT/DELETE | /sub/hotels/:id/rooms/:rid | Edit/delete room |
| GET/POST | /sub/hotels/:id/payment-methods | Payment methods |
| GET | /sub/bookings | View city bookings |
| GET/POST | /sub/managers | CRUD managers |
| GET | /sub/brokers | View brokers |
| **Hotel Manager** | | |
| GET | /manager/dashboard | Hotel dashboard |
| GET/POST | /manager/rooms | CRUD rooms |
| POST | /manager/rooms/:rid/status | Set room status |
| GET | /manager/bookings | View hotel bookings |
| POST | /manager/bookings/:id/status | Update booking status |
| GET | /manager/payments | View payments |
| POST | /manager/payments/:id/verify | Verify (accept/reject) payment |
| GET/POST | /manager/payment-methods | Manage payment methods |

---

# CHAPTER 4: IMPLEMENTATION

## 4.1 Overview of the Programming Languages Used

### 4.1.1 Dart (Flutter Mobile App)

Dart is the programming language used with the Flutter framework to build the cross-platform mobile application. The mobile app is structured using the Provider pattern for state management:

**Project Structure (booking_mobilapp/lib/):**
```
lib/
  main.dart                    -- App entry point, provider setup
  core/
    constants/
      api_constants.dart       -- API URL configuration, environment switching
      app_colors.dart          -- Color palette
      app_images.dart          -- Local asset image paths + network fallbacks
    services/
      api_service.dart         -- Dio HTTP client, JWT interceptors, error handling
    utils/
      validators.dart          -- Form validation rules (name, email, phone, password)
  models/
    hotel.dart                 -- Hotel, Room, City, PaymentMethod models
    booking.dart               -- Booking model
    user.dart                  -- User model
    review.dart                -- Review model
    search_params.dart        -- Search parameter model
  providers/
    auth_provider.dart         -- Authentication state, login, register, OTP
    hotel_provider.dart        -- Hotel data, search, detail, home loading
    booking_provider.dart      -- Booking creation, payment initiation, submission
    wishlist_provider.dart     -- Wishlist state management
    language_provider.dart     -- English/Amharic language switching
  screens/
    splash_screen.dart
    home/home_screen.dart      -- 4-tab home (Home, Search, Saved, Profile)
    hotels/
      hotel_list_screen.dart   -- Hotel search results
      hotel_detail_screen.dart -- Hotel detail with rooms, reviews, booking
      city_hotels_screen.dart  -- Hotels filtered by city
    booking/
      booking_confirm_screen.dart -- 2-step booking form (details + payment)
    payment/
      payment_success_screen.dart
    auth/
      login_screen.dart
      register_screen.dart
      otp_screen.dart
      forgot_password_screen.dart
    dashboard/
      dashboard_screen.dart    -- User dashboard with stats
      bookings_list_screen.dart
      profile_screen.dart
      wishlist_screen.dart
    admin/
      admin_dashboard_screen.dart
      super_admin_screen.dart
      sub_admin_screen.dart
      hotel_manager_screen.dart
      admin_profile_screen.dart
      broker_screen.dart
    notifications/
      notifications_screen.dart
  widgets/
    hotel_card.dart            -- Hotel card (grid + list variants)
    local_or_network_image.dart -- Image loading: local asset -> network -> placeholder
    hotel_image.dart           -- Smart image (network/base64/local)
    star_rating.dart
    app_logo.dart
    app_spinner.dart
    app_bar_widgets.dart
```

### 4.1.2 JavaScript/TypeScript (React.js Web App)

The web application is built with React.js using TypeScript for type safety and Tailwind CSS for styling:

**Project Structure (dallolbook_go/frontend/src/):**
```
src/
  App.tsx                      -- Router setup
  main.tsx                     -- Entry point
  index.css                    -- Global styles
  pages/
    home/Home.tsx
    hotels/HotelList.tsx, HotelDetail.tsx
    booking/BookingConfirm.tsx
    payment/Payment.tsx, PaymentSuccess.tsx
    auth/Login.tsx, Register.tsx, OTP.tsx, ForgotPassword.tsx
    dashboard/Dashboard.tsx, BookingsList.tsx, Profile.tsx, Wishlist.tsx
    admin/
      AdminLogin.tsx
      SuperDashboard.tsx
      SubAdminDashboard.tsx
      ManagerDashboard.tsx
      super/ (CitiesPage, SubAdminsPage, HotelsPage, BookingsPage, UsersPage)
      subadmin/ (HotelsPage, ManagersPage, BookingsPage, BrokersPage)
      manager/ (BookingsPage, PaymentsPage, RoomsPage, PaymentMethodsPage)
      SettingsPage.tsx
  components/
    shared/ (Navbar, Footer, Button, Input, Modal, Spinner, Badge, etc.)
    hotel/ (HotelCard, etc.)
    booking/ (BookingForm, etc.)
    admin/ (AdminSidebar, etc.)
  context/ (AuthContext, LanguageContext)
  hooks/ (useApi, etc.)
  services/ (api.ts, etc.)
  i18n/ (en.ts, am.ts, index.ts)
  router/ (routes.tsx)
  utils/ (helpers.ts, etc.)
```

### 4.1.3 Go (Golang Backend)

The backend is built with Go using the Gin web framework. It follows a modular architecture where each domain (auth, hotels, booking, payment, etc.) has its own module with handler, model, and routes:

**Project Structure (dallolbook_go/backend/):**
```
backend/
  cmd/main.go                  -- Server entry point, route registration, CORS, DB connection
  modules/
    auth/ (handler.go, model.go, routes.go)
    hotels/ (handler.go, model.go, routes.go)
    booking/ (handler.go, model.go, routes.go)
    payment/ (handler.go, model.go, routes.go)
    wishlist/ (handler.go, model.go, routes.go)
    guest/ (handler.go, model.go, routes.go)
    notifications/ (handler.go, model.go, routes.go)
    review/ (handler.go, model.go, routes.go)
    admin/ (handler.go, model.go, routes.go)
  config/ (config.go)
  middleware/ (auth.go, cors.go)
  utils/ (response.go, jwt.go)
  database/
    migrations/ (000001-000024 SQL migration files)
    seed.sql
```

## 4.2 Algorithms Used

### 4.2.1 Booking Creation Algorithm

```
INPUT: hotel_id, room_type_id, check_in, check_out, adults, children, rooms, 
       payment_method, guest_full_name, guest_email, guest_phone, 
       national_id_front, national_id_back

1. Validate required fields (hotel_id, check_in, check_out, adults, rooms, payment_method)
2. Validate national_id_front and national_id_back are not empty (REQUIRED)
3. Validate rooms <= 2 (maximum 2 rooms per booking)
4. Parse dates (YYYY-MM-DD format)
5. Validate check_out > check_in
6. Validate check_in >= today
7. Validate payment_method is in allowed list
8. Verify hotel is active (GetHotelPrice)
9. If room_type_id provided:
   a. Query max_guests from room_types table
   b. Validate (adults + children) <= (max_guests * rooms)
   c. Get room price_per_night
10. Calculate nights = (check_out - check_in) in days
11. Calculate total_price = price_per_night * nights * rooms
12. INSERT booking record (status = 'pending')
13. Auto-create payment record (status = 'pending', amount = total_price)
14. Send notification to Hotel Manager
15. Return booking detail

OUTPUT: booking_id, booking details
```

### 4.2.2 Payment Verification Algorithm

```
INPUT: payment_id, action (accept/reject), admin_id

1. Verify admin is a Hotel Manager assigned to the payment's hotel
2. Get payment record by ID
3. If action == "accept":
   a. UPDATE payment SET status = 'completed', verified_by = admin_id, verified_at = NOW()
   b. UPDATE booking SET status = 'confirmed'
   c. UPDATE room_type SET room_status = 'occupied' (if room_type_id exists)
   d. INSERT notification for user: "Payment confirmed"
4. If action == "reject":
   a. UPDATE payment SET status = 'failed', verified_by = admin_id, verified_at = NOW()
   b. UPDATE booking SET status = 'cancelled'
   c. UPDATE room_type SET room_status = 'available' (if room_type_id exists)
   d. INSERT notification for user: "Payment rejected"

OUTPUT: updated payment and booking status
```

### 4.2.3 Form Validation Algorithm (Mobile App)

```
INPUT: form field values

Name validation:
  - Must not be empty (required)
  - Must be at least 2 characters
  - Must be at most 60 characters
  - Must contain only letters, spaces, hyphens, apostrophes (no numbers/symbols)
  - Supports Amharic characters (Unicode 1200-137F)

Email validation:
  - If required: must not be empty
  - Must match pattern: ^[^\s@]+@[^\s@]+\.[^\s@]{2,}$

Phone validation (Ethiopian format):
  - If required: must not be empty
  - Must match: 09XXXXXXXX, 07XXXXXXXX, +2519XXXXXXXX, +2517XXXXXXXX

Password validation:
  - Must not be empty
  - Must be at least 6 characters
  - Must contain at least one letter
  - Must contain at least one number

National ID validation:
  - Front image must be uploaded (not null, not empty)
  - Back image must be uploaded (not null, not empty)
  - Images are base64-encoded JPEG data URIs

OUTPUT: null (valid) or error message string (invalid)
```

## 4.3 Sample Codes

### 4.3.1 Backend — Booking Creation Handler (Go)

```go
func (h *Handler) Create(c *gin.Context) {
    userID := c.GetInt("user_id")
    
    var body struct {
        HotelID         int     `json:"hotel_id"`
        RoomTypeID      *int    `json:"room_type_id"`
        CheckIn         string  `json:"check_in"`
        CheckOut        string  `json:"check_out"`
        Adults          int     `json:"adults"`
        Children        int     `json:"children"`
        Rooms           int     `json:"rooms"`
        PaymentMethod   string  `json:"payment_method"`
        SpecialRequests *string `json:"special_requests"`
        GuestFullName   string  `json:"guest_full_name"`
        GuestEmail      *string `json:"guest_email"`
        GuestPhone      *string `json:"guest_phone"`
        NationalIDFront *string `json:"national_id_front"`
        NationalIDBack  *string `json:"national_id_back"`
    }
    if err := c.ShouldBindJSON(&body); err != nil {
        utils.BadRequest(c, "Invalid request body")
        return
    }
    
    // Validate required fields
    if body.HotelID == 0 || body.CheckIn == "" || body.CheckOut == "" ||
        body.Adults == 0 || body.Rooms == 0 || body.PaymentMethod == "" {
        utils.Unprocessable(c, "hotel_id, check_in, check_out, adults, 
            rooms, payment_method are required")
        return
    }
    
    // National ID front and back are REQUIRED
    if body.NationalIDFront == nil || *body.NationalIDFront == "" ||
        body.NationalIDBack == nil || *body.NationalIDBack == "" {
        utils.Unprocessable(c, "National ID / Passport front and back 
            images are required")
        return
    }
    
    // Validate dates and calculate price...
    // Create booking and payment records...
    // Send notification to hotel manager...
}
```

### 4.3.2 Mobile App — Booking Form Validation (Dart)

```dart
void _goStep2() {
    if (!_formKey1.currentState!.validate()) return;
    if (_emailCtrl.text.trim().isEmpty && 
        _phoneCtrl.text.trim().isEmpty) {
        showError(context, 'Provide email or phone number');
        return;
    }
    if ((_adults + _children) > _capacity) {
        showError(context, 'Total guests exceed room capacity');
        return;
    }
    // National ID / Passport front is REQUIRED
    if (_idFrontB64 == null) {
        showError(context, 'Please upload your National ID / Passport 
            (front side)');
        return;
    }
    // National ID / Passport back is REQUIRED
    if (_idBackB64 == null) {
        showError(context, 'Please upload your National ID / Passport 
            (back side)');
        return;
    }
    setState(() => _step = 2);
}
```

### 4.3.3 Mobile App — Image Upload via Image Picker (Dart)

```dart
Future<String?> _pick() async {
    try {
        final picker = ImagePicker();
        final XFile? f = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
            maxWidth: 1200,
            maxHeight: 1200,
        );
        if (f == null) return null;
        final bytes = await f.readAsBytes();
        if (bytes.isEmpty) return null;
        return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (e) {
        showError(context, 'Failed to pick image: $e');
        return null;
    }
}
```

### 4.3.4 Backend — JWT Authentication Middleware (Go)

```go
func AuthRequired(cfg *config.Config) gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            utils.Unauthorized(c, "Authorization header required")
            return
        }
        token = strings.TrimPrefix(token, "Bearer ")
        claims, err := utils.VerifyJWT(token, cfg.JWTSecret)
        if err != nil {
            utils.Unauthorized(c, "Invalid or expired token")
            return
        }
        c.Set("user_id", claims.UserID)
        c.Set("admin_id", claims.AdminID)
        c.Set("role", claims.Role)
        c.Next()
    }
}
```

### 4.3.5 Mobile App — API Service with Dio (Dart)

```dart
class ApiService {
    static final ApiService instance = ApiService._();
    late final Dio _api;
    late final Dio _adminApi;
    
    void init() {
        _api = Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: Duration(seconds: 15),
            receiveTimeout: Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
        ));
        _api.interceptors.add(InterceptorsWrapper(
            onRequest: (opts, handler) async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                if (token != null && token.isNotEmpty) {
                    opts.headers['Authorization'] = 'Bearer $token';
                }
                handler.next(opts);
            },
        ));
    }
    
    Future<Map<String, dynamic>> get(String path, 
        {Map<String, dynamic>? params}) async {
        try {
            final r = await _api.get(path, queryParameters: params);
            return _check(r.data);
        } on DioException catch (e) {
            throw _parse(e);
        }
    }
}
```

---

# CHAPTER 5: TESTING

## 5.1 Sample Tests

Testing was conducted on a TECNO KN3 (Android 15, API 35) real device for the mobile app and on Google Chrome (Ubuntu 26.04) for the web app. The Go backend was tested using curl and Postman.

**Table 5.1: Test Case — User Registration**

| Field | Value |
|-------|-------|
| Test ID | TC-01 |
| Test Name | User Registration with valid data |
| Precondition | User does not have an account |
| Test Steps | 1. Open register page. 2. Enter first name "Abebe". 3. Enter last name "Mesfin". 4. Enter email "abebe@test.com". 5. Enter phone "0912345678". 6. Enter password "pass123". 7. Click "Create Account". |
| Expected Result | Account created, user logged in, redirected to home page |
| Actual Result | Account created, user logged in, redirected to home page |
| Status | PASS |

**Table 5.2: Test Case — Hotel Search by City**

| Field | Value |
|-------|-------|
| Test ID | TC-02 |
| Test Name | Search hotels by city |
| Precondition | User is on home page, backend is running |
| Test Steps | 1. Open home page. 2. Click "Addis Ababa" city card. 3. Wait for hotel list to load. |
| Expected Result | List of hotels in Addis Ababa is displayed with images, ratings, and prices |
| Actual Result | Hotels in Addis Ababa displayed with local images, ratings, and prices in ETB |
| Status | PASS |

**Table 5.3: Test Case — Room Booking with National ID**

| Field | Value |
|-------|-------|
| Test ID | TC-03 |
| Test Name | Book a room with mandatory National ID upload |
| Precondition | User is logged in, hotel and room selected, dates selected |
| Test Steps | 1. Fill guest details (name, email, phone). 2. Do NOT upload National ID. 3. Click "Continue to Payment". |
| Expected Result | Error message: "Please upload your National ID / Passport (front side)" |
| Actual Result | Error message displayed, user cannot proceed to payment step |
| Status | PASS |

| Field | Value |
|-------|-------|
| Test ID | TC-03b |
| Test Name | Book a room after uploading National ID |
| Precondition | User is on booking form Step 1 |
| Test Steps | 1. Fill guest details. 2. Upload National ID front image. 3. Upload National ID back image. 4. Click "Continue to Payment". |
| Expected Result | User proceeds to Step 2 (payment) |
| Actual Result | User proceeds to payment step successfully |
| Status | PASS |

**Table 5.4: Test Case — Payment Verification by Manager**

| Field | Value |
|-------|-------|
| Test ID | TC-04 |
| Test Name | Hotel Manager views pending payments |
| Precondition | A booking with pending payment exists, manager is logged in |
| Test Steps | 1. Manager logs in. 2. Open dashboard. 3. Click "Pending Payments". |
| Expected Result | List of pending payments displayed with customer details, amount, payment method, and payment proof screenshot |
| Actual Result | Pending payments displayed with customer name, amount in ETB, payment method, and screenshot |
| Status | PASS |

**Table 5.5: Test Case — Manager Accept Payment**

| Field | Value |
|-------|-------|
| Test ID | TC-05 |
| Test Name | Hotel Manager accepts a payment |
| Precondition | A pending payment exists for the manager's hotel |
| Test Steps | 1. Manager opens pending payment. 2. Reviews payment proof. 3. Clicks "Accept". |
| Expected Result | Payment status → completed, booking status → confirmed, room status → occupied, user receives confirmation notification |
| Actual Result | Payment completed, booking confirmed, room occupied, user notification sent |
| Status | PASS |

**Table 5.6: Test Case — Manager Reject Payment**

| Field | Value |
|-------|-------|
| Test ID | TC-06 |
| Test Name | Hotel Manager rejects a payment |
| Precondition | A pending payment exists for the manager's hotel |
| Test Steps | 1. Manager opens pending payment. 2. Reviews payment proof. 3. Clicks "Reject". |
| Expected Result | Payment status → failed, booking status → cancelled, room status → available, user receives rejection notification |
| Actual Result | Payment failed, booking cancelled, room available, user notification sent |
| Status | PASS |

**Additional Tests Conducted:**

- Form validation: name (letters only), email (format), phone (Ethiopian format), password (min 6 chars with letters + numbers) — all validated correctly on both client and server.
- Multi-city search: tested for all 13 cities — correct hotels returned for each city.
- Wishlist: add and remove hotels — works correctly with optimistic UI updates.
- Reviews: post a review — works correctly, rating updates.
- Notifications: new booking notification to manager — received correctly.
- Language switching: English ↔ Amharic — UI updates correctly.
- Admin roles: Super Admin, Sub Admin, Hotel Manager — each role only accesses their permitted screens.
- JWT authentication: tokens stored in SharedPreferences (mobile) / localStorage (web) — persistent login works.
- Image loading: local asset images load without internet; network fallback to Unsplash works when internet is available.

---

# CHAPTER 6: CONCLUSION AND RECOMMENDATIONS

## 6.1 Conclusion

The Hotel Reservation and Booking Management System for Ethiopia is a comprehensive, dual-platform solution designed to modernize and digitalize the hospitality industry across Ethiopian cities. By combining a Flutter mobile app, a React.js web app, a shared Go (Golang) backend, and a PostgreSQL database, the system addresses the critical inefficiencies of the current manual, telephone-based, and walk-in reservation processes that dominate the Ethiopian hotel sector.

The platform serves four distinct user roles — Super Admin, Sub Admin, Hotel Manager, and User (Customer) — each with clearly defined responsibilities and role-based access control, ensuring secure and efficient operations across all levels of the system. The Super Admin manages cities, Sub Admins, city assignments, and system settings. The Sub Admin manages hotels, rooms, and hotel managers within their assigned city, including Google Maps location integration. The Hotel Manager handles bookings, verifies payments, updates room occupancy, and manages check-in/check-out operations. The User can register, search hotels by city, view real-time room availability, book rooms with mandatory National ID/Passport upload, choose from multiple Ethiopian payment methods, and track their booking history.

The system's core booking and payment flow is designed for clarity and trust: users book rooms, upload National ID images (required), submit payments with proof, and hotel managers verify and approve or reject those payments before bookings are confirmed. This ensures financial security for both hotels and customers, eliminates manual double bookings, and provides full transparency throughout the transaction.

The system was successfully implemented, tested on a real Android device (TECNO KN3, Android 15), and deployed with a working Go backend and PostgreSQL database. All four user roles were tested and function correctly. Form validation, National ID upload enforcement, payment verification workflow, multi-city search, and bilingual support (English/Amharic) all work as designed.

## 6.2 Recommendations and Future Enhancement

1. **Real Payment Integration:** Integrate actual Telebirr and CBE Birr payment APIs when merchant accounts are obtained, replacing the current simulated payment flow.
2. **Cloud Storage:** Migrate National ID images and payment screenshots from base64 database storage to a cloud storage service (AWS S3, Cloudinary) for better scalability and performance.
3. **Push Notifications:** Implement Firebase Cloud Messaging (FCM) for real-time push notifications to mobile users.
4. **Email Notifications:** Integrate an email service (SendGrid, AWS SES) for booking confirmations and payment status updates.
5. **Advanced Search:** Add search by amenities, price range, hotel type, and guest ratings with faceted filtering.
6. **Loyalty Program:** Implement a points-based loyalty program for repeat customers.
7. **Multi-Currency:** Add support for USD and EUR for international tourists.
8. **Analytics Dashboard:** Add advanced analytics with charts (revenue trends, occupancy rates, booking patterns) for administrators.
9. **Mobile App Publication:** Publish the Flutter app to Google Play Store and Apple App Store.
10. **API Rate Limiting:** Implement rate limiting on the Go backend to prevent abuse.
11. **Automated Testing:** Add unit tests and integration tests for the backend and widget tests for the Flutter app.
12. **Docker Deployment:** Containerize the Go backend and PostgreSQL for easy deployment.
13. **Offline Mode Enhancement:** Implement local SQLite caching for hotel data so the app works fully offline after first load.
14. **Chat Support:** Add in-app chat between users and hotel managers for inquiries.

---

# REFERENCES

1. Donovan, A.A.A. and Kernighan, B.W. (2015) *The Go Programming Language*. Addison-Wesley.

2. Elmasri, R. and Navathe, S.B. (2016) *Fundamentals of Database Systems*, 7th ed., Pearson.

3. Ethiopian Ministry of Tourism (2024) *Tourism Statistics and Development Reports*. Addis Ababa: MoT.

4. Flutter Documentation (2024) *Flutter — Build apps for any screen*. Available at: https://flutter.dev/docs

5. Gin Web Framework Documentation (2024) *Gin Web Framework*. Available at: https://gin-gonic.com/docs

6. Go Documentation (2024) *The Go Programming Language*. Available at: https://go.dev/doc

7. Google Maps Platform (2024) *Google Maps SDK for Flutter and JavaScript API*. Available at: https://developers.google.com/maps

8. GORM Documentation (2024) *GORM — The fantastic ORM library for Golang*. Available at: https://gorm.io/docs

9. National Bank of Ethiopia (2024) *Payment System Regulations and Directives*. Addis Ababa: NBE.

10. PostgreSQL Documentation (2024) *PostgreSQL — The World's Most Advanced Open Source Relational Database*. Available at: https://www.postgresql.org/docs

11. Pressman, R.S. and Maxim, B.R. (2020) *Software Engineering: A Practitioner's Approach*, 9th ed., McGraw-Hill.

12. React Documentation (2024) *React — A JavaScript Library for Building User Interfaces*. Available at: https://react.dev

13. Sommerville, I. (2016) *Software Engineering*, 10th ed., Pearson Education.

14. World Travel & Tourism Council (2024) *Ethiopia Travel & Tourism Economic Impact Report*. London: WTTC.

---

# APPENDICES

## Appendix A: API Response Format

All API responses follow a standard JSON format:
```json
{
    "success": true,
    "message": "Description of the result",
    "data": { ... }
}
```

Error responses:
```json
{
    "success": false,
    "message": "Error description",
    "data": null
}
```

## Appendix B: Mobile App Configuration

Environment switching in `api_constants.dart`:
```dart
static const String _env = 'device';  // 'dev', 'android', 'device', 'prod'
static const String _lanIp = '10.129.161.58';  // PC's current IP
```

## Appendix C: Database Migration Files

The database schema is managed through 24 SQL migration files:
- 000001: Create users table
- 000002: Create otp_codes table
- 000003: Create cities table
- 000004: Create hotels table
- 000005: Create hotel_images table
- 000006: Create hotel_amenities table
- 000007: Create room_types table
- 000008: Create reviews table
- 000009: Create bookings table
- 000010: Create payments table
- 000011: Create wishlist table
- 000012: Create admin_users table
- 000013: Create admin_city_assignments table
- 000014: Create brokers table
- 000015: Create hotel_managers table
- 000016: Create broker_messages table
- 000017: Create admin overview view
- 000018: Add payment screenshot column
- 000019: Create notifications table
- 000020: Create hotel_payment_methods table
- 000021: Add national_id columns to bookings
- 000022: Add room_status column to room_types
- 000023: Clean up blob:// image URLs
- 000024: Allow multiple payment methods per hotel

## Appendix D: GitHub Repository

The complete source code is available at:
https://github.com/gitabe60-dev/final-hotel-booking-in-ethiopa

Repository structure:
```
final-hotel-booking-in-ethiopa/
  booking_mobilapp/     -- Flutter mobile app
  dallolbook_go/        -- Go backend + React web frontend
  SRS_Documentation.md  -- This document
```
