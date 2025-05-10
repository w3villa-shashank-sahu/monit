import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:monit/backend/localstorage.dart';

class ParentModel extends ChangeNotifier {
  String id;
  String name;
  String email;

  ParentModel({
    this.id = "",
    this.name = "",
    this.email = "",
  });

  // Convert model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  // Create model from a JSON map
  static ParentModel fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  // Save to localStorage
  Future<void> saveToLocalStorage() async {
    final prefs = Localstorage();
    final String parentJson = jsonEncode(toJson());
    await prefs.setString('parentData', parentJson);
  }

  // Load from localStorage
  static Future<ParentModel?> loadFromLocalStorage() async {
    final prefs = Localstorage();
    final String? parentJson = await prefs.getString('parentData');

    if (parentJson == null) {
      return null;
    }

    final Map<String, dynamic> parentMap = jsonDecode(parentJson);
    return ParentModel.fromJson(parentMap);
  }

  // Update parent information
  void updateParent(ParentModel parent) {
    id = parent.id;
    name = parent.name;
    email = parent.email;
    notifyListeners();
  }
}

class ChildModel extends ChangeNotifier {
  String id;
  String name;
  String className;
  String rollNo;
  double balance;
  SpendingLimitModel spendingLimit;
  EmergencyModel emergency;

  ChildModel({
    this.id = '',
    this.name = '',
    this.className = '',
    this.rollNo = '',
    this.balance = 10000.0,
    SpendingLimitModel? spendingLimit,
    EmergencyModel? emergency,
  })  : spendingLimit = spendingLimit ?? SpendingLimitModel(),
        emergency = emergency ?? EmergencyModel();

  void updateBalance(double newBalance) {
    balance = newBalance;
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

  void updateChild(ChildModel child) {
    id = child.id;
    name = child.name;
    className = child.className;
    rollNo = child.rollNo;
    balance = child.balance;
    spendingLimit = child.spendingLimit;
    emergency = child.emergency;
    notifyListeners();
  }

  // Convert model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'className': className,
      'rollNo': rollNo,
      'balance': balance,
      'spendingLimit': {
        'dailyLimit': spendingLimit.dailyLimit,
        'weeklyLimit': spendingLimit.weeklyLimit,
        'allowedItemsPerDay': spendingLimit.allowedItemsPerDay,
      },
      'emergency': {
        'balance': emergency.balance,
        'emergencyFundLimit': emergency.emergencyFundLimit,
        'usedAmountThisMonth': emergency.usedAmountThisMonth,
        'allowedEmergencyItems': emergency.allowedEmergencyItems,
        'lastResetDate': emergency.lastResetDate.toIso8601String(),
      },
    };
  }

  // Create model from a JSON map
  static ChildModel fromJson(Map<String, dynamic> json) {
    SpendingLimitModel spendingLimit = SpendingLimitModel(
      dailyLimit: json['spendingLimit']['dailyLimit'] as double,
      weeklyLimit: json['spendingLimit']['weeklyLimit'] as double,
      allowedItemsPerDay: Map<String, List<String>>.from(
        (json['spendingLimit']['allowedItemsPerDay'] as Map).map(
          (key, value) => MapEntry(key as String, List<String>.from(value)),
        ),
      ),
    );

    EmergencyModel emergency = EmergencyModel(
      balance: json['emergency']['balance'] as double,
      emergencyFundLimit: json['emergency']['emergencyFundLimit'] as double,
      usedAmountThisMonth: json['emergency']['usedAmountThisMonth'] as double,
      allowedEmergencyItems: List<String>.from(json['emergency']['allowedEmergencyItems']),
      lastResetDate: DateTime.parse(json['emergency']['lastResetDate']),
    );

    return ChildModel(
      id: json['id'] as String,
      name: json['name'] as String,
      className: json['className'] as String,
      rollNo: json['rollNo'] as String,
      balance: json['balance'] as double,
      spendingLimit: spendingLimit,
      emergency: emergency,
    );
  }

  // Save to localStorage
  Future<void> saveToLocalStorage() async {
    final prefs = Localstorage();
    final String childJson = jsonEncode(toJson());
    await prefs.setString('childData', childJson);
  }

  // Load from localStorage
  static Future<ChildModel?> loadFromLocalStorage() async {
    final prefs = Localstorage();
    final String? childJson = await prefs.getString('childData');

    if (childJson == null) {
      return null;
    }

    final Map<String, dynamic> childMap = jsonDecode(childJson);
    return ChildModel.fromJson(childMap);
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
    this.weeklyLimit = 4000,
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
    this.balance = 1000.0,
    List<String>? allowedEmergencyItems,
    DateTime? lastResetDate,
  })  : allowedEmergencyItems = allowedEmergencyItems ?? [],
        lastResetDate = lastResetDate ?? DateTime.now();
}
