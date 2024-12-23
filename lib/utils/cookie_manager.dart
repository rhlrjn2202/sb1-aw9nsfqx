import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CookieManager {
  static const String _cookieKey = 'app_cookies';
  
  static Future<void> saveCookies(WebViewController controller) async {
    final prefs = await SharedPreferences.getInstance();
    final cookies = await controller.runJavaScriptReturningResult(
      'document.cookie'
    ) as String;
    await prefs.setString(_cookieKey, cookies);
  }

  static Future<void> restoreCookies(WebViewController controller) async {
    final prefs = await SharedPreferences.getInstance();
    final cookies = prefs.getString(_cookieKey);
    if (cookies != null && cookies.isNotEmpty) {
      await controller.runJavaScript(
        'document.cookie = "$cookies"'
      );
    }
  }
}