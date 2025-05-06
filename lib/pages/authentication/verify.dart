import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:monit/backend/localstorage.dart';
import 'package:monit/utils/const.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Simulate a brief loading delay to show the splash screen
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Get authentication token from local storage
      final localStorage = Localstorage();
      final token = await localStorage.getToken();

      if (token.isNotEmpty) {
        if (mounted) {
          context.go(MyRoutes.dashboard);
        }
        return;
      }

      // No token or invalid token, navigate to login
      if (mounted) {
        context.go(MyRoutes.login);
      }
    } catch (e) {
      // Error occurred, navigate to login
      if (mounted) {
        context.go(MyRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Icon
            const Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              MyConst.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),

            // Loading Indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 24),

            // Loading Text
            const Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
