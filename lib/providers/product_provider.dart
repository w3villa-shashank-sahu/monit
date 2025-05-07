import 'package:flutter/foundation.dart';
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

  // Update selected products from a Map received from backend
  void updateFromBackend(Map<String, dynamic> backendData) {
    // Clear existing selections first
    _selectedProducts.clear();

    // Convert backend data to SelectedProduct objects
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
  }
}
