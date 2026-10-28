# INTERNSHIP FINAL REPORT

---

## COVER PAGE

**INTERNSHIP FINAL REPORT**

**Submitted in Partial Fulfillment of the Requirements for the Degree of Bachelor of Science in Software Engineering**

---

**Student Name:** _____ABEBE MESFIN_____________________________
**University:** Debre Markos University  
**Institute:** Institute of Technology  
**Academic Program:** Software Engineering

**Internship Hosting Company:** Dallol Tech PLC  
**Company Website:** https://dalloltech.com/  
**Company Location:** Addis Ababa, Ethiopia

**Internship Duration:** ____________ to ____________

**Submitted To:** ________FIKERT SAWUEL___________________________ (Supervisor)

**Date of Submission:** ___________________________________

---

## DECLARATION

I, ___________________________________, hereby declare that this internship report is my own original work, prepared under the supervision of my mentor at Dallol Tech PLC and my academic supervisor at Debre Markos University. All sources of information used in the preparation of this report have been duly acknowledged.

**Student Signature:** _______________ **Date:** ___________

**Mentor Approval:**  

**Mentor Name:** _______________ **Signature:** ___________ **Date:** ___________

**Supervisor Approval:**  

**Supervisor Name:** _______________ **Signature:** ___________ **Date:** ___________

---

## ACKNOWLEDGEMENTS

First and foremost, I would like to express my sincere gratitude to the Almighty God for giving me the strength and wisdom to complete my internship successfully.

I am deeply grateful to the management and staff of **Dallol Tech PLC**, particularly to **Mr. Abel Mulugeta** (Founder & CEO), for providing me with the opportunity to intern at such a dynamic and innovative technology company. I would like to thank my mentor and the entire development team — including the senior developers, QA team, and project managers — for their continuous guidance, patience, and support throughout my internship period.

I would also like to extend my heartfelt thanks to my academic supervisor at **Debre Markos University, Institute of Technology**, for their valuable advice and direction throughout the internship program.

Finally, I thank my family and friends for their unwavering encouragement and moral support during the entire internship journey.

---

## EXECUTIVE SUMMARY

This report documents my internship experience at **Dallol Tech PLC**, a software and IT solutions company based in Addis Ababa, Ethiopia. The internship was conducted as part of the Bachelor of Science in Software Engineering program at Debre Markos University, Institute of Technology.

During my internship at Dallol Tech PLC, I worked on four major software projects that span both web and mobile platforms:

1. **Hotel Booking Mobile Application** — A Flutter-based mobile application for booking hotels across Ethiopia, featuring hotel search, room selection, payment integration, and user authentication.

2. **Hotel Booking Website** — A full-stack web application built with CodeIgniter 4 (PHP framework) and PostgreSQL, featuring a multi-role admin hierarchy (Super Admin, Sub Admin, Broker, Hotel Manager), dynamic city management, real-time room availability checking, and a complete Ethiopian payment system.

3. **ERP System** — An Enterprise Resource Planning system with modules for HR management, inventory, sales, CRM, POS, and finance, built on CodeIgniter 4 with PostgreSQL.

4. **Oromia Communication Bureau Platform** — A Flutter-based government communication platform for the Oromia Communication Bureau, featuring localization, workflow automation, and institutional communication management.

The internship provided me with extensive hands-on experience in modern software development practices, including MVC architecture, RESTful API design, database design with PostgreSQL, JWT authentication, role-based access control, frontend development with Bootstrap 5, and mobile app development with Flutter. I gained practical skills in teamwork, project management, version control with Git, and professional communication in a real-world software development environment.

---

## TABLE OF CONTENTS

1. Cover Page
2. Declaration
3. Acknowledgements
4. Executive Summary
5. Table of Contents
6. Objective
7. Background of the Hosting Company
8. Overall Internship Experience
9. Benefits Gained from the Internhip
10. Practical Application of Knowledge
11. Problems Solved During the Internship
12. Conclusion and Recommendations
13. References
14. Appendices

---

## OBJECTIVE

The primary objectives of this internship were:

1. **To gain practical experience** in a real-world software development environment, bridging the gap between theoretical knowledge acquired at the university and industry practice.

2. **To understand the software development lifecycle** in a professional setting, from requirements analysis to deployment and maintenance.

3. **To develop technical skills** in modern web and mobile application development, including PHP (CodeIgniter 4), Flutter (Dart), PostgreSQL database design, RESTful API development, and frontend technologies.

4. **To understand the organizational structure and workflow** of a technology company, including project management, quality assurance, and client communication.

5. **To contribute to real projects** that serve Ethiopian businesses and government institutions, gaining a sense of professional responsibility and work ethics.

