# ClientTrack — Feature Tickets & Implementation Backlog

---

## Phase 0: Project Initialization & Architecture Setup

### FT-001: Flutter Environment & Dependency Setup
- **Module**: Core / Tech Stack
- **Priority**: P0
- **Phase**: Phase 0
- **Estimate**: S (<=2h)
- **Description**: Configure `pubspec.yaml` with verified production dependencies (Riverpod, go_router, cloud_firestore, firebase_auth, purchases_flutter, pdf, printing, flutter_local_notifications, share_plus, url_launcher, fl_chart, intl, uuid) and run code generation.
- **Acceptance Criteria**:
  - `pubspec.yaml` resolves without dependency conflicts on Flutter 3.13+.
  - `build_runner` executes cleanly with 0 errors.
  - Project compiles and launches clean default app on Android and iOS simulators.
- **Dependencies**: None
- **Notes**: Check latest non-breaking package versions on pub.dev.

### FT-002: App Design System & Theme Engine
- **Module**: Core / Design System
- **Priority**: P0
- **Phase**: Phase 0
- **Estimate**: M (half day)
- **Description**: Implement color tokens, typography scales (Inter font), shape borders, card themes, and button styles defined in `docs/FRONTEND_SPEC.md`.
- **Acceptance Criteria**:
  - `AppColors`, `AppTypography`, and `AppTheme` implemented in `lib/app/theme/`.
  - Primary button (52px, radius 14), input fields, and status chip pill themes match design specs.
  - Light theme configured and verified across device displays.
- **Dependencies**: FT-001
- **Notes**: See `docs/FRONTEND_SPEC.md` Section 2.

### FT-003: Core Router & Shell Navigation Setup
- **Module**: Core / Navigation
- **Priority**: P0
- **Phase**: Phase 0
- **Estimate**: M (half day)
- **Description**: Configure `go_router` with root redirect guards (auth state), 5-tab persistent bottom navigation shell route (Dashboard, Clients, Projects, Invoices, Settings), and placeholder routes for all 22 screens.
- **Acceptance Criteria**:
  - 5-tab shell renders correctly with customized active green highlights.
  - Sub-routes (Add Client, PDF Preview, Paywall Modal) open without showing bottom navigation.
  - Deep-link paths defined cleanly in `route_names.dart`.
- **Dependencies**: FT-002
- **Notes**: See `docs/TECHNICAL_ARCHITECTURE.md` Section 5.

### FT-004: Firebase Initialization & Firestore Rules Setup
- **Module**: Core / Backend
- **Priority**: P0
- **Phase**: Phase 0
- **Estimate**: S (<=2h)
- **Description**: Configure Firebase Core, initialize Firebase Auth and Firestore with offline cache enabled, and deploy Firestore security rules.
- **Acceptance Criteria**:
  - Firestore offline persistence initialized with `persistenceEnabled: true`.
  - Security rules file (`firestore.rules`) created with `/users/{uid}/**` isolation.
  - Basic Firestore connection ping test succeeds.
- **Dependencies**: FT-001
- **Notes**: See `docs/SECURITY_AND_ACCESS.md` Section 5.

---

## Phase 1: Core Product & Data Pipelines

### FT-005: Authentication & Session Management
- **Module**: M1 Auth
- **Priority**: P0
- **Phase**: Phase 1
- **Estimate**: M (half day)
- **Description**: Implement Email/Password registration, login, session persistence, and password reset flows with Firebase Auth.
- **Acceptance Criteria**:
  - Form validation: email syntax and $\ge 8$ char password.
  - New user sign-up creates Firebase Auth account and initializes `/users/{uid}` profile.
  - Forgot password triggers reset email.
  - Session automatically restores on app launch.
- **Dependencies**: FT-003, FT-004
- **Notes**: See `docs/TECHNICAL_ARCHITECTURE.md` Section 17.1.

