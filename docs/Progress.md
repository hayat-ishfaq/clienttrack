# ClientTrack — Project Progress & Living Execution Tracker

---

## Update Rules (Mandatory Maintenance Protocol)
1. **Update Frequency**: Update this file immediately after completing every single task or ticket.
2. **Tick Checklist**: Mark the corresponding ticket item as checked (`- [x]`).
3. **Adjust Percentages**: Recompute overall progress based strictly on completed P0 tickets:
   $$\text{Overall Progress} = \left(\frac{\text{Completed P0 Tickets}}{27}\right) \times 100\%$$
4. **Log Key Decisions**: Record any architectural, design, or scope deviation in the **Decisions Log** with date and rationale.
5. **Track Blockers & Questions**: Move resolved questions out of Open Questions to Resolved, or add new ones.
6. **Preserve History**: Never delete past log entries or historical decisions.

---

## Project Header
- **Project Name**: ClientTrack
- **Repository**: `hayat-ishfaq/clienttrack`
- **Primary Target OS**: Android & iOS (Flutter 3.13+)
- **Monetization Engine**: RevenueCat SDK (`clienttrack_pro`)
- **Hackathon Submission Deadline**: **[VERIFY]** (RevenueCat Hackathon submission window)
- **Current Development Phase**: Phase 5 — Monetization & Phase 6 Store Readiness

---

## Overall Progress Summary

$$\mathbf{88.9\% \text{ Complete (P0 Scope: 24 / 27 Tickets Completed)}}$$

| Phase | Phase Name | Status | % Complete | Done / Total |
| :---: | :--- | :---: | :---: | :---: |
| **Phase 0** | Project Setup & Architecture | Completed | 100% | 4 / 4 (P0) |
| **Phase 1** | Core Product & Invoicing | Completed | 100% | 7 / 7 (P0) |
| **Phase 2** | Payment Chaser Engine | Completed | 100% | 3 / 3 (P0) |
| **Phase 3** | Dashboard Cockpit | Completed | 100% | 1 / 1 (P0) |
| **Phase 4** | Local Notifications | Completed | 100% | 2 / 2 (P0) |
| **Phase 5** | Monetization & RevenueCat | In Progress | 75.0% | 3 / 4 (P0) |
| **Phase 6** | Release Readiness & Store | In Progress | 66.7% | 4 / 6 (P0) |
| **Phase 7** | Post-P0 / Time-Permitting | Deferred | 0% | 0 / 10 (P1/P2) |
| **TOTAL** | | | **64.9%** | **24 / 37** |

---

## Active Status

- **Currently Working On**: FT-019 (Feature Gating Service & Limit Enforcement) and FT-023 (In-App Account Deletion & Data Purge) completed.
- **Next Up**: FT-021 (Sandbox Testing Matrix Execution), FT-026 (Store Metadata, Privacy Policy & Submission Assets), FT-027 (Demonstration Video Production).
- **Blockers**: None.

---

## Master Feature Ticket Checklist

### Phase 0: Project Setup & Architecture Setup
- [x] **FT-001**: Flutter Environment & Dependency Setup (P0)
- [x] **FT-002**: App Design System & Theme Engine (P0)
- [x] **FT-003**: Core Router & Shell Navigation Setup (P0)
- [x] **FT-004**: Firebase Initialization & Firestore Rules Setup (P0)

### Phase 1: Core Product & Data Pipelines
- [x] **FT-005**: Authentication & Session Management (P0)
- [x] **FT-006**: Onboarding Carousel & Profile Setup (P0)
- [x] **FT-007**: Client Management (CRUD & Directory) (P0)
- [x] **FT-008**: Project Management (CRUD & Client Linking) (P0)
- [x] **FT-009**: Invoice Builder & Line Items Engine (P0)
- [x] **FT-010**: Invoice Detail & Mark as Paid Action (P0)
- [x] **FT-011**: On-Device PDF Invoice Generation & Share (P0)

### Phase 2: Payment Chaser & Delivery Engine
- [x] **FT-012**: Deterministic Status Derivation & Payment History (P0)
- [x] **FT-013**: Needs Follow-up Screen (Chaser Cockpit) (P0)
- [x] **FT-014**: Reminder Template Engine & Native Dispatch (P0)

### Phase 3: Dashboard & Daily Cockpit
- [x] **FT-015**: Dashboard Financial Summaries & Action Cards (P0)

### Phase 4: Local Notifications
- [x] **FT-016**: Local Notification Service & Permission Orchestrator (P0)
- [x] **FT-017**: Invoice & Project Deadline Notification Scheduling (P0)

