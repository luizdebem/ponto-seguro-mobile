import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ponto_seguro/screens/Map/MapScreen.dart';
import 'package:ponto_seguro/screens/Signup/SignupScreen.dart';
import 'package:http/http.dart' as http;
import 'package:ponto_seguro/services/AuthService.dart';

class LoginScreen extends StatelessWidget {
  static final routeName = '/login';

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
                      child: Text('Login'),
                      onPressed: () async {
                        final Map data = {
                          'email': emailController.text,
                          'password': passwordController.text
                        };

                        final res = await AuthService.login(data);

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
                  SizedBox(
                    height: 22,
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text('Não tens uma conta ainda?'),
                        FlatButton(
                          textColor: Colors.blue,
                          child: Text(
                            'Cadastre-se',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            SignupScreen.routeName,
                          ),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
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