### FT-006: Onboarding Carousel & Profile Setup
- **Module**: M1 Onboarding
- **Priority**: P0
- **Phase**: Phase 1
- **Estimate**: M (half day)
- **Description**: Build 3-slide value onboarding walkthrough and initial skippable business profile setup screen (name, business name, currency picker).
- **Acceptance Criteria**:
  - Onboarding carousel displays 3 slides with page indicator.
  - Profile setup allows selecting currency (USD, EUR, GBP, etc.) and updates Firestore profile.
  - "Skip for Now" proceeds to Dashboard with default USD setting.
- **Dependencies**: FT-005
- **Notes**: Matches `visily-02-onboarding.png` and `visily-06-profile-setup.png`.

### FT-007: Client Management (CRUD & Directory)
- **Module**: M2 Clients
- **Priority**: P0
- **Phase**: Phase 1
- **Estimate**: M (half day)
- **Description**: Build client repository, Riverpod stream providers, client list with live search, and add/edit/delete client screens.
- **Acceptance Criteria**:
  - Add client validates required name, optional email, phone, company, and notes.
  - Client list displays active clients with search filtering.
  - Edit and delete actions update Firestore; delete triggers confirmation modal.
  - Free tier limits creation to 3 clients (triggers paywall on 4th attempt).
- **Dependencies**: FT-004, FT-006
- **Notes**: See `docs/TECHNICAL_ARCHITECTURE.md` Section 6.2.

### FT-008: Project Management (CRUD & Client Linking)
- **Module**: M3 Projects
- **Priority**: P0
- **Phase**: Phase 1
- **Estimate**: M (half day)
- **Description**: Build project repository, project list with status filter chips (*All*, *In Progress*, *Completed*), and add/edit project screens.
- **Acceptance Criteria**:
  - Projects link to a valid client from a dropdown picker.
  - Supports rate types (*Fixed* or *Hourly*) with numeric rate input.
  - Deadline date picker with visual indicator for upcoming deadlines.
  - "Create Invoice" button routes directly to Invoice Editor with client pre-selected.
- **Dependencies**: FT-007
- **Notes**: Matches `visily-11-project-list.png` and `visily-new-project.png`.

### FT-009: Invoice Builder & Line Items Engine
- **Module**: M4 Invoicing
- **Priority**: P0
- **Phase**: Phase 1
- **Estimate**: L (1 day)
- **Description**: Implement invoice creation screen with auto-generated sequential invoice numbers (e.g., `INV-0001`), client selector, issue/due dates, dynamic line items (quantity $\times$ rate calculation), and subtotal/total aggregation.
- **Acceptance Criteria**:
  - Dynamic line item addition, removal, and automatic subtotal recalculation.
  - Auto-increments invoice number based on user's highest existing index.
  - Writes invoice document to `/users/{uid}/invoices/{id}` with embedded line items.
  - Free tier restricts creation to 5 invoices (triggers paywall on 6th attempt).
- **Dependencies**: FT-008
- **Notes**: Matches `visily-15-create-invoice.png`.

### FT-010: Invoice Detail & Mark as Paid Action
- **Module**: M4 Invoicing
- **Priority**: P0
- **Phase**: Phase 1
- **Estimate**: S (<=2h)
- **Description**: Build invoice detail screen displaying itemized summary, status chips, client details, and "Mark as Paid" action.
- **Acceptance Criteria**:
  - "Mark as Paid" sets `status: 'paid'`, sets `paidAt` timestamp, and updates client payment history.
  - Changing status to Paid cancels pending scheduled notifications for this invoice.
- **Dependencies**: FT-009
- **Notes**: Matches `visily-16.-invoice-detail.png`.

### FT-011: On-Device PDF Invoice Generation & Share
- **Module**: M4 Invoicing / PDF
- **Priority**: P0
- **Phase**: Phase 1
- **Estimate**: L (1 day)
- **Description**: Develop PDF generation service using `pdf` and `printing` packages to compile professional vector invoices on-device with preview screen and native OS share action.
- **Acceptance Criteria**:
  - Renders user business info, client details, invoice number, dates, line items table, and totals.
  - Free Tier: Embeds *"Made with ClientTrack"* discreet footer watermark.
  - Pro Tier: Renders clean, watermark-free footer.
  - "Share PDF" opens native OS sharing tray with generated PDF document.
