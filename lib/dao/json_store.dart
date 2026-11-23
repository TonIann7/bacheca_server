import 'dart:async'; //Future->strumenti per codice asincrono
import 'dart:convert'; //leggere e scrivere JSON
import 'dart:io'; //leggere e scrivere file

//Una collezione di oggetti salvata in un file JSON
//Ogni oggetto è una map con una chiave "id" che lo identifica univocamente
class JsonCollection {
    final String path; //percorso del file JSON
    final List<Map<String, dynamic>> _items = []; //oggetti caricati in memoria
    int _lastId = 0; //ultimo id assegnato (più alto tra quelli presenti nella collezione)
    Future<void> _queue = Future<void>.value(); //coda di operazioni asincrone per evitare conflitti di accesso al file 

    JsonCollection(this.path);//costruttore che prende il percorso del file JSON

    Future<void> load() async { //carica gli oggetti dal file JSON
        final file = File(path);//oggetto che rappresenta il file sul disco
        _items.clear(); //svuota la collezione in memoria
        if (await file.exists()) { //se il file esiste
        final text = await file.readAsString(); //legge il contenuto del file come stringa
        if(text.trim().isNotEmpty){//ignora un file vuoto
            final data = jsonDecode(text) as List<dynamic>; //il file contiene una array JSON
            for(final e in data){//per ogni elemento dell'array
                _items.add(Map<String,dynamic>.from(e as Map));//lo aggiunge alla cache come map
            }
        }}
        _lastId=0;//ricalcolo id piu alto
        for(final e in _items){
            final id= e['id'] as int; //id dell'elemento corrente
            if(id > _lastId) _lastId = id; //salva il max
        }
    }
    List<Map<String,dynamic>> all() => List.unmodifiable(_items);
    int nextId() => ++_lastId;//prossimo id libero con pre-incremento
    //aggiunge un elemento alla cache
    void add(Map<String,dynamic> item) => _items.add(item);
    //salva la chache su file
    Future<void> save() {
        final snapshot = const JsonEncoder.withIndent(' ').convert(_items);
        final op = _queue.then((_) => _write(snapshot));//scrive solo dopo la scrittura precedente

        _queue = op.catchError((_) {});//se una scrittura fallisce la coda non resta bloccata
        return op;
    }

    //Scrittura "atomica" -> prima su un file temporaneo, poi lo rinomina.
    //Cosi Se il pc si spegne a metà , il file vero non resta mezzo scritto.
    Future<void> _write(String content) async {
        final tmp = File('$path.tmp');
        await tmp.parent.create(recursive:true); //crea la cartella data
        await tmp.writeAsString(content,flush:true);
        await tmp.rename(path);
    }

            }