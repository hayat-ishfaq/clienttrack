# Privacy Policy for ClientTrack

**Effective Date:** October 30, 2026  
**Last Updated:** October 30, 2026

Welcome to **ClientTrack** ("we," "our," or "us"), provided by the ClientTrack development team (`hayat-ishfaq/clienttrack`). We are dedicated to safeguarding your privacy and ensuring transparency regarding how your data is collected, processed, and secured.

This Privacy Policy explains what information we collect when you download, install, or use the ClientTrack mobile application on Android and iOS devices, how we use and protect that information, and your rights concerning your personal data.

---

## 1. Information We Collect

### A. Information You Provide Directly
- **Account Credentials**: When registering an account, we collect your email address and password (securely hashed and managed via Firebase Authentication).
- **Business Profile**: Business name, representative name, contact email, phone number, address, and default currency code.
- **Client Records**: Client names, company names, contact emails, phone numbers, billing addresses, and internal notes you enter into the application.
- **Project & Invoice Data**: Project scopes, budgets, hourly/fixed rates, invoice numbers, line items, issue dates, payment due dates, and payment status history.

### B. Automatically Collected Information & Device Data
- **Device & Usage Diagnostics**: Device model, operating system version (iOS/Android), application version, and diagnostic crash events (via Firebase Crashlytics if enabled).
- **In-App Purchase & Subscription Data**: When subscribing to ClientTrack Pro, transaction metadata (purchase tokens, active entitlements, renewal dates, and package identifiers) is processed through our purchase infrastructure partner, **RevenueCat**, and the respective platform store (Google Play Billing / Apple App StoreKit). We never see or store your payment card numbers.

---

## 2. How We Use Your Information

We process your data strictly to deliver and enhance the core capabilities of ClientTrack:
1. **Core Service Delivery**: Storing and synchronizing your clients, projects, invoices, and payment histories across your authenticated devices.
2. **On-Device Document Generation**: Compiling professional vector PDF invoices and receipts locally on your device.
3. **Smart Payment Chasing**: Preparing customizable reminder messages (Friendly, Professional, Final Notice) pre-filled with relevant invoice amounts and due dates for dispatch through external channels (WhatsApp, SMS, Email, Native OS Share Tray).
4. **Subscription Management**: Verifying Pro entitlements (`clienttrack_pro`) to provide unlimited clients, invoices, watermark-free PDFs, and payment reminders.
5. **Local Notifications**: Scheduling local device reminders for approaching invoice due dates and project milestones (processed entirely on-device without remote push server tracking).

---

## 3. Data Storage & Security Architecture

- **Encrypted Cloud Storage**: All cloud data is stored within Google Cloud Firestore and secured with strict row-level security rules (`/users/{uid}/**`). Only you can read, write, or delete your data.
- **Offline Cache**: Data is cached locally using Firestore offline persistence and protected by standard operating system application sandbox boundaries.
- **Data Retention & Account Deletion**: You can permanently delete your account and all associated records (clients, projects, invoices, reminders, and profile) directly from the application (**Settings $\to$ Delete account**). Upon deletion, all records are permanently purged from our servers, and all scheduled device notifications are canceled.

---

## 4. Third-Party Service Providers

We integrate minimal, audited third-party services necessary for application operations:
- **Firebase Authentication & Cloud Firestore (Google LLC)**: User identity and database infrastructure. [Google Privacy Policy](https://policies.google.com/privacy).
- **RevenueCat, Inc.**: Subscription lifecycle and entitlement management. [RevenueCat Privacy Policy](https://www.revenuecat.com/privacy).
- **Native OS Messengers**: When you choose to dispatch a payment reminder via WhatsApp, SMS, or Email, the text is handed off via platform URI schemes (`wa.me`, `sms:`, `mailto:`) to your installed apps. We do not transmit or monitor messages once handed off.

---

## 5. Your Legal Rights & Data Protection (GDPR / CCPA)

Regardless of your geographic location, ClientTrack grants you full autonomy over your data:
- **Right to Access**: View all your stored data anytime inside the app.
- **Right to Rectification**: Edit and update your business profile, client, or invoice information at any time.
- **Right to Erasure (Data Purge)**: Permanently purge your entire account and associated Firestore documents instantly via the in-app deletion utility.
- **Right to Restrict Processing**: Revoke notification permissions anytime through your device operating system settings.

---

## 6. Children's Privacy

ClientTrack is designed exclusively for business professionals, contractors, and freelancers. We do not knowingly collect personal information from individuals under the age of 18.

---

## 7. Contact Us

If you have questions, feedback, or data privacy requests regarding this Privacy Policy:
- **Project Repository**: [https://github.com/hayat-ishfaq/clienttrack](https://github.com/hayat-ishfaq/clienttrack)
- **Developer Support**: support@clienttrack.app