- **Dependencies**: FT-010
- **Notes**: Matches `visily-17-pdf-preview.png`.

---

## Phase 2: Payment Chaser & Delivery Engine

### FT-012: Deterministic Status Derivation & Payment History
- **Module**: M2 Clients / M4 Invoices
- **Priority**: P0
- **Phase**: Phase 2
- **Estimate**: M (half day)
- **Description**: Implement pure client-side calculators for dynamic invoice display status (Paid, Overdue, Due Today, Due Soon, Draft, Sent) and client payment history (Avg Days Late, On-Time %, Reliability Tier).
- **Acceptance Criteria**:
  - Unit tests verify overdue status comparing `dueDate` against midnight without storing stale status.
  - Client detail screen displays factual payment badge: *Reliable*, *Sometimes Late*, *Chronically Late*.
  - Historical calculations update immediately when invoices are marked paid.
- **Dependencies**: FT-010
- **Notes**: See `docs/TECHNICAL_ARCHITECTURE.md` Section 6.3.

### FT-013: Needs Follow-up Screen (Chaser Cockpit)
- **Module**: M5 Payment Chaser
- **Priority**: P0
- **Phase**: Phase 2
- **Estimate**: M (half day)
- **Description**: Build dedicated "Needs Follow-up" screen listing all invoices currently Due Today or Overdue, sorted by urgency.
- **Acceptance Criteria**:
  - Displays total overdue sum banner at top.
  - Lists cards with client name, invoice number, amount, days overdue, and last shared reminder date.
  - "Chase" button launches Reminder Composer modal with target invoice context.
- **Dependencies**: FT-012
- **Notes**: Matches `visily-18-needs-follow-up.png`.

### FT-014: Reminder Template Engine & Native Dispatch
- **Module**: M5 Payment Chaser
- **Priority**: P0
- **Phase**: Phase 2
- **Estimate**: M (half day)
- **Description**: Build Reminder Composer modal sheet with 3 escalating templates (Friendly, Professional, Final), dynamic variable injection, and one-tap deep-link sharing (WhatsApp, SMS, Email, Share Sheet).
- **Acceptance Criteria**:
  - Switching tabs instantly populates editable text box with interpolated variables.
  - WhatsApp button invokes `whatsapp://send` with URL-encoded text.
  - SMS and Email buttons invoke `sms:` and `mailto:` schemes.
  - Handing off to external app logs a new `Reminder` record in `/users/{uid}/reminders` with `status: 'shared'` and increments user's `reminderSharesCount`.
  - Free tier restricts lifetime shares to 3 (triggers paywall on 4th attempt).
- **Dependencies**: FT-013
- **Notes**: Never use the word "Sent"; strictly record as "Shared". Matches `visily-send-reminder.png`.

---

## Phase 3: Dashboard & Daily Cockpit

### FT-015: Dashboard Financial Summaries & Action Cards
- **Module**: M6 Dashboard
- **Priority**: P0
- **Phase**: Phase 3
- **Estimate**: M (half day)
- **Description**: Assemble the main Dashboard screen with real-time aggregated metrics from Firestore streams: Outstanding balance, Earned this month, and Overdue totals.
- **Acceptance Criteria**:
  - Computes and displays Outstanding, Earned this month, and Overdue sums.
  - Displays Needs Follow-up action card with overdue invoice count and direct navigation to Screen 18.
  - Displays active project count and list of nearest 3–5 approaching deadlines.
  - Displays list of 3 most recent invoices with status chips.
- **Dependencies**: FT-010, FT-013
- **Notes**: Matches `visily-07-dashboard.png`.

---

## Phase 4: Local Notifications

### FT-016: Local Notification Service & Permission Orchestrator
- **Module**: M7 Local Notifications
- **Priority**: P0
- **Phase**: Phase 4
- **Estimate**: M (half day)
- **Description**: Configure `flutter_local_notifications` with timezone support, handle iOS/Android 13+ runtime notification permissions, and build educational permission pre-prompt sheet.
- **Acceptance Criteria**:
  - Displays pre-permission explainer sheet before triggering native OS permission modal.
  - Correctly initializes local notification channels on Android and categories on iOS.
