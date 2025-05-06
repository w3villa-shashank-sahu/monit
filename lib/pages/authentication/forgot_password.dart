import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:monit/backend/auth.dart';
import 'package:monit/utils/const.dart';
import 'package:monit/widgets/button.dart';
import 'package:monit/widgets/popup.dart';
import 'package:monit/widgets/textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestOTP() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isLoading = true;
        });

        final email = _emailController.text.trim();
        final authService = Auth();
        await authService.requestPasswordResetOTP(email);

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent to your email'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to reset password screen
          context.go(
            '${MyRoutes.resetPassword}?email=$email',
          );
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
                  // Icon
                  const Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),

                  // Instruction text
                  Text(
                    'Reset Your Password',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email address and we\'ll send you an OTP to reset your password',
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
                    curveType: MytextField.noCurve,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Mybutton(
                    text: 'Send OTP',
                    onPressed: _requestOTP,
                    isActive: !_isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Go back to login
                  TextButton(
                    onPressed: () => context.go(MyRoutes.login),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(color: Colors.blue),
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
