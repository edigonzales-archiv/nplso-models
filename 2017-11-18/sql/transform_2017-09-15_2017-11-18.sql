DELETE FROM nplso_neu.transfermetadaten_datenbestand;
DELETE FROM nplso_neu.transfermetadaten_amt;

DELETE FROM nplso_neu.nutzungsplanung_typ_grundnutzung_dokument;
DELETE FROM nplso_neu.nutzungsplanung_typ_ueberlagernd_flaeche_dokument;
DELETE FROM nplso_neu.nutzungsplanung_typ_ueberlagernd_linie_dokument;
DELETE FROM nplso_neu.nutzungsplanung_typ_ueberlagernd_punkt_dokument;
DELETE FROM nplso_neu.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument;
DELETE FROM nplso_neu.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument;
DELETE FROM nplso_neu.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument;

DELETE FROM nplso_neu.nutzungsplanung_grundnutzung_pos;
DELETE FROM nplso_neu.nutzungsplanung_grundnutzung;
DELETE FROM nplso_neu.nutzungsplanung_typ_grundnutzung;

DELETE FROM nplso_neu.nutzungsplanung_ueberlagernd_flaeche_pos;
DELETE FROM nplso_neu.nutzungsplanung_ueberlagernd_flaeche;
DELETE FROM nplso_neu.nutzungsplanung_typ_ueberlagernd_flaeche;

DELETE FROM nplso_neu.nutzungsplanung_ueberlagernd_linie_pos;
DELETE FROM nplso_neu.nutzungsplanung_ueberlagernd_linie;
DELETE FROM nplso_neu.nutzungsplanung_typ_ueberlagernd_linie;

DELETE FROM nplso_neu.nutzungsplanung_ueberlagernd_punkt_pos;
DELETE FROM nplso_neu.nutzungsplanung_ueberlagernd_punkt;
DELETE FROM nplso_neu.nutzungsplanung_typ_ueberlagernd_punkt;

DELETE FROM nplso_neu.erschlssngsplnung_erschliessung_flaechenobjekt_pos;
DELETE FROM nplso_neu.erschlssngsplnung_erschliessung_flaechenobjekt;
DELETE FROM nplso_neu.erschlssngsplnung_typ_erschliessung_flaechenobjekt;

DELETE FROM nplso_neu.erschlssngsplnung_erschliessung_linienobjekt_pos;
DELETE FROM nplso_neu.erschlssngsplnung_erschliessung_linienobjekt;
DELETE FROM nplso_neu.erschlssngsplnung_typ_erschliessung_linienobjekt;

DELETE FROM nplso_neu.erschlssngsplnung_erschliessung_punktobjekt_pos;
DELETE FROM nplso_neu.erschlssngsplnung_erschliessung_punktobjekt;
DELETE FROM nplso_neu.erschlssngsplnung_typ_erschliessung_punktobjekt;

DELETE FROM nplso_neu.rechtsvorschrften_hinweisweiteredokumente;
DELETE FROM nplso_neu.rechtsvorschrften_dokument;