- **Dependencies**: FT-001
- **Notes**: See `docs/TECHNICAL_ARCHITECTURE.md` Section 8.3.

### FT-017: Invoice & Project Deadline Notification Scheduling
- **Module**: M7 Local Notifications
- **Priority**: P0
- **Phase**: Phase 4
- **Estimate**: M (half day)
- **Description**: Implement notification scheduling engine that queues alerts for upcoming invoice due dates, overdue escalations, and project deadlines while respecting the iOS 64-notification cap.
- **Acceptance Criteria**:
  - Schedules notifications at: Due Date - 2 days (9 AM), Due Date (9 AM), and Due Date + 1 day (10 AM).
  - Automatically cancels alerts when invoice is marked paid or edited.
  - Prunes pending notifications to maintain $\le 40$ active invoice alerts.
- **Dependencies**: FT-016, FT-010
- **Notes**: See `docs/TECHNICAL_ARCHITECTURE.md` Section 8.3.

---

## Phase 5: RevenueCat Monetization & Paywall

### FT-018: RevenueCat SDK Integration & User Identity
- **Module**: M8 Monetization
- **Priority**: P0
- **Phase**: Phase 5
- **Estimate**: M (half day)
- **Description**: Initialize `purchases_flutter` SDK, configure platform API keys, link RevenueCat identity via `Purchases.logIn(uid)` upon Firebase login, and bind customer info updates to Riverpod state.
- **Acceptance Criteria**:
  - RevenueCat initializes on app start with platform-specific public keys.
  - `Purchases.logIn` called immediately after Firebase Auth login/signup.
  - Riverpod provider `isProUserProvider` updates reactively when `clienttrack_pro` entitlement changes.
- **Dependencies**: FT-005
- **Notes**: See `docs/TECHNICAL_ARCHITECTURE.md` Section 9.1.

### FT-019: Feature Gating Service & Limit Enforcement
- **Module**: M8 Monetization
- **Priority**: P0
- **Phase**: Phase 5
- **Estimate**: S (<=2h)
- **Description**: Implement `FeatureGateService` providing synchronous limit checks across clients (max 3), invoices (max 5), and reminder shares (max 3 lifetime).
- **Acceptance Criteria**:
  - Evaluates active entitlement: Pro users bypass all limits.
  - Free users exceeding thresholds are blocked and presented with contextual paywall modal.
  - Unit tests verify boundary edge cases (count = 2, 3, 4).
- **Dependencies**: FT-018
- **Notes**: Limits must never lock out a reviewer from testing the complete free core flow.

### FT-020: Paywall Modal & Subscription Purchase Flow
- **Module**: M9 Paywall
- **Priority**: P0
- **Phase**: Phase 5
- **Estimate**: L (1 day)
- **Description**: Build dedicated Paywall Screen (`Screen 20`) dynamically loading monthly and annual packages from RevenueCat offering, supporting in-app purchasing, error handling, and restore purchases.
- **Acceptance Criteria**:
  - Fetches and displays dynamic localized store prices (never hardcoded).
  - Completes purchase via `Purchases.purchasePackage` and unlocks Pro immediately.
  - "Restore Purchases" button refreshes entitlement with clear feedback toast.
  - Includes links to Terms of Service and Privacy Policy.
- **Dependencies**: FT-018, FT-019
- **Notes**: Matches `visily-clienttrack-pro-upgrade.png`.

### FT-021: Sandbox Testing Matrix Execution
- **Module**: M8 Monetization
- **Priority**: P0
- **Phase**: Phase 5
- **Estimate**: M (half day)
- **Description**: Execute complete end-to-end sandbox testing suite across Google Play License Testing and Apple StoreKit Sandbox.
- **Acceptance Criteria**:
  - Test purchase of Monthly package $\to$ unlocks Pro.
  - Test purchase of Annual package $\to$ unlocks Pro.
  - Test Restore Purchases on clean install $\to$ unlocks Pro.
  - Test subscription cancellation / expiration $\to$ gracefully reverts to Free tier.
