import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ponto_seguro/models/User.dart';
import 'package:ponto_seguro/screens/Map/MapScreen.dart';

class SignupScreen extends StatelessWidget {
  static final routeName = '/signup';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Ponto Seguro',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nome completo',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Senha',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Cadastrar'),
                      onPressed: () async {
                        User user = new User(
                          fullName: '${nameController.text}',
                          email: '${emailController.text}',
                          password: '${passwordController.text}',
                          isAdmin: false,
                        );
                        final url = Uri.https(
                          '47240485522c.ngrok.io',
                          '/users/signup',
                        );
                        final res = await http.post(
                          url,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(
                            user.toJson(),
                          ),
                        );
                        if (res.statusCode == 200) {
                          return Navigator.pushNamedAndRemoveUntil(
                            context,
                            MapScreen.routeName,
                            (route) => false,
                          );
                        }
                        // @TODO @luizdebem validação e tratamento de erros
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
