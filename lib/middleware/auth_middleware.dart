import 'package:shelf/shelf.dart'; // Request, Response, Middleware, Handler

import '../dao/azienda_dao.dart'; // per trovare l'azienda dato il suo id
import '../models/azienda.dart'; // il modello Azienda
import '../services/token_service.dart'; // per verificare i token
import 'error_middleware.dart'; // jsonError

const String _aziendaKey = 'bacheca.azienda'; // "etichetta" con cui salviamo l'azienda nella richiesta
const String _tokenKey = 'bacheca.token'; // "etichetta" con cui salviamo il token nella richiesta

// Restituisce l'azienda autenticata che ha fatto la richiesta (null se è un candidato/ospite).
Azienda? currentAzienda(Request request) =>
    request.context[_aziendaKey] as Azienda?;

// Restituisce il token della richiesta (null se assente o non valido).
String? currentToken(Request request) => request.context[_tokenKey] as String?;

// Legge l'header "Authorization: Bearer <token>" di ogni richiesta.
Middleware authMiddleware(TokenService tokens, AziendaDao aziende) {
  return (Handler inner) { // "inner" è il resto del server (la Cascade)
    return (Request request) { // funzione eseguita per OGNI richiesta
      var req = request; // di partenza, la richiesta così com'è
      final header = request.headers['authorization']; // es. "Bearer 1caKbyQ79..."
      if (header != null && header.toLowerCase().startsWith('bearer ')) { // c'è un token?
        final token = header.substring(7).trim(); // toglie "Bearer " (7 caratteri) e tiene il token
        final aziendaId = tokens.aziendaIdFor(token); // a chi appartiene?
        if (aziendaId != null) { // token valido
          final azienda = aziende.findById(aziendaId); // recupera l'azienda
          if (azienda != null) {
            req = request.change( // crea una copia della richiesta con allegati azienda e token
              context: {_aziendaKey: azienda, _tokenKey: token},
            );
          }
        }
      }
      return inner(req); // passa la richiesta (eventualmente "arricchita") al resto del server
    };
  };
}

// "Guardia": protegge un endpoint riservato alle aziende loggate.
Handler guard(Handler handler) {
  return (Request request) {
    if (currentAzienda(request) == null) { // nessuna azienda autenticata?
      return jsonError(401, 'Autenticazione richiesta'); // 401 = serve il login
    }
    return handler(request); // ok: esegue l'endpoint vero
  };
}