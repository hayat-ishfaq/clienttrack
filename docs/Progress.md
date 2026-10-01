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
- **Current Development Phase**: Phase 0 — Project Initialization

---

## Overall Progress Summary

$$\mathbf{18.5\% \text{ Complete (P0 Scope: 5 / 27 Tickets Completed)}}$$

| Phase | Phase Name | Status | % Complete | Done / Total |
| :---: | :--- | :---: | :---: | :---: |
| **Phase 0** | Project Setup & Architecture | Completed | 100% | 4 / 4 (P0) |
| **Phase 1** | Core Product & Invoicing | In Progress | 14.3% | 1 / 7 (P0) |
| **Phase 2** | Payment Chaser Engine | Pending | 0% | 0 / 3 (P0) |
| **Phase 3** | Dashboard Cockpit | Pending | 0% | 0 / 1 (P0) |
| **Phase 4** | Local Notifications | Pending | 0% | 0 / 2 (P0) |
| **Phase 5** | Monetization & RevenueCat | Pending | 0% | 0 / 4 (P0) |
| **Phase 6** | Release Readiness & Store | Pending | 0% | 0 / 6 (P0) |
| **Phase 7** | Post-P0 / Time-Permitting | Deferred | 0% | 0 / 10 (P1/P2) |
| **TOTAL** | | | **13.5%** | **5 / 37** |

---

## Active Status

- **Currently Working On**: FT-005 (Authentication & Session Management) completed. Ready to proceed with FT-006 (Profile Setup & Business Onboarding).
- **Next Up**: FT-006 (Profile Setup & Business Onboarding), FT-007 (Client Management CRUD).
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
- [ ] **FT-006**: Onboarding Carousel & Profile Setup (P0)
- [ ] **FT-007**: Client Management (CRUD & Directory) (P0)
- [ ] **FT-008**: Project Management (CRUD & Client Linking) (P0)
- [ ] **FT-009**: Invoice Builder & Line Items Engine (P0)
- [ ] **FT-010**: Invoice Detail & Mark as Paid Action (P0)
- [ ] **FT-011**: On-Device PDF Invoice Generation & Share (P0)

### Phase 2: Payment Chaser & Delivery Engine
- [ ] **FT-012**: Deterministic Status Derivation & Payment History (P0)
- [ ] **FT-013**: Needs Follow-up Screen (Chaser Cockpit) (P0)
- [ ] **FT-014**: Reminder Template Engine & Native Dispatch (P0)

### Phase 3: Dashboard & Daily Cockpit
- [ ] **FT-015**: Dashboard Financial Summaries & Action Cards (P0)

### Phase 4: Local Notifications
- [ ] **FT-016**: Local Notification Service & Permission Orchestrator (P0)
- [ ] **FT-017**: Invoice & Project Deadline Notification Scheduling (P0)

### Phase 5: RevenueCat Monetization & Paywall
- [ ] **FT-018**: RevenueCat SDK Integration & User Identity (P0)
- [ ] **FT-019**: Feature Gating Service & Limit Enforcement (P0)
- [ ] **FT-020**: Paywall Modal & Subscription Purchase Flow (P0)
- [ ] **FT-021**: Sandbox Testing Matrix Execution (P0)

### Phase 6: Release Readiness & Store Compliance
- [ ] **FT-022**: Empty, Loading, and Error States (P0)
- [ ] **FT-023**: In-App Account Deletion & Data Purge (P0)
- [ ] **FT-024**: Demo / Seed Data Generator (P0)
- [ ] **FT-025**: Settings Screen & Business Profile Editor (P0)
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
- **Milestone 2**: Phase 1 Core loop (Auth $\to$ Client $\to$ Project $\to$ Invoice $\to$ PDF) complete.
- **Milestone 3**: Phase 2 Payment Chaser ("Needs Follow-up", templates, sharing) complete.
- **Milestone 4**: Phase 3 Dashboard and Phase 4 Local Notifications complete.
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
- **2026-10-01**: Fixed launcher icon clipping and sizing issue on Android (adaptive icons) and iOS. Created `assets/app_launcher_icon.png` with standard safe-zone padding (~45% glyph size on 1024x1024 canvas), preventing circular/squircle mask clipping on OEM launchers (Vivo, Xiaomi, Samsung, Pixel). Regenerated all launcher icons with 0 analyzer issues.
