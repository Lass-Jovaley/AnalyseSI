-- =====================================================================
-- Base SIG de Djékanou (MULCV) - script de création PostgreSQL / PostGIS
-- Partie 1 : tables, clés primaires et clés étrangères générées par
--            AnalyseSI 0.80 (syntaxe PostgreSQL) à partir du MCD validé.
-- Partie 2 : colonnes géométriques ajoutées pour PostGIS (EPSG:32630),
--            AnalyseSI ne gérant pas les types géométriques.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- Partie 1 : script généré par AnalyseSI
DROP TABLE IF EXISTS COMMUNE CASCADE;
CREATE TABLE COMMUNE (id_commune SERIAL NOT NULL,
    nom_commune VARCHAR(50),
    departement VARCHAR(50),
    region VARCHAR(50),
    superficie_commune DECIMAL,
    PRIMARY KEY (id_commune));

DROP TABLE IF EXISTS QUARTIER CASCADE;
CREATE TABLE QUARTIER (id_quartier SERIAL NOT NULL,
    nom_quartier VARCHAR(50),
    superficie_quartier DECIMAL,
    population_estimee INT,
    id_commune INT,
    PRIMARY KEY (id_quartier));

DROP TABLE IF EXISTS ILOT CASCADE;
CREATE TABLE ILOT (id_ilot SERIAL NOT NULL,
    numero_ilot VARCHAR(20),
    id_quartier INT,
    PRIMARY KEY (id_ilot));

DROP TABLE IF EXISTS LOT CASCADE;
CREATE TABLE LOT (id_lot SERIAL NOT NULL,
    numero_lot VARCHAR(20),
    superficie_lot DECIMAL,
    statut_lot VARCHAR(30),
    usage_lot VARCHAR(50),
    occupation_lot VARCHAR(50),
    id_ilot INT,
    PRIMARY KEY (id_lot));

DROP TABLE IF EXISTS PROCEDURE_FONCIERE CASCADE;
CREATE TABLE PROCEDURE_FONCIERE (id_procedure SERIAL NOT NULL,
    type_procedure VARCHAR(30),
    niveau_avancement VARCHAR(50),
    date_maj DATE,
    id_lot INT,
    PRIMARY KEY (id_procedure));

DROP TABLE IF EXISTS OCCUPATION_SOL CASCADE;
CREATE TABLE OCCUPATION_SOL (id_occupation SERIAL NOT NULL,
    classe_occupation VARCHAR(50),
    superficie_occupation DECIMAL,
    annee INT,
    id_commune INT,
    PRIMARY KEY (id_occupation));

DROP TABLE IF EXISTS ZONE_ENJEU CASCADE;
CREATE TABLE ZONE_ENJEU (id_zone SERIAL NOT NULL,
    type_enjeu VARCHAR(50),
    niveau_priorite VARCHAR(20),
    observation_zone VARCHAR(255),
    id_commune INT,
    PRIMARY KEY (id_zone));

DROP TABLE IF EXISTS VOIRIE CASCADE;
CREATE TABLE VOIRIE (id_voie SERIAL NOT NULL,
    nom_voie VARCHAR(50),
    type_voie VARCHAR(30),
    etat_voie VARCHAR(30),
    longueur DECIMAL,
    PRIMARY KEY (id_voie));

DROP TABLE IF EXISTS HYDROGRAPHIE CASCADE;
CREATE TABLE HYDROGRAPHIE (id_hydro SERIAL NOT NULL,
    nom_hydro VARCHAR(50),
    type_hydro VARCHAR(30),
    permanence VARCHAR(30),
    observation_hydro VARCHAR(255),
    PRIMARY KEY (id_hydro));

DROP TABLE IF EXISTS RESEAU_ELECTRIQUE CASCADE;
CREATE TABLE RESEAU_ELECTRIQUE (id_reseau_elec SERIAL NOT NULL,
    type_ouvrage VARCHAR(50),
    etat_ouvrage VARCHAR(30),
    zone_desservie VARCHAR(100),
    PRIMARY KEY (id_reseau_elec));

DROP TABLE IF EXISTS POINT_LEVE CASCADE;
CREATE TABLE POINT_LEVE (id_point SERIAL NOT NULL,
    type_point VARCHAR(20),
    coord_x DOUBLE PRECISION,
    coord_y DOUBLE PRECISION,
    description_point VARCHAR(255),
    date_leve DATE,
    lot_id_lot INT,
    PRIMARY KEY (id_point));

DROP TABLE IF EXISTS RESERVE_ADMIN CASCADE;
CREATE TABLE RESERVE_ADMIN (id_reserve SERIAL NOT NULL,
    type_reserve VARCHAR(50),
    affectation_prevue VARCHAR(100),
    affectation_actuelle VARCHAR(100),
    statut_occupation VARCHAR(50),
    id_quartier INT,
    PRIMARY KEY (id_reserve));

DROP TABLE IF EXISTS EQUIPEMENT CASCADE;
CREATE TABLE EQUIPEMENT (id_equipement SERIAL NOT NULL,
    nom_equipement VARCHAR(50),
    type_equipement VARCHAR(50),
    etat_equipement VARCHAR(30),
    gestionnaire VARCHAR(100),
    id_quartier INT,
    PRIMARY KEY (id_equipement));

DROP TABLE IF EXISTS dessert CASCADE;
CREATE TABLE dessert (id_quartier SERIAL NOT NULL,
    id_voie INT NOT NULL,
    PRIMARY KEY (id_quartier,
     id_voie));

DROP TABLE IF EXISTS traverse CASCADE;
CREATE TABLE traverse (id_quartier SERIAL NOT NULL,
    id_hydro INT NOT NULL,
    PRIMARY KEY (id_quartier,
     id_hydro));