### Phase 5: RevenueCat Monetization & Paywall
- [x] **FT-018**: RevenueCat SDK Integration & User Identity (P0)
- [x] **FT-019**: Feature Gating Service & Limit Enforcement (P0)
- [x] **FT-020**: Paywall Modal & Subscription Purchase Flow (P0)
- [ ] **FT-021**: Sandbox Testing Matrix Execution (P0)

### Phase 6: Release Readiness & Store Compliance
- [x] **FT-022**: Empty, Loading, and Error States (P0)
- [x] **FT-023**: In-App Account Deletion & Data Purge (P0)
- [x] **FT-024**: Demo / Seed Data Generator (P0)
- [x] **FT-025**: Settings Screen & Business Profile Editor (P0)
- [ ] **FT-026**: Store Metadata, Privacy Policy & Submission Assets (P0)
- [ ] **FT-027**: Demonstration Video Production (P0)

### Phase 7: Post-P0 / Time-Permitting (P1 & P2)
- [ ] **FT-028**: Google Sign-In & Sign in with Apple (P1)
- [ ] **FT-029**: AI-Polished Reminders via Cloud Functions (P1)
- [ ] **FT-030**: "Did You Send It?" Post-Share Confirmation Sheet (P1)
- [ ] **FT-031**: Late-Payer Risk Card on Dashboard (P1)
- [ ] **FT-032**: Business Logo Upload for Invoices (P1)
- [ ] **FT-033**: Free Trial Introductory Offer on Annual Plan (P1)
- [ ] **FT-034**: Skeleton Loading Animations (P1)
- [ ] **FT-035**: Project Sub-Tasks & Progress Tracker (P2)
- [ ] **FT-036**: Partial Invoice Payment Tracking (P2)
- [ ] **FT-037**: Accounting Data CSV Export (P2)

---

## Release Readiness Checklist

- [ ] **Developer Accounts Active**: Apple Developer Program & Google Play Developer Console active.
- [ ] **Store Agreements**: Paid Applications Agreement and Tax/Banking forms signed.
- [ ] **RevenueCat Project Linked**: Apps and in-app subscription products registered in RevenueCat dashboard.
- [ ] **Subscription Products Configured**:
  - `clienttrack_pro_monthly` ($9.99/mo)
  - `clienttrack_pro_annual` ($59.99/yr)
- [ ] **Sandbox Purchase Verified**: Successful test purchase, restore, and cancellation cycles on Android and iOS.
- [ ] **In-App Account Deletion**: Fully operational with complete Firestore data purge.
- [ ] **Privacy Policy & Terms**: Publicly accessible web URLs prepared for store listing.
- [ ] **Store Assets Ready**: 1024x1024 App Store icon, Android adaptive icons, feature graphics, and high-res screenshots.
- [ ] **Demo Video Produced**: 2–3 minute video walking through ClientTrack's core loop, Payment Chaser, and Pro upgrade.
- [ ] **Google Play Testing Compliance**: Verified closed-testing tester requirements for Google Play.

---

## Consolidated Open Questions & Verification Registry (VERIFY)

| Item ID | Topic | Description | Status |
| :--- | :--- | :--- | :---: |
| **VERIFY-01** | Submission Window | Confirm opening and final closing deadlines for the RevenueCat hackathon. | Open |
| **VERIFY-02** | Google Play Testing | Check if Google Play developer account is a personal account created after Nov 13, 2023 (requires 20 opt-in testers for 14 continuous days). | Open |
| **VERIFY-03** | Merchant Payouts | Verify merchant account payout availability for the developer's country on Apple App Store and Google Play Console. | Open |
| **VERIFY-04** | Store App Name | Confirm name availability for "ClientTrack" on Apple App Store and Google Play Store. | Open |
| **VERIFY-05** | Firebase Blaze Plan | Verify if Firebase project is on the Blaze plan (needed if P1 Cloud Functions / Storage are deployed). | Open |
| **VERIFY-06** | Sign in with Apple | Confirm if Apple Review requires Sign in with Apple if Google Sign-In (P1) is enabled. | Open |
| **VERIFY-07** | Package Compatibility | Verify exact compatible versions of `purchases_flutter` and `flutter_local_notifications` for Flutter 3.13+. | Open |

---

## Key Decisions Log

| Date | Decision | Rationale | Impacted Areas |
| :--- | :--- | :--- | :--- |
| **2026-10-01** | Use Firestore offline persistence instead of Isar | Firestore handles cloud synchronization automatically with zero schema compilation hurdles, eliminating custom multi-database synchronization bugs. | Architecture, Data Layer |
| **2026-10-01** | Rely on native share sheet / deep links rather than direct messaging APIs | Third-party messaging APIs (Twilio, WhatsApp Business) have high costs, strict business approvals, and outbound spam flags. The native share sheet leverages the user's authentic identity. | Payment Chaser, Privacy |
| **2026-10-01** | Derive overdue status deterministically on client | Storing static "overdue" strings leads to stale data when background crons miss execution. Local clock comparison against midnight guarantees 100% accuracy. | Invoices, Chaser, Notifications |
| **2026-10-01** | Strict terminology: "Shared", never "Sent" | Because message delivery cannot be confirmed once handed off to external apps, UI and data schemas strictly record actions as "Shared". | UI Copy, Data Model |

