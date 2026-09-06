# DGUV Vorgangstool (Pilot)

Werkzeug für die DGUV-V3-Prüfung von PV-Anlagen: aus dem Anlagenplan wird der anlagenspezifische Prüfvorgang erzeugt, den der Techniker vor Ort in einer Prüf-App abarbeitet. Am Ende fällt der Prüfbericht als PDF heraus.

## Zwei Oberflächen

- **`generator/`** – Büro: Plan hochladen → Komponentenbaum auslesen → Prüfvorgang generieren + zuweisen.
- **`app/`** – mobile Prüf-App: Vorgang vor Ort abarbeiten (Besichtigen · Erproben · Messen), Messgerät wählen, Grenzwert-Ampel live, Messstelle vor Ort ergänzen, Bericht erzeugen.

## Datenbank

- **`db/schema.sql`** – Postgres/Supabase-Schema `dguv`: Anlagen, Vorgänge, Stationen, Prüfpunkte, Messwerte, Messgeräte (inkl. Kalibrier-Zertifikate), Mängel, Audit. Mandantenfähig.

## Prinzipien

- Eine config-getriebene Prüfvorlage (Prüfumfang + Grenzwerte), aus dem digitalen Zwilling je Anlage instanziiert.
- Drei DGUV-Säulen: Besichtigen · Erproben · Messen.
- Messgeräte mit Codenummer + Kalibrier-Zertifikat; automatische Vorwarnung vor Ablauf der Kalibrierung.
- Offline-fest fürs Feld; RBAC + Audit.
- Berichte in eigener CI oder White-Label in Kunden-CI.

## Status

Pilot-Shell. Auslesung, DB-Anbindung und Berichtserzeugung folgen im Ausbau. Pilot-Anlage: Solarpark Straßkirchen bzw. Österberg.
