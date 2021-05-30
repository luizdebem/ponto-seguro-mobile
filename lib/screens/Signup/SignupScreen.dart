import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:ponto_seguro/models/User.dart';
import 'package:ponto_seguro/screens/Login/LoginScreen.dart';
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
                                "Faça parte desta comunidade",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Text(
                                "Ajude a tornar a nossa cidade mais segura!",
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
                              name: 'fullName',
                              controller: nameController,
                              keyboardType: TextInputType.name,
                              validator: FormBuilderValidators.compose(
                                [FormBuilderValidators.required(context)],
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
                                labelText: 'Nome',
                                labelStyle: TextStyle(fontSize: 12),
                                errorStyle: TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.fromLTRB(20, 10, 20, 10),
                              ),
                            ),
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
                            height: 22,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              padding: EdgeInsets.zero,
                              child: FormBuilderCheckbox(
                                contentPadding: EdgeInsets.all(0),
                                name: 'termos',
                                initialValue: false,
                                title: Text(
                                  "Eu aceito os Termos de Serviço & Políticas de Privacidade",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                validator: FormBuilderValidators.equal(
                                  context,
                                  true,
                                  errorText:
                                      'You must accept terms and conditions to continue',
                                ),
                              ),
                            ),
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
                MediaQuery.of(context).viewInsets.bottom == 0
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: FlatButton(
                          padding: EdgeInsets.zero,
                          textColor: Colors.blue,
                          child: RichText(
                            text: TextSpan(
                              text: 'Já tem uma conta? ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(19, 19, 19, 1),
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Entrar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(0, 119, 182, 1),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            LoginScreen.routeName,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
