import 'package:dio/dio.dart';
import 'package:monit/backend/localstorage.dart';
import 'package:monit/utils/const.dart';

class Auth {
  Future<String> login(String email, String password) async {
    return "mytoken";
    // Validate email and password
    if (email.isEmpty || password.isEmpty) {
      return Future.error('Username or password cannot be empty');
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return Future.error('Invalid email format');
    }
    if (password.length < 6) {
      return Future.error('Password must be at least 6 characters long');
    }

    // Make API call to login
    try {
      final response = await Dio().post(
        '${MyConst.apiUrl}/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {'accept': '*/*'},
          contentType: Headers.jsonContentType,
        ),
      );

      // Store the access token in local storage
      String accessToken = response.data['accessToken'];
      await Localstorage().setToken(accessToken);
      return accessToken;
    } catch (e) {
      return Future.error('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await Localstorage().removeToken();
    } catch (e) {
      return Future.error('Logout failed: $e');
    }
  }

  // Request OTP for password reset
  Future<void> requestPasswordResetOTP(String email) async {
    // Validate email
    if (email.isEmpty) {
      return Future.error('Email cannot be empty');
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return Future.error('Invalid email format');
    }

    try {
      await Dio().post(
        '${MyConst.apiUrl}/auth/forgot-password',
        data: {
          'email': email,
        },
        options: Options(
          headers: {'accept': '*/*'},
          contentType: Headers.jsonContentType,
        ),
      );

      // If no error, the OTP was sent successfully
      return;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return Future.error('Email address not found');
      }
      return Future.error('Failed to send OTP: ${e.toString()}');
    }
  }

  // Verify OTP and reset password
  Future<void> verifyOTPAndResetPassword(String email, String otp, String newPassword) async {
    // Validate inputs
    if (email.isEmpty || otp.isEmpty || newPassword.isEmpty) {
      return Future.error('Email, OTP, and new password cannot be empty');
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return Future.error('Invalid email format');
    }
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      return Future.error('OTP must be 6 digits');
    }
    if (newPassword.length < 6) {
      return Future.error('Password must be at least 6 characters long');
    }

    try {
      await Dio().post(
        '${MyConst.apiUrl}/auth/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {'accept': '*/*'},
          contentType: Headers.jsonContentType,
        ),
      );

      // If no error, the password was reset successfully
      return;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          return Future.error('Invalid or expired OTP');
        } else if (e.response?.statusCode == 404) {
          return Future.error('Email address not found');
        }
      }
      return Future.error('Failed to reset password: ${e.toString()}');
    }
  }
}
