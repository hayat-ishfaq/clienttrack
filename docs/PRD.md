# ClientTrack — Product Requirements Document (PRD)

---

## 1. Overview and Vision

**ClientTrack** is an intuitive, privacy-first mobile application built with Flutter for iOS and Android, dedicated to freelancers, independent contractors, and solo business owners. While traditional invoicing tools focus heavily on complex double-entry accounting or passive ledger storage, ClientTrack focuses on the critical cashflow moment: **getting paid on time without the anxiety of manual chasing**.

ClientTrack streamlines the entire engagement lifecycle into a tight, frictionless loop:
$$\text{Client} \longrightarrow \text{Project} \longrightarrow \text{Invoice} \longrightarrow \text{Due Date} \longrightarrow \text{Overdue} \longrightarrow \text{Follow-up} \longrightarrow \text{Paid}$$

### Vision Statement
Empower solo operators to manage client deliverables and professional invoices in minutes, while turning overdue invoice recovery from an awkward confrontation into a 3-tap native sharing workflow.

### Core Value Proposition & Differentiators
1. **The Payment Chaser**: A dedicated "Needs Follow-up" operational cockpit with escalating pre-drafted templates (Friendly, Professional, Final) shared natively via the user’s personal messaging channels (WhatsApp, SMS, Email).
2. **Deterministic Payment History**: An automated, client-side score indicating historical client payment habits (Average Days Late, On-Time %, and factual categorization: *Reliable*, *Sometimes Late*, *Chronically Late*).
3. **Frictionless Native Delivery**: Operates through the native OS share sheet rather than impersonal automated server emails, dramatically increasing debtor response rates.

---

## 2. Problem Statement

Freelancers and micro-agencies lose thousands of dollars each year to delayed payments, scope creep, and unbilled deliverables:
- **Awkward Confrontations**: Solo business owners fear damaging client relationships when chasing overdue invoices, often procrastinating follow-up messages for weeks.
- **Fragmented Workflows**: Client contacts live in phone address books, project deliverables live in notes apps, and invoices live across spreadsheets or heavyweight desktop accounting suites (e.g., QuickBooks, FreshBooks).
- **Impersonal Automated Invoicing**: Invoices sent via no-reply email gateways frequently land in spam folders or get deprioritized by clients. Freelancers get much faster results sending personal WhatsApp or SMS notes with invoices attached.
- **Hidden Bad Debt**: Freelancers frequently take on new work from chronic late-payers without objective visibility into that client's historical payment record.

---

## 3. Target Users and Personas

### Primary Audience
Freelancers, creative professionals (designers, videographers, copywriters), independent software consultants, tradespeople, and solo service providers who bill on fixed-rate or hourly projects and require rapid invoicing and cash collection.

---

### Persona 1: Elena Vance — Freelance UX/UI Designer
- **Demographics**: 29, Brooklyn, NY. Solo consultant for 4 years.
- **Tech Stack & Habits**: iPhone 15 Pro, WhatsApp Business, Gmail, Slack, Figma.
- **Workflow**: Manages 4–6 concurrent client projects. Invoices bi-weekly or upon milestone completion.
- **Pain Points**:
  - Hates drafting payment reminder emails; spends 20 minutes agonizing over phrasing so she doesn't sound aggressive.
  - Loses track of whether an invoice was due yesterday or last week until checking her bank account at month-end.
  - Doesn't want complex desktop accounting software; wants to invoice and follow up directly from her phone between client meetings.
- **Elena’s Goals**:
  - Know immediately upon opening the app: *"Who owes me money right now, and how overdue is it?"*
  - Tap once to pick a polite reminder, personalize it, and shoot it to the client via WhatsApp with a clean PDF attached.

---

### Persona 2: Marcus Brody — Independent Commercial HVAC Technician
- **Demographics**: 42, Austin, TX. Operates a solo residential and light commercial repair business.
- **Tech Stack & Habits**: Samsung Galaxy S23, SMS, Phone calls, Paper receipts.
- **Workflow**: Completes 2–3 service calls daily. Invoices customers on-site or in his truck immediately after a job.
- **Pain Points**:
  - Customers promise to "mail a check" or "Zelle it tonight", but 30 days later the balance remains unpaid.
  - Forgets which property management company pays reliably within 10 days and which takes 45 days.
  - Heavy desktop accounting suites require complex chart-of-accounts setups that are overkill for his trade.
