# DhanSETU 🔐💸

> A privacy-focused fraud detection layer for safer digital payments.

DhanSETU is an AI-assisted payment security concept designed to help detect **Authorized Push Payment (APP) fraud**—situations where a user is manipulated or socially engineered into authorizing a payment themselves.

Instead of replacing UPI, DhanSETU acts as a **context-aware security layer** that analyzes transaction and behavioral risk signals and can intervene before a suspicious payment is completed.

## 🚨 Problem

In an APP scam:
1. A scammer contacts the victim.
2. The victim is convinced or pressured to make a payment.
3. The victim enters the correct credentials and authorizes it.
4. The transaction can therefore appear legitimate to conventional fraud systems.

**DhanSETU aims to identify the risk surrounding the payment—not just whether the credentials are valid.**

## 💡 Solution

DhanSETU combines multiple signals to create an explainable risk assessment before payment completion.

### Example signals
- 🆕 New recipient
- 💰 Unusually large transaction
- ⚡ Multiple rapid transactions
- 🕐 Unusual transaction timing
- 📊 Deviation from normal transaction behavior
- 🚨 Suspicious scam context

Risk levels:

```text
🟢 LOW       → Continue normally
🟡 MEDIUM    → Show additional warning
🔴 HIGH      → Trigger fraud intervention
```

## 🔄 Workflow

```text
User
  ↓
Login / Device Authentication
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
                       Verify / Cancel
                              ↓
                       Payment Result
```

## 🛡️ Fraud Intervention

For a high-risk payment, DhanSETU can display:

> ⚠️ **Potential Scam Detected**  
> ₹25,000 → New Recipient  
> This payment differs significantly from your usual activity.  
> **Did someone ask you to make this payment?**  
> `Cancel Payment` | `Verify & Continue`

The goal is to create a **pause before an irreversible payment**, especially when social engineering may be involved.

## 🧠 MVP Risk Engine

The MVP uses an explainable rule-based scoring approach.

| Risk Signal | Example Score |
|---|---:|
| New recipient | +25 |
| Unusually large amount | +25 |
| Multiple rapid payments | +20 |
| Unusual transaction time | +10 |
| Suspicious scam context | +30 |

Prototype thresholds:

```text
0–30    → LOW
31–60   → MEDIUM
61+     → HIGH
```

> These are prototype values for demonstration and are **not validated fraud probabilities**.

## 🔐 Security & Privacy

- Never store UPI PINs or OTPs.
- Use HTTPS/TLS for network communication.
- Authenticate API requests.
- Use device/biometric authentication where available.
- Use Android Keystore or hardware-backed keys where supported.
- Apply rate limiting and server-side validation.
- Minimize sensitive data collection.
- Process sensitive context locally where practical.

### Privacy principle

```text
Raw Sensitive Data
        ↓
Local Processing
        ↓
Minimal Risk Features
        ↓
Risk Assessment
```

The MVP should avoid unnecessarily sending raw messages, call recordings, contacts, or other sensitive content to a server.

## 📱 MVP Screens

1. **Home / Payment**
2. **Recipient + Amount**
3. **Risk Analysis**
4. **Fraud Intervention**
5. **Security / Risk Dashboard**

## 🏗️ Proposed Architecture

```text
┌──────────────────────────────┐
│       Flutter / Dart         │
│      Mobile Application      │
└──────────────┬───────────────┘
               ↓
┌──────────────────────────────┐
│     Context / Signal Layer   │
└──────────────┬───────────────┘
               ↓
┌──────────────────────────────┐
│        Risk Engine           │
│   Rules + Behavioral Model   │
└──────────────┬───────────────┘
               ↓
       ┌───────┴────────┐
       ↓                ↓
   LOW/MEDIUM          HIGH
       ↓                ↓
   Warning          Intervention
                        ↓
                 User Verification
                        ↓
                Payment / Cancellation
```

## 🧰 Technology Stack

**Frontend**
- Flutter
- Dart

**Backend**
- Python
- FastAPI

**Database**
- PostgreSQL / Firebase

**Security**
- Android Keystore
- Biometric Authentication
- HTTPS/TLS
- Token-based authentication

**Intelligence**
- Rule-based risk engine for MVP
- Behavioral anomaly detection as a future enhancement
- Machine learning model for future versions

## 🎬 Demo Scenario

### Normal transaction

```text
₹500
Existing recipient
Normal transaction pattern
        ↓
🟢 LOW RISK
        ↓
Payment proceeds
```

### Potential APP fraud

```text
₹25,000
New recipient
Unusual amount
Rapid transaction
Suspicious scam context
        ↓
🔴 HIGH RISK
        ↓
⚠️ FRAUD INTERVENTION
        ↓
Cancel / Verify / Continue
```

## 🎯 Key Differentiator

DhanSETU is **not another UPI application**.

It focuses on the gap between:

> **"Was the payment technically authorized?"**

and

> **"Was the user manipulated into authorizing it?"**

By combining transaction behavior with contextual risk signals, DhanSETU aims to detect potentially scam-driven payments before completion.

## 🚀 Future Scope

- On-device machine learning
- Personalized behavioral baselines
- Federated learning
- Advanced anomaly detection
- Device and app integrity checks
- Explainable AI for fraud decisions
- Integration with authorized payment-provider/sandbox APIs
- Privacy-preserving model improvement

## ⚠️ MVP Disclaimer

DhanSETU is a **prototype/hackathon concept**. The MVP uses simulated payment flows and prototype risk thresholds. It should not be treated as a production banking or UPI security system without validation, regulatory compliance, security testing, privacy review, and integration with authorized payment infrastructure.

## 📌 One-Line Description

> **DhanSETU is a privacy-focused, context-aware fraud detection layer that helps protect users from socially engineered digital payments and Authorized Push Payment fraud.**

---

**Project:** DhanSETU  
**Category:** FinTech / Cybersecurity / Fraud Prevention  
**Focus:** Authorized Push Payment (APP) Fraud  
**Stage:** MVP / Prototype
