# DhanSETU 

> **DhanSETU** is a privacy-focused fraud detection layer that identifies potentially scam-driven UPI payments using transaction patterns, user behavior, and risk signals. It provides real-time warnings and intervention before payment completion, helping users avoid social-engineering and Authorized Push Payment (APP) fraud.

DhanSETU is an AI-assisted payment security concept designed to help detect **Authorized Push Payment (APP) fraud**—situations where a user is manipulated or socially engineered into authorizing a payment themselves.

Instead of replacing UPI, DhanSETU acts as a **context-aware security layer** that analyzes transaction and behavioral risk signals and can intervene before a suspicious payment is completed.

---

##  Problem

In an APP scam:
1. A scammer contacts the victim.
2. The victim is convinced or pressured to make a payment.
3. The victim enters the correct credentials and authorizes it.
4. The transaction can therefore appear legitimate to conventional fraud systems.

**DhanSETU aims to identify the risk surrounding the payment—not just whether the credentials are valid.**

---

##  Solution

DhanSETU combines multiple signals to create an explainable risk assessment before payment completion.

### Example signals
-  New recipient
-  Unusually large transaction (>3x typical average)
-  Multiple rapid transactions (Velocity limit)
-  Unusual transaction timing (Late night hours)
- Active telephone call detection (Social engineering / coercion risk)
-  Deviation from normal transaction behavior
-  Prior scam reports and unverified recipient accounts

Risk levels:

```text
🟢 LOW       → Continue normally
🟡 MEDIUM    → Show additional warning & verification friction
🔴 HIGH      → Trigger fraud intervention ("Pause & Verify" / Coercion audit)
```

---

## 🔄 Workflow

```text
User
  ↓
Login / Device Authentication (Biometric / PIN)
  ↓
Enter Recipient + Amount
  ↓
Collect Risk Signals
  ↓
Risk Engine
  ↓
Calculate Risk
  ↓
┌───────────┬────────────┬────────────┐
│    LOW    │   MEDIUM   │    HIGH    │
│           │            │            │
│ Continue  │   Warn     │ Intervene  │
└───────────┴────────────┴────────────┘
                               ↓
                        Pressure Check
                               ↓
                      ┌────────┴────────┐
                      ↓                 ↓
                     YES                NO
                      ↓                 ↓
                Scam Warning       Interception
               & 1930 Helpline       Checklist
                      ↓                 ↓
                Cancel Payment      Confirm / Pay
```

---

## 🛡️ Fraud Intervention

For a high-risk payment, DhanSETU displays:

> ⚠️ **Potential Scam Detected — PAUSE & VERIFY**  
> Mandatory 5-Second Cooldown Timer  
> Detected Threat: Active phone call + New unverified recipient + Unusual amount  
> **Did someone pressure or instruct you to make this payment?**  
> `Cancel Payment Immediately` | `Call 1930 Helpline` | `Verify & Re-check`

---

## 🧠 Risk Engine Implementation

The application includes an explainable rule-based scoring engine (`RiskEngine`):

| Risk Signal | Score |
|---|---:|
| New unverified recipient | +2 pts |
| Amount > 3x user typical average | +3 pts |
| Active telephone call detected | +2 pts |
| High velocity (>3 tx in 1 hr) | +2 pts |
| Late night transaction (11 PM – 5 AM) | +1 pt |
| Contact added in last 24 hours | +1 pt |

### Risk Thresholds
- **0–2 pts**: `Low Risk` → Normal confirmation flow
- **3–5 pts**: `Medium Risk` → Elevated warning banner & acknowledgment checklist
- **6+ pts**: `High Risk` → "Pause & Verify" alert, mandatory cooldown timer, and coercion audit

---

## 📱 15 Implemented Screens

1. **Splash/Launch (`/splash`)**: Animated logo and security shield initialization.
2. **Login / Device Auth (`/login`)**: Biometric scan (Fingerprint / Face ID), 4-digit PIN, and Quick Demo bypass.
3. **Home Dashboard (`/home`)**: UPI balance card, quick actions, live risk score pill, recent activity.
4. **Send Money (`/send-money`)**: Recipient search, numerical keypad, notes, and **Risk Simulator Sandbox Drawer**.
5. **Recipient Profiling (`/recipient-profile`)**: Payee verification badge, account maturity, fraud complaints count, call status.
6. **Payment Confirmation — Low Risk (`/confirm-low`)**: Frictionless green clearance, source bank debit, UPI PIN prompt.
7. **Payment Confirmation — Medium Risk (`/confirm-medium`)**: Amber alert banner, risk factor breakdown, friction checkbox.
8. **Fraud Alert — High Risk (`/fraud-alert`)**: Crimson alert, 5-second mandatory cooldown timer, danger points, emergency abort button.
9. **Pressure-Check Screen (`/pressure-check`)**: Coercion detection for digital arrest, utility cutoff, and screen-sharing scams.
10. **Verification Steps (`/verification-steps`)**: High-coercion intervention: Strong warning, cancellation, and **National Cyber Helpline 1930 dialer**.
11. **Payment Interception Alert (`/payment-interception`)**: Re-check screen with 3 legal checkpoints before proceeding.
12. **Security Center (`/security-center`)**: 96% Health gauge, toggles for 5 active shields, 1930 helpline portal.
13. **Transaction History (`/history`)**: Search transactions, filter chips (All, Low, Medium, High), detail modal sheet.
14. **Profile / Settings (`/profile`)**: User information, linked bank accounts (HDFC, SBI), transaction limits.
15. **Payment Success (`/payment-success`)**: Animated checkmark, UPI reference ID, risk engine audit summary, share receipt.

---

##  Technology Stack

- **Framework**: Flutter 3.x / Dart 3.x (Null-Safety)
- **State Management**: Riverpod 3 (`Notifier` / `NotifierProvider`)
- **Routing**: `go_router` with declarative, guarded redirects
- **Local Auth**: `local_auth` (Biometric & device PIN with cross-platform fallback)
- **Design System**: Material 3 Teal (`#0D9488`) / Mint (`#F0FBF9`) theme with Inter typography
- **Testing**: Comprehensive unit, widget, and workflow integration test suite

---

##  Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/DHANSETU-DCGC/DhanSETU.git
   cd DhanSETU
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 📌 Project Information

- **Project**: DhanSETU (SecurePay)
- **Category**: FinTech / Cybersecurity / UPI Fraud Prevention
- **Focus**: Authorized Push Payment (APP) Fraud & Social Engineering Detection
- **Repository**: [github.com/DHANSETU-DCGC/DhanSETU](https://github.com/DHANSETU-DCGC/DhanSETU)
