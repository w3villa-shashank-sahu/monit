import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:monit/models/product.dart';
import 'package:monit/providers/product_provider.dart';
import 'package:monit/utils/const.dart';
import 'package:provider/provider.dart';

class ProductDatabase {
  Future<List<Product>> getProducts() async {
    return [
      Product(id: '1', name: 'Sandwich', price: 30, imageUrl: MyConst.defaultProductImage, category: 'Lunch'),
      Product(id: '2', name: 'Salad', price: 20, imageUrl: MyConst.defaultProductImage, category: 'Lunch'),
      Product(id: '3', name: 'Pasta', price: 40, imageUrl: MyConst.defaultProductImage, category: 'Lunch'),
      Product(id: '4', name: 'Chocolate Bar', price: 10, imageUrl: MyConst.defaultProductImage, category: 'Snacks'),
      Product(id: '5', name: 'Chips', price: 20, imageUrl: MyConst.defaultProductImage, category: 'Snacks'),
      Product(id: '6', name: 'Fruit Cup', price: 60, imageUrl: MyConst.defaultProductImage, category: 'Snacks'),
      Product(id: '7', name: 'Notebook', price: 40, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(id: '8', name: 'Pen Pack', price: 5, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(id: '9', name: 'Highlighters', price: 10, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(id: '10', name: 'Pencil Case', price: 30, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(id: '11', name: 'Water Bottle', price: 7.99, imageUrl: MyConst.defaultProductImage, category: 'Snacks'),
      Product(id: '12', name: 'Calculator', price: 120, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(id: '13', name: 'Lunch Box', price: 300, imageUrl: MyConst.defaultProductImage, category: 'Lunch')
    ];
    // try {
    //   final dio = Dio();
    //   final response = await dio.get('${MyConst.apiUrl}/products');
    //   if (response.statusCode == 200) {
    //     final List<dynamic> productsJson = response.data;
    //     return productsJson
    //         .map((json) => Product(
    //               id: json['id'],
    //               name: json['name'],
    //               price: json['price'].toDouble(),
    //               imageUrl: json['imageUrl'] ?? MyConst.defaultProductImage,
    //               stockQuantity: json['stockQuantity'] ?? 0,
    //               forEmergency: json['forEmergency'] ?? false,
    //               category: json['category'] ?? 'Miscellaneous', // Default to 'Miscellaneous' if not provided
    //             ))
    //         .toList();
    //   } else {
    //     throw Exception('Failed to load products: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   // print('Error fetching products: $e');
    //   // Fallback to mock data if the request fails
    //   await Future.delayed(Duration(seconds: 2));

    // }
  }

  // Get all selected products for a user directly into the product provider
  void getUserSelectedProducts(BuildContext context) {
    context.read<ProductProvider>().loadFromLocalStorage();
  }

  // Save selected products to the database
  Future<void> saveSelectedProducts(String token, BuildContext context) async {
    try {
      final productProvider = context.read<ProductProvider>();
      productProvider.saveToLocalStorage();
      return;
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.post(
        '${MyConst.apiUrl}/save-selected-products',
        data: {'selectedProducts': productProvider.toJson()},
      );
      if (response.statusCode == 200) {
        productProvider.saveToLocalStorage();
      } else {
        throw Exception('Failed to save selected products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving selected products: $e');
    }
  }

  Future<List<PurchasedProductModel>> getPurchaseHistory(String token) async {
    try {
      // dummy response
      await Future.delayed(Duration(seconds: 2));
      return [
        PurchasedProductModel(
          id: '1',
          name: 'Sandwich',
          amount: 30,
          imageUrl: MyConst.defaultProductImage,
          dateTime: DateTime.now().subtract(Duration(days: 3)),
          isTeacherAuthorized: true,
        ),
        PurchasedProductModel(
          id: '2',
          name: 'Chips',
          amount: 20,
          imageUrl: MyConst.defaultProductImage,
          dateTime: DateTime.now().subtract(Duration(days: 3)),
          isTeacherAuthorized: false,
        ),
        PurchasedProductModel(
          id: '3',
          name: 'Calculator',
          amount: 120,
          imageUrl: MyConst.defaultProductImage,
          dateTime: DateTime.now().subtract(Duration(days: 5)),
          isTeacherAuthorized: false,
        ),
      ];

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.get('${MyConst.apiUrl}/purchase-history');
      if (response.statusCode == 200) {
        final List<dynamic> purchaseHistoryJson = response.data;
        return purchaseHistoryJson
            .map((json) => PurchasedProductModel(
                  id: json['id'],
                  name: json['name'],
                  amount: json['amount'].toDouble(),
                  imageUrl: json['imageUrl'] ?? MyConst.defaultProductImage,
                  dateTime: DateTime.parse(json['dateTime']),
                  isTeacherAuthorized: json['isTeacherAuthorized'] ?? false,
                ))
            .toList();
      } else {
        throw Exception('Failed to load purchase history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching purchase history: $e');
    }
  }
}
