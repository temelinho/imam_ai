import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const ImamAIApp());
}

class ImamAIApp extends StatelessWidget {
  const ImamAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İmam AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F6E56),
          primary: const Color(0xFF0F6E56),
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
