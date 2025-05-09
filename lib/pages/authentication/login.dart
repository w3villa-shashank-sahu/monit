import 'package:flutter/material.dart';
import 'package:monit/backend/auth.dart';
import 'package:monit/backend/localstorage.dart';
import 'package:monit/utils/const.dart';
import 'package:monit/widgets/button.dart';
import 'package:monit/widgets/popup.dart';
import 'package:monit/widgets/textfield.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isLoading = true;
        });

        final authService = Auth();
        String token = await authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        await Localstorage().setToken(token);

        // On successful login, navigate to dashboard
        if (mounted) {
          context.go(MyRoutes.verify);
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => MyAlert(
              msg: e.toString(),
              iserror: true,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _forgotPassword() {
    // Navigate to forgot password screen
    context.go(MyRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or App Name
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),

                  // App Name
                  Text(
                    MyConst.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Welcome Text
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  MytextField(
                    hintText: 'Email',
                    controller: _emailController,
                    curveType: MytextField.topCurve,
                  ),

                  // Password Field
                  MytextField(
                    hintText: 'Password',
                    controller: _passwordController,
                    isPasswordField: true,
                    curveType: MytextField.bottomCurve,
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In Button
                  Mybutton(
                    text: 'Sign In',
                    onPressed: _signIn,
                    isActive: !_isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Optional: Additional Info or Support Contact
                  Text(
                    'Need help? Contact ${MyConst.supportEmail}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
