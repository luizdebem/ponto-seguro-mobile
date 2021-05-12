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
      home: true
          ? LoginScreen()
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  'Ponto Seguro',
                ),
              ),
              drawer: Drawer(),
              body: MapScreen(),
            ),
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        SignupScreen.routeName: (context) => SignupScreen()
      },
    );
  }
}