- **Marcus’s Goals**:
  - Generate a professional PDF invoice from his truck in under 60 seconds and hand-off via SMS.
  - When an invoice turns red (overdue), tap a button to send an escalating "Professional" or "Final" notice without drafting a single word.
  - Check the client's past payment history before accepting new emergency weekend calls.

---

## 4. Goals and Non-Goals

### Goals
- **G1**: Ship a cross-platform (iOS and Android) Flutter app that installs, runs, and functions reliably.
- **G2**: Implement the full core flow: Client $\to$ Project $\to$ Invoice $\to$ PDF Generation $\to$ Overdue Status $\to$ Payment Chaser Share.
- **G3**: Integrate RevenueCat SDK (`purchases_flutter`) with an active entitlement (`clienttrack_pro`) supporting Monthly and Annual subscription packages.
- **G4**: Ensure the free tier is generous enough for a hackathon judge or new user to experience the complete core loop without hitting immediate walls, while strictly gating volume and polish.
- **G5**: Enforce robust privacy and compliance: zero server-side message interception, complete in-app account and data deletion, and strict per-user Firestore isolation.

### Non-Goals (Strictly Out of Scope for v1)
- **NG1 — No Payment Gateway / Processing**: No Stripe, PayPal, or card terminal integrations. Invoices are marked paid manually.
- **NG2 — No Client Portal**: Clients do not log in to a web interface to view invoices.
- **NG3 — No Automated Server-Side Dispatch**: The app does not send emails or SMS directly via Twilio or SendGrid. Everything passes through the user's native share sheet.
- **NG4 — No Time Tracking**: No active timers, stopwatches, or GPS tracking.
- **NG5 — No Multi-User / Team Support**: Single-tenant freelancer architecture only.
- **NG6 — No Multi-Currency**: Each user profile operates on one global selected currency symbol for all balances.
- **NG7 — No Recurring Invoices**: Recurring subscriptions or automated repeating invoices are deferred to v2.

---

## 5. Success Metrics

### 5.1 Hackathon Qualification Checklist
- [ ] App builds and runs reliably on iOS and Android devices/simulators.
- [ ] App utilizes RevenueCat SDK for at least one in-app purchase flow (`clienttrack_pro`).
- [ ] In-app offerings, paywall, purchase, restore, and entitlement verification functional in sandbox.
- [ ] First public release submitted to Apple App Store, Google Play Store, or Samsung Galaxy Store during the hackathon submission window.
- [ ] App is fully accessible and functional in the United States.
- [ ] All third-party services and APIs properly authorized and documented.

### 5.2 Product Metrics
- **Activation Rate**: $\ge 70\%$ of signed-up users create their first Client and Invoice within the first session.
- **Core Loop Completion**: $\ge 50\%$ of active users execute at least one Payment Chaser "Share" action.
- **Free-to-Pro Paywall Conversion**: $\ge 5\%$ of users encountering a contextual paywall trigger initiate a subscription.
- **Retention (D14)**: $\ge 35\%$ weekly active users returning to track invoice due dates and record payments.

---

## 6. User Stories

### M1: Auth & Onboarding
- **US-001**: As a new user, I want to register using my email and password so my client data is safely synced to the cloud.
  - *Acceptance Criteria*: Email validation, password minimum 8 characters, immediate creation of Firestore user record and RevenueCat user login via Firebase UID.
- **US-002**: As an existing user, I want to log in or reset my forgotten password so I can regain access to my records.
  - *Acceptance Criteria*: Firebase Auth password reset email dispatched, clear user feedback on success/failure.
- **US-003**: As a first-time user, I want a quick, skippable profile setup (name, business name, currency) so that my generated invoices look professional immediately.
  - *Acceptance Criteria*: Pre-populates business name and currency default (USD); can be updated later in Settings.
- **US-004**: As a user, I want to delete my account and all associated cloud records from within the app so that my privacy rights are respected.
  - *Acceptance Criteria*: Explicit confirmation modal; deletes all clients, projects, invoices, and reminders under `/users/{uid}`, deletes Firebase Auth profile, notes that active store subscriptions must be cancelled in OS store settings.

### M2: Clients & Payment History
- **US-005**: As a freelancer, I want to create, view, update, and delete client contacts so I have a single address book of billable parties.
  - *Acceptance Criteria*: Name (required), email, phone, company, notes. Free tier enforces maximum 3 clients.
