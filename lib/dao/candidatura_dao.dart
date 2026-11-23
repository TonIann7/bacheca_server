import '../models/candidatura.dart'; // il modello Candidatura
import 'json_store.dart'; // la JsonCollection

class CandidaturaDao {
  final JsonCollection _col; // collezione salvata in data/candidature.json

  CandidaturaDao(this._col);

  Future<void> load() => _col.load(); // carica il file all'avvio

  // Tutte le candidature ricevute da un annuncio, dalla più recente.
  List<Candidatura> byAnnuncio(int annuncioId) {
    final list = _col
        .all()
        .map(Candidatura.fromJson) // Map -> Candidatura
        .where((c) => c.annuncioId == annuncioId) // solo quelle di questo annuncio
        .toList();
    list.sort((a, b) => b.id.compareTo(a.id)); // più recenti prima
    return list;
  }

  // Quante candidature ha ricevuto un annuncio (da mostrare nell'area riservata).
  int countByAnnuncio(int annuncioId) =>
      _col.all().where((m) => m['annuncioId'] == annuncioId).length;

  // Una candidatura per id, oppure null.
  Candidatura? findById(int id) {
    for (final m in _col.all()) {
      if (m['id'] == id) return Candidatura.fromJson(m);
    }
    return null;
  }

  // Il prossimo id: serve PRIMA di creare la candidatura, per dare il nome al file del CV.
  int nextId() => _col.nextId();

  // Salva una candidatura già costruita (con l'id ottenuto da nextId()).
  Future<Candidatura> add(Candidatura c) async {
    _col.add(c.toJson()); // aggiunge alla cache
    await _col.save(); // scrive su data/candidature.json
    return c;
  }
}