6. **To improve interpersonal and teamwork skills** by collaborating with senior developers, QA engineers, and project managers in a professional environment.

---

## 1. BACKGROUND OF THE HOSTING COMPANY

### 1.1 Brief History

**Dallol Tech PLC** is a modern software and IT solutions company based in Addis Ababa, Ethiopia. The company is inspired by the resilience of the Dallol region — one of the most extreme and geologically unique areas in the world, located in the Danakil Depression of northeastern Ethiopia. Just as the Dallol region represents extremes of nature and resilience, Dallol Tech PLC embodies resilience, innovation, and the drive to push technological boundaries in Africa.

Founded by **Mr. Abel Mulugeta**, Dallol Tech PLC has been operating for over **5 years** in the Ethiopian technology sector. The company began as a small software development team and has grown into a comprehensive technology solutions provider serving both private businesses and government institutions across Ethiopia.

The company received its **Certificate of Professional Competence** from the FDRE Ministry of Innovation and Technology (MOST) in 2020, acknowledging fulfillment of requirements for software development activities. Since then, the company has expanded its services and received multiple recognitions.

### 1.2 Main Products and Services

Dallol Tech PLC offers a comprehensive suite of IT solutions organized into the following service pillars:

**1. Managed Platforms**  
Scalable digital platforms tailored to organizational operations. This includes custom web applications, ERP systems, booking platforms, and enterprise management software.

**2. Simulation & Training Systems**  
Hands-on systems and simulation programs for performance and safety, including driving simulator systems and school management platforms.

**3. Security & Compliance**  
Security-first solutions with strong governance and reliability, including cybersecurity consulting, secure payment integrations, and data protection services.

**4. Custom Software Development**  
- Web application development using CodeIgniter 4, PHP, and modern frontend frameworks
- Mobile application development using Flutter (Dart) for Android and iOS
- Cloud solutions and database design with PostgreSQL
- API development and system integrations
- E-commerce and payment gateway integration

**5. IT Consulting**  
Technology consulting for organizations undergoing digital transformation, including system architecture design, technology stack selection, and project planning.

**6. Learning Hub**  
The company offers educational courses including:
- CodeIgniter 4 Complete Course (From Beginner to Advanced)
- Go (Golang) Complete Course
- PostgreSQL Course: From Zero to Database Hero

### 1.3 Main Customers and End Users

Dallol Tech PLC serves a diverse range of clients across Ethiopia:

**Government Institutions:**
- **Oromia Communication Bureau** — A large-scale government digital transformation platform to modernize communication infrastructure and automate institutional workflows.

**Private Companies:**
- **Yadi EV (Electric Vehicle)** — Contributed to fintech and enterprise digitalization projects, including secure payment gateway integrations and scalable transaction systems.
- **Rehoboth Drivers Training Center** — Delivered eSchool (school management) and driving-simulator systems.
- **Betelhem Yosef Telecom** — Short code development and integration with Ethio Telecom (9495).

**Non-Profit Organizations:**
- **Mekedonia Charity Association** — Provided free website software and technology support, recognized with an award in 2021.

**General Clients:**
- Hotels and hospitality businesses requiring booking platforms
- Educational institutions needing management systems
- Organizations requiring ERP and CRM solutions

The company has served over **120 happy clients** and completed **82+ finished projects** with **120+ partnerships** over its 5+ years of operation.

### 1.4 Overall Organization and Work Flow

Dallol Tech PLC operates with a clear organizational structure designed to ensure efficient project delivery and quality control:

**Leadership:**
- **Abel Mulugeta** — Founder & CEO
- **Bezawit Nigussu** — Chief Finance Officer (CFO)

**Technology Management:**
- **Walelign Damtew** — Manager: Technology
- **Sisay Gebremedhin** — Development Manager: Software Engineering Expert
- **Leul Sewale, Habtamu Esubalew, Fikirte Shawul** — Senior Developers

**Quality & Project Management:**
- **Sintayehu Nigussie** — Manager: QA
- **Kidstemariam Asfaw** — Manager: Project
- **Mesay Alemayehu** — Manager: Business Strategy & Analysis

**Data & Analytics:**
- **Gedion Bula** — Business Support & Analytics Manager
- **Mikiyas Mesfin** — Data Science Specialist & Communication Liaison

**Project Workflow:**
The company follows an agile-inspired development workflow:

1. **Requirements Gathering** — Client needs are analyzed by the Business Strategy team
2. **System Design** — Architecture and database design by the Technology team
3. **Development** — Implementation by the development team using MVC architecture
4. **Quality Assurance** — Testing and validation by the QA team
5. **Deployment** — Production release with ongoing support
6. **Maintenance** — Long-term partnership and optimization

### 1.5 Overall Site Layout

