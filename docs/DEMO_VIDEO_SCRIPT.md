# ClientTrack — Demonstration Video Script & Storyboard (FT-027)

**Total Duration**: 2 minutes 45 seconds  
**Target Audience**: Hackathon Judges, App Store Reviewers, Freelance Community  
**Aspect Ratio**: 9:16 (Portrait for mobile shorts) or 16:9 with device mockup frame  
**Audio**: Clear spoken English voiceover + upbeat background lo-fi music  

---

## Scene-by-Scene Storyboard & Timeline

### Scene 1: Hook & The Freelancer Problem (0:00 – 0:25)
- **Visual**: Screen opens on Splash screen with animated ClientTrack logo and green glowing pulse. Transitions into Dashboard showing an active business with \$3,520 in overdue invoices.
- **Voiceover**:
  > *"Every freelancer knows the dread of late payments. You deliver great work, send an invoice, and then... silence. Awkward follow-ups get delayed, spreadsheets get forgotten, and cash flow suffers. Meet ClientTrack: the all-in-one business cockpit and payment chaser built to get freelancers paid on time, every time."*

---

### Scene 2: Client & Project Setup (0:25 – 0:50)
- **Visual**: Tap **Clients tab**, browse the client directory. Tap **+ Add Client**, enter client details (Name: "Alex Rivera", Company: "Studio Arc", email, phone), tap Save. Tap **Projects tab**, view project card with budget burn bar and upcoming deadline countdown.
- **Voiceover**:
  > *"ClientTrack organizes your entire freelance operation. Add clients with instant contact details and track active projects with visual budget indicators and approaching deadline alerts—so you never miss a client commitment."*

---

### Scene 3: Fast Invoicing & On-Device PDF Engine (0:50 – 1:25)
- **Visual**: Tap **Invoices tab**, tap **+ Create Invoice**. Select "Alex Rivera" from bottom sheet picker. Sequential number `INV-2026-1025` is auto-generated. Add line items: "Brand Identity Design" (\$2,400) and "Logo Guidelines" (\$800). Subtotal and tax auto-calculate. Tap **Generate Invoice**.
- **Visual**: Tap the new invoice, show itemized breakdown, then tap **PDF Preview**. High-resolution vector PDF invoice appears instantly with business details, clean table layout, and direct **Share PDF** action opening native OS tray.
- **Voiceover**:
  > *"Creating professional invoices takes less than a minute. Dynamic line items calculate subtotals and taxes automatically. And with our on-device vector PDF engine, you can generate and share crisp, professional PDF invoices directly to clients via email or messaging apps without relying on slow remote servers."*

---

### Scene 4: The Payment Chaser Cockpit (1:25 – 2:00)
- **Visual**: Return to Dashboard. Overdue balance badge is highlighted. Tap the **Needs Follow-up** card.
- **Visual**: Overdue list displays with days-late counter. Tap **Chase** on overdue invoice.
- **Visual**: Reminder Composer opens. Tap across templates: **Friendly** $\to$ **Professional** $\to$ **Final Notice**. Show interpolated client name and exact balance. Tap **✨ AI Polish** (text refines smoothly). Tap **WhatsApp** button: WhatsApp opens with pre-filled message ready to send!
- **Voiceover**:
  > *"Here is where ClientTrack truly shines: The Payment Chaser. Our deterministic status engine tracks overdue balances the moment midnight strikes. The 'Needs Follow-up' cockpit sorts your overdue invoices by urgency. Choose from escalating reminder templates—Friendly, Professional, or Final Notice—complete with AI polish and 1-tap dispatch to WhatsApp, SMS, or Email pre-filled with the exact balance due. No awkward drafting needed."*

---

### Scene 5: Local Notifications & Smart Gating (2:00 – 2:25)
- **Visual**: Brief shot of local notification banner appearing at the top: *"Payment Reminder: Invoice #1023 is due in 2 days."*
- **Visual**: User attempts to create a 4th client or 6th invoice. The feature gate triggers an informative snackbar and smoothly slides up the **ClientTrack Pro Paywall**.
- **Voiceover**:
  > *"Local device notifications alert you before and after due dates without server tracking. Free users get generous access to manage their first clients and invoices. When you're ready to scale, ClientTrack Pro powered by RevenueCat unlocks unlimited clients, invoices, and watermark-free PDF exports with 1 tap."*

---

### Scene 6: RevenueCat Subscription & Wrap-up (2:25 – 2:45)
- **Visual**: Select Annual Plan (\$59.99/yr), tap **Upgrade to Pro**, sandbox checkmark appears, Pro Badge shines on Settings profile. End on logo lockup with GitHub link and download CTA.
- **Voiceover**:
  > *"Integrated seamlessly with RevenueCat for rock-solid monthly and annual subscriptions. ClientTrack: Take control of your freelance finances and get paid what you're worth. Download today or check out our open-source codebase on GitHub!"*

---

## Production Checklist

- [x] Full script written with precise voiceover timings.
- [x] Scene-by-scene visual interactions mapped to implemented screens.
- [x] Demo data seeded for smooth visual walkthrough (`kSeedClients`, `kSeedInvoices`).
- [x] High-resolution device frames (1080x1920 60fps) prepared.
- [x] Video script stored in `docs/DEMO_VIDEO_SCRIPT.md` for hackathon submission repository.

