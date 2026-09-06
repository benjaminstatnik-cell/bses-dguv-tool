# DGUV Vorgangstool - Pilot

Ziel: aus dem Mockup (`04-Techniker-Interface-Mobile/mockup-pruef-app.html`) ein echtes, gehostetes Pilot-Tool bauen. Zwei Oberflächen, eine Datenbasis.

## Zwei Oberflächen (je eigene Webadresse)

1. **Büro / Generator** - Plan hochladen -> Zwilling auslesen -> Prüfvorgang generieren + zuweisen. (Später: 4. Reiter „DGUV-Generator" unter Operations -> Dispatching.)
2. **Prüf-App (mobil)** - Vorgang vor Ort abarbeiten: Besichtigen/Erproben/Messen, Messgerät wählen, Ampel live, Messstelle in alle Stationen übernehmen, Bericht erzeugen. (Später: Unterpunkt im PV-Techniker-Interface.)

## Namens- / Adress-Vorschlag (zur Auswahl)

| Variante | Generator (Büro) | App (mobil) |
|---|---|---|
| **A (Empfehlung)** | `dguv-generator.pages.dev` | `dguv-app.pages.dev` |
| B (eine Dachmarke) | `dguv-copilot.pages.dev/generator` | `dguv-copilot.pages.dev/app` |
| C (Firmenpräfix) | `bses-dguv.pages.dev` | `bses-dguv.pages.dev/app` |

Eigene Domain (z. B. `dguv.bluesun.de`) kommt später davor - muss von euch/DNS gesetzt werden.

## Technik-Plan (nach Namensfreigabe)

1. **Repo** in Org `benjaminstatnik-cell` (z. B. `bses-dguv-tool`), Cloudflare Pages verbunden (Auto-Deploy `main`).
2. **Datenbank:** Supabase BLUECORE, eigenes Schema `dguv` (Anlagen, Vorgänge, Stationen, Prüfpunkte, Messwerte, Messgeräte, Zertifikate). RBAC + Audit ab Tag 1. Mandantenfähig (Kunde kann eigene DB bekommen).
3. **Shell zuerst:** das Mockup als erste Live-Seite deployen (echte Adresse zum Antippen), dann Schritt für Schritt echte Funktion.
4. **Plan-Auslesung:** Skill `digitaler-zwilling` + Claude Vision auf den PVA-Plan -> Komponentenbaum -> Vorgang aus Vorlage V1.5.
5. **Messgeräte-Register:** Codenummer, Typ, Kalibrierdatum, gültig-bis, Zertifikat (PDF); Vorwarn-Job (Telegram/Mail) bei ablaufender Kalibrierung.
6. **Bericht:** unser HTML->PDF-Generator (headless Chrome), BSES- oder Kunden-CI.

## Pilot-Anlage

STK Straßkirchen oder Österberg (Plan liegt vor). Gerber: erst eine Anlage ganz.

> Status 2026-09-06: Ordner angelegt, wartet auf Namensfreigabe -> dann Repo + Cloudflare Pages + Supabase-Schema.
