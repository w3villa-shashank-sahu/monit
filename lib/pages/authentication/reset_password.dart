import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:monit/backend/auth.dart';
import 'package:monit/utils/const.dart';
import 'package:monit/widgets/button.dart';
import 'package:monit/widgets/popup.dart';
import 'package:monit/widgets/textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        showDialog(
          context: context,
          builder: (context) => const MyAlert(
            msg: 'Passwords do not match',
            iserror: true,
          ),
        );
        return;
      }

      try {
        setState(() {
          _isLoading = true;
        });

        final authService = Auth();
        await authService.verifyOTPAndResetPassword(
          widget.email,
          _otpController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          // Show success message
          showDialog(
            context: context,
            builder: (context) => MyAlert(
              msg: 'Password reset successful',
              iserror: false,
            ),
          ).then((_) {
            // Navigate to login screen
            context.go(MyRoutes.login);
          });
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
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
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
                    Icons.lock_open,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),

                  // Instruction text
                  Text(
                    'Verify & Reset',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the OTP sent to ${widget.email} and create a new password',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Field
                  MytextField(
                    hintText: '6-digit OTP',
                    controller: _otpController,
                    curveType: MytextField.topCurve,
                  ),
                  const SizedBox(height: 16),

                  // New Password Field
                  MytextField(
                    hintText: 'New Password',
                    controller: _passwordController,
                    isPasswordField: true,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  MytextField(
                    hintText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    isPasswordField: true,
                    curveType: MytextField.bottomCurve,
                  ),
                  const SizedBox(height: 32),

                  // Reset Button
                  Mybutton(
                    text: 'Reset Password',
                    onPressed: _resetPassword,
                    isActive: !_isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Resend OTP
                  TextButton(
                    onPressed: () => context.go('${MyRoutes.forgotPassword}'),
                    child: const Text(
                      'Resend OTP',
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
