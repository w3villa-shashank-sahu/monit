import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:monit/models/user.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final childModel = context.watch<ChildModel>();
    // This is a placeholder - in a real app, you would connect to your parent provider
    final parentModel = ParentModel(
      id: 'P12345',
      name: 'Parent Name',
      email: 'parent@example.com',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF3A86FF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A86FF), Color(0xFFF8F9FA)],
            stops: [0.0, 0.6],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header with avatar and name
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 55,
                          color: Color(0xFF3A86FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      childModel.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(76),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Class: ${childModel.className} | Roll No: ${childModel.rollNo}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content - Cards
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    // ID Barcode section
                    _buildSectionCard(
                      context,
                      title: 'Student ID',
                      icon: Icons.badge_outlined,
                      iconColor: const Color(0xFF3A86FF),
                      content: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEAECF0)),
                            ),
                            child: Column(
                              children: [
                                BarcodeWidget(
                                  barcode: Barcode.code128(),
                                  data: childModel.id,
                                  width: 250,
                                  height: 80,
                                  drawText: false,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'ID: ${childModel.id}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Wallet Information
                    _buildSectionCard(
                      context,
                      title: 'Wallet',
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      content: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildWalletCard(
                                  title: 'Regular Balance',
                                  amount: childModel.balance,
                                  gradientColors: const [Color(0xFF4ADE80), Color(0xFF22C55E)],
                                  icon: Icons.payments_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildWalletCard(
                                  title: 'Emergency Fund',
                                  amount: childModel.emergency.balance,
                                  gradientColors: const [Color(0xFFF87171), Color(0xFFEF4444)],
                                  icon: Icons.health_and_safety_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEAECF0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Weekly Spending Limit',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${childModel.spendingLimit.weeklyLimit.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => _showEditWeeklyLimitDialog(context, childModel),
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF3A86FF).withAlpha(25),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                              color: Color(0xFF3A86FF),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Student Details
                    _buildSectionCard(
                      context,
                      title: 'Student Details',
                      icon: Icons.school_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      content: Column(
                        children: [
                          _buildDetailItem(
                            icon: Icons.person_outline,
                            label: 'Name',
                            value: childModel.name,
                          ),
                          const Divider(height: 1),
                          _buildDetailItem(
                            icon: Icons.class_outlined,
                            label: 'Class',
                            value: childModel.className,
                          ),
                          const Divider(height: 1),
                          _buildDetailItem(
                            icon: Icons.format_list_numbered,
                            label: 'Roll No',
                            value: childModel.rollNo,
                          ),
                          const Divider(height: 1),
                          _buildDetailItem(
                            icon: Icons.perm_identity_outlined,
                            label: 'ID',
                            value: childModel.id,
                          ),
                        ],
                      ),
                    ),

                    // Parent Details
                    _buildSectionCard(
                      context,
                      title: 'Parent Details',
                      icon: Icons.people_outline,
                      iconColor: const Color(0xFF06B6D4),
                      content: Column(
                        children: [
                          _buildDetailItem(
                            icon: Icons.person_outline,
                            label: 'Name',
                            value: parentModel.name,
                          ),
                          const Divider(height: 1),
                          _buildDetailItem(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: parentModel.email,
                          ),
                          const Divider(height: 1),
                          _buildDetailItem(
                            icon: Icons.perm_identity_outlined,
                            label: 'ID',
                            value: parentModel.id,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditWeeklyLimitDialog(BuildContext context, ChildModel childModel) {
    final TextEditingController controller =
        TextEditingController(text: childModel.spendingLimit.weeklyLimit.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Weekly Spending Limit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the new weekly spending limit for your child:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.attach_money, size: 18),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                hintText: 'Enter amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3A86FF), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
            ),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              final newLimit = double.tryParse(controller.text);
              if (newLimit != null && newLimit >= 0) {
                // Update the spending limit in the provider
                final spendingLimit = SpendingLimitModel(
                  dailyLimit: childModel.spendingLimit.dailyLimit,
                  weeklyLimit: newLimit,
                  allowedItemsPerDay: childModel.spendingLimit.allowedItemsPerDay,
                );
                childModel.updateSpendingLimit(spendingLimit);
                Navigator.of(context).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3A86FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('SAVE'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard({
    required String title,
    required double amount,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withAlpha(76),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(64),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
