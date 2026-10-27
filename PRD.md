# Product Requirement Document (PRD)
## Project: jWallet Lite — Digital Wallet Mobile Application & Mock REST API

---

## 1. Executive Summary & Overview

### 1.1 Objective
**jWallet Lite** is a lightweight, secure, and production-grade digital wallet mobile application developed using Flutter and Dart, backed by an independent Mock REST API backend. The system demonstrates fintech-standard engineering practices including Clean Architecture / MVVM, secure session management, robust financial transaction handling (with server-side validation & idempotency), responsive Material Design 3 UI, and comprehensive automated test coverage.

### 1.2 Evaluation Metrics & Weightage (Total: 100 Marks)
| Module / Dimension | Max Marks | Key Focus |
|---|---|---|
| **UI/UX Implementation** | 15 | Material 3 fintech aesthetic, responsive layout, loading/error/empty states |
| **Authentication & Session Management** | 10 | Login validation, token storage, auto-login persistence, logout |
| **Wallet Dashboard** | 10 | Server-driven balance display, pull-to-refresh, recent activity |
| **Money Transfer Workflow** | 15 | Input validation, confirmation screen, idempotency, success/failure handling |
| **Transaction History** | 10 | Descending order list, search, credit/debit filter, detail view |
| **Mock API Development** | 15 | Independent Node.js/Express service, REST standards, idempotency support |
| **API Integration & Error Handling** | 10 | Dio/HTTP layer, token interceptors, HTTP 400/401/404/409/500 handling |
| **Architecture & Code Quality** | 10 | Clean Architecture / MVVM, separation of concerns, testability |
| **Testing & Documentation** | 5 | Unit tests, widget tests, comprehensive README, Postman collection |

---

## 2. System Architecture & Tech Stack

### 2.1 Technology Stack

| Layer | Component | Chosen Technology | Rationale |
|---|---|---|---|
| **Mobile App** | Framework | Flutter 3.x / Dart 3.x | Cross-platform, high performance |
| | Architecture | Clean Architecture (Presentation, Domain, Data) | Maintainable, decoupled, testable |
| | State Management | Bloc / Cubit or Riverpod | Predictable state flow, easy mocking |
| | API Client | Dio | Interceptors for Bearer auth, logging & error mapping |
| | Local Storage | `flutter_secure_storage` & `shared_preferences` | Secure token storage + cached user preferences |
| | Navigation | `go_router` or Navigator 2.0 | Declarative routing & auth redirect guards |
| | UI Design | Material Design 3 | Modern fintech cards, elevation, typography |
| **Backend** | Runtime & Server | Node.js + Express.js | Lightweight, fast startup, zero external DB setup needed |
| | Data Persistence | In-memory with JSON file backup | Zero-friction setup for evaluators |
| | Auth & Security | Bearer Token Auth + Idempotency Headers | Realistic financial API behavior |
| | API Testing | Postman Collection / OpenAPI (Swagger) | Clear documentation for evaluators |

### 2.2 Architectural Layering (Clean Architecture)

```
lib/
├── core/
│   ├── constants/        # API endpoints, colors, dimensions, string constants
│   ├── network/          # Dio client, interceptors, error handler, network info
│   ├── theme/            # Material 3 light/dark theme definitions
│   └── utils/            # Validators, currency formatters, date formatters
├── data/
│   ├── datasources/      # Remote API data sources & Local secure storage
│   ├── models/           # JSON serializable DTOs (User, Wallet, Transaction)
│   └── repositories/     # Concrete repository implementations
├── domain/
│   ├── entities/         # Pure Dart business objects
│   ├── repositories/     # Abstract repository contracts
│   └── usecases/         # Business logic units (Login, GetBalance, TransferMoney, etc.)
└── presentation/
    ├── blocs_or_providers/ # State management controllers
    ├── screens/          # 7 Mandatory screens
    └── widgets/          # Reusable UI components (buttons, input fields, cards, badges)
```

