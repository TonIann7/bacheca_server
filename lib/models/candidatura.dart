// Modello della candidatura inviata da un candidato a un annuncio.
class Candidatura {
  final int id; // identificativo unico
  final int annuncioId; // a quale annuncio si riferisce
  final String nome; // nome del candidato
  final String cognome; // cognome del candidato
  final String email; // email del candidato
  final String cvFile; // nome del file salvato sul server, es. "cv_3.pdf"
  final String cvNomeOriginale; // nome del file scelto dal candidato, es. "CV_Mario_Rossi.pdf"
  final String createdAt; // data di invio in formato ISO

  const Candidatura({
    required this.id,
    required this.annuncioId,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.cvFile,
    required this.cvNomeOriginale,
    required this.createdAt,
  });

  // Crea una Candidatura da una Map letta dal file JSON.
  factory Candidatura.fromJson(Map<String, dynamic> j) => Candidatura(
        id: j['id'] as int,
        annuncioId: j['annuncioId'] as int,
        nome: j['nome'] as String,
        cognome: j['cognome'] as String,
        email: j['email'] as String,
        cvFile: j['cvFile'] as String,
        cvNomeOriginale: j['cvNomeOriginale'] as String,
        createdAt: j['createdAt'] as String,
      );

  // Map COMPLETA: per il salvataggio su file.
  Map<String, dynamic> toJson() => {
        'id': id,
        'annuncioId': annuncioId,
        'nome': nome,
        'cognome': cognome,
        'email': email,
        'cvFile': cvFile,
        'cvNomeOriginale': cvNomeOriginale,
        'createdAt': createdAt,
      };

  // Map PUBBLICA: per l'app. Il nome interno del file non serve al client.
  Map<String, dynamic> toPublicJson() => {
        'id': id,
        'annuncioId': annuncioId,
        'nome': nome,
        'cognome': cognome,
        'email': email,
        'cvNomeOriginale': cvNomeOriginale,
        'createdAt': createdAt,
      };
}