The company office is organized into functional zones:

- **Reception and Meeting Area** — Client meetings and initial consultations
- **Development Floor** — Open-plan workspace for developers with dual-monitor setups
- **QA Testing Area** — Dedicated testing environment with multiple devices and platforms
- **Project Management Office** — Planning and coordination space
- **Server Room** — On-premise servers and networking equipment
- **Conference Room** — Team meetings, presentations, and training sessions
- **Break Area** — Kitchen and rest facilities for staff

The development environment utilizes:
- **Version Control:** Git and GitHub for source code management
- **Development Frameworks:** CodeIgniter 4 (PHP), Flutter (Dart)
- **Database:** PostgreSQL for all production systems
- **Deployment:** Linux-based servers with Apache/Nginx
- **Testing:** Manual and automated testing with QA processes

---

## 2. OVERALL INTERNSHIP EXPERIENCE

### 2.1 How I Got Into the Company

I learned about Dallol Tech PLC through the university's internship placement program. After researching the company on their website (https://dalloltech.com/), I was impressed by their portfolio of real-world projects and their commitment to digital transformation in Ethiopia. I submitted my application along with my academic transcript and a cover letter expressing my interest in software development. Following a technical interview where I demonstrated my knowledge of PHP, database concepts, and basic mobile development, I was accepted as an intern in the development team.

### 2.2 Section of the Company I Worked In

During my internship, I was placed in the **Software Development** section under the supervision of the Technology Manager and senior developers. My work was divided across four main projects, each representing a different aspect of modern software development:

**Project 1: Hotel Booking Mobile Application (Flutter)**
- Role: Mobile App Developer
- Technology: Flutter (Dart), RESTful API integration
- Duration: Initial phase of internship

**Project 2: Hotel Booking Website (CodeIgniter 4 + PostgreSQL)**
- Role: Full-Stack Web Developer
- Technology: PHP (CodeIgniter 4), PostgreSQL, Bootstrap 5, JavaScript
- Duration: Major portion of internship

**Project 3: ERP System**
- Role: Backend Developer
- Technology: CodeIgniter 4, PostgreSQL, Module-based architecture
- Duration: Middle phase of internship

**Project 4: Oromia Communication Bureau Platform (Flutter)**
- Role: Mobile App Developer
- Technology: Flutter, Localization, Government communication workflows
- Duration: Final phase of internship

### 2.3 Work Flow in the Section

The development section followed a structured workflow:

1. **Daily Stand-up Meetings** — Each morning, the team discussed tasks, progress, and blockers.

2. **Task Assignment** — Tasks were assigned based on project priorities and individual skills. I received tasks through verbal assignment from my mentor and through project discussions.

3. **Development Phase** — I worked on my assigned tasks using:
   - Local development environment with PHP spark serve
   - PostgreSQL database for data storage
   - CodeIgniter 4 MVC architecture for web projects
   - Flutter framework for mobile projects
   - Git for version control

4. **Code Review** — My code was reviewed by senior developers before merging.

5. **Testing** — QA team tested the features I developed on different devices and scenarios.

6. **Deployment** — After passing QA, features were deployed to the production server.

### 2.4 Work Tasks I Executed

During my internship, I executed a wide range of tasks across all four projects:

**Hotel Booking Website Tasks:**
- Designed and implemented the PostgreSQL database schema with 15+ tables including users, hotels, room_types, bookings, payments, reviews, wishlist, cities, admin_users, brokers, and hotel_managers
- Built the complete MVC architecture with CodeIgniter 4 — models, controllers, and views
- Implemented a multi-role admin hierarchy: Super Admin → Sub Admin → Broker → Hotel Manager, each with role-based access control
- Created dynamic city management — super admin can add any Ethiopian city (52 cities pre-loaded) and they appear instantly on the website
- Implemented real-time room availability checking — rooms show as "Available" or "Occupied for selected dates" based on existing bookings
- Built the complete booking flow: Hotel search → Room selection → Booking → Payment → Confirmation
- Implemented 12 Ethiopian payment methods (Telebirr, CBE Birr, Awash Bank, Dashen Bank, Amhara Bank, etc.)
- Created animated test payment forms with credit card preview, bank transfer forms, and mobile money forms
- Developed an expert recommendation system that suggests similar hotels based on city, price, rating, and user booking history
- Implemented JWT authentication for the mobile API endpoints
- Built the complete frontend with Bootstrap 5, custom CSS animations (hero slider, card carousels, scroll reveal), and JavaScript interactivity

**Hotel Booking Mobile App Tasks:**
- Developed the Flutter mobile application with screens for authentication, home, hotel search, hotel detail, booking, wishlist, and user profile
- Integrated the mobile app with the RESTful API built on the web backend
- Implemented state management with providers
- Designed the app UI following the booking website's visual language

