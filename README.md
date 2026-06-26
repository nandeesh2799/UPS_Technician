# UPS Service Manager 🛠️

An advanced enterprise Flutter application designed for UPS technicians and service centers to manage service orders, customer records, appointments, inventory, and branch operations. Built with offline-first capabilities, real-time Firebase syncing, automated PDF invoicing, WhatsApp notifications, and deep analytics.

---

## 🚀 Key Features

* **Multi-Step Order Wizard**: Streamlined order creation covering customer intake, classification (with flexible date picker), diagnostics with photo attachments, financials/payment states, and warranty setup.
* **Offline-First Architecture**: Powered by a local **Hive** database cache with a synchronization service that queues operations while offline and automatically reconciles/syncs when connection is restored.
* **Real-time Synchronization**: Instant data sync across devices utilizing **Cloud Firestore** and **Firebase Storage**.
* **Financials & Analytics Dashboard**: Dynamic KPIs, interactive revenue charts (via `fl_chart`), low-stock indicators, and service type distribution graphs.
* **Invoicing & PDF Generation**: Automatic PDF generation for service receipts and invoices, supporting instant printing and sharing.
* **WhatsApp Communication**: Direct customer alerts for order status updates, pickups, and custom communication logs.
* **Inventory & Parts Catalog**: Inventory control tracking items used in repairs, low-stock warnings, and barcode/part numbers.
* **Appointment Management**: On-site visit scheduler and tracker.
* **Branch Configuration**: Support for multiple service branch profiles, custom settings, and custom GST/tax rates.

---

## 🛠️ Tech Stack & Libraries

* **Core Framework**: [Flutter (Dart)](https://flutter.dev)
* **State Management**: [Provider](https://pub.dev/packages/provider)
* **Backend Database & Storage**: [Cloud Firestore](https://pub.dev/packages/cloud_firestore), [Firebase Storage](https://pub.dev/packages/firebase_storage)
* **Auth**: [Firebase Authentication](https://pub.dev/packages/firebase_auth)
* **Local Storage / Offline Cache**: [Hive](https://pub.dev/packages/hive), [SharedPreferences](https://pub.dev/packages/shared_preferences)
* **Charts & Visualizations**: [fl_chart](https://pub.dev/packages/fl_chart)
* **PDF Invoicing**: [pdf](https://pub.dev/packages/pdf), [printing](https://pub.dev/packages/printing)
* **Notifications**: [FCM](https://pub.dev/packages/firebase_messaging), [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
* **Device Services**: [Geolocator](https://pub.dev/packages/geolocator), [Geocoding](https://pub.dev/packages/geocoding), [Image Picker](https://pub.dev/packages/image_picker)

---

## 📁 Folder Structure

```text
lib/
├── app.dart               # App configuration, routes, and overall providers setup
├── main.dart              # Main entrypoint, Hive initialization, and app bootstrap
├── models/                # Data models (Order, Customer, Parts, PendingOperation, etc.)
├── providers/             # State management classes using ChangeNotifier (Provider pattern)
├── screens/               # UI screens organized by feature (dashboard, orders, inventory, etc.)
│   ├── appointments/      # Appointment list and creation widgets
│   ├── auth/              # Login, Registration, and reset password
│   ├── branches/          # Branch and store management
│   ├── customers/         # Customer database lists and details
│   ├── dashboard/         # KPIs, charts, and reports
│   ├── financials/        # Financial and revenue reports
│   ├── inventory/         # Parts catalog and inventory level monitoring
│   └── orders/            # Order list, details, and the Multi-Step Order Wizard
├── services/              # API connections, offline sync engine, WhatsApp, and PDF exports
├── theme/                 # App Colors, Styles, and Themes
├── utils/                 # Extension methods, helper functions, and constants
└── widgets/               # Reusable UI components (shimmer loaders, empty states, error boundaries)
```

---

## ⚙️ Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.5.0 or higher)
* [Dart SDK](https://dart.dev/get-started)
* A Firebase Project with Firestore, Auth, and Storage enabled.

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nandeesh2799/UPS_Technician.git
   cd ups_service
   ```

2. **Add Firebase configuration**:
   * For **Android**: Place `google-services.json` in `android/app/`.
   * For **iOS**: Place `GoogleService-Info.plist` in `ios/Runner/`.

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Generate Hive Adapters**:
   Run the build runner to compile database models for Hive:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the application**:
   ```bash
   flutter run
   ```

### Running Tests
To run unit and widget tests:
```bash
flutter test
```
