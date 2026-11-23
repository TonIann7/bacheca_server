import 'dart:io'; // File e Directory

// Salva e legge i file dei curriculum nella cartella "uploads".
class CvStorage {
  final String dir; // percorso della cartella, es. "uploads"

  CvStorage(this.dir);

  // Crea la cartella all'avvio del server, se non esiste.
  Future<void> init() => Directory(dir).create(recursive: true);

  // Scrive i byte del PDF in un file e restituisce il nome del file creato.
  Future<String> save(int candidaturaId, List<int> bytes) async {
    final fileName = 'cv_$candidaturaId.pdf'; // nome deciso dal server: niente nomi "pericolosi" dal client
    await File('$dir/$fileName').writeAsBytes(bytes, flush: true); // scrive sul disco
    return fileName;
  }

  // Legge i byte di un CV già salvato (null se il file non c'è più).
  Future<List<int>?> read(String fileName) async {
    final file = File('$dir/$fileName');
    if (!await file.exists()) return null; // file mancante
    return file.readAsBytes(); // tutti i byte del PDF
  }
}