**ERP System Tasks:**
- Worked on ERP modules including HR management, inventory control, sales, CRM, POS, and finance
- Built controllers for CRUD operations across multiple modules
- Designed database queries for reporting and dashboard analytics
- Implemented user authentication and role-based access

**Oromia Communication Bureau Platform Tasks:**
- Developed Flutter screens for the government communication platform
- Implemented localization for multiple languages (Afan Oromo, Amharic, English)
- Built communication workflow screens and institutional management features

### 2.5 Procedures I Used

Throughout my internship, I followed these development procedures:

**Version Control:**
- Used Git for all source code management
- Created branches for each feature
- Committed changes with descriptive commit messages
- Pushed code to GitHub repositories

**Database Design:**
- Designed normalized PostgreSQL schemas
- Used raw SQL queries to avoid ORM boolean quoting issues with PostgreSQL
- Created database triggers for auto-updating timestamps and ratings
- Implemented views for complex reporting queries

**Development:**
- Followed MVC (Model-View-Controller) architecture strictly
- Used CodeIgniter 4's routing system for clean URLs
- Implemented CSRF protection on all form submissions
- Used prepared statements and parameterized queries to prevent SQL injection
- Validated all user inputs both on frontend and backend

**Testing:**
- Manually tested all features using the browser
- Used curl commands to test API endpoints
- Verified database state after each operation
- Tested role-based access control for all admin roles

**Deployment:**
- Used `php spark serve` for local development
- Configured `.env` files for environment-specific settings
- Used dedicated database users with limited privileges

### 2.6 How Good I Was in Performing My Tasks

I demonstrated strong performance throughout my internship:

- **Fast Learning:** I quickly learned CodeIgniter 4's framework conventions, PostgreSQL-specific SQL syntax, and Flutter's widget system.
- **Problem Solving:** I independently resolved several technical challenges, including PostgreSQL boolean column compatibility with CodeIgniter 4's query builder, session handling issues, and payment flow edge cases.
- **Code Quality:** My code followed the company's coding standards — clean indentation, descriptive variable names, proper error handling, and comprehensive comments.
- **Reliability:** I completed assigned tasks on time and communicated proactively when facing challenges.
- **Adaptability:** I successfully transitioned between web development (PHP/CodeIgniter 4) and mobile development (Flutter) as project needs changed.

### 2.7 Challenges and Measures Taken

**Challenge 1: PostgreSQL Boolean Column Compatibility**  
CodeIgniter 4's query builder quoted PostgreSQL boolean values (TRUE/FALSE) as strings, causing database errors. I resolved this by using raw SQL queries with parameterized bindings instead of the query builder for boolean columns.

**Challenge 2: Session Management**  
CodeIgniter 4 uses a different session API than Laravel. I initially used `session()->pull()` (a Laravel method) which doesn't exist in CI4. I resolved this by using `session()->get()` and `session()->remove()` separately.

**Challenge 3: User Registration with Duplicate Detection**  
CI4's `is_unique` validation rule was causing unexpected errors during registration. I replaced it with manual database checks that provide clear, user-friendly error messages for duplicate emails and phone numbers.

**Challenge 4: Payment System Integration**  
Ethiopian payment systems require specific handling for different methods (Telebirr, CBE Birr, bank transfers). I built a multi-step payment flow with test mode that simulates real payment processing without actual money transfer.

**Challenge 5: Dynamic City Management**  
The requirement was that super admin could add any Ethiopian city and it would appear instantly on the website. I created a `cities` table with 52 pre-loaded Ethiopian cities and built dynamic dropdowns that pull from the database in real-time.

---

## 3. BENEFITS GAINED FROM THE INTERNSHIP

### 3.1 Practical Skills Improvement

During my internship at Dallol Tech PLC, I significantly improved my practical software development skills:

**Backend Development:**
- Mastered CodeIgniter 4 framework — routing, controllers, models, views, filters, helpers, and configuration
- Learned to design and implement complex PostgreSQL database schemas with proper normalization, foreign keys, triggers, and views
- Gained experience writing raw SQL queries with parameterized bindings for security and PostgreSQL compatibility
- Implemented JWT-based authentication for APIs and session-based authentication for web applications
- Built role-based access control systems with multiple user types

**Frontend Development:**
- Advanced my knowledge of Bootstrap 5 for responsive web design
- Learned to create custom CSS animations (keyframe animations, transitions, scroll reveal)
- Improved JavaScript skills — DOM manipulation, event handling, AJAX calls, form validation
- Built interactive UI components — image carousels, price calculators, payment method selectors, OTP input boxes