- **US-006**: As a freelancer, I want to see a client’s computed Payment History on their detail screen so I can objectively assess their creditworthiness.
  - *Acceptance Criteria*: Displays total billed, total paid, outstanding balance, Average Days Late, On-Time %, and factual badge (*Reliable* if avg $\le 0$ days, *Sometimes Late* if avg $1\text{--}14$ days, *Chronically Late* if avg $>14$ days). Free tier shows basic metrics; Pro unlocks full breakdown.

### M3: Projects
- **US-007**: As a freelancer, I want to organize deliverables under projects associated with a client so I can track deadlines and rates.
  - *Acceptance Criteria*: Title (required), client selector, description, deadline, status (*Not Started*, *In Progress*, *Completed*), rate, and rate type (*Fixed* or *Hourly*).
- **US-008**: As a freelancer, I want to tap "Create Invoice" directly from a project screen to automatically pre-populate client and rate information onto a new invoice.
  - *Acceptance Criteria*: Direct routing to invoice editor with project and client pre-selected.

### M4: Invoicing & PDF
- **US-009**: As a freelancer, I want to build an invoice with multiple line items, tax notes, issue date, and due date so that my client receives an itemized breakdown.
  - *Acceptance Criteria*: Auto-incrementing invoice number (e.g., INV-0001), line items with description, quantity, rate, and calculated amounts. Free tier enforces maximum 5 invoices.
- **US-010**: As a freelancer, I want to preview and share a clean, high-resolution PDF of the invoice via native sharing.
  - *Acceptance Criteria*: Direct on-device PDF generation. Free tier renders discreet "Made with ClientTrack" footer; Pro tier renders clean footer. Opens OS share sheet.
- **US-011**: As a freelancer, I want to mark an invoice as Paid in full so my financial dashboard and client payment history update immediately.
  - *Acceptance Criteria*: Sets `status` to Paid and records `paidAt` timestamp. Reschedules/cancels upcoming reminder notifications.

### M5: Payment Chaser
- **US-012**: As a freelancer, I want a "Needs Follow-up" screen listing all invoices that are due today or overdue so I know who needs chasing.
  - *Acceptance Criteria*: Lists invoice number, client name, amount, days overdue, and timestamp of last shared reminder.
- **US-013**: As a freelancer, I want three pre-written, escalating reminder templates (Friendly, Professional, Final) that automatically fill in client details.
  - *Acceptance Criteria*: Variables `{client_name}`, `{invoice_number}`, `{amount}`, `{due_date}` auto-populate. User can edit the text before sharing.
- **US-014**: As a freelancer, I want to tap to share the reminder message via WhatsApp, SMS, Email, or standard share sheet, and have the app record this as "Shared".
  - *Acceptance Criteria*: Deep-links to chosen channel; upon return, records reminder in history with status "Shared" and current timestamp. Free tier allows 3 lifetime reminder shares.

### M6: Dashboard
- **US-015**: As a freelancer, I want an executive summary on app launch answering *"What do I need to do today?"*
  - *Acceptance Criteria*: Outstanding balance, Earned this month, Overdue total; Needs Follow-up card; active project count with 3–5 nearest deadlines; quick access to recent invoices.

### M7: Local Notifications
- **US-016**: As a freelancer, I want local push notifications when an invoice is due soon, due today, or overdue so I never forget to follow up.
  - *Acceptance Criteria*: Schedules notifications on device without server push. Automatically reschedules or cancels when an invoice is edited or marked paid. Respects iOS 64 pending notification cap.

### M8 & M9: Monetization & Paywall
- **US-017**: As a user encountering a free limit (4th client, 6th invoice, 4th reminder share), I want to see a clear, high-converting paywall explaining the benefits of ClientTrack Pro.
  - *Acceptance Criteria*: Contextual trigger modal displaying RevenueCat monthly ($9.99) and annual ($59.99) offerings loaded dynamically from store, features list, "Restore Purchases", Terms, and Privacy links.
- **US-018**: As a subscriber, I want my Pro entitlement restored seamlessly if I switch devices or reinstall the app.
  - *Acceptance Criteria*: One-tap "Restore Purchases" querying RevenueCat SDK and updating the local entitlement state.

