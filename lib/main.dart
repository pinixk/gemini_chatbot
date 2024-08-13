import 'package:flutter/material.dart';
import 'package:gemini_chatbot/chatroom.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color.fromARGB(255, 0, 225, 225),
          brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gemini'),
          centerTitle: true,
        ),
        body: const Center(
          child: Chatroom(),
        ),
      ),
    );
  }
}