**Mobile Development:**
- Gained hands-on experience with Flutter framework
- Learned Dart programming language
- Implemented state management with providers
- Built RESTful API integration from mobile apps
- Worked with Flutter's widget system for complex UI layouts

**Database Skills:**
- Designed database schemas with 15+ related tables
- Wrote complex SQL queries with JOINs, subqueries, and aggregations
- Implemented database triggers for automatic timestamp updates and rating calculations
- Created database views for reporting dashboards
- Managed database users with appropriate privileges

### 3.2 Theoretical Knowledge Upgrading

My internship reinforced and expanded my theoretical knowledge:

- **MVC Architecture:** I deeply understood the separation of concerns in Model-View-Controller pattern through real implementation
- **RESTful API Design:** I learned to design clean, stateless API endpoints with proper HTTP methods, status codes, and response formats
- **Database Normalization:** I applied normalization principles to real-world data with complex relationships
- **Authentication & Authorization:** I implemented both JWT (stateless) and session-based (stateful) authentication, understanding the trade-offs
- **Role-Based Access Control:** I designed a four-tier admin hierarchy with proper access filtering
- **Software Development Lifecycle:** I experienced the full cycle from requirements to deployment in a professional setting

### 3.3 Interpersonal Communication Skills

- **Daily Stand-ups:** I learned to communicate progress, blockers, and plans concisely in team meetings
- **Code Reviews:** I learned to accept and provide constructive feedback on code quality
- **Client Communication:** I observed how senior developers communicate technical concepts to non-technical clients
- **Written Communication:** I improved my technical writing through code comments, commit messages, and documentation

### 3.4 Team Playing Skills

- **Collaboration:** I worked alongside senior developers, QA engineers, and project managers, learning to coordinate tasks and share knowledge
- **Code Integration:** I learned to integrate my code with others' work using Git branches and pull requests
- **Knowledge Sharing:** I shared my solutions to PostgreSQL and CI4 compatibility issues with the team
- **Supporting Others:** I helped test features developed by other interns and provided feedback

### 3.5 Leadership Skills

- **Taking Ownership:** I took full responsibility for the booking website project, from database design to deployment
- **Decision Making:** I made architectural decisions (raw SQL vs query builder, session handling approach) that affected the entire project
- **Mentoring:** I helped newer interns understand the codebase and development workflow
- **Initiative:** I proactively identified and fixed bugs, suggested improvements, and proposed new features

### 3.6 Work Ethics

- **Professionalism:** I maintained regular working hours, met deadlines, and communicated proactively
- **Integrity:** I was honest about challenges and mistakes, and took responsibility for fixing them
- **Quality Focus:** I prioritized code quality, security, and user experience over speed
- **Respect:** I respected the company's confidentiality, coding standards, and team hierarchy
- **Continuous Learning:** I actively sought to learn new technologies and improve my skills

### 3.7 Entrepreneurship Skills

- **Problem Identification:** I learned to identify real-world problems that technology can solve (e.g., lack of online hotel booking in Ethiopia)
- **Solution Design:** I designed complete solutions from database to UI, considering business requirements
- **User-Centric Thinking:** I built features with the end user in mind — clear error messages, intuitive flows, responsive design
- **Business Understanding:** I gained insight into how software products generate value for businesses and how payment systems work in Ethiopia

### 3.8 Challenges Faced

- **Technical Complexity:** The booking system involved complex relationships between hotels, rooms, bookings, payments, and multiple admin roles
- **Framework Learning Curve:** Learning CodeIgniter 4's specific conventions while avoiding common pitfalls took time
- **PostgreSQL Specifics:** PostgreSQL's strict type system and boolean handling differed from MySQL, requiring adaptation
- **Time Management:** Balancing work across four different projects with different technologies
- **Remote Collaboration:** Coordinating with team members on code integration and deployment

---

## 4. PRACTICAL APPLICATION OF KNOWLEDGE

During my internship, I applied the theoretical knowledge I gained at Debre Markos University to real-world projects at Dallol Tech PLC:

### 4.1 Database Design (Database Systems Course)
I applied normalization principles (1NF, 2NF, 3NF) to design the hotel booking database with 15+ tables. I used my knowledge of entity-relationship modeling to define relationships between users, hotels, rooms, bookings, payments, reviews, and admin roles. I implemented foreign key constraints, unique constraints, and CHECK constraints to maintain data integrity.

### 4.2 Web Programming (Web Programming Course)
My university courses in PHP and web programming directly applied to the CodeIgniter 4 projects. I used my knowledge of HTTP request/response cycles, form handling, session management, and URL routing to build the booking website's backend.

