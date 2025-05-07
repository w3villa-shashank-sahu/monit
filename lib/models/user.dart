import 'package:flutter/foundation.dart';

class ParentModel {
  final String id;
  final String name;
  final String email;

  ParentModel({
    required this.id,
    required this.name,
    required this.email,
  });
}

class ChildModel extends ChangeNotifier {
  final String id;
  final String name;
  final String className;
  final String rollNo;
  double balance;
  List<PurchaseHistoryModel> purchaseHistory;
  SpendingLimitModel spendingLimit;
  EmergencyModel emergency;

  ChildModel({
    this.id = '',
    this.name = '',
    this.className = '',
    this.rollNo = '',
    this.balance = 1000.0,
    List<PurchaseHistoryModel>? purchaseHistory,
    SpendingLimitModel? spendingLimit,
    EmergencyModel? emergency,
  })  : purchaseHistory = purchaseHistory ?? [],
        spendingLimit = spendingLimit ?? SpendingLimitModel(),
        emergency = emergency ?? EmergencyModel();

  void updateBalance(double newBalance) {
    balance = newBalance;
    notifyListeners();
  }

  void addPurchase(PurchaseHistoryModel purchase) {
    purchaseHistory.add(purchase);
    balance -= purchase.amount;
    notifyListeners();
  }

  void updateSpendingLimit(SpendingLimitModel newLimit) {
    spendingLimit = newLimit;
    notifyListeners();
  }

  void updateEmergency(EmergencyModel newEmergency) {
    emergency = newEmergency;
    notifyListeners();
  }
}

class PurchaseHistoryModel {
  final String id;
  final String itemName;
  final double amount;
  final DateTime dateTime;
  final bool isEmergency;
  final bool isTeacherAuthorized;

  PurchaseHistoryModel({
    required this.id,
    required this.itemName,
    required this.amount,
    required this.dateTime,
    this.isEmergency = false,
    this.isTeacherAuthorized = false,
  });
}

class SpendingLimitModel extends ChangeNotifier {
  final double dailyLimit;
  final double weeklyLimit;

  /// e.g., {"Monday": ["Sandwich", "Juice"]}
  Map<String, List<String>> allowedItemsPerDay;

  SpendingLimitModel({
    this.dailyLimit = 0.0,
    this.weeklyLimit = 0.0,
    Map<String, List<String>>? allowedItemsPerDay,
  }) : allowedItemsPerDay = allowedItemsPerDay ?? {};

  void updateLimits({double? newDailyLimit, double? newWeeklyLimit}) {
    if (newDailyLimit != null || newWeeklyLimit != null) {
      notifyListeners();
    }
  }

  void updateAllowedItems(Map<String, List<String>> newAllowedItems) {
    allowedItemsPerDay = newAllowedItems;
    notifyListeners();
  }
}

class EmergencyModel {
  final double balance;
  final double emergencyFundLimit;
  final double usedAmountThisMonth;
  final List<String> allowedEmergencyItems;
  final DateTime lastResetDate;

  EmergencyModel({
    this.emergencyFundLimit = 0.0,
    this.usedAmountThisMonth = 0.0,
    this.balance = 200.0,
    List<String>? allowedEmergencyItems,
    DateTime? lastResetDate,
  })  : allowedEmergencyItems = allowedEmergencyItems ?? [],
        lastResetDate = lastResetDate ?? DateTime.now();
}
