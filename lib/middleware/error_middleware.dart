import 'dart:convert'; ///trasforma oggetti Dart in testo JSON
import 'dart:ffi';
import 'dart:io';///stdderr -> terminale

import 'package:shelf/shelf.dart';

import '../errors/api_exception.dart';

const Map<String, String> _jsonHeaders = {
  'content-type': 'application/json; charset=utf-8',
};

///Risposta Standard JSON
Response jsonResponse(Object? body, {int status = 200}) =>
    Response(status, body: jsonEncode(body), headers: _jsonHeaders);

///Risposta di errore
Response jsonError(int status, String message) =>
    jsonResponse({'error': message}, status: status);

Middleware errorMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      try { ///prova a far gestire la richiesta
        return await inner(request);
      } on ApiException catch (e) { ///altrimenti cattura le eccezioni
        return jsonError(e.status, e.message);
      } on FormatException {
        return jsonError(400, 'JSON non valido'); ///BAD request
      } catch (e, st) {
        stderr.writeln('Errore interno (${e.runtimeType}): $st');
        return jsonError(500, 'Errore interno del server');
      }
    };
  };
}
