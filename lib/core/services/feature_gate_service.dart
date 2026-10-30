import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/clients/data/client_repository.dart';
import '../../features/invoices/data/invoice_repository.dart';
import '../../features/paywall/data/revenue_cat_service.dart';

// ---------------------------------------------------------------------------
// FT-019: Feature Gating Service & Limit Enforcement
// ---------------------------------------------------------------------------
//
// Free-Tier limits:
//   • Clients    : max 3 active clients
//   • Invoices   : max 5 invoices (all-time)
//   • Reminders  : max 3 lifetime reminder shares
//
// Pro users (entitlement `clienttrack_pro`) bypass all limits.
// ---------------------------------------------------------------------------

/// Result returned by every gate check.
class GateResult {
  /// true  → action is allowed
  /// false → action is blocked; show paywall
  final bool allowed;

  /// Human-readable reason shown in the paywall context label.
  final String blockedReason;

  const GateResult.allowed()
      : allowed = true,
        blockedReason = '';

  const GateResult.blocked(this.blockedReason) : allowed = false;
}

/// Synchronous, reactive gating service.
///
/// All counts are read from live Riverpod providers so they stay up to date
/// without any extra Firestore reads inside this class.
class FeatureGateService {
  final bool _isPro;
  final int _clientCount;
  final int _invoiceCount;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const int kMaxFreeClients = 3;
  static const int kMaxFreeInvoices = 5;
  static const int kMaxFreeReminderShares = 3;

  const FeatureGateService({
    required bool isPro,
    required int clientCount,
    required int invoiceCount,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _isPro = isPro,
        _clientCount = clientCount,
        _invoiceCount = invoiceCount,
        _auth = auth,
        _firestore = firestore;

  /// Check whether the user can create another client.
  GateResult checkCanAddClient() {
    if (_isPro) return const GateResult.allowed();
    if (_clientCount >= kMaxFreeClients) {
      return GateResult.blocked(
        'You\'ve reached the free limit of $kMaxFreeClients clients. '
        'Upgrade to Pro for unlimited clients.',
      );
    }
    return const GateResult.allowed();
  }

  /// Check whether the user can create another invoice.
  GateResult checkCanAddInvoice() {
    if (_isPro) return const GateResult.allowed();
    if (_invoiceCount >= kMaxFreeInvoices) {
      return GateResult.blocked(
        'You\'ve reached the free limit of $kMaxFreeInvoices invoices. '
        'Upgrade to Pro for unlimited invoices.',
      );
    }
    return const GateResult.allowed();
  }

  /// Async check for reminder shares (reads `reminderSharesCount` from
  /// the user root document so it works across sessions / devices).
  Future<GateResult> checkCanShareReminder() async {
    if (_isPro) return const GateResult.allowed();

    final uid = _auth.currentUser?.uid;
    if (uid == null) return const GateResult.allowed();

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final count = (doc.data()?['reminderSharesCount'] as int?) ?? 0;
      if (count >= kMaxFreeReminderShares) {
        return GateResult.blocked(
          'You\'ve used all $kMaxFreeReminderShares free reminder shares. '
          'Upgrade to Pro for unlimited payment chasers.',
        );
      }
    } catch (_) {
      // Allow on error — never block a user due to a network hiccup.
    }
    return const GateResult.allowed();
  }
}

// ---------------------------------------------------------------------------
// Riverpod Provider
// ---------------------------------------------------------------------------

final featureGateServiceProvider = Provider<FeatureGateService>((ref) {
  final isPro = ref.watch(isProProvider);

  // Non-null counts from live streams; fall back to 0 while loading.
  final clients =
      ref.watch(clientsStreamProvider).asData?.value ?? [];
  final invoices =
      ref.watch(invoicesStreamProvider).asData?.value ?? [];

  // Filter out seed data (they have hardcoded ids starting with 'c' or 'inv')
  // so limits only apply to real Firestore documents.
  // Simplest heuristic: if the auth user is logged in, count the live stream.
  // The stream already returns kSeedClients when offline/unauthenticated, but
  // Firestore doc IDs are random UUIDs — seed ids like 'c1', 'inv-1023' are
  // never stored in Firestore, so counting them is safe (they won't trigger
  // limits against real users).
  final clientCount = clients.length;
  final invoiceCount = invoices.length;

  return FeatureGateService(
    isPro: isPro,
    clientCount: clientCount,
    invoiceCount: invoiceCount,
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

