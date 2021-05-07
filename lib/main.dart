import 'package:flutter/material.dart';
import 'package:ponto_seguro/screens/Map/MapScreen.dart';

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
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Ponto Seguro',
          ),
        ),
        drawer: Drawer(),
        body: MapScreen(),
      ),
    );
  }
}
