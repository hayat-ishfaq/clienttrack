# ClientTrack — Store Listing, Submission Metadata & Compliance Guide (FT-026)

---

## 1. App Store Connect (iOS) Metadata

### Basic Information
- **App Name**: ClientTrack: Freelance Invoice
- **Subtitle**: Invoicing & Payment Chaser (30 chars)
- **Primary Category**: Business
- **Secondary Category**: Finance / Productivity
- **Content Rating**: 4+ (No unrestricted web access or mature content)
- **Bundle Identifier**: `com.clienttrack.app`
- **Default Language**: English (U.S.)

### App URLs
- **Support URL**: `https://github.com/hayat-ishfaq/clienttrack/issues`
- **Marketing URL**: `https://github.com/hayat-ishfaq/clienttrack`
- **Privacy Policy URL**: `https://raw.githubusercontent.com/hayat-ishfaq/clienttrack/main/docs/PRIVACY_POLICY.md`
- **Terms of Use (EULA) URL**: `https://raw.githubusercontent.com/hayat-ishfaq/clienttrack/main/docs/TERMS_OF_SERVICE.md`

### Promotional Text (170 characters max)
> Get paid on time, every time. Track clients, manage project deadlines, build professional invoices in seconds, and politely chase overdue payments with 1-tap reminders.

### Keywords (100 characters max, comma-separated)
> invoice,freelance,billing,invoice maker,payment reminder,pdf invoice,client tracker,contractor,receipt

### Full Description
```text
ClientTrack is the all-in-one business cockpit built specifically for freelancers, consultants, contractors, and independent creators who want to spend less time managing paperwork and more time getting paid.

Stop letting unpaid invoices slip through the cracks. ClientTrack combines intuitive client management, project milestone tracking, fast itemized invoice generation, and an automated Payment Chaser engine that turns awkward collection conversations into effortless 1-tap reminders.

KEY FEATURES:

💼 COMPLETE CLIENT & PROJECT DIRECTORY
• Organize all your clients with contact details, company information, and billing history.
• Track active projects, budget burn rates, hourly vs. fixed rates, and delivery deadlines.
• Instant Client Reliability scoring: see who pays on time and who is chronically late.

🧾 EFFORTLESS INVOICING & REAL VECTOR PDF GENERATION
• Create clean, itemized invoices with dynamic tax and subtotal calculations in under 60 seconds.
• Auto-generating sequential invoice numbers (e.g., INV-2026-0001).
• Export and share crisp, vector PDF invoices directly via email, messaging apps, or native print tray.

⚡ THE PAYMENT CHASER COCKPIT
• Dedicated "Needs Follow-up" screen showing overdue invoices sorted by urgency.
• Pre-built escalating reminder templates: Friendly, Professional, and Final Notice.
• 1-tap dispatch to WhatsApp, SMS, or Email pre-filled with client names and exact balance due.
• Keep track of reminder history with zero friction.

🔔 LOCAL DEADLINE ALERTS (NO SERVER TRACKING)
• Intelligent local device reminders alert you 2 days before an invoice is due, on the due date, and 1 day after.
• Zero push notification tracking or spam: all alarms run strictly on your device.

🔒 PRIVACY & CLOUD PERSISTENCE
• Fully synchronized with encrypted cloud persistence so your data is always safe.
• Compliant, 1-tap in-app account deletion that wipes all your data upon request.

UPGRADE TO CLIENTTRACK PRO
Unlock the full power of your business:
• Unlimited active clients (Free tier: up to 3)
• Unlimited invoices (Free tier: up to 5)
• Unlimited Payment Chaser reminder shares (Free tier: up to 3)
• Clean, watermark-free PDF invoice exports

Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless canceled at least 24 hours before the end of the current billing cycle. Manage or cancel anytime in your App Store Account Settings.
```

---

## 2. Google Play Console (Android) Metadata

### Listing Details
- **App Name**: ClientTrack: Freelance Invoice
- **Short Description (80 characters max)**:
  > Smart freelance invoicing, project tracking, and 1-tap payment chaser reminders.
- **Application Category**: Business
- **Tags**: Productivity, Invoicing, Billing, Freelancer

### Full Description (4,000 characters max)
*(Matches the Full Description above, formatted for Google Play Store formatting).*

---

## 3. In-App Subscriptions Configuration (RevenueCat / StoreKit / Play Billing)

| Product ID | Type | Price (USD) | Entitlement ID | Description |
| :--- | :--- | :--- | :--- | :--- |
| `clienttrack_pro_monthly` | Auto-Renewable Subscription | \$9.99 / month | `clienttrack_pro` | Monthly access to ClientTrack Pro |
| `clienttrack_pro_annual` | Auto-Renewable Subscription | \$59.99 / year | `clienttrack_pro` | Annual access to ClientTrack Pro (50% savings) |

---

## 4. App Store Privacy Nutrition Labels (Apple)

Under Apple's privacy guidelines, declare the following data usages:

| Data Type | Collected? | Linked to User? | Used for Tracking? | Purpose |
| :--- | :---: | :---: | :---: | :--- |
| **Contact Info** (Email address, Name, Phone) | Yes | Yes | No | App Functionality, Account Authentication |
| **Financial Info** (Invoices, rates, payment history) | Yes | Yes | No | App Functionality (Core service) |
| **User Content** (Client notes, company details) | Yes | Yes | No | App Functionality |
| **Purchases** (Purchase history, active entitlement) | Yes | Yes | No | App Functionality (Subscription management via RevenueCat) |
| **Diagnostics** (Crash data, performance metrics) | Optional | No | No | Analytics & Bug Fixes |

---

## 5. Google Play Data Safety Declaration

1. **Does your app collect or share any of the required user data types?**  
   $\to$ **Yes**.
2. **Is all user data collected encrypted in transit?**  
   $\to$ **Yes** (all communications use HTTPS / TLS 1.3 to Firebase and RevenueCat).
3. **Do you provide a way for users to request that their data be deleted?**  
   $\to$ **Yes** (In-app deletion feature available under Settings $\to$ Delete account, immediately purging all Firestore records).
4. **Data Categories Collected**:
   - **Personal Info**: Email address (for account setup), Name/Phone (optional business profile).
   - **Financial Info**: Invoicing history, balance due, billing rates.
   - **Device or other IDs**: Firebase installation IDs and RevenueCat anonymous subscriber IDs.

---

## 6. Reviewer Credentials & App Review Notes

When submitting for App Review (Apple App Store Connect / Google Play Console):

- **Demo Account Email**: `reviewer@clienttrack.app`
- **Demo Account Password**: `ReviewPass2026!`
- **Reviewer Notes**:
  ```text
  Hello App Review Team,
  
  ClientTrack is a client management, invoicing, and payment follow-up tool for freelancers.
  
  Test credentials have been pre-seeded with sample clients, projects, and invoices.
  
  Key user flows to verify:
  1. Login with the credentials provided above.
  2. View Dashboard financial overview.
  3. Create an Invoice (Invoices tab -> "+" button). View generated PDF preview.
  4. Test Payment Chaser: Go to "Needs Follow-up" from Dashboard or Chaser tab to compose and view reminder templates.
  5. In-App Purchases / Subscriptions: Tap "Upgrade to Pro" or navigate to Settings -> Subscription to view the RevenueCat Paywall in sandbox mode.
  6. Account Deletion: Accessible in Settings -> "Delete account". Requires password confirmation and purges all data in compliance with Guideline 5.1.1(v).
  
  Thank you for your review!
  ```

