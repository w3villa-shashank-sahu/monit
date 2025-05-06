class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int stockQuantity;
  final bool forEmergency;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.stockQuantity = 0,
    this.forEmergency = false,
    required this.category, // "lunch", "snack", "drink", "stationery"
  });
}
