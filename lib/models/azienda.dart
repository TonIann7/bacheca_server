//Modello per l'azienda registrata
class Azienda {
    final int id;//id univoco
    final String nome;
    final String email;
    final String passwordHash;
    final String salt;//cifrare password
    final String createdAt; //data registrazione in formato ISO (2026-11-23T10:00:00Z)

    const Azienda({
        required this.id,
        required this.nome,
        required this.email,
        required this.passwordHash,
        required this.salt,
        required this.createdAt,
    });

    //Factory -> costruttore speciale che crea un'azienda a partire da una Map letta dal JSON.
    factory Azienda.fromJson(Map<String,dynamic> j)=> Azienda(
        id: j['id'] as int,
        nome: j['nome'] as String,
        email: j['email'] as String,
        passwordHash: j['passwordHash'] as String,
        salt: j['salt'] as String,
        createdAt: j['createdAt'] as String,
    );

    // Map COMPLETA: usata solo per salvare su file (contiene hash e salt).
  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'passwordHash': passwordHash,
        'salt': salt,
        'createdAt': createdAt,
      };

  // Map PUBBLICA: è quella che mandiamo all'app. Niente hash né salt!
  Map<String, dynamic> toPublicJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'createdAt': createdAt,
      };

}