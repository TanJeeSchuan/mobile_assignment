import 'package:flutter/material.dart';
import 'package:mobile_assignment/login.dart';

import 'dashboard.dart';

void main() {
  runApp(const MainApp());
}

// for debug
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<bool> _checkLogin() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FutureBuilder<bool>(
            future: _checkLogin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (snapshot.hasData && snapshot.data == true) {
                return Dashboard();
              }
              return LoginScreen();
            }
        )
    );
  }
}