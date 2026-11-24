# Bacheca Lavoro - Server

Back-end dell'app "Bacheca Lavoro" (corso EMAD), scritto in Dart con Shelf.
Il front-end è qui: https://github.com/TonIann7/bacheca_app

## Avvio

```bash
dart pub get              # scarica i pacchetti
dart run bin/server.dart  # avvia il server sulla porta 8080
```

All'avvio il server stampa l'indirizzo da usare nell'app.

## Persistenza

- `data/`: aziende, annunci e candidature in file JSON
- `uploads/`: curriculum in PDF (massimo 5 MB)

Le due cartelle vengono create all'avvio e non sono incluse nella repository.

## API

| Metodo | Indirizzo | Accesso | Descrizione |
|---|---|---|---|
| GET | `/api/health` | pubblico | verifica che il server sia attivo |
| POST | `/api/auth/register` | pubblico | registrazione azienda |
| POST | `/api/auth/login` | pubblico | login |
| POST | `/api/auth/logout` | azienda | logout |
| GET | `/api/auth/me` | azienda | dati dell'azienda autenticata |
| GET | `/api/annunci` | pubblico | bacheca |
| GET | `/api/annunci/<id>` | pubblico | dettaglio annuncio |
| POST | `/api/annunci` | azienda | pubblicazione annuncio |
| GET | `/api/me/annunci` | azienda | annunci dell'azienda |
| POST | `/api/annunci/<id>/candidature` | pubblico | invio candidatura |
| GET | `/api/annunci/<id>/candidature` | azienda proprietaria | candidature ricevute |
| GET | `/api/candidature/<id>` | azienda proprietaria | dati del candidato |
| GET | `/api/candidature/<id>/cv` | azienda proprietaria | curriculum in PDF |

Gli endpoint riservati richiedono l'header `Authorization: Bearer <token>`.
Le password sono salvate come hash SHA-256 con salt.