import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../auth/data/auth_repository.dart';

// ---------------------------------------------------------------------------
// Constants & Entitlement Keys
// ---------------------------------------------------------------------------
const String kRevenueCatEntitlementId = 'clienttrack_pro';
const String kRevenueCatGoogleKey = String.fromEnvironment(
  'RC_GOOGLE_KEY',
  defaultValue: 'goog_sandbox_clienttrack_public_key',
);
const String kRevenueCatAppleKey = String.fromEnvironment(
  'RC_APPLE_KEY',
  defaultValue: 'appl_sandbox_clienttrack_public_key',
);

/// Singleton service wrapping RevenueCat `purchases_flutter` operations.
class RevenueCatService {
  bool _isInitialized = false;

  bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  /// Initializes the RevenueCat SDK with the authenticated user ID.
  Future<void> initialize({String? userId}) async {
    if (!isSupportedPlatform) {
      debugPrint('[RevenueCat] Platform not supported for store billing.');
      return;
    }

    if (_isInitialized) {
      if (userId != null && userId.isNotEmpty) {
        try {
          await Purchases.logIn(userId);
        } catch (e) {
          debugPrint('[RevenueCat] logIn error: $e');
        }
      }
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(kRevenueCatGoogleKey);
      } else {
        configuration = PurchasesConfiguration(kRevenueCatAppleKey);
      }

      if (userId != null && userId.isNotEmpty) {
        configuration.appUserID = userId;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('[RevenueCat] Initialized successfully for user: $userId');
    } catch (e) {
      debugPrint('[RevenueCat] Configuration notice: $e');
    }
  }

  /// Fetches current user customer info from cache or store.
  Future<CustomerInfo?> getCustomerInfo() async {
    if (!isSupportedPlatform || !_isInitialized) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('[RevenueCat] getCustomerInfo error: $e');
      return null;
    }
  }

  /// Fetches current offerings from RevenueCat dashboard.
  Future<Offerings?> getOfferings() async {
    if (!isSupportedPlatform || !_isInitialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[RevenueCat] getOfferings error: $e');
      return null;
    }
  }

  /// Purchases a selected package (e.g. Monthly or Annual).
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!isSupportedPlatform || !_isInitialized) return null;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo;
    } catch (e) {
      debugPrint('[RevenueCat] purchasePackage error: $e');
      rethrow;
    }
  }

  /// Restores existing purchases for the signed-in user.
  Future<CustomerInfo?> restorePurchases() async {
    if (!isSupportedPlatform || !_isInitialized) return null;
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint('[RevenueCat] restorePurchases error: $e');
      rethrow;
    }
  }

  /// Synchronous verification if clienttrack_pro is active.
  bool checkIsPro(CustomerInfo? info) {
    if (info == null) return false;
    final entitlement = info.entitlements.all[kRevenueCatEntitlementId];
    return entitlement != null && entitlement.isActive;
  }
}

// ---------------------------------------------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  final service = RevenueCatService();
  final authUser = ref.watch(authStateStreamProvider).asData?.value;
  service.initialize(userId: authUser?.uid);
  return service;
});

/// Future provider fetching current offerings.
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});

/// Notifier tracking real-time CustomerInfo.
class CustomerInfoNotifier extends Notifier<AsyncValue<CustomerInfo?>> {
  @override
  AsyncValue<CustomerInfo?> build() {
    _init();
    return const AsyncValue.loading();
  }

  Future<void> _init() async {
    final service = ref.read(revenueCatServiceProvider);
    if (!service.isSupportedPlatform) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final info = await service.getCustomerInfo();
      state = AsyncValue.data(info);

      // Listen for runtime entitlement updates (renewals, cancellations)
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        state = AsyncValue.data(customerInfo);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    final service = ref.read(revenueCatServiceProvider);
    try {
      final info = await service.getCustomerInfo();
      state = AsyncValue.data(info);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setManualCustomerInfo(CustomerInfo? info) {
    state = AsyncValue.data(info);
  }
}

final customerInfoNotifierProvider =
    NotifierProvider<CustomerInfoNotifier, AsyncValue<CustomerInfo?>>(
  CustomerInfoNotifier.new,
);

/// Global provider for checking Pro entitlement status across the app.
final isProProvider = Provider<bool>((ref) {
  final customerInfo = ref.watch(customerInfoNotifierProvider).asData?.value;
  final service = ref.read(revenueCatServiceProvider);
  return service.checkIsPro(customerInfo);
});
