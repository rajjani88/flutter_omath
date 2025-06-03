import 'dart:async';
import 'package:flutter_omath/utils/sharedprefs.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseController extends GetxController implements GetxService {
  static const String _proProductId = 'go_pro';
  final InAppPurchase _iap = InAppPurchase.instance;

  final isAvailable = false.obs;
  final isPro = false.obs;
  final products = <ProductDetails>[].obs;
  final purchasePending = false.obs;
  final price = ''.obs;

  final Sharedprefs sp;

  late StreamSubscription<List<PurchaseDetails>> _subscription;

  InAppPurchaseController({required this.sp});

  @override
  void onInit() {
    super.onInit();

    _initialize();
  }

  Future<void> _initialize() async {
    isPro.value = sp.userType;
    final available = await _iap.isAvailable();
    isAvailable.value = available;

    if (available) {
      await _loadProducts();
      _subscription =
          _iap.purchaseStream.listen(_onPurchaseUpdated, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        // handle error
        print("Purchase stream error: $error");
      });
    }
  }

  Future<void> _loadProducts() async {
    const Set<String> ids = {_proProductId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.productDetails.isNotEmpty) {
      products.assignAll(response.productDetails);
      price.value = products.first.price;
    }
  }

  void buyPro() {
    final product = products.firstWhere((p) => p.id == _proProductId);
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.productID == _proProductId &&
          purchase.status == PurchaseStatus.purchased) {
        _verifyAndCompletePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        Get.snackbar(
            'Purchase Failed', purchase.error?.message ?? 'Unknown error');
      }
    }
  }

  Future<void> _verifyAndCompletePurchase(PurchaseDetails purchase) async {
    // ✅ Add your own backend verification here if needed

    // Save locally (or in secure storage)
    isPro.value = true;
    sp.userType = true;

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    Get.snackbar('Success', 'You are now a Pro user!');
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