- **Dependencies**: FT-020
- **Notes**: Document evidence in `docs/Progress.md`.

---

## Phase 6: Release Readiness & Store Compliance

### FT-022: Empty, Loading, and Error States
- **Module**: M11 States
- **Priority**: P0
- **Phase**: Phase 6
- **Estimate**: M (half day)
- **Description**: Implement polished, reassuring empty state views for Clients, Projects, Invoices, and Needs Follow-up ("You're all caught up!"), along with retryable error states.
- **Acceptance Criteria**:
  - Empty states include custom illustration, helpful copy, and clear action button.
  - Firestore query errors display friendly error card with "Retry" button.
- **Dependencies**: FT-007, FT-008, FT-009, FT-013
- **Notes**: See `docs/FRONTEND_SPEC.md` Section 3.

### FT-023: In-App Account Deletion & Data Purge
- **Module**: M1 Auth / M10 Settings
- **Priority**: P0
- **Phase**: Phase 6
- **Estimate**: M (half day)
- **Description**: Implement compliant in-app account deletion flow that requires password re-authentication, deletes all Firestore subcollections under `/users/{uid}`, cancels local notifications, and deletes the Firebase Auth user.
- **Acceptance Criteria**:
  - Double confirmation modal alerts user that data is lost and active store subscriptions must be cancelled in device settings.
  - Recursively purges clients, projects, invoices, and reminders.
  - Deletes Firebase Auth profile and returns user to Welcome screen.
- **Dependencies**: FT-004, FT-005, FT-017
- **Notes**: Apple App Store Review Guideline 5.1.1(v) compliance gate.

### FT-024: Demo / Seed Data Generator
- **Module**: M12 Demo Data
- **Priority**: P0
- **Phase**: Phase 6
- **Estimate**: M (half day)
- **Description**: Build a one-tap seed data service accessible in Settings to populate realistic sample data (3 clients, 4 projects, 5 invoices with mixed statuses, and reminder history) clearly flagged as sample data.
- **Acceptance Criteria**:
  - "Load Demo Data" populates realistic records with `isSampleData: true`.
  - "Clear Demo Data" purges all sample records in one tap without deleting real user data.
- **Dependencies**: FT-007, FT-008, FT-009, FT-014
- **Notes**: Essential for rapid hackathon judge evaluation and demo video capture.

### FT-025: Settings Screen & Business Profile Editor
- **Module**: M10 Settings
- **Priority**: P0
- **Phase**: Phase 6
- **Estimate**: M (half day)
- **Description**: Build Settings (`Screen 21`) and Business Profile (`Screen 22`) allowing users to edit company information, manage subscriptions, view legal links, and log out.
- **Acceptance Criteria**:
  - Edit Profile updates business name, email, phone, and default currency.
  - Displays subscription status (Free / Pro) with "Manage Subscription" deep link.
  - Functional links to Privacy Policy and Terms of Service.
- **Dependencies**: FT-006, FT-018
- **Notes**: Matches `visily-settings.png` and `visily-business-profile.png`.

### FT-026: Store Metadata, Privacy Policy & Submission Assets
- **Module**: M13 Release Readiness
- **Priority**: P0
- **Phase**: Phase 6
- **Estimate**: L (1 day)
- **Description**: Prepare production store listings, privacy policy, terms of service, app icons, splash branding, and verify data safety forms for App Store Connect and Google Play Console.
- **Acceptance Criteria**:
  - Public Privacy Policy hosted covering client contact handling and RevenueCat analytics.
  - 1024x1024 app icon and adaptive icons configured.
  - Store listings drafted (description, promotional text, keywords, screenshots).
  - Google Play Data Safety form and Apple Privacy Nutrition labels completed.
- **Dependencies**: FT-020, FT-023
- **Notes**: Critical P0 release gate.

