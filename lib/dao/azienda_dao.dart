//DATA ACCES OBJECT -> Cerca e salva aziende
import '../errors/api_exception.dart';//per lanciare errori
import '../models/azienda.dart';//il Modello Azienda
import 'json_store.dart';

class AziendaDao{
    final JsonCollection _col;
    AziendaDao(this._col);

    Future<void> load() => _col.load();

    //Cerca azienda con id => resituisce null se non esiste
    Azienda? findById(int id){
        for(final m in _col.all()){
            if(m['id'] == id) return Azienda.fromJson(m);//trovata ->oggetto azienda
        }
        return null;//non trovata
    }

    Azienda? findByEmail(String email){
        final lower=email.toLowerCase();
        for (final m in _col.all()) {
        if ((m['email'] as String).toLowerCase() == lower) {
        return Azienda.fromJson(m);
      }
    }
    return null;
  }
    
    // Crea e salva una nuova azienda. "async" perché deve aspettare il salvataggio su file.
  Future<Azienda> create({
    required String nome,
    required String email,
    required String passwordHash,
    required String salt,
  }) async {
    if (findByEmail(email) != null) { // email già usata da un'altra azienda?
      throw ApiException(409, 'Email già registrata'); // 409 = Conflict
    }
    final azienda = Azienda(
      id: _col.nextId(), // nuovo id progressivo
      nome: nome,
      email: email,
      passwordHash: passwordHash,
      salt: salt,
      createdAt: DateTime.now().toUtc().toIso8601String(), // data e ora attuali in formato ISO
    );
    _col.add(azienda.toJson()); // la aggiunge alla cache (versione completa, con hash)
    await _col.save(); // e la scrive sul file data/aziende.json
    return azienda; // restituisce l'azienda appena creata
  }
}