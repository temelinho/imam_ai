import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  
  // Initialize local notifications in a fail-safe way
  final notificationService = NotificationService();
  await notificationService.init();
  
  runApp(const ImamAIApp());
}

class ImamAIApp extends StatelessWidget {
  const ImamAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İmam AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
