Base SIG de Djekanou (MULCV) - modele Merise realise avec AnalyseSI 0.80

Memoire : « Les SIG, un outil d'optimisation de gestion des donnees spatiales :
cas du MULCV de la ville de Djekanou » - YAO Konan Claudel Franck Anicet.

Fichiers
- BD_SIG_Djekanou.asi            modele AnalyseSI (13 entites, 12 associations, 59 attributs)
- MCD_Djekanou.png               export de la vue MCD
- MPD_Djekanou.png               export de la vue MPD (schema relationnel)
- BD_SIG_Djekanou_PostGIS.sql    script PostgreSQL genere par AnalyseSI (syntaxe PostgreSQL),
                                 complete des colonnes geometriques PostGIS (EPSG:32630)

Le script genere (partie 1) a ete execute sur PostgreSQL 16 : 16 tables et
15 contraintes de cle etrangere creees.

Correctifs apportes au generateur dans ce depot
- MPDComponent.java : le type d'une cle etrangere dont le nom contient un « _ »
  (ex. id_commune) n'etait pas retrouve dans le dictionnaire (« **NOT FOUND** »
  dans le script SQL).
- MCDComponent.java : le lien d'une association (1,1)/(0,1) n'etait pas ajoute
  au MPD ; il est maintenant trace, oriente vers la table referencee.
