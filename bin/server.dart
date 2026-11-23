import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import '../lib/controllers/auth_controller.dart'; // NUOVO
import '../lib/dao/azienda_dao.dart'; // NUOVO
import '../lib/dao/json_store.dart'; // NUOVO
import '../lib/middleware/auth_middleware.dart'; // NUOVO
import '../lib/middleware/error_middleware.dart';
import '../lib/services/token_service.dart'; // NUOVO

Future<void> main() async {
  final dataDir = Platform.environment['DATA_DIR'] ?? 'data'; // NUOVO: cartella dei dati (default "data")
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  await Directory(dataDir).create(recursive: true); // NUOVO: crea data/ se non esiste

  // NUOVO: DAO delle aziende, salvato in data/aziende.json, caricato all'avvio
  final aziendaDao = AziendaDao(JsonCollection('$dataDir/aziende.json'));
  await aziendaDao.load();

  final tokens = TokenService(); // NUOVO: gestore dei token (uno solo per tutto il server)

  final health = Router()
    ..get('/api/health', (Request req) => jsonResponse({'status': 'ok'}));

  final api = Cascade()
      .add(health.call)
      .add(AuthController(aziendaDao, tokens).router.call) // NUOVO: endpoint /api/auth/...
      .add((Request req) => jsonError(404, 'Risorsa non trovata'))
      .handler;

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(errorMiddleware())
      .addMiddleware(authMiddleware(tokens, aziendaDao)) // NUOVO: legge il token di ogni richiesta
      .addHandler(api);


  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Bacheca beckend in ascolto sulla porta ${server.port}');
  print('Emulatore android: http://10.0.2.2:${server.port}');
  try{
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final iface in interfaces) {
      for(final addr in iface.addresses){
        print('Usa questo URL nell\'app http://${addr.address}:${server.port}');
      }
    }
  } catch(_){
    print('Impossibile leggere gli indirizzi di rete locali');
  }
}