DROP TABLE IF EXISTS alimente CASCADE;
CREATE TABLE alimente (id_quartier SERIAL NOT NULL,
    id_reseau_elec INT NOT NULL,
    PRIMARY KEY (id_quartier,
     id_reseau_elec));

ALTER TABLE QUARTIER ADD CONSTRAINT FK_QUARTIER_id_commune FOREIGN KEY (id_commune) REFERENCES COMMUNE (id_commune);
ALTER TABLE ILOT ADD CONSTRAINT FK_ILOT_id_quartier FOREIGN KEY (id_quartier) REFERENCES QUARTIER (id_quartier);
ALTER TABLE LOT ADD CONSTRAINT FK_LOT_id_ilot FOREIGN KEY (id_ilot) REFERENCES ILOT (id_ilot);
ALTER TABLE PROCEDURE_FONCIERE ADD CONSTRAINT FK_PROCEDURE_FONCIERE_id_lot FOREIGN KEY (id_lot) REFERENCES LOT (id_lot);
ALTER TABLE OCCUPATION_SOL ADD CONSTRAINT FK_OCCUPATION_SOL_id_commune FOREIGN KEY (id_commune) REFERENCES COMMUNE (id_commune);
ALTER TABLE ZONE_ENJEU ADD CONSTRAINT FK_ZONE_ENJEU_id_commune FOREIGN KEY (id_commune) REFERENCES COMMUNE (id_commune);
ALTER TABLE POINT_LEVE ADD CONSTRAINT FK_POINT_LEVE_lot_id_lot FOREIGN KEY (lot_id_lot) REFERENCES LOT (id_lot);
ALTER TABLE RESERVE_ADMIN ADD CONSTRAINT FK_RESERVE_ADMIN_id_quartier FOREIGN KEY (id_quartier) REFERENCES QUARTIER (id_quartier);
ALTER TABLE EQUIPEMENT ADD CONSTRAINT FK_EQUIPEMENT_id_quartier FOREIGN KEY (id_quartier) REFERENCES QUARTIER (id_quartier);
ALTER TABLE dessert ADD CONSTRAINT FK_dessert_id_quartier FOREIGN KEY (id_quartier) REFERENCES QUARTIER (id_quartier);
ALTER TABLE dessert ADD CONSTRAINT FK_dessert_id_voie FOREIGN KEY (id_voie) REFERENCES VOIRIE (id_voie);
ALTER TABLE traverse ADD CONSTRAINT FK_traverse_id_quartier FOREIGN KEY (id_quartier) REFERENCES QUARTIER (id_quartier);
ALTER TABLE traverse ADD CONSTRAINT FK_traverse_id_hydro FOREIGN KEY (id_hydro) REFERENCES HYDROGRAPHIE (id_hydro);
ALTER TABLE alimente ADD CONSTRAINT FK_alimente_id_quartier FOREIGN KEY (id_quartier) REFERENCES QUARTIER (id_quartier);
ALTER TABLE alimente ADD CONSTRAINT FK_alimente_id_reseau_elec FOREIGN KEY (id_reseau_elec) REFERENCES RESEAU_ELECTRIQUE (id_reseau_elec);

-- Partie 2 : géométries PostGIS (WGS 84 / UTM zone 30N)
ALTER TABLE COMMUNE ADD COLUMN geom geometry(MultiPolygon, 32630);
CREATE INDEX idx_commune_geom ON COMMUNE USING GIST (geom);
ALTER TABLE QUARTIER ADD COLUMN geom geometry(MultiPolygon, 32630);
CREATE INDEX idx_quartier_geom ON QUARTIER USING GIST (geom);
ALTER TABLE ILOT ADD COLUMN geom geometry(MultiPolygon, 32630);
CREATE INDEX idx_ilot_geom ON ILOT USING GIST (geom);
ALTER TABLE LOT ADD COLUMN geom geometry(MultiPolygon, 32630);
CREATE INDEX idx_lot_geom ON LOT USING GIST (geom);
ALTER TABLE OCCUPATION_SOL ADD COLUMN geom geometry(MultiPolygon, 32630);
CREATE INDEX idx_occupation_sol_geom ON OCCUPATION_SOL USING GIST (geom);
ALTER TABLE ZONE_ENJEU ADD COLUMN geom geometry(MultiPolygon, 32630);
CREATE INDEX idx_zone_enjeu_geom ON ZONE_ENJEU USING GIST (geom);
ALTER TABLE RESERVE_ADMIN ADD COLUMN geom geometry(MultiPolygon, 32630);
CREATE INDEX idx_reserve_admin_geom ON RESERVE_ADMIN USING GIST (geom);
ALTER TABLE VOIRIE ADD COLUMN geom geometry(MultiLineString, 32630);
CREATE INDEX idx_voirie_geom ON VOIRIE USING GIST (geom);
ALTER TABLE HYDROGRAPHIE ADD COLUMN geom geometry(Geometry, 32630);
CREATE INDEX idx_hydrographie_geom ON HYDROGRAPHIE USING GIST (geom);
ALTER TABLE RESEAU_ELECTRIQUE ADD COLUMN geom geometry(Geometry, 32630);
CREATE INDEX idx_reseau_electrique_geom ON RESEAU_ELECTRIQUE USING GIST (geom);
ALTER TABLE EQUIPEMENT ADD COLUMN geom geometry(Point, 32630);
CREATE INDEX idx_equipement_geom ON EQUIPEMENT USING GIST (geom);
ALTER TABLE POINT_LEVE ADD COLUMN geom geometry(Point, 32630);
CREATE INDEX idx_point_leve_geom ON POINT_LEVE USING GIST (geom);
