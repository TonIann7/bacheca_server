import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../errors/api_exception.dart';

Future<Map<String, dynamic>> readJsonObject(Request request) async {
  final text = await request.readAsString();
  final decoded = jsonDecode(text);
  if (decoded is! Map) {
    throw const FormatException('Il corpo deve essere un oggetto JSON');
  }
  return Map<String, dynamic>.from(decoded);
}

String requiredText(Map<String, dynamic> body, String key, String label) {
  final value = body[key];
  if (value is! String || value.trim().isEmpty) {
    throw ApiException(422, 'Il campo "$label" è obbligatorio');
  }
  return value.trim();
}
