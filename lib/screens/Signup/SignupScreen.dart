import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:ponto_seguro/models/User.dart';
import 'package:ponto_seguro/screens/Map/MapScreen.dart';
import 'package:ponto_seguro/services/AuthService.dart';
import 'package:toast/toast.dart';

class SignupScreen extends StatelessWidget {
  static final routeName = '/signup';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: FormBuilder(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      child: FormBuilderTextField(
                        name: 'fullName',
                        controller: nameController,
                        validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(context)],
                        ),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nome completo',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: FormBuilderTextField(
                        name: 'email',
                        controller: emailController,
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.email(context),
                          ],
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: FormBuilderTextField(
                        name: 'password',
                        obscureText: true,
                        controller: passwordController,
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(context),
                            FormBuilderValidators.minLength(context, 8),
                          ],
                        ),
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
                          _formKey.currentState.save();
                          if (_formKey.currentState.validate()) {
                            User user = new User(
                              fullName: '${nameController.text}',
                              email: '${emailController.text}',
                              password: '${passwordController.text}',
                              isAdmin: false,
                            );

                            final res = await AuthService.signup(user);

                            if (res.statusCode == 200) {
                              final data = jsonDecode(res.body);
                              AuthService.TOKEN = data['data']['token'];
                              return Navigator.pushNamedAndRemoveUntil(
                                context,
                                MapScreen.routeName,
                                (route) => false,
                              );
                            }

                            if (res.statusCode == 400) {
                              return Toast.show(
                                "Um usuário já existe com este e-mail.",
                                context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }

                            return Toast.show(
                              "Ocorreu um erro ao comunicar com o servidor.",
                              context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          } else {
                            return Toast.show(
                              "Verifique os dados do formulário!",
                              context,
                              duration: Toast.LENGTH_LONG,
                              gravity: Toast.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
