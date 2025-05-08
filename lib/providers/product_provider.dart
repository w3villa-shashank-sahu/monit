import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:monit/backend/localstorage.dart';
import 'package:monit/models/product.dart';
import 'package:monit/utils/const.dart';

// Class to track a product and its selected quantity
class SelectedProduct {
  final Product product;
  int quantity;
  List<bool> selectedDays;

  SelectedProduct({
    required this.product,
    this.quantity = 1,
    List<bool>? selectedDays,
  }) : selectedDays = selectedDays ?? List.filled(6, false);
}

class ProductProvider extends ChangeNotifier {
  // Map of product IDs to SelectedProduct objects
  final Map<String, SelectedProduct> _selectedProducts = {};

  // Get a map of all selected products
  Map<String, SelectedProduct> get selectedProducts => _selectedProducts;

  // Get total count of unique selected products
  int get selectedProductCount => _selectedProducts.length;

  // Get total quantity of all selected products
  int get totalQuantity {
    return _selectedProducts.values.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get total price of all selected products
  double get totalPrice {
    return _selectedProducts.values.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  // Check if a product is selected
  bool isSelected(String productId) {
    return _selectedProducts.containsKey(productId);
  }

  // Get quantity of a specific product
  int getQuantity(String productId) {
    return _selectedProducts[productId]?.quantity ?? 0;
  }

  // Get selected days for a specific product
  List<bool> getSelectedDays(String productId) {
    return _selectedProducts[productId]?.selectedDays ?? List.filled(6, false);
  }

  // Set selected days for a specific product
  void setSelectedDays(String productId, List<bool> days) {
    if (_selectedProducts.containsKey(productId)) {
      _selectedProducts[productId]!.selectedDays = days;
      notifyListeners();
    }
  }

  // Add a product or update its quantity
  void addProduct(Product product, {int quantity = 1, List<bool>? selectedDays}) {
    if (_selectedProducts.containsKey(product.id)) {
      _selectedProducts[product.id]!.quantity = quantity;

      if (selectedDays != null) {
        _selectedProducts[product.id]!.selectedDays = selectedDays;
      }
    } else {
      _selectedProducts[product.id] = SelectedProduct(
        product: product,
        quantity: quantity,
        selectedDays: selectedDays ?? List.filled(6, false),
      );
    }
    notifyListeners();
  }

  // Remove a product completely
  void removeProduct(String productId) {
    _selectedProducts.remove(productId);
    notifyListeners();
  }

  // Increment quantity of a product
  void incrementQuantity(String productId) {
    if (_selectedProducts.containsKey(productId)) {
      _selectedProducts[productId]!.quantity++;
      notifyListeners();
    }
  }

  // Decrement quantity of a product
  void decrementQuantity(String productId) {
    if (_selectedProducts.containsKey(productId)) {
      if (_selectedProducts[productId]!.quantity > 1) {
        _selectedProducts[productId]!.quantity--;
      } else {
        _selectedProducts.remove(productId);
      }
      notifyListeners();
    }
  }

  // Clear all selected products
  void clearAll() {
    _selectedProducts.clear();
    notifyListeners();
  }

  // Convert selected products to JSON format
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = {};

    _selectedProducts.forEach((productId, selectedProduct) {
      jsonData[productId] = {
        'product': {
          'id': selectedProduct.product.id,
          'name': selectedProduct.product.name,
          'price': selectedProduct.product.price,
          'imageUrl': selectedProduct.product.imageUrl,
          'stockQuantity': selectedProduct.product.stockQuantity,
          'forEmergency': selectedProduct.product.forEmergency,
          'category': selectedProduct.product.category,
        },
        'quantity': selectedProduct.quantity,
        'selectedDays': selectedProduct.selectedDays,
      };
    });

    return jsonData;
  }

  // Create selected products from JSON data
  void fromJson(Map<String, dynamic> json) {
    _selectedProducts.clear();

    json.forEach((productId, productData) {
      final productJson = productData['product'];
      final product = Product(
        id: productJson['id'],
        name: productJson['name'],
        price: productJson['price'],
        imageUrl: productJson['imageUrl'],
        stockQuantity: productJson['stockQuantity'],
        forEmergency: productJson['forEmergency'],
        category: productJson['category'],
      );

      final quantity = productData['quantity'];
      List<bool> selectedDays = List<bool>.from(productData['selectedDays']);

      _selectedProducts[productId] = SelectedProduct(
        product: product,
        quantity: quantity,
        selectedDays: selectedDays,
      );
    });

    notifyListeners();
  }

  // Save selected products to localStorage
  void saveToLocalStorage() async {
    try {
      // Get the SharedPreferences instance
      final localStorage = Localstorage();

      // Convert selected products to JSON format
      final Map<String, dynamic> jsonData = {};

      _selectedProducts.forEach((productId, selectedProduct) {
        jsonData[productId] = {
          'id': selectedProduct.product.id,
          'name': selectedProduct.product.name,
          'price': selectedProduct.product.price,
          'imageUrl': selectedProduct.product.imageUrl,
          'stockQuantity': selectedProduct.product.stockQuantity,
          'forEmergency': selectedProduct.product.forEmergency,
          'category': selectedProduct.product.category,
          'quantity': selectedProduct.quantity,
          'selectedDays': selectedProduct.selectedDays,
        };
      });

      // Save the JSON string
      await localStorage.setString('selectedProducts', jsonEncode(jsonData));
    } catch (e) {
      // print('Error saving products to localStorage: $e');
      throw Exception('Failed to save products to localStorage: $e');
    }
  }

  // Update selected products from localStorage
  void loadFromLocalStorage() async {
    try {
      // Get the SharedPreferences instance
      final localStorage = Localstorage();
      final String? productsJson = await localStorage.getString('selectedProducts');

      if (productsJson == null || productsJson.isEmpty) {
        return;
      }

      // Parse the JSON data
      final Map<String, dynamic> backendData = jsonDecode(productsJson) as Map<String, dynamic>;

      // Clear existing selections first
      _selectedProducts.clear();

      // Convert the data to SelectedProduct objects
      backendData.forEach((productId, productData) {
        final product = Product(
          id: productData['id'] ?? productId,
          name: productData['name'] ?? 'Unknown Product',
          price: productData['price'] ?? 0,
          imageUrl: productData['imageUrl'] ?? MyConst.defaultProductImage,
          stockQuantity: productData['stockQuantity'] ?? 0,
          forEmergency: productData['forEmergency'] ?? false,
          category: productData['category'] ?? 'Miscellaneous',
        );

        final quantity = productData['quantity'] ?? 1;

        List<bool> selectedDays = List.filled(6, false);
        if (productData.containsKey('selectedDays') && productData['selectedDays'] is List) {
          selectedDays = List<bool>.from(productData['selectedDays'].map((day) => day == true));
        }

        _selectedProducts[productId] = SelectedProduct(
          product: product,
          quantity: quantity,
          selectedDays: selectedDays,
        );
      });

      notifyListeners();
    } catch (e) {
      // print('Error loading products from localStorage: $e');
      throw Exception('Failed to load products from localStorage: $e');
    }
  }
}
