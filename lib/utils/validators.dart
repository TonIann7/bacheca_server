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

// Email obbligatoria e con un formato plausibile (testo@testo.testo).
String requiredEmail(Map<String, dynamic> body) {
  final email = requiredText(body, 'email', 'Email'); // prima: non deve essere vuota
  final valida = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email); // espressione regolare: qualcosa@qualcosa.qualcosa
  if (!valida) {
    throw ApiException(422, 'Email non valida'); // 422 = dati non validi
  }
  return email.toLowerCase(); // salviamo le email sempre in minuscolo
}

// Password obbligatoria, lunga almeno 6 caratteri (non facciamo trim: gli spazi possono far parte della password).
String requiredPassword(Map<String, dynamic> body) {
  final password = body['password']; // valore inviato dall'app
  if (password is! String || password.length < 6) { // mancante, non testo, oppure troppo corta
    throw ApiException(422, 'La password deve avere almeno 6 caratteri');
  }
  return password;
}
