# jWallet Lite — Digital Wallet Mobile Application

A lightweight, secure, and production-grade digital wallet mobile application developed using **Flutter (Dart)** and integrated with an independent **Mock REST API backend (Node.js + Express)**. Built adhering strictly to the **jStack Technical Assessment** specifications with **Material Design 3** and the **Sahara Warm Minimalism** fintech design system.

---

## 📱 Features & Highlights

- **All 7 Core Screens Implemented**:
  1. **Login & Authentication**: Demo Quick Access with `⚡ Auto-fill`, form validation, password visibility toggle, hardware trust device options, and biometric cue.
  2. **Wallet Dashboard**: Authoritative live wallet balance (`₹24,850.50`), dynamic sync, 4 Quick Actions (*Send Instant*, *Add Top-up UI*, *Scan QR*, *History*), Monthly Outflow tracker, Quick contacts auto-pay, and Top 5 recent transactions.
  3. **Send Money Form**: Beneficiary name, 10-digit mobile number validation, quick amount chips (`+₹500`, `+₹1,000`, `+₹2,000`, `+₹5,000`, `Max`), Instant UPI vs Standard NEFT mode, and remarks counter.
  4. **Transfer Confirmation**: Deduction summary, KYC verified badge, current vs post-transfer balance pre-check, and active **Idempotency Guard**.
  5. **Transfer Success & Failure Handling**: Complete payment receipt with NPCI UTR and UTR copy, split bill CTA, plus graceful fallback and retry dialogs for `409 Insufficient Balance` / server errors.
  6. **Transaction History**: Real-time sync, Ledger metrics (*Total Sent*, *Total Received*, *Net*), search by beneficiary or Ref ID, filter chips (*All*, *Debit*, *Credit*), date grouping, and illustrated empty states.
  7. **Transaction Details**: Detailed receipt, platform fee breakdown (`₹0.00 Free`), NPCI UTR, Auth code, and repeat payment action.

---

## 🛠️ Technology Stack & Architecture

- **Mobile Framework**: Flutter 3.44.x / Dart 3.12.x
- **UI Design System**: Material Design 3 + Sahara Warm Minimalism (Burnt Sienna `#C2652A`, Warm Linen `#FAF7F2`, EB Garamond serif & Manrope sans-serif)
- **State Management**: `flutter_riverpod` (v2.6.x)
- **Networking**: `http` package (v1.6.x) with Bearer token authentication & idempotency headers
- **Local Storage / Session**: `shared_preferences` (persisting token, session, and cached profile)
- **Backend**: Node.js (v24.x) + Express.js with in-memory persistence and idempotency cache

### Architecture Layering (Clean Architecture)
```
lib/
├── core/
│   ├── network/          # ApiConstants & dynamic emulator/localhost base URL resolution
│   ├── theme/            # AppColors, AppTextStyles (EB Garamond & Manrope), AppTheme
│   └── utils/            # CurrencyFormatter (INR ₹) & DateFormatter
├── data/
│   ├── datasources/      # WalletRemoteDataSource (http) & AuthLocalDataSource (shared_preferences)
│   └── models/           # UserModel, WalletModel, TransactionModel
└── presentation/
    ├── providers/        # WalletNotifier & WalletState (Riverpod)
    ├── screens/          # All 7 screens + failure dialog
    └── widgets/          # WalletCard, TransactionItemTile, CustomButton, StatusBadge, etc.
```

---

## 🚀 Setup & Execution Guide

### 1. Prerequisites
- **Flutter SDK**: `^3.12.0` (Verified on Flutter 3.44.9)
- **Node.js**: `v18.x` or higher (Verified on Node v24.19.0)
- **npm**: `v9.x` or higher

---

### 2. Mock REST API Backend Setup

1. Open a terminal and navigate to the `backend/` directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the mock backend server:
   ```bash
   npm start
   # or
   node server.js
   ```
   The backend will start on port `3000`:
   - Local: `http://localhost:3000`
   - Android Emulator: `http://10.0.2.2:3000`

---

### 3. Flutter Application Setup

1. In the project root, get all Flutter dependencies:
   ```bash
   flutter pub get
   ```
2. Run the application:
   ```bash
   # Run on Chrome / Desktop
   flutter run -d chrome
   # or run on Android Emulator / Connected Device
   flutter run
   ```

---

### 4. API Base URL Configuration

The app automatically detects the platform environment in [api_constants.dart](file:///c:/Users/Neha%20Sahu/Desktop/projects/jwallet_lite/lib/core/network/api_constants.dart):
* **Android Emulator**: Automatically routes to `http://10.0.2.2:3000/api/v1` (host loopback alias).
* **Desktop / Web / iOS**: Automatically routes to `http://localhost:3000/api/v1`.
* **Physical Android Device**: If running on a physical phone via Wi-Fi, update `baseUrl` in `lib/core/network/api_constants.dart` to your computer's local Wi-Fi IP address (e.g. `http://192.168.1.X:3000/api/v1`).

---

## 🔑 Demo Credentials

| Role | Email | Password |
|---|---|---|
| **Demo User** | `demo@jstack.co` | `Demo@123` |

> *Tip: On the Login screen, tap the **"⚡ Auto-fill"** button in the Quick Demo Access card to instantly fill the credentials.*

---

## 🧪 Running Automated Tests

Run the full automated test suite covering login validation, amount validation, insufficient balance handling (HTTP 409), and state updates:

```bash
flutter test
```

### Test Coverage Breakdown:
1. **Login Form Validation**: Rejects invalid email/passwords and verifies demo credential authentication.
2. **Transfer Amount Validation**: Prevents zero, negative, or invalid amounts.
3. **Insufficient Balance Handling**: Verifies error dialog and prevents transfers exceeding balance.
4. **Successful Transfer State Update**: Verifies balance deduction and prepending transaction to history.
5. **Widget Smoke Tests**: Verifies UI components and login screen rendering.

---

## 📁 API Documentation (Postman)

A pre-configured Postman Collection is included at [jWallet_Lite_API.postman_collection.json](file:///c:/Users/Neha%20Sahu/Desktop/projects/jwallet_lite/jWallet_Lite_API.postman_collection.json).
Import this JSON file into Postman or Bruno to test all 6 endpoints:
1. `POST /api/v1/auth/login`
2. `GET /api/v1/users/profile`
3. `GET /api/v1/wallet/balance`
4. `GET /api/v1/transactions`
5. `POST /api/v1/transactions/transfer` (with `Idempotency-Key` header)
6. `GET /api/v1/transactions/:id`

---

## 🛡️ Idempotency Business Logic

The backend and Flutter client implement strict idempotency for financial transfers:
- The Flutter client generates a unique UUID header: `Idempotency-Key: IDEMP-XXXXXXXX-2024`.
- If a network retry occurs with the same idempotency key and identical payload, the backend returns the original cached transfer result **without deducting the user balance again**.

---

## 📝 Disclosures & Known Limitations

- **AI Assistance**: AI tools were utilized to generate component structure, and mock datasets against the technical assignment requirements.