---- Transfermetatdaten
WITH transfermetadaten_amt AS
(
  SELECT 
    t_id AS transfermetadaten_amt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    aname,
    amtimweb
  FROM
    nplso_alt.transfermetadaten_amt
),
transfermetadaten_amt_insert AS 
(
  INSERT INTO nplso_neu.transfermetadaten_amt
  (
    t_id,
    aname,
    amtimweb
  )
  SELECT
    t_id,
    aname,
    amtimweb
  FROM
    transfermetadaten_amt
),
transfermetadaten_datenbestand_insert AS
(
  INSERT INTO nplso_neu.transfermetadaten_datenbestand
  (
    t_id,
    stand,
    lieferdatum,
    bemerkungen,
    amt
  )
  SELECT
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    stand,
    lieferdatum,
    bemerkungen,
    transfermetadaten_amt.t_id AS amt
  FROM
    nplso_alt.transfermetadaten_datenbestand AS transfermetadaten_datenbestand
    LEFT JOIN transfermetadaten_amt
    ON transfermetadaten_amt.transfermetadaten_amt_t_id = transfermetadaten_datenbestand.amt
),
--- Grundnutzung
typ_grundnutzung AS 
(
  SELECT 
    t_id AS typ_grundnutzung_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    nutzungsziffer,
    nutzungsziffer_art,
    geschosszahl,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM 
    nplso_alt.nutzungsplanung_typ_grundnutzung
),
typ_grundnutzung_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_typ_grundnutzung
  (
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    nutzungsziffer,
    nutzungsziffer_art,
    geschosszahl,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  )
  SELECT
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    nutzungsziffer,
    nutzungsziffer_art,
    geschosszahl,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM
    typ_grundnutzung
  RETURNING *
),
grundnutzung AS 
(
  SELECT
    t_id AS grundnutzung_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    dokument,
    typ_grundnutzung,
    geometrie
  FROM
    nplso_alt.nutzungsplanung_grundnutzung
),
grundnutzung_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_grundnutzung
  (
    t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_grundnutzung,
    geometrie
  )
  SELECT 
    grundnutzung.t_id,
    grundnutzung.t_ili_tid,
    grundnutzung.name_nummer,
    grundnutzung.rechtsstatus,
    grundnutzung.publiziertab,
    grundnutzung.bemerkungen,
    grundnutzung.erfasser,
    grundnutzung.datum,
    typ_grundnutzung.t_id,
    grundnutzung.geometrie
  FROM
    grundnutzung
    LEFT JOIN typ_grundnutzung
    ON typ_grundnutzung.typ_grundnutzung_t_id = grundnutzung.typ_grundnutzung
  RETURNING *
),
-- Direktes INSERT möglich, da Assoziation nur ggü "grundnutzung".
grundnutzung_pos_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_grundnutzung_pos
  (
    t_id,
    grundnutzung,
    ori,
    hali,
    vali,
    groesse,
    pos 
  )
  SELECT
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    grundnutzung.t_id AS grundnutzung,
    grundnutzung_pos.ori,
    grundnutzung_pos.hali,
    grundnutzung_pos.vali,
    grundnutzung_pos.groesse,
    grundnutzung_pos.pos
  FROM
    nplso_alt.nutzungsplanung_grundnutzung_pos AS grundnutzung_pos
    LEFT JOIN grundnutzung
    ON grundnutzung.grundnutzung_t_id = grundnutzung_pos.grundnutzung
  RETURNING *
),
---- überlagernd Fläche
typ_ueberlagernd_flaeche AS 
(
  SELECT 
    t_id AS typ_ueberlagernd_flaeche_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM 
    nplso_alt.nutzungsplanung_typ_ueberlagernd_flaeche
),
typ_ueberlagernd_flaeche_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_typ_ueberlagernd_flaeche
  (
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  )
  SELECT
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM
    typ_ueberlagernd_flaeche
  RETURNING *
),
ueberlagernd_flaeche AS 
(
  SELECT
    t_id AS ueberlagernd_flaeche_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    dokument,
    plandokument,
    typ_ueberlagernd_flaeche,
    geometrie
  FROM
    nplso_alt.nutzungsplanung_ueberlagernd_flaeche
),
ueberlagernd_flaeche_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_ueberlagernd_flaeche
  (
    t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_ueberlagernd_flaeche,
    geometrie
  )
  SELECT 
    ueberlagernd_flaeche.t_id,
    ueberlagernd_flaeche.t_ili_tid,
    ueberlagernd_flaeche.name_nummer,
    ueberlagernd_flaeche.rechtsstatus,
    ueberlagernd_flaeche.publiziertab,
    ueberlagernd_flaeche.bemerkungen,
    ueberlagernd_flaeche.erfasser,
    ueberlagernd_flaeche.datum,
    typ_ueberlagernd_flaeche.t_id,
    ueberlagernd_flaeche.geometrie
  FROM
    ueberlagernd_flaeche
    LEFT JOIN typ_ueberlagernd_flaeche
    ON typ_ueberlagernd_flaeche.typ_ueberlagernd_flaeche_t_id = ueberlagernd_flaeche.typ_ueberlagernd_flaeche
  RETURNING *
),
ueberlagernd_flaeche_pos_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_ueberlagernd_flaeche_pos
  (
    t_id,
    ueberlagernd_flaeche,
    ori,
    hali,
    vali,
    groesse,
    pos 
  )
  SELECT
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    ueberlagernd_flaeche.t_id AS ueberlagernd_flaeche,
    ueberlagernd_flaeche_pos.ori,
    ueberlagernd_flaeche_pos.hali,
    ueberlagernd_flaeche_pos.vali,
    ueberlagernd_flaeche_pos.groesse,
    ueberlagernd_flaeche_pos.pos
  FROM
    nplso_alt.nutzungsplanung_ueberlagernd_flaeche_pos AS ueberlagernd_flaeche_pos
    LEFT JOIN ueberlagernd_flaeche
    ON ueberlagernd_flaeche.ueberlagernd_flaeche_t_id = ueberlagernd_flaeche_pos.ueberlagernd_flaeche
  RETURNING *
),
--- überlagernd Linie
typ_ueberlagernd_linie AS 
(
  SELECT 
    t_id AS typ_ueberlagernd_linie_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM 
    nplso_alt.nutzungsplanung_typ_ueberlagernd_linie
),
typ_ueberlagernd_linie_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_typ_ueberlagernd_linie
  (
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  )
  SELECT
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM
    typ_ueberlagernd_linie
  RETURNING *
),
ueberlagernd_linie AS 
(
  SELECT
    t_id AS ueberlagernd_linie_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    dokument,
    typ_ueberlagernd_linie,
    geometrie
  FROM
    nplso_alt.nutzungsplanung_ueberlagernd_linie
),
ueberlagernd_linie_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_ueberlagernd_linie
  (
    t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_ueberlagernd_linie,
    geometrie
  )
  SELECT 
    ueberlagernd_linie.t_id,
    ueberlagernd_linie.t_ili_tid,
    ueberlagernd_linie.name_nummer,
    ueberlagernd_linie.rechtsstatus,
    ueberlagernd_linie.publiziertab,
    ueberlagernd_linie.bemerkungen,
    ueberlagernd_linie.erfasser,
    ueberlagernd_linie.datum,
    typ_ueberlagernd_linie.t_id,
    ueberlagernd_linie.geometrie
  FROM
    ueberlagernd_linie
    LEFT JOIN typ_ueberlagernd_linie
    ON typ_ueberlagernd_linie.typ_ueberlagernd_linie_t_id = ueberlagernd_linie.typ_ueberlagernd_linie
  RETURNING *
),
ueberlagernd_linie_pos_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_ueberlagernd_linie_pos
  (
    t_id,
    ueberlagernd_linie,
    ori,
    hali,
    vali,
    groesse,
    pos 
  )
  SELECT
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    ueberlagernd_linie.t_id AS ueberlagernd_linie,
    ueberlagernd_linie_pos.ori,
    ueberlagernd_linie_pos.hali,
    ueberlagernd_linie_pos.vali,
    ueberlagernd_linie_pos.groesse,
    ueberlagernd_linie_pos.pos
  FROM
    nplso_alt.nutzungsplanung_ueberlagernd_linie_pos AS ueberlagernd_linie_pos
    LEFT JOIN ueberlagernd_linie
    ON ueberlagernd_linie.ueberlagernd_linie_t_id = ueberlagernd_linie_pos.ueberlagernd_linie
  RETURNING *
),
--- überlagernd Punkt
typ_ueberlagernd_punkt AS 
(
  SELECT 
    t_id AS typ_ueberlagernd_punkt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM 
    nplso_alt.nutzungsplanung_typ_ueberlagernd_punkt
),
typ_ueberlagernd_punkt_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_typ_ueberlagernd_punkt
  (
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  )
  SELECT
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM
    typ_ueberlagernd_punkt
  RETURNING *
),
ueberlagernd_punkt AS 
(
  SELECT
    t_id AS ueberlagernd_punkt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    dokument,
    typ_ueberlagernd_punkt,
    geometrie
  FROM
    nplso_alt.nutzungsplanung_ueberlagernd_punkt
),
ueberlagernd_punkt_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_ueberlagernd_punkt
  (
    t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_ueberlagernd_punkt,
    geometrie
  )
  SELECT 
    ueberlagernd_punkt.t_id,
    ueberlagernd_punkt.t_ili_tid,
    ueberlagernd_punkt.name_nummer,
    ueberlagernd_punkt.rechtsstatus,
    ueberlagernd_punkt.publiziertab,
    ueberlagernd_punkt.bemerkungen,
    ueberlagernd_punkt.erfasser,
    ueberlagernd_punkt.datum,
    typ_ueberlagernd_punkt.t_id,
    ueberlagernd_punkt.geometrie
  FROM
    ueberlagernd_punkt
    LEFT JOIN typ_ueberlagernd_punkt
    ON typ_ueberlagernd_punkt.typ_ueberlagernd_punkt_t_id = ueberlagernd_punkt.typ_ueberlagernd_punkt
  RETURNING *
),
ueberlagernd_punkt_pos_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_ueberlagernd_punkt_pos
  (
    t_id,
    ueberlagernd_punkt,
    ori,
    hali,
    vali,
    groesse,
    pos 
  )
  SELECT
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    ueberlagernd_punkt.t_id AS ueberlagernd_punkt,
    ueberlagernd_punkt_pos.ori,
    ueberlagernd_punkt_pos.hali,
    ueberlagernd_punkt_pos.vali,
    ueberlagernd_punkt_pos.groesse,
    ueberlagernd_punkt_pos.pos
  FROM
    nplso_alt.nutzungsplanung_ueberlagernd_punkt_pos AS ueberlagernd_punkt_pos
    LEFT JOIN ueberlagernd_punkt
    ON ueberlagernd_punkt.ueberlagernd_punkt_t_id = ueberlagernd_punkt_pos.ueberlagernd_punkt
  RETURNING *
),
--- Erschliessung Flächenobjekt
typ_erschliessung_flaechenobjekt AS 
(
  SELECT 
    t_id AS typ_erschliessung_flaechenobjekt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM 
    nplso_alt.erschlssngsplnung_typ_erschliessung_flaechenobjekt
),
typ_erschliessung_flaechenobjekt_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_typ_erschliessung_flaechenobjekt
  (
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  )
  SELECT
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM
    typ_erschliessung_flaechenobjekt
  RETURNING *
),
erschliessung_flaechenobjekt AS 
(
  SELECT
    t_id AS erschliessung_flaechenobjekt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_erschliessung_flaechenobjekt,
    geometrie
  FROM
    nplso_alt.erschlssngsplnung_erschliessung_flaechenobjekt
),
erschliessung_flaechenobjekt_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_erschliessung_flaechenobjekt
  (
    t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_erschliessung_flaechenobjekt,
    geometrie
  )
  SELECT 
    erschliessung_flaechenobjekt.t_id,
    erschliessung_flaechenobjekt.t_ili_tid,
    erschliessung_flaechenobjekt.name_nummer,
    erschliessung_flaechenobjekt.rechtsstatus,
    erschliessung_flaechenobjekt.publiziertab,
    erschliessung_flaechenobjekt.bemerkungen,
    erschliessung_flaechenobjekt.erfasser,
    erschliessung_flaechenobjekt.datum,
    typ_erschliessung_flaechenobjekt.t_id,
    erschliessung_flaechenobjekt.geometrie
  FROM
    erschliessung_flaechenobjekt
    LEFT JOIN typ_erschliessung_flaechenobjekt
    ON typ_erschliessung_flaechenobjekt.typ_erschliessung_flaechenobjekt_t_id = erschliessung_flaechenobjekt.typ_erschliessung_flaechenobjekt
  RETURNING *
),
erschliessung_flaechenobjekt_pos_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_erschliessung_flaechenobjekt_pos
  (
    t_id,
    erschliessung_flaechenobjekt,
    ori,
    hali,
    vali,
    groesse,
    pos 
  )
  SELECT
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    erschliessung_flaechenobjekt.t_id AS erschliessung_flaechenobjekt,
    erschliessung_flaechenobjekt_pos.ori,
    erschliessung_flaechenobjekt_pos.hali,
    erschliessung_flaechenobjekt_pos.vali,
    erschliessung_flaechenobjekt_pos.groesse,
    erschliessung_flaechenobjekt_pos.pos
  FROM
    nplso_alt.erschlssngsplnung_erschliessung_flaechenobjekt_pos AS erschliessung_flaechenobjekt_pos
    LEFT JOIN erschliessung_flaechenobjekt
    ON erschliessung_flaechenobjekt.erschliessung_flaechenobjekt_t_id = erschliessung_flaechenobjekt_pos.erschliessung_flaechenobjekt
  RETURNING *
),
---- Erschliessung Linienobjekt
typ_erschliessung_linienobjekt AS 
(
  SELECT 
    t_id AS typ_erschliessung_linienobjekt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM 
    nplso_alt.erschlssngsplnung_typ_erschliessung_linienobjekt
),
typ_erschliessung_linienobjekt_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_typ_erschliessung_linienobjekt
  (
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  )
  SELECT
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM
    typ_erschliessung_linienobjekt
  RETURNING *
),
erschliessung_linienobjekt AS 
(
  SELECT
    t_id AS erschliessung_linienobjekt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_erschliessung_linienobjekt,
    geometrie
  FROM
    nplso_alt.erschlssngsplnung_erschliessung_linienobjekt
),
erschliessung_linienobjekt_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_erschliessung_linienobjekt
  (
    t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_erschliessung_linienobjekt,
    geometrie
  )
  SELECT 
    erschliessung_linienobjekt.t_id,
    erschliessung_linienobjekt.t_ili_tid,
    erschliessung_linienobjekt.name_nummer,
    erschliessung_linienobjekt.rechtsstatus,
    erschliessung_linienobjekt.publiziertab,
    erschliessung_linienobjekt.bemerkungen,
    erschliessung_linienobjekt.erfasser,
    erschliessung_linienobjekt.datum,
    typ_erschliessung_linienobjekt.t_id,
    erschliessung_linienobjekt.geometrie
  FROM
    erschliessung_linienobjekt
    LEFT JOIN typ_erschliessung_linienobjekt
    ON typ_erschliessung_linienobjekt.typ_erschliessung_linienobjekt_t_id = erschliessung_linienobjekt.typ_erschliessung_linienobjekt
  RETURNING *
),
erschliessung_linienobjekt_pos_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_erschliessung_linienobjekt_pos
  (
    t_id,
    erschliessung_linienobjekt,
    ori,
    hali,
    vali,
    groesse,
    pos 
  )
  SELECT
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    erschliessung_linienobjekt.t_id AS erschliessung_linienobjekt,
    erschliessung_linienobjekt_pos.ori,
    erschliessung_linienobjekt_pos.hali,
    erschliessung_linienobjekt_pos.vali,
    erschliessung_linienobjekt_pos.groesse,
    erschliessung_linienobjekt_pos.pos
  FROM
    nplso_alt.erschlssngsplnung_erschliessung_linienobjekt_pos AS erschliessung_linienobjekt_pos
    LEFT JOIN erschliessung_linienobjekt
    ON erschliessung_linienobjekt.erschliessung_linienobjekt_t_id = erschliessung_linienobjekt_pos.erschliessung_linienobjekt
  RETURNING *
),
typ_erschliessung_punktobjekt AS 
(
  SELECT 
    t_id AS typ_erschliessung_punktobjekt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM 
    nplso_alt.erschlssngsplnung_typ_erschliessung_punktobjekt
),
typ_erschliessung_punktobjekt_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_typ_erschliessung_punktobjekt
  (
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  )
  SELECT
    t_id,
    t_ili_tid,
    typ_kt,
    code_kommunal,
    bezeichnung,
    abkuerzung,
    verbindlichkeit,
    bemerkungen
  FROM
    typ_erschliessung_punktobjekt
  RETURNING *
),
erschliessung_punktobjekt AS 
(
  SELECT
    t_id AS erschliessung_punktobjekt_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_erschliessung_punktobjekt,
    geometrie
  FROM
    nplso_alt.erschlssngsplnung_erschliessung_punktobjekt
),
erschliessung_punktobjekt_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_erschliessung_punktobjekt
  (
    t_id,
    t_ili_tid,
    name_nummer,
    rechtsstatus,
    publiziertab,
    bemerkungen,
    erfasser,
    datum,
    typ_erschliessung_punktobjekt,
    geometrie
  )
  SELECT 
    erschliessung_punktobjekt.t_id,
    erschliessung_punktobjekt.t_ili_tid,
    erschliessung_punktobjekt.name_nummer,
    erschliessung_punktobjekt.rechtsstatus,
    erschliessung_punktobjekt.publiziertab,
    erschliessung_punktobjekt.bemerkungen,
    erschliessung_punktobjekt.erfasser,
    erschliessung_punktobjekt.datum,
    typ_erschliessung_punktobjekt.t_id,
    erschliessung_punktobjekt.geometrie
  FROM
    erschliessung_punktobjekt
    LEFT JOIN typ_erschliessung_punktobjekt
    ON typ_erschliessung_punktobjekt.typ_erschliessung_punktobjekt_t_id = erschliessung_punktobjekt.typ_erschliessung_punktobjekt
  RETURNING *
),
erschliessung_punktobjekt_pos_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_erschliessung_punktobjekt_pos
  (
    t_id,
    erschliessung_punktobjekt,
    ori,
    hali,
    vali,
    groesse,
    pos 
  )
  SELECT
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    erschliessung_punktobjekt.t_id AS erschliessung_punktobjekt,
    erschliessung_punktobjekt_pos.ori,
    erschliessung_punktobjekt_pos.hali,
    erschliessung_punktobjekt_pos.vali,
    erschliessung_punktobjekt_pos.groesse,
    erschliessung_punktobjekt_pos.pos
  FROM
    nplso_alt.erschlssngsplnung_erschliessung_punktobjekt_pos AS erschliessung_punktobjekt_pos
    LEFT JOIN erschliessung_punktobjekt
    ON erschliessung_punktobjekt.erschliessung_punktobjekt_t_id = erschliessung_punktobjekt_pos.erschliessung_punktobjekt
  RETURNING *
),
---- Dokumente
dokument AS 
(
  SELECT 
    t_id AS dokument_t_id,
    nextval('nplso_neu.t_ili2db_seq'::regclass) AS t_id,
    t_ili_tid,
    dokumentid,
    titel,
    offiziellertitel,
    abkuerzung,
    offiziellenr,
    kanton,
    gemeinde,
    publiziertab,
    rechtsstatus,
    textimweb,
    bemerkungen,
    rechtsvorschrift
  FROM
    nplso_alt.rechtsvorschrften_dokument
),
dokument_insert AS 
(
  INSERT INTO nplso_neu.rechtsvorschrften_dokument
  (
    t_id,
    t_ili_tid,
    dokumentid,
    titel,
    offiziellertitel,
    abkuerzung,
    offiziellenr,
    kanton,
    gemeinde,
    publiziertab,
    rechtsstatus,
    textimweb,
    bemerkungen,
    rechtsvorschrift
  )
  SELECT
    t_id,
    t_ili_tid,
    dokumentid,
    titel,
    offiziellertitel,
    abkuerzung,
    offiziellenr,
    kanton,
    gemeinde,
    publiziertab,
    rechtsstatus,
    textimweb,
    bemerkungen,
    rechtsvorschrift
  FROM
    dokument
),
/*
 * TODO: NICHT SICHER, OB DIREKTES INSERT OK REICHT????!!!!
 */