---

## Target Project Milestones

- **Milestone 1**: Phase 0 Architecture, Theme, and Navigation Shell complete. (Done: 2026-10-01)
- **Milestone 2**: Phase 1 Core loop (Auth $\to$ Client $\to$ Project $\to$ Invoice $\to$ PDF) complete. (Done: 2026-10-21)
- **Milestone 3**: Phase 2 Payment Chaser ("Needs Follow-up", templates, sharing) complete. (Done: 2026-10-21)
- **Milestone 4**: Phase 3 Dashboard and Phase 4 Local Notifications complete. (Done: 2026-10-21)
- **Milestone 5**: Phase 5 RevenueCat Monetization & Paywall functional in sandbox.
- **Milestone 6**: Phase 6 Release prep, demo data, account deletion, and demo video completed.
- **Milestone 7**: Store submission finalized.

---

## Change Log

- **2026-10-01**: Comprehensive project documentation suite created (`docs/PRD.md`, `docs/TECHNICAL_ARCHITECTURE.md`, `docs/SECURITY_AND_ACCESS.md`, `docs/FRONTEND_SPEC.md`, `docs/FEATURE_TICKETS.md`, `docs/Progress.md`).
- **2026-10-01**: Phase 0 Foundation completed: verified dependencies added to `pubspec.yaml`, design system tokens and Inter typography implemented in `lib/app/theme/`, go_router shell route with 5-tab persistent bottom navigation registered, core UI components built, `firestore.rules` deployed, and smoke test passed with 0 analyzer issues.
- **2026-10-01**: Screen 01 Splash implemented in `lib/features/onboarding/presentation/splash_screen.dart` matching `visily-01-splash.png`. Features 3-second display of logo and tagline with smooth entrance animation before smoothly revealing the "Get Started" and "Log In" actions. Router and automated widget tests verified.
- **2026-10-01**: Screen 02 Onboarding implemented in `lib/features/onboarding/presentation/onboarding_screen.dart` matching `visily-02-onboarding.png` and incorporating the 3 new assets (`onboarding1.jpeg`, `onboarding2.jpeg`, `onboarding3.jpeg`). Features smooth carousel, animated indicator pills, Skip and Next/Get Started actions navigating to `/auth/signup`. Automated widget test passes.
- **2026-10-01**: FT-005 completed: Screen 03 Sign Up and Screen 04 Login built in `lib/features/auth/presentation/` adhering to `visily-03-sign-up.png` and `visily-04-login.png`. Features email and password validation, remember me toggle, custom Google branded button, legal disclaimer, Firebase Auth repository integration, and end-to-end automated widget test coverage. 0 analyzer warnings.
- **2026-10-01**: App icon configured via `flutter_launcher_icons` using `assets/app-logo.png`. Generated adaptive icons for Android and App Store-compliant alpha-removed icons for iOS. Recompiled debug APK and verified live on connected device V2043.
- **2026-10-01**: Updated app logo with the new high-resolution branding asset (`assets/app-logo.png`). Regenerated all launcher icons across Android and iOS densities. Updated global theme background (`AppColors.background`) and all screens (Splash, Onboarding, Sign Up, Login) to pure white (`#FFFFFF`). All tests passing, 0 analyzer issues.
- **2026-10-01**: Screen 05 Forgot Password implemented in `lib/features/auth/presentation/forgot_password_screen.dart` strictly matching `visily-05-forgot-password.png`. Features email validation, back navigation, Firebase Auth password reset integration, loading state, error banner, and animated confirmation success state. End-to-end widget tests and router integration verified with 0 analyzer issues.
- **2026-10-01**: Screen 06 Profile Setup implemented in `lib/features/onboarding/presentation/profile_setup_screen.dart` matching `visily-06-profile-setup.png`. Features dedicated top banner illustration (`assets/profile_setup_banner.jpg`), "Your Name" validation, optional "Business Name", "Preferred Currency" selector (USD, EUR, GBP, CAD, AUD, INR, AED, SGD, PKR), informational account settings notice, "Complete Setup" action with Firestore profile sync, "Skip for now" fallback, and step indicator footer. Full automated test suite passes with 0 analyzer issues.
- **2026-10-21**: Shared Domain Entities & Firestore Repositories: Extracted and formalized models with strongly-typed `fromMap`/`toMap`/`fromFirestore` converters (`ClientModel`, `ProjectModel`, `InvoiceModel`, `LineItemModel`, `BusinessProfileModel`, `ReminderLogModel`). Replaced local mock data with real-time Firestore stream providers (`users/{uid}/clients`, `projects`, `invoices`, `reminder_logs`, `profile`).
- **2026-10-21**: Global Riverpod State Providers & Metric Aggregators: Built comprehensive live reactive state engine in `lib/shared/providers/app_state_providers.dart`: `dashboardMetricsProvider`, `clientPaymentSummaryProvider`, `projectFinancialSummaryProvider`, `needsFollowUpSummaryProvider`, and `invoicesSummaryProvider`. Wired all list screens (`ClientListScreen`, `ProjectListScreen`, `InvoicesScreen`), detail views (`ClientDetailScreen`, `ProjectDetailScreen`, `InvoiceDetailScreen`), and `DashboardScreen` to live streams with loading skeletons, fallback seed data, and deterministic overdue computations. Analyzer verified with 0 issues.
- **2026-10-21**: Live Native Integrations Completed:
  1. `url_launcher`: Direct WhatsApp deep-linking (`whatsapp://send` & `https://wa.me/`), SMS with platform query separator (`&` on iOS vs `?` on others), and Email (`mailto:`) with automatic fallback to native share sheet. Configured `AndroidManifest.xml` intent queries and `Info.plist` `LSApplicationQueriesSchemes`.
  2. RevenueCat (`purchases_flutter`): Created `RevenueCatService` with entitlement `clienttrack_pro`. Wired `PaywallScreen` with dynamic offerings retrieval, reactive pricing, purchase execution, restore purchases flow, and `isProProvider` subscription checking.
  3. Real PDF Byte Generation: Implemented `PdfInvoiceService` with `pdf` and `printing` packages. Connected `PdfPreviewScreen` and `InvoiceDetailScreen` to compile high-resolution PDF documents from Firestore invoice and business profile data with direct native sharing and printing. 0 analyzer issues.