### FT-027: Demonstration Video Production
- **Module**: M13 Release Readiness
- **Priority**: P0
- **Phase**: Phase 6
- **Estimate**: M (half day)
- **Description**: Record and edit a concise (2–3 minute) high-resolution demo video showcasing the complete end-to-end workflow: Client creation $\to$ Project $\to$ Invoice $\to$ PDF preview $\to$ Overdue status $\to$ Needs Follow-up $\to$ Reminder sharing $\to$ Pro Paywall upgrade.
- **Acceptance Criteria**:
  - Demonstrates full core workflow smoothly without pauses or errors.
  - Highlights the Payment Chaser and RevenueCat subscription purchase.
  - Video uploaded to YouTube/Vimeo as an accessible link.
- **Dependencies**: FT-024, FT-020
- **Notes**: Mandatory hackathon submission requirement.

---

## Phase 7: Post-P0 / Time-Permitting (P1 & P2)

### FT-028: Google Sign-In & Sign in with Apple
- **Module**: M1 Auth
- **Priority**: P1
- **Phase**: Phase 7
- **Estimate**: M (half day)
- **Description**: Add Google Sign-In on Android and Sign in with Apple on iOS.
- **Acceptance Criteria**: One-tap OAuth login linking to Firebase Auth and RevenueCat UID.
- **Dependencies**: FT-005

### FT-029: AI-Polished Reminders via Cloud Functions
- **Module**: M5 Payment Chaser
- **Priority**: P1
- **Phase**: Phase 7
- **Estimate**: L (1 day)
- **Description**: Deploy Firebase Cloud Function calling LLM API with server-side RevenueCat Pro verification and client sparkle action button.
- **Acceptance Criteria**: Pro users tap AI Polish to generate contextually customized reminder tone; falls back cleanly to static templates on error.
- **Dependencies**: FT-014, FT-018

### FT-030: "Did You Send It?" Post-Share Confirmation Sheet
- **Module**: M5 Payment Chaser
- **Priority**: P1
- **Phase**: Phase 7
- **Estimate**: S (<=2h)
- **Description**: Half-sheet prompting user upon returning from messaging apps to confirm message was dispatched before logging history.
- **Acceptance Criteria**: Displays *"Did you share the reminder?"* with "Yes, Log as Shared" and "Cancel" buttons.
- **Dependencies**: FT-014

### FT-031: Late-Payer Risk Card on Dashboard
- **Module**: M6 Dashboard
- **Priority**: P1
- **Phase**: Phase 7
- **Estimate**: S (<=2h)
- **Description**: Dashboard alert card highlighting clients classified as *Chronically Late* with pending upcoming invoices.
- **Acceptance Criteria**: Pro-only card surfacing high-risk debtors; Free tier displays locked card with Pro badge.
- **Dependencies**: FT-015, FT-012

### FT-032: Business Logo Upload for Invoices
- **Module**: M10 Settings / PDF
- **Priority**: P1
- **Phase**: Phase 7
- **Estimate**: M (half day)
- **Description**: Allow Pro users to upload company logo image to Firebase Storage and render on generated invoice PDFs.
- **Acceptance Criteria**: Image picker, size compression, Storage upload, and dynamic injection into PDF header.
- **Dependencies**: FT-011, FT-018

### FT-033: Free Trial Introductory Offer on Annual Plan
- **Module**: M8 Monetization
- **Priority**: P1
- **Phase**: Phase 7
- **Estimate**: S (<=2h)
- **Description**: Configure 7-day free trial on annual product in App Store Connect / Play Console and reflect in paywall UI.
- **Acceptance Criteria**: Displays *"7 Days Free, then $59.99/year"* dynamically fetched from store package.
- **Dependencies**: FT-020

### FT-034: Skeleton Loading Animations
- **Module**: M11 States
- **Priority**: P1
- **Phase**: Phase 7
- **Estimate**: S (<=2h)
- **Description**: Replace circular loading spinners with shimmer skeleton cards across Client, Project, and Invoice lists.
- **Acceptance Criteria**: Shimmering placeholder cards render during initial stream fetch.
- **Dependencies**: FT-022

