//Eccezione Applicativa : viene convertita in {"error" : message} con lo status indicato

class ApiException implements Exception{ //eccezione cioè lanciabile con throw : throw ApiException(404, 'Annuncio non trovato');
  final int status;//codice http
  final String message; //messaggio

  ApiException(this.status,this.message);

  @override
  String toString() => 'ApiException($status): $message';
}