### M10: Settings & Seed Data
- **US-019**: As a user or hackathon reviewer, I want to load realistic sample demo data so I can immediately test and evaluate the app's full capabilities.
  - *Acceptance Criteria*: One-tap "Load Demo Data" creating 3 clients, 4 projects, 5 invoices (various statuses), and reminder history, clearly labeled with `isSampleData: true`. One-tap "Clear Demo Data" button.

---

## 7. Functional Requirements

| ID | Module | Feature / Requirement | Priority | Free Limit | Pro Capability |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **FR-001** | M1 Auth | Email/Password Sign-up & Login | P0 | Included | Included |
| **FR-002** | M1 Auth | Password Reset flow via Firebase Auth | P0 | Included | Included |
| **FR-003** | M1 Auth | First-run onboarding walkthrough & Profile Setup | P0 | Included | Included |
| **FR-004** | M1 Auth | Account deletion with recursive Firestore cleanup | P0 | Included | Included |
| **FR-005** | M1 Auth | Google Sign-In (Android) / Sign in with Apple (iOS) | P1 | Included | Included |
| **FR-006** | M2 Clients | Add/Edit/Delete Client profile | P0 | Max 3 clients | Unlimited |
| **FR-007** | M2 Clients | Client detail with project/invoice breakdown | P0 | Included | Included |
| **FR-008** | M2 Clients | Client Payment History metrics & reliability rating | P0 | Basic metrics | Full analytics + risk card |
| **FR-009** | M3 Projects | Project CRUD with fixed/hourly rate & deadline | P0 | Unlimited | Unlimited |
| **FR-010** | M3 Projects | Filter projects by status & upcoming deadline alert | P0 | Included | Included |
| **FR-011** | M3 Projects | Sub-task checklist per project | P2 | Out of v1 | Out of v1 |
| **FR-012** | M4 Invoices | Create Invoice linked to project with auto-increment ID | P0 | Max 5 invoices | Unlimited |
| **FR-013** | M4 Invoices | Line items editor (rate, quantity, amount) | P0 | Included | Included |
| **FR-014** | M4 Invoices | Automatic overdue derivation from due date | P0 | Included | Included |
| **FR-015** | M4 Invoices | Mark as Paid (full) & update cashflow metrics | P0 | Included | Included |
| **FR-016** | M4 Invoices | On-device PDF generation, preview & native share | P0 | Watermark footer | Clean PDF |
| **FR-017** | M4 Invoices | Partial invoice payments | P2 | Out of v1 | Out of v1 |
| **FR-018** | M5 Chaser | Needs Follow-up cockpit listing overdue/due-today | P0 | Included | Included |
| **FR-019** | M5 Chaser | 3 Escalating templates (Friendly, Professional, Final) | P0 | Included | Included |
| **FR-020** | M5 Chaser | One-tap native share (WhatsApp, SMS, Email, Share Sheet) | P0 | 3 shares lifetime | Unlimited shares |
| **FR-021** | M5 Chaser | Reminder history logged as "Shared" (invoice, date, channel) | P0 | Last 3 logged | Full history |
| **FR-022** | M5 Chaser | "Did you send it?" user confirmation prompt | P1 | Included | Included |
| **FR-023** | M5 Chaser | AI-Polished reminder tone generator (Firebase Cloud Function) | P1 | Locked | Pro only |
| **FR-024** | M6 Dashboard | Financial cards: Outstanding, Earned this month, Overdue | P0 | Included | Included |
| **FR-025** | M6 Dashboard | Needs Follow-up action card & upcoming deadlines list | P0 | Included | Included |
| **FR-026** | M6 Dashboard | Late-payer risk indicator card | P1 | Locked | Pro only |
| **FR-027** | M7 Notifications | Local notifications for due-soon, due-today, overdue | P0 | Max 64 alerts | Max 64 alerts |
| **FR-028** | M8 Monetization | RevenueCat SDK integration (`clienttrack_pro`) | P0 | Included | Included |
| **FR-029** | M8 Monetization | Dynamic monthly/annual pricing fetched from Store | P0 | Included | Included |
| **FR-030** | M8 Monetization | Restore purchases with immediate entitlement refresh | P0 | Included | Included |
| **FR-031** | M8 Monetization | Free trial on Annual subscription | P1 | — | Pro only |
| **FR-032** | M9 Paywall | Dedicated Paywall screen & contextual limit sheets | P0 | Included | Included |
| **FR-033** | M10 Settings | Profile management, currency select, terms/privacy | P0 | Included | Included |
| **FR-034** | M10 Settings | Business logo upload for invoice PDFs | P1 | Locked | Pro only |
| **FR-035** | M10 Settings | CSV data export | P2 | Out of v1 | Out of v1 |
| **FR-036** | M11 States | Polished empty states, retryable error handling | P0 | Included | Included |
| **FR-037** | M11 States | Skeleton loading widgets | P1 | Included | Included |
| **FR-038** | M12 Demo Data | Realistic seed data loader & one-tap purge | P0 | Included | Included |
| **FR-039** | M13 Release | Store metadata, privacy policy, terms, data safety | P0 | Included | Included |

