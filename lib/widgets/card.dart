import 'package:flutter/material.dart';
import 'package:monit/models/product.dart';
import 'package:monit/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function() onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Define fixed card height to prevent overflow
    const double cardHeight = 240.0;
    const double cardWidth = 200.0;
    const double imageHeight = 120.0;
    // List<bool> selectedDays = context.watch<ProductProvider>().getSelectedDays(widget.product.id);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            widget.onTap();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                    // Emergency indicator as an overlay badge
                    if (widget.product.forEmergency)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Emergency',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Details - Use Expanded to take remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${widget.product.price.toStringAsFixed(2)}/per day',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Only show out of stock message when needed
                      if (widget.product.stockQuantity <= 0)
                        Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      // Display if product is selected
                      _daysList()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _daysList() {
    final List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S'];
    List<bool> selectedDays = context.watch<ProductProvider>().getSelectedDays(widget.product.id);

    return Wrap(
      spacing: 4, // horizontal space between chips
      children: List.generate(
        dayLabels.length,
        (index) => Container(
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
    );
  }
}