### 4.3 Software Engineering (Software Engineering Course)
I applied software engineering principles including:
- **Modular Design:** Separating the system into Admin, API, and Web controllers
- **Design Patterns:** Using MVC, Singleton (database connection), and Factory patterns
- **Requirements Analysis:** Understanding client requirements for each project
- **Testing:** Manual and automated testing of all features

### 4.4 Object-Oriented Programming (OOP Course)
CodeIgniter 4 is built on OOP principles. I applied inheritance (extending Base controllers), encapsulation (protected/private properties), and polymorphism (overriding methods) throughout the codebase.

### 4.5 Data Structures and Algorithms
I implemented efficient data structures for:
- Hotel search with multiple filters (city, price, rating, type)
- Room availability checking by querying overlapping date ranges
- Expert recommendation scoring algorithm based on multiple weighted factors
- Pagination for large result sets

### 4.6 Human-Computer Interaction (HCI Course)
I applied HCI principles to design intuitive user interfaces:
- Clear navigation with breadcrumbs and visual hierarchy
- Progressive disclosure (multi-step payment flow)
- Immediate feedback (loading spinners, toast notifications, animations)
- Error prevention (date validation, room selection before booking)
- Responsive design for different screen sizes

---

## 5. PROBLEMS SOLVED DURING THE INTERNSHIP

### 5.1 PostgreSQL Boolean Column Compatibility with CodeIgniter 4

**Problem:** CodeIgniter 4's query builder quoted PostgreSQL boolean values (TRUE/FALSE) as string literals ('TRUE'/'FALSE'), causing SQL errors like "column TRUE does not exist."

**Solution:** I replaced all query builder calls for boolean columns with raw SQL queries using parameterized bindings. For example, instead of `$builder->where('is_active', true)`, I used `$db->query("SELECT * FROM hotels WHERE is_active = TRUE")`. I also created helper methods like `pgBool()` to convert PostgreSQL's 't'/'f' string representations to PHP booleans.

### 5.2 Session Handling for Post-Auth Redirect

**Problem:** When a user tried to book a hotel without being logged in, they needed to be redirected to login/register, then back to the hotel booking page. CodeIgniter 4 doesn't have Laravel's `session()->pull()` method.

**Solution:** I created a custom `_pullRedirect()` method that reads and removes the redirect URL from the session in two steps: `session()->get('post_auth_redirect')` followed by `session()->remove('post_auth_redirect')`. This preserved the booking intent across the authentication flow.

### 5.3 User Registration with Duplicate Email/Phone Detection

**Problem:** CodeIgniter 4's `is_unique` validation rule caused unexpected errors during user registration, especially when a user with the same email or phone number already existed.

**Solution:** I replaced the framework's `is_unique` rule with manual database checks in the `createUser()` method. The method returns specific error codes ('email_exists', 'phone_exists') that the controller translates into clear, user-friendly messages with links to the login page.

### 5.4 Dynamic City Management

**Problem:** The hotel search dropdown was hardcoded with a fixed list of cities. The client (super admin) needed to add any Ethiopian city and have it appear instantly on the website.

**Solution:** I created a `cities` table with 52 pre-loaded Ethiopian cities (including Debre Markos, Lalibela, Gambella, etc.) and built a `CityModel` that fetches active cities from the database. The home page, search dropdown, and admin panel all pull cities dynamically, so when a super admin adds a new city, it appears everywhere immediately.

### 5.5 Multi-Step Ethiopian Payment Flow

**Problem:** The booking system needed to support multiple Ethiopian payment methods (Telebirr, CBE Birr, Awash Bank, Dashen Bank, etc.) with different form requirements for each.

**Solution:** I built a `PaymentWebController` with a 4-step payment flow:
1. **Method Selection** — All 12 Ethiopian payment methods displayed in categorized cards
2. **Booking Summary** — Review page with hotel details, dates, and total price
3. **Payment Form** — Different forms for card (card number, expiry, CVV with animated preview), mobile (phone number with push notification preview), and bank (account number with bank card preview)
4. **Success Receipt** — Transaction ID, payment details, and booking reference

Each step has a progress indicator and the payment is simulated in test mode.

### 5.6 Room Availability Checking

**Problem:** When a user selects dates for a hotel, the system needed to show which rooms are available and which are already booked for those dates.

**Solution:** I modified the `getRoomTypes()` method to accept check-in and check-out dates as parameters. For each room type, the method queries the `bookings` table for overlapping date ranges (using `check_in < ? AND check_out > ?`) and marks rooms as "Occupied for selected dates" if any confirmed or pending booking exists for those dates.

### 5.7 Expert Recommendation System

**Problem:** The hotel detail page needed to suggest similar hotels to users.

