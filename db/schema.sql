-- DGUV Vorgangstool · Supabase (Postgres) · Schema-Grundgerüst (Pilot)
-- Anlegen in Supabase BLUECORE. RLS-Policies je Rolle folgen im Ausbau (RBAC + Audit ab Tag 1).
-- Mandantenfähig: tenant_id trennt Kunden; ein Kunde kann optional eigenes Schema/Projekt bekommen.

create schema if not exists dguv;

-- Mandanten (BSES + je Kunde)
create table if not exists dguv.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  ci_mode text not null default 'bses',        -- 'bses' | 'kunde'
  brand jsonb,                                   -- {brand, brand_strong, brand_tint, logo_url}
  created_at timestamptz not null default now()
);

-- Messgeräte-Register (mit Kalibrierung + Zertifikat)
create table if not exists dguv.messgeraete (
  id uuid primary key default gen_random_uuid(),
  code_nr text not null unique,                  -- Codenummer / Inventar-Nr.
  typ text not null,                             -- z.B. Fluke 1654b
  hersteller text,
  kalibriert_am date,
  kalibriert_bis date,                           -- Vorwarn-Job prüft dieses Datum
  zertifikat_url text,                           -- PDF-Zertifikat
  aktiv boolean not null default true,
  created_at timestamptz not null default now()
);

-- Anlagen (digitaler Zwilling, aus Plan-Auslesung)
create table if not exists dguv.anlagen (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references dguv.tenants(id),
  name text not null,                            -- PVA Österberg III
  kunde text, adresse text, plz text, ort text,
  nennleistung_kwp numeric,
  wr_typ text, system_typ text default 'zentral', bauform text default 'freiflaeche',
  komponenten jsonb,                             -- Baum L1-L6 aus Auslesung
  created_at timestamptz not null default now()
);

-- Prüfvorgänge
create table if not exists dguv.vorgaenge (
  id uuid primary key default gen_random_uuid(),
  anlage_id uuid references dguv.anlagen(id),
  vorlage_version text not null default '1.5.0',
  pruefdatum date,
  pruefer text,
  prueffrist_jahre int default 4,
  ci_mode text default 'bses',
  status text not null default 'offen',          -- offen|in_arbeit|abgeschlossen|freigegeben
  created_by text, created_at timestamptz not null default now(),
  abgeschlossen_at timestamptz
);

-- Stationen je Vorgang
create table if not exists dguv.stationen (
  id uuid primary key default gen_random_uuid(),
  vorgang_id uuid references dguv.vorgaenge(id) on delete cascade,
  name text not null, sort int default 0
);

-- Prüfpunkte (Besichtigen/Erproben) - G/M/N
create table if not exists dguv.pruefpunkte (
  id uuid primary key default gen_random_uuid(),
  station_id uuid references dguv.stationen(id) on delete cascade,
  saeule text not null,                          -- Besichtigen|Erproben
  bereich text, nr text, text text,
  ergebnis text,                                 -- G|M|N|null
  kommentar text, foto_url text,
  vor_ort_ergaenzt boolean not null default false
);

-- Messwerte (Messen: Erdung/Niederohm/Steckdosen/Generator/GAK/Felder)
create table if not exists dguv.messwerte (
  id uuid primary key default gen_random_uuid(),
  station_id uuid references dguv.stationen(id) on delete cascade,
  gruppe text not null,                          -- erdung|steckdosen|pv_generator|felder|gak
  bauteil text, groesse text, einheit text,
  wert numeric,
  grenzwert_ref text,                            -- Regel-Key aus der Config
  ergebnis text,                                 -- G|gelb|rot (auto aus Grenzwert)
  geraet_id uuid references dguv.messgeraete(id),-- welches Messgerät (+ Zertifikat)
  vor_ort_ergaenzt boolean not null default false,
  erfasst_at timestamptz not null default now()
);

-- Mängel / Kundeninformation (Kennbuchstaben S/M/B/E/O/I/A)
create table if not exists dguv.maengel (
  id uuid primary key default gen_random_uuid(),
  vorgang_id uuid references dguv.vorgaenge(id) on delete cascade,
  station_id uuid references dguv.stationen(id),
  kennbuchstabe text, prioritaet text, text text, frist text
);

-- Audit-Log (jede Eingabe nachvollziehbar)
create table if not exists dguv.audit (
  id bigint generated always as identity primary key,
  akteur text, aktion text, ref_tabelle text, ref_id uuid, payload jsonb,
  at timestamptz not null default now()
);

create index if not exists idx_vorgaenge_status on dguv.vorgaenge(status);
create index if not exists idx_messwerte_station on dguv.messwerte(station_id);
create index if not exists idx_geraete_kal on dguv.messgeraete(kalibriert_bis);

-- Vorwarn-Sicht: Messgeräte mit Kalibrierung, die in den nächsten 90 Tagen abläuft
create or replace view dguv.kalibrierung_faellig as
  select id, code_nr, typ, kalibriert_bis, (kalibriert_bis - current_date) as tage_bis_ablauf
  from dguv.messgeraete
  where aktiv and kalibriert_bis is not null and kalibriert_bis <= current_date + interval '90 days'
  order by kalibriert_bis;
