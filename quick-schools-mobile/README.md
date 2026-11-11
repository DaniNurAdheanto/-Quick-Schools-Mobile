# Quick Schools Mobile App 📱

A modern, minimal, and professional mobile application built with **Flutter (Dart)** for Android and iOS. This app integrates directly with the shared **Next.js** backend and **PostgreSQL** database (via Prisma ORM), preserving the existing business logic, table relationships, and Role-Based Access Control (RBAC).

---

## 🎨 Visual Identity
- **Primary Brand Color**: `#531FFF` (Quick Schools Indigo/Purple)
- **Secondary Accent**: `#7B4DFF`
- **Background**: Soft Gray `#F8FAFC` (Light) / `#0B0F19` (Dark)
- **Typography**: Google Fonts (Plus Jakarta Sans)
- **Design Philosophy**: Minimalist, high contrast, clean typography, zero clutter, accessible touch targets ($\ge 44\text{px}$).

---

## 🏗️ Architecture & Shared Integration

```
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│     Quick Schools Web App       │       │    Quick Schools Mobile App     │
│       (Next.js Frontend)        │       │         (Flutter Dart)          │
└────────────────┬────────────────┘       └────────────────┬────────────────┘
                 │                                         │
                 │                 REST API                │
                 └───────────────────►◄────────────────────┘
                                     │
                     ┌───────────────▼───────────────┐
                     │     Shared Next.js Backend    │
                     │      API Route Handlers       │
                     │  (JWT Auth, RBAC Middleware)  │
                     └───────────────┬───────────────┘
                                     │
                             Prisma ORM Client
                                     │
                     ┌───────────────▼───────────────┐
                     │      PostgreSQL Database      │
                     │  (Single Source of Truth)     │
                     └───────────────────────────────┘
```

Both the web platform and mobile app use the **exact same** backend endpoints, authentication tokens, and database records. Changes made in the mobile app are instantly reflected in the web dashboard and vice-versa.

---

## 👥 Role-Based Access Control (RBAC)

The mobile application adapts its interface, permissions, and available navigation tabs according to the user's role:

| Feature / Module | Admin | Teacher | Student | Parent |
| :--- | :---: | :---: | :---: | :---: |
| School Overview & KPIs | ✅ | ❌ | ❌ | ❌ |
| Manage Classes & Teachers | ✅ | ❌ | ❌ | ❌ |
| Mark Student Attendance | ✅ | ✅ | ❌ | ❌ |
| View Class Schedule | ✅ | ✅ (Assigned) | ✅ (Enrolled) | ✅ (Child's) |
| Submit / Edit Grades | ✅ | ✅ | ❌ | ❌ |
| View Grades & Report Cards | ✅ | ✅ | ✅ | ✅ |
| Broadcast Announcements | ✅ | ✅ | ❌ | ❌ |
| View School Announcements | ✅ | ✅ | ✅ | ✅ |
| Digital ID Card | ✅ | ✅ | ✅ | ✅ |

---

## 📂 Project Structure

```
quick-schools-mobile/
├── android/                   # Native Android wrapper and Gradle build
├── ios/                       # Native iOS wrapper and Xcode project
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart  # Shared Next.js API paths
│   │   │   └── app_colors.dart     # #531FFF theme palette
│   │   ├── network/
│   │   │   └── api_client.dart     # HTTP client with Bearer auth token injection
│   │   ├── storage/
│   │   │   └── secure_storage.dart # Encrypted JWT storage
│   │   └── theme/
│   │       └── app_theme.dart      # Material 3 Theme with #531FFF
│   ├── models/
│   │   ├── user_model.dart         # User & Role enums
│   │   ├── student_model.dart      # Student entity & classroom
│   │   ├── attendance_model.dart   # Attendance records & status
│   │   ├── grade_model.dart        # Academic grades & reports
│   │   ├── schedule_model.dart     # Daily class timetable
│   │   └── announcement_model.dart # School news & broadcasts
│   ├── providers/
│   │   ├── auth_provider.dart      # Authentication & RBAC state
│   │   ├── attendance_provider.dart# Attendance submission & history
│   │   └── academic_provider.dart  # Schedules & Grade records
│   ├── screens/
│   │   ├── splash_screen.dart      # Initial session check & animation
│   │   ├── auth/
│   │   │   └── login_screen.dart   # Secure credentials & quick role picker
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart # Role-adaptive home view
│   │   ├── attendance/
│   │   │   └── attendance_screen.dart # QR / quick check-in & logs
│   │   ├── schedule/
│   │   │   └── schedule_screen.dart # Timetable per day of the week
│   │   ├── grades/
│   │   │   └── grades_screen.dart   # Student scores & GPA calculations
│   │   ├── announcements/
│   │   │   └── announcements_screen.dart # School announcements feed
│   │   └── profile/
│   │       └── profile_screen.dart  # Digital School ID Card & settings
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_card.dart
│   │   ├── status_badge.dart
│   │   └── quick_stat_tile.dart
│   └── main.dart                   # Application entrypoint
├── pubspec.yaml               # Dependencies & assets configuration
└── analysis_options.yaml      # Dart static analysis configuration
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version $\ge$ 3.19.0)
- Android Studio or Xcode (for simulator/device testing)
- Next.js backend running (default: port 3000)

### 1. Install Dependencies
```bash
cd quick-schools-mobile
flutter pub get
```

### 2. Configure Backend URL
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Update `API_BASE_URL` with your running Next.js API server host.

### 3. Run on Emulator / Connected Device
```bash
# List available devices
flutter devices

# Run on Android Emulator
flutter run -d android

# Run on iOS Simulator
flutter run -d iphone
```

### 4. Build Release Packages
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Google Play Store)
flutter build appbundle --release

# iOS IPA (for App Store / TestFlight)
flutter build ipa --release
```
