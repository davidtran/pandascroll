import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pandascroll/src/core/constants/api_keys.dart';

class SubscriptionRepository {
  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(ApiKeys.revenueCatGoogleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(ApiKeys.revenueCatAppleApiKey);
    } else {
      return;
    }

    await Purchases.configure(configuration);
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (_) {
      // optional: handle error
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // optional: show error
        rethrow; // Rethrow to let provider handle/log it
      }
      return null; // Cancelled
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } on PlatformException catch (_) {
      // optional: handle error
      return null;
    }
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }
}
