import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:monit/models/product.dart';
import 'package:monit/providers/product_provider.dart';
import 'package:monit/utils/const.dart';
import 'package:provider/provider.dart';

class ProductDatabase {
  Future<List<Product>> getProducts() async {
    return [
      Product(id: '1', name: 'Sandwich', price: 3.99, imageUrl: MyConst.defaultProductImage, category: 'Lunch'),
      Product(id: '2', name: 'Salad', price: 4.50, imageUrl: MyConst.defaultProductImage, category: 'Lunch'),
      Product(id: '3', name: 'Pasta', price: 5.99, imageUrl: MyConst.defaultProductImage, category: 'Lunch'),
      Product(id: '4', name: 'Chocolate Bar', price: 1.50, imageUrl: MyConst.defaultProductImage, category: 'Snacks'),
      Product(id: '5', name: 'Chips', price: 1.25, imageUrl: MyConst.defaultProductImage, category: 'Snacks'),
      Product(id: '6', name: 'Fruit Cup', price: 2.99, imageUrl: MyConst.defaultProductImage, category: 'Snacks'),
      Product(id: '7', name: 'Notebook', price: 3.99, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(id: '8', name: 'Pen Pack', price: 4.99, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(
          id: '9', name: 'Highlighters', price: 5.99, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(
          id: '10', name: 'Pencil Case', price: 6.99, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(id: '11', name: 'Water Bottle', price: 7.99, imageUrl: MyConst.defaultProductImage, category: 'Snacks'),
      Product(
          id: '12', name: 'Calculator', price: 12.99, imageUrl: MyConst.defaultProductImage, category: 'Stationery'),
      Product(id: '13', name: 'Lunch Box', price: 9.99, imageUrl: MyConst.defaultProductImage, category: 'Lunch')
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
}
