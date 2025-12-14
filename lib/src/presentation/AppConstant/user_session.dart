// lib/src/presentation/AppConstant/user_session.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? uid;
  
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('otpVerified', false); // Clear OTP verification
    uid = null;
  }
  
  static Future<void> saveLogin(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('userEmail', email);
    await prefs.setBool('isLoggedIn', true);
    uid = userId;
  }
  
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
  
  // ✅ ADD THIS METHOD to check OTP verification status
  static Future<bool> isOtpVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('otpVerified') ?? false;
  }
  
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
  
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
}