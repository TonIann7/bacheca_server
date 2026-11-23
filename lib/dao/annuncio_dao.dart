import '../models/annuncio.dart'; // il modello Annuncio
import 'json_store.dart'; // la JsonCollection

class AnnuncioDao {
  final JsonCollection _col; // collezione salvata in data/annunci.json

  AnnuncioDao(this._col);

  Future<void> load() => _col.load(); // carica il file all'avvio

  // Tutti gli annunci, dal più recente al più vecchio.
  List<Annuncio> all() {
    final list = _col.all().map(Annuncio.fromJson).toList(); // converte ogni Map in Annuncio
    list.sort((a, b) => b.id.compareTo(a.id)); // id più alto = più recente, quindi prima
    return list;
  }

  // Solo gli annunci di una certa azienda (per l'area riservata).
  List<Annuncio> byAzienda(int aziendaId) =>
      all().where((a) => a.aziendaId == aziendaId).toList();

  // Un annuncio per id, oppure null se non esiste.
  Annuncio? findById(int id) {
    for (final m in _col.all()) {
      if (m['id'] == id) return Annuncio.fromJson(m);
    }
    return null;
  }

  // Crea e salva un nuovo annuncio.
  Future<Annuncio> create({
    required int aziendaId,
    required String aziendaNome,
    required String titolo,
    required String descrizione,
    required String sede,
  }) async {
    final annuncio = Annuncio(
      id: _col.nextId(), // nuovo id progressivo
      aziendaId: aziendaId,
      aziendaNome: aziendaNome,
      titolo: titolo,
      descrizione: descrizione,
      sede: sede,
      createdAt: DateTime.now().toUtc().toIso8601String(), // adesso, in formato ISO
    );
    _col.add(annuncio.toJson()); // aggiunge alla cache
    await _col.save(); // scrive su data/annunci.json
    return annuncio;
  }
}