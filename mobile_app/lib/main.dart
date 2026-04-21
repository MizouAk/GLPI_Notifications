import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/app_shell.dart';
import 'package:mobile_app/theme/app_theme.dart';

void main() {
  runApp(const AlertBuddyApp());
}

class AlertBuddyApp extends StatelessWidget {
  const AlertBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alert Buddy',
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
