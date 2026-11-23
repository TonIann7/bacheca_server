import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import '../lib/middleware/error_middleware.dart';

Future <void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  final healt = Router()
    ..get('/api/health', (Request req) => jsonResponse({'status' : 'ok'}));

  final api = Cascade()
  .add(healt.call)
  .add((Request req) => jsonError(404,'Risorsa non trovata'))
  .handler;

  final handler = const Pipeline()
  .addMiddleware(logRequests())
  .addMiddleware(errorMiddleware())
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