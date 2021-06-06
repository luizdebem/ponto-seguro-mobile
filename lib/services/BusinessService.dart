import 'dart:convert';

import 'package:http/http.dart';
import 'package:ponto_seguro/environments.dart';
import 'package:http/http.dart' as http;
import 'package:ponto_seguro/services/AuthService.dart';

class BusinessService {
  static final url = Uri.http(
    Environments.URI_API,
    '/businesses',
  );

  static Future<Response> listAll() {
    return http.get(url, headers: {'x-auth-token': AuthService.TOKEN});
  }
}