---

## 8. Non-Functional Requirements

### 8.1 Performance
- **App Launch Time**: Cold launch to interactive dashboard $\le 2.0$ seconds on modern mid-range devices.
- **PDF Generation**: On-device PDF compile and preview render $\le 1.2$ seconds for standard 1–5 item invoices.
- **Scroll Performance**: Smooth 60 fps (120 fps on high refresh rate displays) throughout list views.

### 8.2 Offline Behavior & Data Persistence
- **Cloud Firestore Persistence**: Firestore offline cache enabled by default. Users can create, view, and edit clients, projects, and invoices completely offline.
- **Background Synchronization**: Local writes commit immediately to disk cache and synchronize transparently with Firestore servers upon reconnection.
- **Local Notification Autonomy**: All notification scheduling operates directly on the device hardware clock via `flutter_local_notifications`; no network required.

### 8.3 Reliability
- **Crash-Free Sessions**: $\ge 99.5\%$ crash-free user sessions.
- **Zero Data Loss**: Form inputs validate before state mutation; optimistic UI updates backbacked by transactional Firestore batches.

### 8.4 Accessibility
- **Touch Target Sizes**: Minimum interactive touch targets of $44 \times 44$ pt (iOS) / $48 \times 48$ dp (Android).
- **Contrast Ratios**: Body text meets WCAG AA standards (minimum 4.5:1 against surfaces).
- **Screen Reader Support**: Semantic labels applied across buttons, custom icon actions, and status chips.

### 8.5 Privacy & Security
- **No Client PII Leaks**: Client contact records are stored strictly in the user's isolated Firestore subcollection.
- **No Message Snooping**: Reminder dispatch is handed off to third-party native apps via system intent; no message content or recipient communication logs are monitored or retained.
- **Zero Secrets in Client**: RevenueCat public keys only; zero Firebase Admin keys, OpenAI/Anthropic API keys, or database credentials embedded in the client binary.

### 8.6 Platform Compatibility
- **iOS**: iOS 15.0+ on iPhone.
- **Android**: Android 8.0 (API Level 26)+ on phones and tablets.

### 8.7 Localization & Currency
- English (US) as primary v1 locale.
- Global single-currency configuration selected in profile (USD `$`, EUR `€`, GBP `£`, CAD `$`, AUD `$`, etc.). Numeric formatting adheres to locale conventions via the `intl` package.

---

## 9. Monetization Strategy

### 9.1 Entitlement & Tier Breakdown

ClientTrack adopts a **Freemium** model powered by RevenueCat. The single entitlement ID is **`clienttrack_pro`**.

| Feature / Limit | Free Tier | ClientTrack Pro |
| :--- | :--- | :--- |
| **Client Profiles** | Maximum 3 clients | **Unlimited** |
| **Invoices** | Maximum 5 invoices | **Unlimited** |
| **Payment Chaser Shares** | 3 lifetime shares | **Unlimited** |
| **Reminder History** | Last 3 shared logged | **Full chronological log** |
| **Invoice PDF Branding** | "Made with ClientTrack" watermark | **Clean, professional invoice** |
| **Payment History Analytics** | Basic stats (avg days late) | **Detailed metrics + Risk Card** |
| **AI-Polished Reminders** | Locked | **Included (P1)** |
| **Business Logo on PDF** | Locked | **Included (P1)** |
| **CSV Export** | Locked | **Included (P2)** |

### 9.2 Pricing & Offerings
- **Offering ID**: `default`
- **Monthly Package (`$rc_monthly`)**: $9.99 / month (store localized).
- **Annual Package (`$rc_annual`)**: $59.99 / year (~$4.99/mo, 50% savings; store localized).
- *Strict Rule*: Prices are never hardcoded in the Flutter codebase. All price strings, currency codes, and introductory trial terms are pulled dynamically from the RevenueCat `Package` object.

