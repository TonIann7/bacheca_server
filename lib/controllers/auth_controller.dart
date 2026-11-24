import 'package:shelf/shelf.dart'; // Request, Response
import 'package:shelf_router/shelf_router.dart'; // Router

import '../dao/azienda_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart'; // guard, currentAzienda, currentToken
import '../middleware/error_middleware.dart'; // jsonResponse
import '../services/password_service.dart';
import '../services/token_service.dart';
import '../utils/validators.dart'; // readJsonObject, requiredText, requiredEmail, requiredPassword

class AuthController {
  final AziendaDao aziende; // accesso ai dati delle aziende
  final TokenService tokens; // gestione dei token

  AuthController(this.aziende, this.tokens); // li riceve da server.dart

  // L'elenco degli endpoint gestiti da questo controller.
  Router get router {
    final r = Router();
    r.post('/api/auth/register', _register); // R1: registrazione (pubblico)
    r.post('/api/auth/login', _login); // R2: login (pubblico)
    r.post('/api/auth/logout', guard(_logout)); // R3: logout (solo se loggati)
    r.get(
      '/api/auth/me',
      guard(_me),
    ); // "chi sono?" (servirà all'app per ripristinare la sessione)
    return r;
  }

  // POST /api/auth/register   body: {"nome": ..., "email": ..., "password": ...}
  Future<Response> _register(Request req) async {
    final body = await readJsonObject(req); // legge il JSON inviato dall'app
    final nome = requiredText(
      body,
      'nome',
      'Nome azienda',
    ); // obbligatorio, altrimenti 422
    final email = requiredEmail(body); // obbligatoria e valida, altrimenti 422
    final password = requiredPassword(
      body,
    ); // almeno 6 caratteri, altrimenti 422
    final salt =
        PasswordService.generateSalt(); // salt casuale per questa azienda
    final azienda = await aziende.create(
      // salva su file (409 se l'email esiste già)
      nome: nome,
      email: email,
      passwordHash: PasswordService.hash(password, salt),
      // salva l'hash, non la password
      salt: salt,
    );
    return jsonResponse(
      azienda.toPublicJson(),
      status: 201,
    ); // 201 = account creato; niente token: il login è un passo separato
  }

  // POST /api/auth/login   body: {"email": ..., "password": ...}
  Future<Response> _login(Request req) async {
    final body = await readJsonObject(req);
    final email = body['email'];
    final password = body['password'];
    if (email is! String || password is! String) {
      // campi mancanti o non testuali
      throw ApiException(422, 'Email e password obbligatorie');
    }
    final azienda = aziende.findByEmail(email.trim()); // cerca l'azienda
    if (azienda == null || // email inesistente, OPPURE...
        !PasswordService.verify(password, azienda.salt, azienda.passwordHash)) {
      // ...password sbagliata
      throw ApiException(
        401,
        'Credenziali non valide',
      ); // stesso messaggio nei due casi: non riveliamo quale campo è errato
    }
    final token = tokens.issue(azienda.id); // nuovo token
    return jsonResponse({
      'token': token,
      'azienda': azienda.toPublicJson(),
    }); // 200 OK
  }

  // POST /api/auth/logout   header: Authorization: Bearer <token>
  Response _logout(Request req) {
    final token = currentToken(req); // il token di questa richiesta
    if (token != null)
      tokens.revoke(token); // lo invalida: da ora non funziona più
    return Response(204); // 204 = ok, nessun contenuto da restituire
  }

  // GET /api/auth/me   header: Authorization: Bearer <token>
  // "!" perché guard ci garantisce che qui l'azienda c'è sempre.
  Response _me(Request req) =>
      jsonResponse(currentAzienda(req)!.toPublicJson());
}
