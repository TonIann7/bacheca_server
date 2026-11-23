import 'package:shelf/shelf.dart'; // Request, Response
import 'package:shelf_router/shelf_router.dart'; // Router

import '../dao/annuncio_dao.dart';
import '../dao/candidatura_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart'; // guard, currentAzienda
import '../middleware/error_middleware.dart'; // jsonResponse
import '../utils/validators.dart'; // readJsonObject, requiredText

class AnnuncioController {
  final AnnuncioDao annunci;
  final CandidaturaDao candidature; // serve per contare le candidature di ogni annuncio

  AnnuncioController(this.annunci, this.candidature);

  Router get router {
    final r = Router();
    r.get('/api/annunci', _list); // R5: bacheca pubblica
    r.get('/api/annunci/<id|[0-9]+>', _get); // R5: dettaglio pubblico ("[0-9]+" = solo numeri)
    r.post('/api/annunci', guard(_create)); // R4: pubblicazione (solo aziende loggate)
    r.get('/api/me/annunci', guard(_mine)); // R7: "i miei annunci" (area riservata)
    return r;
  }

  // GET /api/annunci -> lista di tutti gli annunci
  Response _list(Request req) =>
      jsonResponse(annunci.all().map((a) => a.toJson()).toList());

  // GET /api/annunci/3 -> l'annuncio con id 3 (il router passa "3" come parametro id)
  Response _get(Request req, String id) {
    final annuncio = annunci.findById(int.parse(id)); // la regex garantisce che sia un numero
    if (annuncio == null) {
      throw ApiException(404, 'Annuncio non trovato');
    }
    return jsonResponse(annuncio.toJson());
  }

  // POST /api/annunci   body: {"titolo": ..., "descrizione": ..., "sede": ...}
  Future<Response> _create(Request req) async {
    final azienda = currentAzienda(req)!; // chi sta pubblicando ("!" perché guard garantisce il login)
    final body = await readJsonObject(req);
    final titolo = requiredText(body, 'titolo', 'Titolo'); // obbligatorio
    final descrizione = requiredText(body, 'descrizione', 'Descrizione'); // obbligatoria
    final sede = (body['sede'] is String) ? (body['sede'] as String).trim() : ''; // facoltativa
    final annuncio = await annunci.create(
      aziendaId: azienda.id, // l'autore lo decide il SERVER dal token, non il client
      aziendaNome: azienda.nome,
      titolo: titolo,
      descrizione: descrizione,
      sede: sede,
    );
    return jsonResponse(annuncio.toJson(), status: 201); // 201 = Created
  }

  // GET /api/me/annunci -> annunci dell'azienda loggata, ciascuno con il numero di candidature
  Response _mine(Request req) {
    final azienda = currentAzienda(req)!;
    final lista = annunci.byAzienda(azienda.id).map((a) => {
          ...a.toJson(), // "..." copia tutti i campi dell'annuncio...
          'numCandidature': candidature.countByAnnuncio(a.id), // ...e aggiunge il conteggio
        });
    return jsonResponse(lista.toList());
  }
}