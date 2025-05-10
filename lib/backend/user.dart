import 'package:dio/dio.dart';
import 'package:monit/backend/localstorage.dart';
import 'package:monit/models/user.dart';
import 'package:monit/utils/const.dart';

class UserDatabase {
  final Dio _dio = Dio();
  final Localstorage _localStorage = Localstorage();

  // Update child's spending limit
  Future<void> updateSpendingLimit(String childId, SpendingLimitModel newLimit) async {
    try {
      final token = await _localStorage.getToken();

      await _dio.put(
        '${MyConst.apiUrl}/children/$childId/spending-limit',
        data: {
          'dailyLimit': newLimit.dailyLimit,
          'weeklyLimit': newLimit.weeklyLimit,
          'allowedItemsPerDay': newLimit.allowedItemsPerDay,
        },
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
          contentType: Headers.jsonContentType,
        ),
      );
    } catch (e) {
      return Future.error('Failed to update spending limit: $e');
    }
  }

  // Update child's emergency settings
  Future<void> updateEmergencySettings(String childId, EmergencyModel emergency) async {
    try {
      final token = await _localStorage.getToken();

      await _dio.put(
        '${MyConst.apiUrl}/children/$childId/emergency',
        data: {
          'emergencyFundLimit': emergency.emergencyFundLimit,
          'allowedEmergencyItems': emergency.allowedEmergencyItems,
        },
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
          contentType: Headers.jsonContentType,
        ),
      );
    } catch (e) {
      return Future.error('Failed to update emergency settings: $e');
    }
  }

  // Add balance to child's account
  Future<double> addBalance(String childId, double amount) async {
    try {
      final token = await _localStorage.getToken();

      final response = await _dio.post(
        '${MyConst.apiUrl}/children/$childId/balance',
        data: {
          'amount': amount,
        },
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
          contentType: Headers.jsonContentType,
        ),
      );

      return response.data['newBalance'].toDouble();
    } catch (e) {
      return Future.error('Failed to add balance: $e');
    }
  }

  // Get child's purchase history
  Future<List<PurchaseHistoryModel>> getPurchaseHistory(String childId) async {
    try {
      final token = await _localStorage.getToken();

      final response = await _dio.get(
        '${MyConst.apiUrl}/children/$childId/purchases',
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
          contentType: Headers.jsonContentType,
        ),
      );

      List<PurchaseHistoryModel> purchases = [];
      for (var purchase in response.data) {
        purchases.add(PurchaseHistoryModel(
          id: purchase['id'],
          itemName: purchase['itemName'],
          amount: purchase['amount'].toDouble(),
          dateTime: DateTime.parse(purchase['dateTime']),
          isEmergency: purchase['isEmergency'],
          isTeacherAuthorized: purchase['isTeacherAuthorized'],
        ));
      }

      return purchases;
    } catch (e) {
      return Future.error('Failed to fetch purchase history: $e');
    }
  }

  // Update parent profile
  Future<void> updateParentProfile({String? name, String? email}) async {
    try {
      final token = await _localStorage.getToken();

      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      if (data.isEmpty) {
        return; // Nothing to update
      }

      await _dio.put(
        '${MyConst.apiUrl}/users/profile',
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
          contentType: Headers.jsonContentType,
        ),
      );
    } catch (e) {
      return Future.error('Failed to update profile: $e');
    }
  }

  // Mock data for testing
  final parent = ParentModel(
    id: 'p1',
    name: 'John Doe',
    email: 'john.doe@example.com',
  );
  final child = ChildModel(
    id: '232780',
    name: 'Shashank Sahu',
    className: 'MCA',
    rollNo: '81',
    balance: 500.0,
    spendingLimit: SpendingLimitModel(
      dailyLimit: 50.0,
      weeklyLimit: 200.0,
      allowedItemsPerDay: {
        'Monday': ['Sandwich', 'Juice'],
        'Tuesday': ['Pizza', 'Water'],
      },
    ),
    emergency: EmergencyModel(
      emergencyFundLimit: 200.0,
      usedAmountThisMonth: 50.0,
      allowedEmergencyItems: ['Medicine', 'Emergency Meal'],
      lastResetDate: DateTime.now().subtract(Duration(days: 15)),
    ),
  );

  // Fetch combined parent and children data
  // return type
  // return {
  //       'parentData': parent,
  //       'childData': child,
  //     };
  Future<Map<String, dynamic>> fetchCombinedData(String token) async {
    try {
      // Mock data for testing
      return {
        'parentData': parent,
        'childData': child,
      };

      /* Commented out actual implementation for now
      final token = await _localStorage.getToken();

      // Single API call to get all data
      final response = await _dio.get(
        '${MyConst.apiUrl}/users/dashboard',
        options: Options(
          headers: {
            'accept': '*',
            'Authorization': 'Bearer $token',
          },
          contentType: Headers.jsonContentType,
        ),
      );

      final data = response.data;

      // Parse parent data
      final parentData = data['parent'];
      final parentModel = ParentModel(
        id: parentData['id'],
        name: parentData['name'],
        email: parentData['email'],
      );

      // Parse children data
      final childrenData = data['children'];
      List<ChildModel> children = [];

      for (var child in childrenData) {
        // Parse spending limit
        SpendingLimitModel spendingLimit = SpendingLimitModel(
          dailyLimit: child['spendingLimit']['dailyLimit'].toDouble(),
          weeklyLimit: child['spendingLimit']['weeklyLimit'].toDouble(),
          allowedItemsPerDay: Map<String, List<String>>.from(child['spendingLimit']['allowedItemsPerDay']
              .map((key, value) => MapEntry(key, List<String>.from(value)))),
        );

        // Parse emergency settings
        EmergencyModel emergency = EmergencyModel(
          emergencyFundLimit: child['emergency']['emergencyFundLimit'].toDouble(),
          usedAmountThisMonth: child['emergency']['usedAmountThisMonth'].toDouble(),
          allowedEmergencyItems: List<String>.from(child['emergency']['allowedEmergencyItems']),
          lastResetDate: DateTime.parse(child['emergency']['lastResetDate']),
        );

        children.add(ChildModel(
          id: child['id'],
          name: child['name'],
          className: child['className'],
          rollNo: child['rollNo'],
          balance: child['balance'].toDouble(),
          spendingLimit: spendingLimit,
          emergency: emergency,
        ));
      }

      // Return combined data
      return {
        'parentData': parentModel,
        'childrenData': children,
      };
      */
    } catch (e) {
      return Future.error('Failed to fetch combined data: $e');
    }
  }
}
