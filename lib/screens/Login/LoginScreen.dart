import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:ponto_seguro/screens/Map/MapScreen.dart';
import 'package:ponto_seguro/screens/Signup/SignupScreen.dart';
import 'package:http/http.dart' as http;
import 'package:ponto_seguro/services/AuthService.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatelessWidget {
  static final routeName = '/login';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // background color
        image: DecorationImage(
          image: AssetImage('assets/auth-bg-2.png'),
          fit: BoxFit.cover,
        ), // background image above color
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Image.asset('assets/ponto-seguro-banner.png'),
                              SizedBox(
                                height: 55,
                              ),
                              Text(
                                "Bem vindo",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Mais segurança no dia-a-dia na palma da sua mão",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: FormBuilderTextField(
                              style: TextStyle(fontSize: 12),
                              name: 'email',
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: FormBuilderValidators.compose(
                                [
                                  FormBuilderValidators.required(context),
                                  FormBuilderValidators.email(context),
                                ],
                              ),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                suffixIcon: Icon(
                                  Icons.check,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(),
                                labelText: 'E-mail',
                                labelStyle: TextStyle(fontSize: 12),
                                errorStyle: TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 10, 20, 10),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: FormBuilderTextField(
                              style: TextStyle(fontSize: 12),
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
                                fillColor: Colors.white,
                                filled: true,
                                suffixIcon: Icon(
                                  Icons.visibility_off,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(),
                                labelText: 'Senha',
                                labelStyle: TextStyle(fontSize: 12),
                                errorStyle: TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 10, 20, 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              elevation: 12,
                              minWidth: double.infinity,
                              textColor: Colors.white,
                              color: Color.fromRGBO(0, 150, 199, 1),
                              child: Text(
                                'Entrar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () async {
                                _formKey.currentState.save();
                                if (_formKey.currentState.validate()) {
                                  final Map data = {
                                    'email': emailController.text,
                                    'password': passwordController.text
                                  };

                                  final res = await AuthService.login(data);

                                  if (res.statusCode == 200) {
                                    final data = jsonDecode(res.body);
                                    AuthService.TOKEN = data['data']['token'];
                                    AuthService.USER_ID =
                                        data['data']['user']['_id'];
                                    return Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      MapScreen.routeName,
                                      (route) => false,
                                    );
                                  }

                                  if (res.statusCode == 400) {
                                    return Toast.show(
                                      "Credenciais inválidas, tente novamente",
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
                          Text(
                            "Esqueceu sua senha?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(0, 119, 182, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FlatButton(
                    padding: EdgeInsets.zero,
                    textColor: Colors.blue,
                    child: RichText(
                      text: TextSpan(
                        text: 'Não tem uma conta? ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(19, 19, 19, 1),
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'Crie agora',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(0, 119, 182, 1),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      SignupScreen.routeName,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
