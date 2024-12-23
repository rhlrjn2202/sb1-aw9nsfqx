import 'package:flutter/material.dart';
import 'screens/webview_screen.dart';
import 'theme/app_theme.dart';

class EaglesFoodApp extends StatelessWidget {
  const EaglesFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eagles Food',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WebViewScreen(),
    );
  }
}