**Solution:** I built an `ExpertModel` with a scoring algorithm that evaluates candidate hotels based on:
- Same city (+5 points)
- Similar price range (+4 points)
- High rating (+3 points)
- Same hotel type (+2 points)
- Matching amenities (+1 per match, up to 5)
- User booking history preference (+4 points)
- Trending (high booking count in last 30 days) (+2 points)

The top 3 scored hotels are displayed as "You May Also Like" on the detail page.

---

## 6. CONCLUSION AND RECOMMENDATIONS

### 6.1 Conclusion

My internship at Dallol Tech PLC was a transformative experience that bridged the gap between academic theory and professional practice. Over the course of my internship, I worked on four real-world software projects that serve Ethiopian businesses and government institutions, gaining hands-on experience in:

- Full-stack web development with CodeIgniter 4 and PostgreSQL
- Mobile app development with Flutter
- Database design and optimization
- RESTful API development
- Multi-role authentication and authorization
- Ethiopian payment system integration
- Government communication platforms

The internship reinforced my passion for software engineering and gave me confidence in my ability to contribute to real-world projects. I am grateful to Dallol Tech PLC for providing this opportunity and to Debre Markos University for preparing me with the theoretical foundation to succeed.

### 6.2 Recommendations for the Company

Based on my internship experience, I offer the following recommendations to Dallol Tech PLC:

1. **Adopt Automated Testing:** Implement PHPUnit tests for the CodeIgniter 4 projects to catch regressions early and improve code quality.

2. **API Documentation:** Generate API documentation using tools like Swagger/OpenAPI to improve communication between web and mobile development teams.

3. **Continuous Integration/Deployment:** Set up CI/CD pipelines using GitHub Actions to automate testing and deployment, reducing manual errors.

4. **PostgreSQL Connection Pooling:** Implement connection pooling (e.g., PgBouncer) for production databases to handle high-traffic scenarios.

5. **Real Payment Gateway Integration:** While the current test-mode payment system is excellent for development, integrate actual Telebirr and CBE Birr APIs for production use.

6. **Mobile App Publishing:** Complete and publish the Flutter mobile apps to Google Play Store and Apple App Store to reach wider audiences.

7. **Internship Program Enhancement:** Consider creating a structured internship curriculum with defined learning milestones and regular evaluation checkpoints.

8. **Documentation Standards:** Establish internal documentation standards for APIs, database schemas, and deployment procedures to facilitate knowledge transfer.

---

## 7. REFERENCES

1. CodeIgniter 4 User Guide — https://codeigniter.com/userguide4/
2. PostgreSQL Documentation — https://www.postgresql.org/docs/
3. Flutter Documentation — https://docs.flutter.dev/
4. Bootstrap 5 Documentation — https://getbootstrap.com/docs/5.3/
5. Dallol Tech PLC Website — https://dalloltech.com/
6. Debre Markos University, Institute of Technology — Software Engineering Curriculum
7. Firebase PHP-JWT Library — https://github.com/firebase/php-jwt
8. PHP Manual — https://www.php.net/manual/en/
9. MDN Web Docs (JavaScript, CSS) — https://developer.mozilla.org/
10. Unsplash (Free Images) — https://unsplash.com/

---

## 8. APPENDICES

### Appendix A: Project File Structure — Booking Website

```
booking_website/
├── app/
│   ├── Config/          — App, Database, Routes, Filters, Jwt, Paths
│   ├── Controllers/
│   │   ├── Api/         — Auth, Hotel, Booking, Guest, Wishlist, Payment controllers
│   │   ├── Web/         — Home, HotelWeb, AuthWeb, Dashboard, BookingWeb, PaymentWeb
│   │   └── Admin/       — SuperAdmin, SubAdmin, Broker, HotelManager, AdminAuth
│   ├── Filters/         — JwtFilter, SessionFilter, AdminFilter
│   ├── Helpers/         — jwt_helper, api_helper
│   ├── Models/          — User, Hotel, Booking, Review, Wishlist, Payment, OTP, AdminUser, Broker, HotelManager, Expert, City
│   └── Views/
│       ├── layouts/     — main.php, dashboard.php
│       ├── home/        — index.php (animated hero, search, destinations, featured)
│       ├── hotels/      — list.php, detail.php (room availability, booking form)
│       ├── auth/        — login.php, register.php, otp.php, forgot.php
│       ├── dashboard/   — index, bookings, booking_detail, wishlist, profile
│       ├── booking/     — confirm.php, payment/
│       ├── payment/     — method, summary, card, bank, success
│       ├── admin/       — super, subadmin, broker, manager, shared
│       └── errors/      — 404.php
├── database/
│   ├── schema.sql       — Main PostgreSQL schema (15 tables + seed data)
│   └── admin_schema.sql — Admin hierarchy schema (6 tables + super admin seed)
├── public/
│   ├── assets/css/app.css  — Full animated stylesheet
│   ├── assets/js/app.js    — Interactive JavaScript
│   └── index.php
├── composer.json
├── .env
└── START.sh
```

