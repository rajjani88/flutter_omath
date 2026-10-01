import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/sharedprefs.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum SubscriptionPlan { weekly, monthly, yearly, lifetime }

class InAppPurchaseController extends GetxController implements GetxService {
  final Sharedprefs sp;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product IDs
  final Set<String> _productIds = {
    AppConfig.idWeekly,
    AppConfig.idMonthly,
    AppConfig.idYearly,
    AppConfig.idLifetime,
  };

  // Reactive state
  final isPro = false.obs;
  final isLoading = false.obs;
  final isAvailable = true.obs;
  final products = <ProductDetails>[].obs;
  final selectedPlan = SubscriptionPlan.yearly.obs;

  // Store ProductDetails by plan
  final Rxn<ProductDetails> weeklyProduct = Rxn<ProductDetails>();
  final Rxn<ProductDetails> monthlyProduct = Rxn<ProductDetails>();
  final Rxn<ProductDetails> yearlyProduct = Rxn<ProductDetails>();
  final Rxn<ProductDetails> lifetimeProduct = Rxn<ProductDetails>();

  // Formatted price strings with fallbacks
  final priceWeekly = '\$2.99 / wk'.obs;
  final priceMonthly = '\$6.99 / mo'.obs;
  final priceYearly = '\$29.99 / yr'.obs;
  final priceLifetime = '\$49.99'.obs;

  InAppPurchaseController({required this.sp});

  @override
  void onInit() {
    super.onInit();
    isPro.value = sp.userType;
    _initInAppPurchase();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _initInAppPurchase() async {
    isLoading.value = true;
    try {
      final available = await _iap.isAvailable();
      isAvailable.value = available;

      if (!available) {
        debugPrint("InAppPurchase not available on this device.");
        return;
      }

      // Listen to purchase updates stream
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => debugPrint("IAP Purchase Stream Error: $error"),
      );

      // Load products from store
      await loadProducts();
    } catch (e) {
      debugPrint("InAppPurchase initialization error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Load product details from Google Play / Apple App Store
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("Products not found: ${response.notFoundIDs}");
      }

      products.value = response.productDetails;

      for (var prod in response.productDetails) {
        if (prod.id == AppConfig.idWeekly) {
          weeklyProduct.value = prod;
          priceWeekly.value = '${prod.price} / wk';
        } else if (prod.id == AppConfig.idMonthly) {
          monthlyProduct.value = prod;
          priceMonthly.value = '${prod.price} / mo';
        } else if (prod.id == AppConfig.idYearly) {
          yearlyProduct.value = prod;
          priceYearly.value = '${prod.price} / yr';
        } else if (prod.id == AppConfig.idLifetime) {
          lifetimeProduct.value = prod;
          priceLifetime.value = prod.price;
        }
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }
  }

  /// Purchase selected plan
  Future<void> purchaseSelectedPlan() async {
    ProductDetails? productToBuy;
    switch (selectedPlan.value) {
      case SubscriptionPlan.weekly:
        productToBuy = weeklyProduct.value;
        break;
      case SubscriptionPlan.monthly:
        productToBuy = monthlyProduct.value;
        break;
      case SubscriptionPlan.yearly:
        productToBuy = yearlyProduct.value;
        break;
      case SubscriptionPlan.lifetime:
        productToBuy = lifetimeProduct.value;
        break;
    }

    if (productToBuy != null) {
      await purchaseProduct(productToBuy);
    } else {
      // Sandbox / Demo fallback grant if store products are not configured in console yet
      _grantProAccess("Pro Unlocked! Welcome to MathWize Pro.");
    }
  }

  /// Initiate purchase flow using official in_app_purchase SDK
  Future<void> purchaseProduct(ProductDetails productDetails) async {
    isLoading.value = true;
    try {
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint("Purchase launch exception: $e");
      Get.snackbar("Purchase Failed", e.toString(),
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white);
      isLoading.value = false;
    }
  }

  /// Listen and process purchase stream updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        isLoading.value = true;
      } else {
        if (purchase.status == PurchaseStatus.error) {
          isLoading.value = false;
          Get.snackbar(
            "Purchase Error",
            purchase.error?.message ?? "Transaction failed",
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white,
          );
        } else if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _grantProAccess("Welcome to MathWize Pro!");
        }

        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
        isLoading.value = false;
      }
    }
  }

  /// Restore Purchases
  Future<void> restorePurchases() async {
    isLoading.value = true;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      Get.snackbar("Restore Failed", "Could not restore purchases: $e",
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Internal helper to grant Pro state
  void _grantProAccess(String message) {
    isPro.value = true;
    sp.userType = true;
    Get.snackbar(
      "🎉 Success",
      message,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}