-- Cross-Referenz-Tabelle: rechtsvorschrften_hinweisweiteredokumente
-- Entspricht mehr oder weniger einem Copy/Paste mit Ersetzen der 
-- Fremdschlüsseln (look-up).
hinweisweiteredokumente_insert AS 
(
  INSERT INTO nplso_neu.rechtsvorschrften_hinweisweiteredokumente
    (
      ursprung,
      hinweis
    )
  SELECT
    u.ursprung,
    d.t_id AS hinweis
  FROM 
  (
    SELECT
      d.t_id AS ursprung,
      hinweisweiteredokumente.hinweis
    FROM 
      dokument AS d 
      LEFT JOIN nplso_alt.rechtsvorschrften_hinweisweiteredokumente AS hinweisweiteredokumente
      ON d.dokument_t_id = hinweisweiteredokumente.ursprung
    WHERE
      hinweisweiteredokumente.ursprung IS NOT NULL
  ) AS u
  LEFT JOIN dokument AS d 
  ON d.dokument_t_id = u.hinweis
  RETURNING *
),
---- Cross-Referenz-Tabellen: Typ <-> Dokumente
typ_grundnutzung_dokument_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_typ_grundnutzung_dokument
  (
    typ_grundnutzung,
    dokument
  )
  SELECT
    typ_grundnutzung.t_id AS typ_grundnutzung,
    dokument.t_id AS dokument
  FROM
    nplso_alt.nutzungsplanung_typ_grundnutzung_dokument AS typ_grundnutzung_dokument 
    LEFT JOIN typ_grundnutzung
    ON typ_grundnutzung_dokument.typ_grundnutzung = typ_grundnutzung.typ_grundnutzung_t_id
    LEFT JOIN dokument
    ON typ_grundnutzung_dokument.dokument = dokument.dokument_t_id
  RETURNING *
),
typ_ueberlagernd_flaeche_dokument_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_typ_ueberlagernd_flaeche_dokument
  (
    typ_ueberlagernd_flaeche,
    dokument
  )
  SELECT
    typ_ueberlagernd_flaeche.t_id AS typ_ueberlagernd_flaeche,
    dokument.t_id AS dokument
  FROM
    nplso_alt.nutzungsplanung_typ_ueberlagernd_flaeche_dokument AS typ_ueberlagernd_flaeche_dokument 
    LEFT JOIN typ_ueberlagernd_flaeche
    ON typ_ueberlagernd_flaeche_dokument.typ_ueberlagernd_flaeche = typ_ueberlagernd_flaeche.typ_ueberlagernd_flaeche_t_id
    LEFT JOIN dokument
    ON typ_ueberlagernd_flaeche_dokument.dokument = dokument.dokument_t_id
  RETURNING *
),
typ_ueberlagernd_linie_dokument_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_typ_ueberlagernd_linie_dokument
  (
    typ_ueberlagernd_linie,
    dokument
  )
  SELECT
    typ_ueberlagernd_linie.t_id AS typ_ueberlagernd_linie,
    dokument.t_id AS dokument
  FROM
    nplso_alt.nutzungsplanung_typ_ueberlagernd_linie_dokument AS typ_ueberlagernd_linie_dokument 
    LEFT JOIN typ_ueberlagernd_linie
    ON typ_ueberlagernd_linie_dokument.typ_ueberlagernd_linie = typ_ueberlagernd_linie.typ_ueberlagernd_linie_t_id
    LEFT JOIN dokument
    ON typ_ueberlagernd_linie_dokument.dokument = dokument.dokument_t_id
  RETURNING *
),
typ_ueberlagernd_punkt_dokument_insert AS 
(
  INSERT INTO nplso_neu.nutzungsplanung_typ_ueberlagernd_punkt_dokument
  (
    typ_ueberlagernd_punkt,
    dokument
  )
  SELECT
    typ_ueberlagernd_punkt.t_id AS typ_ueberlagernd_punkt,
    dokument.t_id AS dokument
  FROM
    nplso_alt.nutzungsplanung_typ_ueberlagernd_punkt_dokument AS typ_ueberlagernd_punkt_dokument 
    LEFT JOIN typ_ueberlagernd_punkt
    ON typ_ueberlagernd_punkt_dokument.typ_ueberlagernd_punkt = typ_ueberlagernd_punkt.typ_ueberlagernd_punkt_t_id
    LEFT JOIN dokument
    ON typ_ueberlagernd_punkt_dokument.dokument = dokument.dokument_t_id
  RETURNING *
),
typ_erschliessung_flaechenobjekt_dokument_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument
  (
    typ_erschliessung_flaechenobjekt,
    dokument
  )
  SELECT
    typ_erschliessung_flaechenobjekt.t_id AS typ_erschliessung_flaechenobjekt,
    dokument.t_id AS dokument
  FROM
    nplso_alt.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument AS typ_erschliessung_flaechenobjekt_dokument 
    LEFT JOIN typ_erschliessung_flaechenobjekt
    ON typ_erschliessung_flaechenobjekt_dokument.typ_erschliessung_flaechenobjekt = typ_erschliessung_flaechenobjekt.typ_erschliessung_flaechenobjekt_t_id
    LEFT JOIN dokument
    ON typ_erschliessung_flaechenobjekt_dokument.dokument = dokument.dokument_t_id
  RETURNING *
),
typ_erschliessung_linienobjekt_dokument_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument
  (
    typ_erschliessung_linienobjekt,
    dokument
  )
  SELECT
    typ_erschliessung_linienobjekt.t_id AS typ_erschliessung_linienobjekt,
    dokument.t_id AS dokument
  FROM
    nplso_alt.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument AS typ_erschliessung_linienobjekt_dokument 
    LEFT JOIN typ_erschliessung_linienobjekt
    ON typ_erschliessung_linienobjekt_dokument.typ_erschliessung_linienobjekt = typ_erschliessung_linienobjekt.typ_erschliessung_linienobjekt_t_id
    LEFT JOIN dokument
    ON typ_erschliessung_linienobjekt_dokument.dokument = dokument.dokument_t_id
  RETURNING *
),
typ_erschliessung_punktobjekt_dokument_insert AS 
(
  INSERT INTO nplso_neu.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument
  (
    typ_erschliessung_punktobjekt,
    dokument
  )
  SELECT
    typ_erschliessung_punktobjekt.t_id AS typ_erschliessung_punktobjekt,
    dokument.t_id AS dokument
  FROM
    nplso_alt.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument AS typ_erschliessung_punktobjekt_dokument 
    LEFT JOIN typ_erschliessung_punktobjekt
    ON typ_erschliessung_punktobjekt_dokument.typ_erschliessung_punktobjekt = typ_erschliessung_punktobjekt.typ_erschliessung_punktobjekt_t_id
    LEFT JOIN dokument
    ON typ_erschliessung_punktobjekt_dokument.dokument = dokument.dokument_t_id
  RETURNING *
)

SELECT
  *
FROM
  typ_erschliessung_punktobjekt_dokument_insert