### 9.3 Contextual Paywall Triggers
Instead of blocking users prematurely, the paywall modal (`Screen 20`) is triggered contextually when value has been demonstrated:
1. **Client Limit Hit**: User attempts to create a 4th client $\to$ *"You've reached your 3 client limit. Unlock unlimited clients with Pro."*
2. **Invoice Limit Hit**: User attempts to create a 6th invoice $\to$ *"Create unlimited invoices and keep your cashflow moving."*
3. **Chaser Limit Hit**: User attempts a 4th reminder share $\to$ *"You’ve recovered payments with 3 free reminders! Unlock unlimited payment chasing."*
4. **Watermark-Free PDF**: User taps toggle to remove "Made with ClientTrack" watermark from invoice settings.
5. **AI Polish Tap**: User taps the sparkle icon in Reminder Composer to generate an AI reminder.
6. **Risk Card Tap**: User taps the locked Late-Payer Risk indicator on the Dashboard.

---

## 10. Scope & Release Plan

### In Scope for v1 (P0 Must Ship)
- Full Authentication & profile setup (Firebase Auth).
- Client management (CRUD, search, basic payment history).
- Project management (CRUD, status, rates, deadlines).
- Invoicing (CRUD, line items, auto-numbering, due dates, manual full payment).
- On-device PDF generation, preview, and sharing.
- Payment Chaser ("Needs Follow-up", 3 templates, native share sheet, history logged as "Shared").
- Dashboard (financial cards, action alerts, recent invoices).
- Local Notifications (due soon, due today, overdue).
- RevenueCat integration (`clienttrack_pro`, monthly/annual packages, restore, paywall).
- Account deletion (in-app and recursive data purge).
- Realistic seed demo data generator.

### In Scope for v1 (P1 Time-Permitting)
- Google Sign-In on Android.
- Sign in with Apple on iOS (mandatory if social auth offered).
- AI-polished reminder generator via Firebase Cloud Function.
- "Did you send it?" confirmation dialog after native share sheet handoff.
- Late-payer risk card on Dashboard.
- Business logo upload for PDFs.
- Free trial introductory offer on Annual subscription.
- Skeleton loading animations.

### Out of Scope (P2 / Deferred to v2)
- Sub-task project checklists.
- Partial invoice payment recording.
- CSV / Excel accounting export.
- Server-side automated email/SMS dispatch.
- Multi-currency conversion.
- Multiple organization/team access.
- Payment processor integrations (Stripe, Square, PayPal).

---

## 11. Release Criteria & Hackathon Compliance

### 11.1 Technical Gates
- [ ] 0 critical security vulnerabilities or exposed API credentials.
- [ ] Passes `flutter analyze` with 0 warnings or errors under Flutter lints.
- [ ] All P0 User Stories verified on physical iOS and Android hardware.
- [ ] Sandbox end-to-end purchase flow verified: Free $\to$ Monthly purchase $\to$ Pro unlocked $\to$ Restore purchase verified.

### 11.2 App Store & Google Play Compliance
- [ ] In-app account deletion fully compliant with Apple App Store Guideline 5.1.1(v) and Google Play Policy.
- [ ] Privacy Policy and Terms of Service hosted publicly, clearly disclosing handling of user contact records and device analytics.
- [ ] Apple App Store Review Guideline 3.1.1 (In-App Purchase) and RevenueCat configuration complete with functional "Restore Purchases" button and terms disclosure.
- [ ] Verified Google Play 20-tester closed testing requirement status (if applicable).

---

## 12. Dependencies

| Dependency | Purpose | Dependency Type |
| :--- | :--- | :--- |
| **Flutter SDK (3.13+)** | Cross-platform framework | Core Platform |
| **Firebase Auth** | User authentication & session management | Cloud Service |
| **Cloud Firestore** | Cloud database with offline local cache | Cloud Database |
| **RevenueCat (`purchases_flutter`)**| In-app subscription orchestration & entitlement gating | IAP Middleware |
| **Apple App Store Connect** | iOS app distribution, merchant agreement, IAP items | Platform Store |
| **Google Play Console** | Android distribution, merchant account, subscriptions | Platform Store |
| **`pdf` & `printing`** | On-device invoice rendering and preview | Client Package |
| **`share_plus` & `url_launcher`**| Invoking OS share sheet, WhatsApp, SMS, and Mail deep links | Native Interop |
| **`flutter_local_notifications`**| Scheduling local hardware alerts for deadlines/due dates | Native Interop |
| **Firebase Cloud Functions (P1)** | Serverless Node.js backend for AI reminder generation | Backend Service |
| **OpenAI / Anthropic API (P1)** | Large language model for reminder tone polishing | External AI API |

