import 'dart:convert';

import 'package:http/http.dart';
import 'package:ponto_seguro/environments.dart';
import 'package:http/http.dart' as http;
import 'package:ponto_seguro/services/AuthService.dart';

class ReportService {
  static final url = Uri.http(
    Environments.URI_API,
    '/reports',
  );

  static Future<Response> listAll() {
    return http.get(url, headers: {'x-auth-token': AuthService.TOKEN});
  }

  static Future<Response> create(data) {
    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': AuthService.TOKEN,
      },
      body: jsonEncode(data),
    );
  }
}
