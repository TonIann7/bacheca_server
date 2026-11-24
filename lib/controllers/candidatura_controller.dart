import 'dart:convert'; // base64Decode e utf8

import 'package:shelf/shelf.dart'; // Request, Response
import 'package:shelf_router/shelf_router.dart'; // Router (e req.params)

import '../dao/annuncio_dao.dart';
import '../dao/candidatura_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart'; // guard, currentAzienda
import '../middleware/error_middleware.dart'; // jsonResponse
import '../models/annuncio.dart';
import '../models/candidatura.dart';
import '../services/cv_storage.dart';
import '../utils/validators.dart'; // readJsonObject, requiredText, requiredEmail

const int _maxCvBytes = 5 * 1024 * 1024; // dimensione massima del CV: 5 MB

class CandidaturaController {
  final AnnuncioDao annunci;
  final CandidaturaDao candidature;
  final CvStorage storage; // dove salvare i PDF

  CandidaturaController(this.annunci, this.candidature, this.storage);

  Router get router {
    final r = Router();
    r.post('/api/annunci/<id|[0-9]+>/candidature', _create); // R6: candidatura (pubblica, niente login)
    r.get('/api/annunci/<id|[0-9]+>/candidature', guard(_listForAnnuncio)); // R7: candidature ricevute
    r.get('/api/candidature/<id|[0-9]+>', guard(_get)); // R7: dettaglio di una candidatura
    r.get('/api/candidature/<id|[0-9]+>/cv', guard(_cv)); // R7: scarica il PDF del curriculum
    return r;
  }

  // Trova l'annuncio indicato nell'indirizzo, oppure 404.
  Annuncio _annuncioOr404(String id) {
    final annuncio = annunci.findById(int.parse(id));
    if (annuncio == null) throw ApiException(404, 'Annuncio non trovato');
    return annuncio;
  }

  // Trova una candidatura E controlla che appartenga a un annuncio dell'azienda loggata.
  Candidatura _candidaturaDellAzienda(Request req) {
    final id = int.parse(req.params['id']!); // con guard() l'id si legge da req.params
    final c = candidature.findById(id);
    if (c == null) throw ApiException(404, 'Candidatura non trovata');
    final annuncio = annunci.findById(c.annuncioId);
    if (annuncio == null || annuncio.aziendaId != currentAzienda(req)!.id) {
      throw ApiException(403, 'Non puoi vedere questa candidatura'); // 403 = è di un'altra azienda
    }
    return c;
  }

  // POST /api/annunci/3/candidature
  // body: {"nome", "cognome", "email", "cvNome": "cv.pdf", "cvBase64": "<il PDF codificato in base64>"}
  Future<Response> _create(Request req, String id) async {
    if (currentAzienda(req) != null) { // c'è un'azienda loggata
      throw ApiException(403, 'Le aziende non possono candidarsi'); // 403 = operazione non consentita
    }
    final annuncio = _annuncioOr404(id); // l'annuncio deve esistere
    final body = await readJsonObject(req);
    final nome = requiredText(body, 'nome', 'Nome');
    final cognome = requiredText(body, 'cognome', 'Cognome');
    final email = requiredEmail(body);
    final cvNome = requiredText(body, 'cvNome', 'Curriculum'); // nome originale del file
    final cvBase64 = requiredText(body, 'cvBase64', 'Curriculum'); // contenuto del file, come testo

    List<int> bytes; // qui finiranno i byte veri del PDF
    try {
      bytes = base64Decode(cvBase64); // da testo base64 a byte
    } on FormatException {
      throw ApiException(422, 'Curriculum non valido');
    }
    if (bytes.length > _maxCvBytes) {
      throw ApiException(422, 'Il curriculum supera i 5 MB');
    }
    // Ogni PDF inizia con i caratteri "%PDF": così rifiutiamo file di altro tipo.
    if (bytes.length < 4 || utf8.decode(bytes.sublist(0, 4), allowMalformed: true) != '%PDF') {
      throw ApiException(422, 'Il curriculum deve essere un file PDF');
    }

    final newId = candidature.nextId(); // id della nuova candidatura
    final cvFile = await storage.save(newId, bytes); // salva il PDF in uploads/cv_<id>.pdf
    final c = await candidature.add(Candidatura(
      id: newId,
      annuncioId: annuncio.id,
      nome: nome,
      cognome: cognome,
      email: email,
      cvFile: cvFile,
      cvNomeOriginale: cvNome,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    ));
    return jsonResponse(c.toPublicJson(), status: 201); // 201 = candidatura registrata
  }

  // GET /api/annunci/3/candidature -> solo se l'annuncio è dell'azienda loggata
  Response _listForAnnuncio(Request req) {
    final annuncio = _annuncioOr404(req.params['id']!);
    if (annuncio.aziendaId != currentAzienda(req)!.id) {
      throw ApiException(403, 'Questo annuncio non è tuo'); // un'azienda non vede le candidature altrui
    }
    final lista = candidature.byAnnuncio(annuncio.id).map((c) => c.toPublicJson());
    return jsonResponse(lista.toList());
  }

  // GET /api/candidature/5 -> i dati del candidato
  Response _get(Request req) => jsonResponse(_candidaturaDellAzienda(req).toPublicJson());

  // GET /api/candidature/5/cv -> il file PDF (questa risposta NON è JSON)
  Future<Response> _cv(Request req) async {
    final c = _candidaturaDellAzienda(req); // controlla anche che sia dell'azienda loggata
    final bytes = await storage.read(c.cvFile);
    if (bytes == null) throw ApiException(404, 'Curriculum non trovato');
    return Response.ok(
      bytes, // il corpo della risposta sono i byte del PDF
      headers: {
        'content-type': 'application/pdf', // dice al client che è un PDF
        'content-disposition': 'inline; filename="${c.cvFile}"', // nome suggerito per il file
      },
    );
  }
}