### Appendix B: Database Tables Overview

**Booking Website Tables (15):**
| Table | Purpose |
|-------|---------|
| users | Guest accounts |
| hotels | Hotel listings |
| hotel_images | Hotel photo gallery |
| hotel_amenities | Hotel features |
| room_types | Room categories per hotel |
| bookings | Reservation records |
| payments | Payment transactions |
| reviews | Guest reviews |
| wishlist | Saved hotels |
| otp_codes | OTP verification |
| refresh_tokens | JWT refresh tokens |
| cities | Ethiopian cities (52 entries) |
| admin_users | Admin accounts |
| brokers | Broker records |
| hotel_managers | Hotel manager assignments |

**Admin Hierarchy Tables (6):**
| Table | Purpose |
|-------|---------|
| admin_users | Super Admin, Sub Admin, Broker, Hotel Manager |
| admin_city_assignments | City assignments to sub-admins |
| brokers | Broker records with commission |
| hotel_managers | Hotel-to-manager mappings |
| broker_hotel_links | Broker-to-hotel links |
| broker_messages | Inter-admin messaging |

### Appendix C: API Endpoints

| Method | Endpoint | Purpose |
|--------|---------|---------|
| POST | /api/v1/auth/guest/register | Register new guest |
| POST | /api/v1/auth/guest/login | Guest login |
| POST | /api/v1/auth/otp/send | Send OTP |
| POST | /api/v1/auth/otp/verify | Verify OTP |
| GET | /api/v1/hotels/search | Search hotels |
| GET | /api/v1/hotels/featured | Featured hotels |
| GET | /api/v1/hotels/{id} | Hotel detail |
| GET | /api/v1/hotels/{id}/reviews | Hotel reviews |
| POST | /api/v1/hotels/{id}/reviews | Post review (JWT) |
| GET | /api/v1/bookings | List bookings (JWT) |
| POST | /api/v1/bookings | Create booking (JWT) |
| GET | /api/v1/bookings/{id} | Booking detail (JWT) |
| POST | /api/v1/bookings/{id}/cancel | Cancel booking (JWT) |
| GET | /api/v1/guest/profile | Guest profile (JWT) |
| PUT | /api/v1/guest/profile | Update profile (JWT) |
| GET | /api/v1/wishlist | Wishlist (JWT) |
| POST | /api/v1/wishlist | Toggle wishlist (JWT) |
| POST | /api/v1/payments/initiate | Initiate payment (JWT) |

### Appendix D: Admin Panel URLs

| URL | Role | Purpose |
|-----|------|---------|
| /admin/login | All | Admin login |
| /admin/super/dashboard | Super Admin | System overview |
| /admin/super/cities | Super Admin | Manage cities |
| /admin/super/hotels | Super Admin | All hotels |
| /admin/super/hotels/add | Super Admin | Add hotel |
| /admin/super/sub-admins | Super Admin | Manage sub-admins |
| /admin/super/bookings | Super Admin | All bookings |
| /admin/super/users | Super Admin | All guests |
| /admin/subadmin/dashboard | Sub Admin | City dashboard |
| /admin/subadmin/hotels | Sub Admin | Hotels in city |
| /admin/subadmin/brokers | Sub Admin | Manage brokers |
| /admin/broker/dashboard | Broker | Broker dashboard |
| /admin/broker/inbox | Broker | Messages |
| /admin/manager/dashboard | Hotel Manager | Hotel dashboard |
| /admin/manager/rooms | Hotel Manager | Manage rooms |
| /admin/manager/bookings | Hotel Manager | View bookings |

---

*End of Report*
bash /home/abebe/Documents/dallolbook/dallolbookingall/START.sh
✅ Both Systems Running
System	URL	Status
ERP System	http://localhost:8081	✅ Running
Booking Website	http://localhost:8080	✅ Running
🔑 All Login Credentials
ERP (http://localhost:8081/auth/login)
Role	Username	Password	Access
👑 Super Admin	admin	admin123	View all + manage companies/users
🏢 Company User	companyuser	Company@1234	Full CRUD all modules
Booking Website (http://localhost:8080/admin/login)
Role	Email	Password
👑 Super Admin	superadmin@dalloltech.com	Admin@1234
🏙️ Sub Admin	subadmin.addis@dalloltech.com	SubAdmin@1234
🤝 Broker	broker1.addis@dalloltech.com	Broker@1234
🏨 Manager	manager.sheraton@dalloltech.com	Manager@1234
bash /home/abebe/Documents/dallolbook/dallolbookingall/START.sh
