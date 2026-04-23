import 'package:flutter/material.dart';
import 'package:mobile_app/helpdesk/design_system/app_theme.dart';
import 'package:mobile_app/helpdesk/screens/app_shell_screen.dart';

void main() {
  runApp(const HelpdeskApp());
}

class HelpdeskApp extends StatefulWidget {
  const HelpdeskApp({super.key});

  @override
  State<HelpdeskApp> createState() => _HelpdeskAppState();
}

class _HelpdeskAppState extends State<HelpdeskApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GLPI Helpdesk Mobile',
      theme: HelpdeskTheme.light,
      darkTheme: HelpdeskTheme.dark,
      themeMode: _themeMode,
      home: AppShellScreen(
        onThemeChanged: (isDark) {
          setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }
}
