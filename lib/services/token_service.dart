import 'dart:convert'; // base64Url
import 'dart:math'; // Random

class TokenService {
  final Map<String, int> _tokens = {}; // token -> id dell'azienda (tenuto solo in memoria)
  final Random _rng = Random.secure(); // generatore casuale sicuro

  // Crea un nuovo token per l'azienda indicata e lo memorizza.
  String issue(int aziendaId) {
    final bytes = List<int>.generate(32, (_) => _rng.nextInt(256)); // 32 byte casuali: impossibile indovinarli
    final token = base64Url.encode(bytes).replaceAll('=', ''); // convertiti in testo, senza i "=" finali
    _tokens[token] = aziendaId; // ricorda a chi appartiene il token
    return token; // il token viene mandato all'app
  }

  // Dato un token, restituisce l'id dell'azienda (o null se il token non è valido).
  int? aziendaIdFor(String token) => _tokens[token];

  // Logout: il token viene cancellato e non funziona più.
  void revoke(String token) => _tokens.remove(token);
}