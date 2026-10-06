# Notizen für Agenten

Hugo-Website von Moritz Valentin Bartl, zweisprachig (de/en), ausgeliefert an
zwei Adressen. Die ausführlichen Begründungen stehen jeweils als Kommentar in
der betroffenen Datei -- diese Datei sagt nur, wo man nachsieht.

## Bauen

```
hugo --environment beruehrungen   # https://berührungen.com/  (Punycode: xn--berhrungen-ceb.com)
hugo --environment innenreise     # https://www.innenreisebegleitung.de/
```

`--environment` ist Pflicht. Ohne das Flag fehlt die `baseURL`, und der Bau
bricht mit „params.email fehlt" ab -- Absicht, damit nicht versehentlich die
falsche Adresse verteilt wird.

Konfiguration liegt in `config/_default/` (gemeinsam) plus
`config/beruehrungen/` bzw. `config/innenreise/` (baseURL, E-Mail, Untertitel).
Mehr unterscheidet die beiden Auslieferungen nicht.

`./publish.sh` baut beide nacheinander und überträgt sie per `rsync --delete`
auf denselben Server. Argumente gehen an rsync durch, also `./publish.sh
--dry-run` vor einem Lauf mit Löschungen.

Wegen `canonifyURLs = true` steckt die baseURL in fast jeder erzeugten Datei;
die beiden Bauten sind wirklich zwei Bauten, nicht einer, der zweimal
hochgeladen wird. `publish.sh` leert `public/` deshalb zwischen den Läufen.

## Adressen und Umleitungen

Die URL einer Seite steuert der `slug` im Front Matter, nicht der Dateiname.
Verweise im Inhalt laufen über `{{< ref "datei.md" >}}` und bleiben damit beim
Umbenennen gültig -- eine Seite umbenennen heißt in der Regel: Slug ändern,
Dateiname lassen.

Beim Umbenennen zusätzlich:

1. `aliases: ["/alte-adresse/"]` ins Front Matter. Hugo setzt den
   Sprachpräfix selbst davor; für die englische Fassung also
   `/why-not-a-therapist/`, nicht `/en/why-not-a-therapist/`.
2. Eine 301-Regel in `assets/htaccess.tmpl` zu den übrigen Altadressen. Der
   Server greift vor den Alias-Seiten; die bleiben nur als Rückfall.

Die `.htaccess` wird **nicht** aus `static/` kopiert, sondern aus
`assets/htaccess.tmpl` erzeugt (`layouts/index.html`, einmal je Bau), weil
zwei Regeln von der Adresse abhängen. Eine Datei `static/.htaccess` würde
stillschweigend überschrieben.

In `assets/htaccess.tmpl` darf der Hostname in keiner `RewriteCond` wörtlich
stehen: bei berührungen.com kommt der Host als Punycode an, ein Vergleich
gegen die Umlautform träfe nie zu und die daran hängende Umleitung liefe
endlos. Näheres im Kopf der Datei.

## Inhalt

* Übersetzungen über Dateinamen-Suffix: `ueber.md` (de) ↔ `ueber.en.md` (en).
  Deutsch liegt unter `/`, Englisch unter `/en/`.
* Eine Inhaltsänderung an der deutschen Fassung ist erst fertig, wenn die
  englische nachgezogen ist -- die beiden laufen leicht auseinander.
* Die englischen Fassungen folgen amerikanischer Rechtschreibung
  (*practice*, *license*, *recognized*, *organizational*, *program*,
  *counseling*) und setzen als Gedankenstrich den Geviertstrich mit
  Leerzeichen (` — `), nicht ` – ` oder ` -- `. Ausgenommen sind wörtliche
  Zitate und Titel: britische Schreibweisen und Striche in Zitaten,
  Buch-, Kurs- und Veranstaltungstiteln bleiben, wie sie in der Quelle
  stehen. Die deutschen Fassungen behalten ihre eigene Zeichensetzung
  (`„…“`, `»…«`, Halbgeviertstrich).
* Menüeinträge stehen pro Seite im Front Matter (`menus.main.weight`), es gibt
  keine automatische Menüerzeugung.
* Die E-Mail-Adresse steht nie im Inhalt, sondern kommt über den Shortcode
  `{{< email >}}` aus der Umgebungskonfiguration.
* Bilder gehen durch `layouts/_default/_markup/render-image.html` (srcset,
  WebP, width/height, lazy ab dem zweiten Bild). Normales
  `![](/images/x.jpg)` genügt.
* Volle Bildoriginale liegen unversioniert in `originals/`; vier lizenzierte
  Dateien unter `assets/images/` und `static/images/social/` sind ebenfalls
  aus der Versionierung genommen (siehe `.gitignore`). Nach einem frischen
  Klon fehlen sie.

## Konventionen

* Alles im Repo ist deutsch: Kommentare, Commit-Nachrichten, diese Datei.
* Kommentare erklären das *Warum*, oft mit Datum und Commit-Verweis. Diesen
  Stil beibehalten, statt zu kürzen. Mehrere Kommentare warnen ausdrücklich
  vor dem „Aufräumen" scheinbarer Dopplungen (z. B. `noindex`-Header *und*
  `robots.txt`-Disallow) -- das ist Absicht.
* Das Theme `hugo-coder` ist ein Git-Submodul unter `themes/` und wird als
  Modul mit eigenen Mounts eingebunden (spart 1,1 MB ungenutzte Schriften).
  Nichts darin ändern; Anpassungen gehören nach `layouts/` bzw. `assets/scss/`.

## Prüfen

Nach Änderungen an Adressen oder `.htaccess`:

```
hugo --environment beruehrungen --cleanDestinationDir --destination "$TMPDIR/hugotest"
```

und im Ergebnis die erzeugte `.htaccess` sowie die Zielverzeichnisse ansehen.
Nach dem Deploy die Weiterleitungen live prüfen, und zwar auf **beiden**
Adressen:

```
curl -sS -o /dev/null -w '%{http_code} -> %{redirect_url}\n' https://xn--berhrungen-ceb.com/alte-adresse/
```
