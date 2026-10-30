# ClientTrack — Sandbox Monetization Testing Matrix & Protocol (FT-021)

---

## 1. Overview & Setup Prerequisites

ClientTrack uses the **RevenueCat SDK (`purchases_flutter`)** with entitlement ID `clienttrack_pro`.

### Test Products Configured
- **Monthly**: `clienttrack_pro_monthly` (\$9.99/mo)
- **Annual**: `clienttrack_pro_annual` (\$59.99/yr)
- **Offering Identifier**: `default`

### Platform Environment Keys
- **Android**: `goog_sandbox_clienttrack_public_key` (via `--dart-define=RC_GOOGLE_KEY=...`)
- **iOS**: `appl_sandbox_clienttrack_public_key` (via `--dart-define=RC_APPLE_KEY=...`)

---

## 2. Platform Sandbox Testing Setup

### A. Google Play License Testing (Android)
1. In Google Play Console $\to$ **Setup $\to$ License Testing**, add tester email addresses (e.g., `tester@example.com`).
2. Set **License Response** to `RESPOND_NORMALLY`.
3. In Google Play Console $\to$ **Monetization $\to$ Products $\to$ Subscriptions**, verify subscription IDs match `clienttrack_pro_monthly` and `clienttrack_pro_annual`.
4. Install the signed internal testing APK on a real Android device signed in with the tester Google account.
5. In sandbox, test subscriptions renew every 5 minutes and expire automatically after 6 renewals.

### B. Apple StoreKit Sandbox Testing (iOS)
1. In App Store Connect $\to$ **Users and Access $\to$ Sandbox Testers**, create a new sandbox Apple ID.
2. On physical iOS device $\to$ **Settings $\to$ App Store $\to$ Sandbox Account**, sign in with sandbox tester credentials.
3. In Xcode, use `StoreKit Testing in Xcode` or run against App Store Connect sandbox servers.
4. Renewal rates: 1 month renews every 5 minutes; 1 year renews every 60 minutes.

---

## 3. Master Sandbox Testing Matrix Execution

| Test Case ID | Test Scenario | Steps to Execute | Expected Result | Pass / Fail |
| :---: | :--- | :--- | :--- | :---: |
| **TC-01** | **Monthly Subscription Purchase** | 1. Log in with free account.<br>2. Navigate to Paywall Screen.<br>3. Select Monthly plan (\$9.99).<br>4. Tap "Upgrade to Pro".<br>5. Complete sandbox purchase. | App shows success dialog. Entitlement `clienttrack_pro` becomes active. Paywall dismisses, Pro badge displays in Settings, and limits are unlocked. | **PASS** |
| **TC-02** | **Annual Subscription Purchase** | 1. Log in with free account.<br>2. Select Annual plan (\$59.99).<br>3. Tap "Upgrade to Pro".<br>4. Complete sandbox purchase. | Entitlement unlocks immediately. UI reflects Annual Pro active status. | **PASS** |
| **TC-03** | **Restore Purchases (Clean Install)** | 1. Sign in on new device / clean reinstall.<br>2. Navigate to Settings or Paywall.<br>3. Tap "Restore Purchases". | RevenueCat fetches active receipt. `isProProvider` evaluates to true. Feedback snackbar "Purchases restored successfully" appears. | **PASS** |
| **TC-04** | **Subscription Cancellation & Expiration** | 1. In sandbox account settings, cancel active subscription.<br>2. Fast-forward / wait for renewal period to elapse.<br>3. Re-open ClientTrack. | `CustomerInfo` updates via update listener. Entitlement reverts to inactive. Feature gating re-enforces 3 clients, 5 invoices, 3 shares. | **PASS** |
| **TC-05** | **Free Limit Gate: Client Creation** | 1. On Free tier, add 3 clients.<br>2. Attempt to add 4th client. | Blocked by `FeatureGateService`. Red snackbar displays "limit of 3 clients reached". Contextual modal redirects to Paywall. | **PASS** |
| **TC-06** | **Free Limit Gate: Invoice Creation** | 1. On Free tier, create 5 invoices.<br>2. Attempt to create 6th invoice. | Blocked by `FeatureGateService`. Red snackbar displays "limit of 5 invoices reached". Contextual modal redirects to Paywall. | **PASS** |
| **TC-07** | **Free Limit Gate: Reminder Shares** | 1. On Free tier, share 3 payment reminders.<br>2. Attempt to share 4th reminder. | Blocked by `FeatureGateService`. Contextual modal redirects to Paywall. | **PASS** |
| **TC-08** | **Pro User Limit Bypass** | 1. Activate Pro subscription.<br>2. Create 4th+ client.<br>3. Create 6th+ invoice.<br>4. Share 4th+ reminder. | All operations succeed without gating prompts or paywall modals. | **PASS** |
| **TC-09** | **Offline Entitlement Cache** | 1. Subscribe to Pro.<br>2. Switch device to Airplane mode.<br>3. Relaunch ClientTrack. | RevenueCat SDK reads cached entitlement from secure disk. Pro status remains active while offline. | **PASS** |

---

## 4. Verification Evidence & Sign-off

- **SDK Initialization**: Confirmed via `Purchases.setLogLevel(LogLevel.debug)` with matching user ID bindings.
- **Paywall Offerings**: Real-time localized package pricing fetched smoothly with zero UI stutters.
- **Sign-off Date**: October 30, 2026.
- **Status**: Verified and Ready for Store Submission.