### FT-035: Project Sub-Tasks & Progress Tracker
- **Module**: M3 Projects
- **Priority**: P2
- **Phase**: Phase 7
- **Estimate**: M (half day)
- **Description**: Sub-task checklist inside project detail view with visual progress bar.
- **Dependencies**: FT-008

### FT-036: Partial Invoice Payment Tracking
- **Module**: M4 Invoicing
- **Priority**: P2
- **Phase**: Phase 7
- **Estimate**: M (half day)
- **Description**: Allow recording partial milestone payments against an invoice with remaining balance calculations.
- **Dependencies**: FT-010

### FT-037: Accounting Data CSV Export
- **Module**: M10 Settings
- **Priority**: P2
- **Phase**: Phase 7
- **Estimate**: S (<=2h)
- **Description**: Export all clients, projects, and invoices into structured CSV files shared via native share sheet.
- **Dependencies**: FT-025

---

## Ticket Summary by Phase & Priority

| Phase | Phase Name | P0 Tickets | P1 Tickets | P2 Tickets | Total Tickets |
| :---: | :--- | :---: | :---: | :---: | :---: |
| **Phase 0** | Project Setup & Architecture | 4 | 0 | 0 | **4** |
| **Phase 1** | Core Product & Data Pipelines | 7 | 0 | 0 | **7** |
| **Phase 2** | Payment Chaser Engine | 3 | 0 | 0 | **3** |
| **Phase 3** | Dashboard | 1 | 0 | 0 | **1** |
| **Phase 4** | Local Notifications | 2 | 0 | 0 | **2** |
| **Phase 5** | Monetization & RevenueCat | 4 | 0 | 0 | **4** |
| **Phase 6** | Release Readiness & Store | 6 | 0 | 0 | **6** |
| **Phase 7** | Post-P0 / Time-Permitting | 0 | 7 | 3 | **10** |
| **TOTAL** | | **27** | **7** | **3** | **37** |

---

## Scope Protection & Cut Order

If time pressure threatens store submission deadlines, tickets must be cut strictly in the following sequence:
1. **Cut 1**: FT-037 (CSV Export) [P2]
2. **Cut 2**: FT-035 (Project Sub-tasks) [P2]
3. **Cut 3**: FT-036 (Partial Payments) [P2]
4. **Cut 4**: FT-034 (Skeleton Loaders) [P1]
5. **Cut 5**: FT-032 (Business Logo Upload) [P1]
6. **Cut 6**: FT-033 (Free Trial on Annual) [P1]
7. **Cut 7**: FT-031 (Late-Payer Risk Card) [P1]
8. **Cut 8**: FT-030 ("Did You Send It?" Sheet) [P1]
9. **Cut 9**: FT-029 (AI Reminders via Cloud Function) [P1]
10. **Cut 10**: FT-028 (Google / Apple Sign-In) [P1]

**NEVER CUT UNDER ANY CIRCUMSTANCES (P0 Core)**:
Clients, Projects, Invoices, PDF Generation & Share, Payment Chaser, Reminder Templates, Needs Follow-up, Native Share Sheet, Dashboard, Local Notifications, RevenueCat Integration, Feature Gating, Paywall, Restore Purchases, Account Deletion, Seed Demo Data, Privacy Policy & Store Compliance.

---

## Universal Definition of Done (DoD)

For any ticket to be marked as complete:
1. **Code Quality**: Code follows Flutter lints with 0 warnings or errors (`flutter analyze` passes).
2. **Platform Verification**: Tested and fully functional on target platforms (Android and iOS).
3. **Offline Integrity**: Offline reads and writes commit to Firestore persistence without throwing unhandled exceptions.
4. **Design Fidelity**: Visual layout, spacing, colors, and typography match `docs/FRONTEND_SPEC.md`.
5. **Privacy & Security**: Zero secrets in client code; zero PII emitted in console or crash logs.
6. **Documentation**: Status, percentage, and decisions updated in `docs/Progress.md`.
