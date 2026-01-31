import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  static const String _pinKey = 'adminPin';
  static const String _loggedInKey = 'isAdminLoggedIn';
  static const String _defaultPin = '1234';

  Future<String> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) ?? _defaultPin;
  }

  Future<bool> verifyPin(String input) async {
    final storedPin = await getPin();
    return input == storedPin;
  }

  Future<void> setPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, newPin);
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, value);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }
}