---

## 3. Mock REST API Specifications

The mock backend must run independently on `http://localhost:3000` (or `http://10.0.2.2:3000` for Android Emulator).

### 3.1 Standard Response Format
**Success Response:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_BALANCE",
    "message": "Transfer amount exceeds available wallet balance"
  }
}
```

### 3.2 Endpoints Specification

| Method | Endpoint | Auth Required | Idempotency | Description |
|---|---|---|---|---|
| `POST` | `/api/v1/auth/login` | No | No | Authenticates user credentials |
| `GET` | `/api/v1/users/profile` | Yes (Bearer) | No | Returns logged-in user profile details |
| `GET` | `/api/v1/wallet/balance` | Yes (Bearer) | No | Returns authoritative wallet balance |
| `GET` | `/api/v1/transactions` | Yes (Bearer) | No | Returns list of transactions (>= 10 records) |
| `POST` | `/api/v1/transactions/transfer` | Yes (Bearer) | **Yes (`Idempotency-Key`)** | Executes balance deduction and transfer |
| `GET` | `/api/v1/transactions/:id` | Yes (Bearer) | No | Returns single transaction details |

### 3.3 Backend Business Rules
1. **Authoritative Balance**: Flutter app cannot manipulate balance locally. Only the backend validates balance, performs deductions, and generates transaction IDs.
2. **Idempotency**: Repeated requests with the identical `Idempotency-Key` header return the original transfer result without double-deduction.
3. **HTTP Status Codes**:
   - `200 OK`: Request succeeded.
   - `400 Bad Request`: Validation failure (missing fields, invalid phone, amount <= 0).
   - `401 Unauthorized`: Missing or invalid Bearer token / credentials.
   - `404 Not Found`: Transaction ID not found.
   - `409 Conflict`: Insufficient balance.
   - `500 Internal Server Error`: Unexpected server exception.

---

## 4. Mobile Application Functional Specifications

### 4.1 Screen Breakdown & Features

#### Screen 1: Login & Authentication
- **Components**:
  - jWallet Lite logo & branding
  - Email field (`demo@jstack.co`) with regex validation
  - Password field (`Demo@123`) with visibility toggle
  - Sign In CTA button with loading spinner
  - Form-level error alerts
- **Behavior**:
  - On 200: Saves token to `flutter_secure_storage`, stores user session, navigates to Dashboard.
  - Auto-login check on app launch: If valid token exists, route directly to Dashboard.
  - Logout action clears secure storage and redirects to Login.

#### Screen 2: Wallet Dashboard (Home)
- **Components**:
  - Header: User greeting ("Hello, Demo User"), profile avatar/initials, Logout icon
  - Wallet Card: Available balance formatted in INR (e.g. `₹25,450.75`), Currency badge, Masked account number (`XXXX XXXX 4589`)
  - Quick Actions row:
    - **Send Money** (Navigates to Transfer Form)
    - **Add Money** (UI demonstration modal / bottom sheet)
    - **Transaction History** (Navigates to Full History)
  - Recent Transactions: Top 5 latest transactions displaying Icon (Credit/Debit), Beneficiary/Source, Date, Amount (Green for Credit, Red for Debit), Status tag
- **Behavior**:
  - Pull-to-refresh to sync balance and recent activity
  - Real-time refresh after a completed transfer

#### Screen 3: Money Transfer (Send Money Form)
- **Fields & Validations**:
  - Beneficiary Name: Mandatory, min 3 characters
  - Beneficiary Mobile Number: Mandatory, exact 10 digits (`^[6-9]\d{9}$`)
  - Transfer Amount: Numeric, > 0, cannot exceed current balance (client-side pre-check)
  - Remarks: Optional (max 100 chars)
- **Behavior**:
  - "Continue" button validates form and navigates to Transfer Confirmation.

#### Screen 4: Transfer Confirmation
- **Components**:
  - Review summary card: Transfer amount, Beneficiary name, Mobile number, Fee (₹0.00), Remarks, Deducting account
  - "Confirm & Pay" button and "Cancel / Edit" button
- **Behavior**:
  - Generates a UUID `Idempotency-Key`
  - Dispatches transfer API call with loading overlay
  - Prevents double-clicks / repeated submissions

#### Screen 5: Transfer Success / Failure
- **Success State**:
  - Animated checkmark icon
  - "Transfer Successful" headline
  - Transaction Reference Number (e.g. `TXN10003`)
  - Transferred Amount in bold
  - Beneficiary details & Timestamp
  - "Back to Dashboard" button (resets stack & updates balance)
- **Failure State**:
  - Cross/alert icon
  - Error reason returned by API (e.g. "Insufficient wallet balance")
  - "Retry" and "Cancel" buttons

#### Screen 6: Transaction History
- **Components**:
  - Search Bar: Live search by transaction reference or beneficiary name
  - Filter Chips: `All`, `Credit`, `Debit`
  - List View: All transactions grouped/sorted by descending timestamp
  - Empty State: Illustrated empty placeholder when filters yield 0 results
  - Pull-to-refresh and shimmer loading states
- **Behavior**:
  - Tap on item navigates to Transaction Details.

#### Screen 7: Transaction Details
- **Components**:
  - Detail card with Transaction ID, Type (Credit/Debit badge), Formatted Amount, Beneficiary/Sender, Date & Time, Status tag (SUCCESS/FAILED/PENDING), Remarks
  - "Share Receipt" button (or mock action)

---

## 5. UI/UX & Design Guidelines

1. **Fintech Aesthetics**: Dark/Light mode support, Material 3 elevation, rounded corner cards (16dp radius), distinct credit (+ green) / debit (- red) color tokens.
2. **Micro-interactions**: Subtle feedback on button presses, shimmer loaders instead of raw spinners for lists, animated transitions between confirmation and success.
3. **Accessibility & Usability**: Clear text contrast, explicit error messages below text fields, numeric keyboards for amounts and phone numbers.

---

## 6. Testing Requirements

### 6.1 Required Automated Tests
1. **Login Form Validation**:
   - Verify error when email format is invalid.
   - Verify error when password is empty.
   - Verify successful submission triggers auth state.
2. **Transfer Amount Validation**:
   - Verify validation error when amount is <= 0 or empty.
   - Verify validation error for non-numeric input.
3. **Insufficient Balance Handling**:
   - Verify error banner/dialog when API returns HTTP 409 (insufficient funds).
4. **Successful Transfer State Update**:
   - Verify wallet balance and transaction list update upon successful transfer response.

---

## 7. Submission Checklist & Deliverables

- [ ] **A. Source Code**: Clean Git repository with Flutter app (`/`) and Mock API backend (`/backend` or `/server`).
- [ ] **B. Android APK**: Release or debug APK generated in `build/app/outputs/flutter-apk/app-release.apk`.
- [ ] **C. API Documentation**: Exported Postman Collection (`jWallet_Lite_API.postman_collection.json`) or OpenAPI specification.
- [ ] **D. Screenshots**: High-resolution screenshots of all 7 screens stored in `/screenshots` or README.
- [ ] **E. Demonstration Video**: 2–3 minute video recording covering:
  - Login flow & Session persistence
  - Dashboard & balance fetch
  - Send money form validation
  - Successful transfer & immediate balance deduction
  - Transaction history search & filter
  - Error scenario (e.g., insufficient balance or invalid credentials)
- [ ] **F. Comprehensive README**:
  - Prerequisites (Flutter version, Node.js version)
  - Step-by-step setup instructions for backend & Flutter app
  - Base URL configuration (emulator vs physical device: `10.0.2.2` vs Local IP)
  - Testing instructions (`flutter test`)
  - Architectural decisions & state management justification
  - AI disclosures & known limitations
