import 'package:flutter/material.dart';
import 'package:monit/models/product.dart';
import 'package:monit/models/user.dart';
import 'package:monit/providers/product_provider.dart';
import 'package:monit/widgets/appbar.dart';
import 'package:monit/widgets/purchase_product.dart';
import 'package:provider/provider.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  final List<String> _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    // Get the child model from the provider for wallet info
    final childModel = Provider.of<ChildModel>(context);

    return Scaffold(
      appBar: customAppBar(context, 'Watchlist', childModel),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.selectedProductCount == 0) {
            return _buildEmptyState();
          }

          return _buildDaysList(productProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items in your watchlist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to Menu to select products',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysList(ProductProvider productProvider) {
    // Get selected products
    final selectedProducts = productProvider.selectedProducts;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 45),
      itemCount: _dayNames.length,
      itemBuilder: (context, dayIndex) {
        // Get products selected for this day
        final productsForDay = _getProductsForDay(selectedProducts, dayIndex);

        // Calculate total amount for this day
        final totalAmount = _calculateTotalForDay(productsForDay);

        // If no products for this day, return empty container
        if (productsForDay.isEmpty) {
          return _buildEmptyDayCard(dayIndex);
        }

        return _buildDayCard(dayIndex, productsForDay, totalAmount);
      },
    );
  }

  Widget _buildEmptyDayCard(int dayIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _dayLabels[dayIndex],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _dayNames[dayIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              'No items selected',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(int dayIndex, List<MapEntry<String, SelectedProduct>> productsForDay, double totalAmount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header with total amount
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withAlpha(25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _dayLabels[dayIndex],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _dayNames[dayIndex],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withAlpha(50),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Products list for this day
          SizedBox(
            height: 200, // Increased height to prevent overflow
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              scrollDirection: Axis.horizontal,
              itemCount: productsForDay.length,
              itemBuilder: (context, index) {
                final productEntry = productsForDay[index];
                final product = productEntry.value.product;
                final quantity = productEntry.value.quantity;

                return _buildProductCard(product, quantity);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, int quantity) {
    return GestureDetector(
      onTap: () {
        // Get the ProductProvider without modifying it yet
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        showProductDetailsDialog(product, productProvider, context);
      },
      child: Container(
        width: 150, // Slightly wider
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(38),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: Container(
                height: 90, // Increased height for image
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: product.imageUrl.startsWith('http')
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, color: Colors.grey);
                          },
                        )
                      : Image.asset(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported, color: Colors.grey);
                          },
                        ),
                ),
              ),
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_basket_outlined,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Qty: $quantity',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get products for a specific day
  List<MapEntry<String, SelectedProduct>> _getProductsForDay(
      Map<String, SelectedProduct> selectedProducts, int dayIndex) {
    return selectedProducts.entries
        .where((entry) => entry.value.selectedDays.length > dayIndex && entry.value.selectedDays[dayIndex])
        .toList();
  }

  // Helper method to calculate total amount for a day
  double _calculateTotalForDay(List<MapEntry<String, SelectedProduct>> productsForDay) {
    return productsForDay.fold(
      0.0,
      (total, entry) => total + (entry.value.product.price * entry.value.quantity),
    );
  }
}
