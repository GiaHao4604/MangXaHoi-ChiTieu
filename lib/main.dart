import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home.dart';
import 'package:flutter_application_1/screens/login.dart';
import 'package:flutter_application_1/screens/register.dart';
import 'widgets/status_bar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const AppWrapper(child: Login()),
        '/login': (context) => const AppWrapper(child: Login()),
        '/register': (context) => const AppWrapper(child: Register()),
        '/home': (context) => const AppWrapper(child: HomeScreen()),
      },
    );
  }
}

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5C4DE1), Color(0xFF7A3CF0)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const StatusBar(),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
