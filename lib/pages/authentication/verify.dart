import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:monit/backend/localstorage.dart';
import 'package:monit/backend/user.dart';
import 'package:monit/models/user.dart';
import 'package:monit/utils/const.dart';
import 'package:provider/provider.dart';

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
        ChildModel? childData = await ChildModel.loadFromLocalStorage();
        ParentModel? parentData = await ParentModel.loadFromLocalStorage();
        // Navigate to dashboard since we have data
        if (childData != null && parentData != null && mounted) {
          // Update the provider with the loaded data
          Provider.of<ChildModel>(context, listen: false).updateChild(childData);
          Provider.of<ParentModel>(context, listen: false).updateParent(parentData);
          if (mounted) {
            context.go(MyRoutes.dashboard);
          }
          return;
        }

        // We have a token but no cached data, so fetch from API
        final userData = await UserDatabase().fetchCombinedData(token);
        if (!mounted) return;

        // Extract data from response
        if (userData.containsKey('childData') && userData.containsKey('parentData')) {
          ChildModel child = userData['childData'];
          ParentModel parent = userData['parentData'];

          print("Child data: ${child.name}, Balance: ${child.balance}");
          print("Parent data: ${parent.name}, Email: ${parent.email}");

          // Save the data to local storage
          await child.saveToLocalStorage();
          await parent.saveToLocalStorage();

          if (!mounted) return;
          print("Data saved to local storage");
          // Save the data to provider
          Provider.of<ChildModel>(context, listen: false).updateChild(child);
          Provider.of<ParentModel>(context, listen: false).updateParent(parent);

          print("Data updated in provider");

          context.go(MyRoutes.dashboard);
        } else {
          print("Error: Missing expected data in API response");
          if (mounted) {
            context.go(MyRoutes.login);
          }
        }

        return;
      }

      // No token, navigate to login
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