- **2026-10-21**: Phase 4 Local Notifications Implemented & Master Progress Audit:
  1. Implemented `NotificationService` in `lib/core/services/notification_service.dart` (FT-016 & FT-017) with `flutter_local_notifications` and `timezone`.
  2. Configured native channels (`clienttrack_invoices`, `clienttrack_projects`, `clienttrack_general`), exact alarm permissions in `AndroidManifest.xml`, and iOS Darwin notification setup.
  3. Built educational pre-permission explainer bottom sheet and permission orchestrator.
  4. Built notification scheduling engine queuing alerts for upcoming invoice due dates (Due - 2 days at 9 AM, Due Day at 9 AM, Due + 1 day overdue alert at 10 AM) and project deadlines, with pruning engine maintaining $\le 40$ active alerts (iOS 64 limit).
  5. Wired notification service to `create_invoice_screen.dart`, `invoice_detail_screen.dart` (cancel/schedule on paid toggle), `new_project_screen.dart`, and added notification triggers/test alerts to `settings_screen.dart`.
  6. Synchronized `docs/Progress.md` living checklist: Phase 1 (100%), Phase 2 (100%), Phase 3 (100%), and Phase 4 (100%) completed; overall P0 scope advanced to 81.5% (22/27 tickets). 0 analyzer issues verified.
- **2026-10-30**: FT-019 (Feature Gating Service & Limit Enforcement) & FT-023 (Compliant Account Deletion & Data Purge) Completed:
  1. Created `FeatureGateService` in `lib/core/services/feature_gate_service.dart` enforcing free-tier caps: max 3 clients, max 5 invoices, and max 3 lifetime reminder shares, with instantaneous Pro bypass.
  2. Wired feature gate checks into `add_edit_client_screen.dart` (blocking on 4th client attempt), `create_invoice_screen.dart` (blocking on 6th invoice attempt), and `send_reminder_screen.dart` (blocking on 4th lifetime reminder share across WhatsApp, SMS, Email, and Native Share sheet), automatically surfacing contextual upgrade snackbars and routing to `/paywall`.
  3. Implemented full Apple App Store Guideline 5.1.1(v) compliant account deletion flow in `settings_screen.dart`: two-step irreversible deletion alert, password re-authentication dialog, recursive batch deletion of all user subcollections (`clients`, `projects`, `invoices`, `reminder_logs`, `profile`) and the root user doc, cancellation of all scheduled local notifications via `NotificationService.cancelAllNotifications()`, Firebase Auth account deletion, and redirect to the login screen.
  4. Updated master execution checklist: Overall P0 completion advanced to 88.9% (24 / 27 tickets).



