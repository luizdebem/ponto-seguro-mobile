import 'package:flutter/material.dart';
import 'package:ponto_seguro/screens/Map/MapScreen.dart';
import 'package:ponto_seguro/screens/Signup/SignupScreen.dart';

import 'screens/Login/LoginScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        SignupScreen.routeName: (context) => SignupScreen(),
        MapScreen.routeName: (context) => MapScreen(),
      },
    );
  }
}
