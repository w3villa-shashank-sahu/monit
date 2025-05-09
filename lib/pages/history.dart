import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monit/backend/localstorage.dart';
import 'package:monit/backend/product.dart';
import 'package:monit/models/product.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<PurchasedProductModel>> _purchaseHistoryFuture;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPurchaseHistory();
  }

  Future<void> _loadPurchaseHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await Localstorage().getToken();
      _purchaseHistoryFuture = ProductDatabase().getPurchaseHistory(token);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load purchase history: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPurchaseHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        onPressed: _loadPurchaseHistory,
                      ),
                    ],
                  ),
                )
              : FutureBuilder<List<PurchasedProductModel>>(
                  future: _purchaseHistoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: theme.colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              onPressed: _loadPurchaseHistory,
                            ),
                          ],
                        ),
                      );
                    }

                    final purchases = snapshot.data!;
                    if (purchases.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 72,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No purchase history yet',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Items you purchase will appear here',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Group purchases by date
                    final Map<String, List<PurchasedProductModel>> groupedPurchases = {};
                    for (var purchase in purchases) {
                      final dateKey = DateFormat('MMMM d, yyyy').format(purchase.dateTime);
                      if (!groupedPurchases.containsKey(dateKey)) {
                        groupedPurchases[dateKey] = [];
                      }
                      groupedPurchases[dateKey]!.add(purchase);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedPurchases.length,
                      itemBuilder: (context, index) {
                        final dateKey = groupedPurchases.keys.elementAt(index);
                        final dayPurchases = groupedPurchases[dateKey]!;

                        // Calculate total for the day
                        final dayTotal = dayPurchases.fold(0.0, (total, purchase) => total + purchase.amount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateKey,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Total: ₹${dayTotal.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dayPurchases.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey[300],
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final purchase = dayPurchases[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        purchase.imageUrl,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 56,
                                          height: 56,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image_not_supported),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      purchase.name,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat('h:mm a').format(purchase.dateTime),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        if (purchase.isTeacherAuthorized)
                                          Chip(
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            backgroundColor: Colors.green[100],
                                            label: Text(
                                              'Authorized by Teacher',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.green[900],
                                              ),
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                      ],
                                    ),
                                    trailing: Text(
                                      '₹${purchase.amount.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  },
                ),
    );
  }
}