---

## 13. Risks and Mitigations

| Risk | Severity | Mitigation Strategy |
| :--- | :---: | :--- |
| **Google Play Closed-Testing Requirement** (20 testers for 14 days on personal accounts) | **CRITICAL** | **VERIFY** immediately whether developer account is personal (post-Nov 2023) or enterprise. If personal, recruit 20 testers on Day 1 or deploy on Apple App Store / Samsung Galaxy Store first. |
| **Store Review Delays** (Review taking 3–7 business days close to deadline) | **HIGH** | Submit early with P0 features; do not wait for P1 features to initiate initial store submission. |
| **Merchant Account / Payout Approval Delays** | **HIGH** | Set up tax and banking profiles in App Store Connect and Google Play Console immediately. Sandbox testing proceeds independently of banking approval. |
| **iOS 64 Local Notification Cap** | **MEDIUM** | Implement a pruning and prioritization scheduler: sort pending invoices by urgency and schedule only the nearest 40 notification slots. |
| **Third-Party Messaging Channel Unreliability** | **LOW** | App explicitly records reminders as **"Shared"** rather than "Sent" and does not claim delivery verification. |
| **Cloud Functions Blaze Plan & AI Costs (P1)** | **LOW** | Keep AI polish behind Pro entitlement. Free tier uses hardcoded static templates. Fall back cleanly if Cloud Function fails. |

---

## 14. Assumptions

1. **Native Sharing Reliance**: The app will never guarantee message delivery; hand-off to the OS share sheet or deep link constitutes a completed "Share" event.
2. **Single User Account Model**: Each user manages their own records; no sharing of invoices or clients between user accounts.
3. **Single Currency Profile**: Invoices are formatted in the user's primary selected currency; multi-currency conversions are not calculated.
4. **Manual Payment Reconciliation**: Mark as paid is a manual user toggle. No automatic bank feed or gateway webhook exists in v1.
5. **Deterministic Status Derivation**: Overdue status is never stored as a static field that risks becoming stale; it is derived at runtime from `dueDate < today && status != Paid`.

---

## 15. Open Questions (VERIFY)

- **[VERIFY-01]**: What are the exact start and final closing dates for the RevenueCat hackathon submission period?
- **[VERIFY-02]**: Is the Google Play developer account a personal account created after November 13, 2023 (subject to the 20-tester, 14-day closed testing policy), or an organization account?
- **[VERIFY-03]**: Are merchant banking and tax details fully verified in Apple App Store Connect and Google Play Console for the target developer country to allow subscription sales?
- **[VERIFY-04]**: Is the exact application name "ClientTrack" available on the Apple App Store and Google Play Store, or is a secondary name required (e.g., "ClientTrack: Invoice Chaser")?
- **[VERIFY-05]**: Is the Firebase project upgraded to the Blaze (pay-as-you-go) plan to support Cloud Functions for P1 AI reminders?
- **[VERIFY-06]**: Does the iOS distribution plan mandate Sign in with Apple if Google Sign-In is introduced in P1?

---

## 16. Glossary

- **Payment Chaser**: The core feature set in ClientTrack responsible for identifying overdue invoices and generating rapid follow-up communications.
- **Needs Follow-up**: The dedicated operational view listing invoices currently due today or overdue, sorted by urgency.
- **Shared vs Sent**: Terminology rule. Because reminders are handed off to external apps via the OS share sheet without callback confirmation, status is strictly recorded as "Shared", never "Sent".
- **Payment History**: A calculated rating per client based on historical payment performance (Average Days Late, On-Time Percentage, and reliability classification).
- **ClientTrack Pro**: The premium subscription tier unlocking unlimited records, clean PDFs, unlimited reminder shares, and advanced analytics.
- **Entitlement (`clienttrack_pro`)**: The RevenueCat entitlement identifier determining access to Pro features.
- **Offering**: The RevenueCat collection of packages presented to the customer on the paywall (containing monthly and annual options).
- **Deterministic Overdue**: Status derived dynamically on the client by comparing the invoice due date against current local midnight.
