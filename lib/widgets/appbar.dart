import 'package:flutter/material.dart';

AppBar customAppBar(BuildContext context, String title, dynamic childModel) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    centerTitle: false,
    elevation: 0,
    actions: [
      // Wallet Amount - Compact version
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet, size: 14, color: Colors.blue),
            const SizedBox(width: 3),
            Text(
              '₹${childModel.balance.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      // Emergency fund with icon instead of text
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, size: 14, color: Colors.red),
            const SizedBox(width: 3),
            Text(
              '₹${childModel.emergency.balance.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
    ],
  );
}
