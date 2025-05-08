import 'package:flutter/material.dart';
import 'package:monit/backend/localstorage.dart';
import 'package:monit/backend/product.dart';
import 'package:monit/models/product.dart';
import 'package:monit/providers/product_provider.dart';

void showProductDetailsDialog(Product product, ProductProvider productProvider, BuildContext context) {
  final theme = Theme.of(context);
  // Get current quantity and selected days from provider
  int quantity = productProvider.getQuantity(product.id);
  List<bool> selectedDays = productProvider.getSelectedDays(product.id);

  // If this is a new product selection and quantity is 0, set it to 1 by default
  if (quantity == 0) {
    quantity = 1;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product image header
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      image: product.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: product.imageUrl.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '₹${product.price.toStringAsFixed(2)} / Per day',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Stock information
                        Text(
                          'Available: ${product.stockQuantity} in stock',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quantity selector
                        Row(
                          children: [
                            const Text(
                              'Quantity:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: quantity > 0
                                        ? () => setState(() {
                                              quantity--;
                                            })
                                        : null,
                                    icon: const Icon(Icons.remove),
                                    color: theme.colorScheme.primary,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                    onPressed: quantity < (product.stockQuantity > 10 ? 10 : product.stockQuantity)
                                        ? () => setState(() {
                                              quantity++;
                                            })
                                        : null,
                                    icon: const Icon(Icons.add),
                                    color: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Days selector
                        const Text(
                          'Select Days:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _daysList(product, selectedDays, (index) {
                          setState(() {
                            selectedDays[index] = !selectedDays[index];
                            if (productProvider.isSelected(product.id)) {
                              productProvider.setSelectedDays(product.id, selectedDays);
                            }
                          });
                        }, context),
                      ],
                    ),
                  ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              if (quantity > 0) {
                                productProvider.addProduct(
                                  product,
                                  quantity: quantity,
                                  selectedDays: selectedDays,
                                );
                                final token = await Localstorage().getToken();
                                if (!context.mounted) return;
                                await ProductDatabase().saveSelectedProducts(token, context);
                              } else {
                                productProvider.removeProduct(product.id);
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              // Handle error (e.g., show a snackbar or dialog)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _daysList(Product product, List<bool> selectedDays, Function(int) onDayToggle, BuildContext context) {
  final List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S'];

  return Wrap(
    spacing: 4, // horizontal space between chips
    children: List.generate(
      dayLabels.length,
      (index) => GestureDetector(
        onTap: () => onDayToggle(index),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: selectedDays[index] ? Theme.of(context).colorScheme.primary : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              dayLabels[index],
              style: TextStyle(
                color: selectedDays[index] ? Colors.white : Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
