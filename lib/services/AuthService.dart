import 'dart:convert';

import 'package:ponto_seguro/environments.dart';
import 'package:http/http.dart' as http;
import 'package:ponto_seguro/models/User.dart';

// @TODO @luizdebem refac, dá pra reutilizar bastante coisa
class AuthService {
  static Future login(Map data) {
    final url = Uri.http(
      Environments.URI_API,
      '/users/login',
    );

    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future signup(User user) {
    final url = Uri.http(
      Environments.URI_API,
      '/users/signup',
    );
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
  }
}
