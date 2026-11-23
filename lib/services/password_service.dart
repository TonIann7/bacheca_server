import 'dart:convert'; // utf8 (testo -> byte) e base64Url (byte -> testo)
import 'dart:math'; // Random

import 'package:crypto/crypto.dart'; // sha256: la funzione di hash (il pacchetto aggiunto in A0)

class PasswordService {
  static final Random _rng = Random.secure(); // generatore casuale "sicuro" (adatto alla crittografia)

  // Genera un "salt": 16 byte casuali trasformati in testo.
  // Due aziende con la stessa password avranno così hash diversi.
  static String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256)); // 16 numeri casuali da 0 a 255
    return base64Url.encode(bytes); // li converte in una stringa leggibile
  }

  // Calcola l'hash SHA-256 di "salt:password". Non si può tornare indietro alla password.
  static String hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  // Verifica una password: ricalcola l'hash e lo confronta con quello salvato.
  static bool verify(String password, String salt, String expectedHash) {
    final actual = hash(password, salt); // hash della password appena inserita
    if (actual.length != expectedHash.length) return false; // lunghezze diverse: sicuramente sbagliata
    var diff = 0; // accumula le differenze carattere per carattere
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i); // "^" vale 0 solo se i caratteri sono uguali
    }
    return diff == 0; // nessuna differenza = password corretta
    // (si confronta sempre tutta la stringa, così il tempo impiegato non rivela nulla: "tempo costante")
  }
}