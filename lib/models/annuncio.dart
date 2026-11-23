// Modello dell'annuncio di lavoro pubblicato da un'azienda.
class Annuncio {
  final int id; // identificativo unico, assegnato dal server
  final int aziendaId; // id dell'azienda che l'ha pubblicato (serve a sapere "di chi è")
  final String aziendaNome; // nome dell'azienda, copiato qui per mostrarlo in bacheca senza altre ricerche
  final String titolo; // es. "Sviluppatore Flutter"
  final String descrizione; // testo libero con i dettagli dell'offerta
  final String sede; // luogo di lavoro (facoltativo: può essere stringa vuota)
  final String createdAt; // data di pubblicazione in formato ISO

  const Annuncio({ // costruttore con parametri nominati
    required this.id,
    required this.aziendaId,
    required this.aziendaNome,
    required this.titolo,
    required this.descrizione,
    required this.sede,
    required this.createdAt,
  });

  // Crea un Annuncio da una Map letta dal file JSON.
  factory Annuncio.fromJson(Map<String, dynamic> j) => Annuncio(
        id: j['id'] as int,
        aziendaId: j['aziendaId'] as int,
        aziendaNome: j['aziendaNome'] as String,
        titolo: j['titolo'] as String,
        descrizione: j['descrizione'] as String,
        sede: (j['sede'] ?? '') as String, // "??": se manca il campo, usa stringa vuota
        createdAt: j['createdAt'] as String,
      );

  // Map usata sia per il file sia per l'app (un annuncio non ha dati segreti).
  Map<String, dynamic> toJson() => {
        'id': id,
        'aziendaId': aziendaId,
        'aziendaNome': aziendaNome,
        'titolo': titolo,
        'descrizione': descrizione,
        'sede': sede,
        'createdAt': createdAt,
      };
}