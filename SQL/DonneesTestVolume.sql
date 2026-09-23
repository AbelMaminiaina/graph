-- ===========================================
-- Donnees de test en volume pour la page Programme
-- Tables: LINE_VIS_HEA + LINE_VIS_EDG (lignes LNA_UID 'VOL_%' uniquement)
-- Relancable : supprime puis recree les lignes 'VOL_%', le reste n'est pas touche
--
-- 5 programmes, jusqu'a 500 predecesseurs / successeurs distincts chacun :
--   Programme       Executions  Liens/exec/direction  Pred. distincts  Succ. distincts
--   EXE_PAIE             2            1000                 500              500
--   EXE_COMPTA           2             800                 400              350
--   EXE_REPORTING        3             500                  80              500
--   EXE_STOCK            1             250                 250              200
--   EXE_CLIENT           1             120                 120              100
-- Les executions d'un meme programme partagent les memes noeuds (doublons a dedoublonner)
-- ===========================================

SET NOCOUNT ON;

DELETE FROM dbo.LINE_VIS_EDG WHERE LNA_UID LIKE 'VOL[_]%';
DELETE FROM dbo.LINE_VIS_HEA WHERE LNA_UID LIKE 'VOL[_]%';
GO

-- Executions : LNA_UID, programme, prefixe des noeuds, nombre de liens, nb de noeuds distincts par direction
DECLARE @Executions TABLE (
    LNA_UID NVARCHAR(50), EXE_PGM_NME VARCHAR(500), PFX NVARCHAR(10),
    NB INT, MOD_PRED INT, MOD_SUCC INT, APP_ENV VARCHAR(20), VRS VARCHAR(100), JOURS INT
);
INSERT INTO @Executions VALUES
    ('VOL_PAIE_01',   'EXE_PAIE',      'PAIE',   1000, 500, 500, 'PROD',    'v2.3', 1),
    ('VOL_PAIE_02',   'EXE_PAIE',      'PAIE',   1000, 500, 500, 'PROD',    'v2.4', 0),
    ('VOL_COMPTA_01', 'EXE_COMPTA',    'COMPTA',  800, 400, 350, 'PROD',    'v5.0', 1),
    ('VOL_COMPTA_02', 'EXE_COMPTA',    'COMPTA',  800, 400, 350, 'RECETTE', 'v5.1', 0),
    ('VOL_REPORT_01', 'EXE_REPORTING', 'REPORT',  500,  80, 500, 'PROD',    'v1.0', 2),
    ('VOL_REPORT_02', 'EXE_REPORTING', 'REPORT',  500,  80, 500, 'PROD',    'v1.0', 1),
    ('VOL_REPORT_03', 'EXE_REPORTING', 'REPORT',  500,  80, 500, 'PROD',    'v1.1', 0),
    ('VOL_STOCK_01',  'EXE_STOCK',     'STOCK',   250, 250, 200, 'RECETTE', 'v0.9', 0),
    ('VOL_CLIENT_01', 'EXE_CLIENT',    'CLIENT',  120, 120, 100, 'DEV',     'v0.1', 0);

INSERT INTO dbo.LINE_VIS_HEA
    (LNA_UID, RON_APP, PCK_PGM_NME, EXE_PGM_NME, VRS_EXE_PGM, APP_ENV,
     DLY_PGM_TSP, LNA_TSP, PGM_TEC, VRS_LNA_TOO, TUS_IND)
SELECT LNA_UID, 'RVOL', 'PCK_' + EXE_PGM_NME, EXE_PGM_NME, VRS, APP_ENV,
       DATEADD(DAY, -JOURS, SYSDATETIME()), DATEADD(DAY, -JOURS, SYSDATETIME()),
       'SPARK', 'lna1', 0
FROM @Executions;

-- Suite de nombres 1..1000 ; kp / ks = indice du noeud lie (d'ou le nombre de noeuds distincts)
WITH N AS (
    SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
Liens AS (
    SELECT x.LNA_UID, x.PFX, N.n, N.n % x.MOD_PRED AS kp, N.n % x.MOD_SUCC AS ks
    FROM @Executions x
    JOIN N ON N.n <= x.NB
)
INSERT INTO dbo.LINE_VIS_EDG
    (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
-- Predecesseurs : fichiers sources SRC_<pfx>_xxxx
SELECT LNA_UID, 'LIN' + RIGHT('00000' + CAST(n AS VARCHAR(5)), 5),
       'TBL_' + PFX + '_' + RIGHT('000' + CAST(n % 50 AS VARCHAR(3)), 3), 'TABLE', 'SCHEMA_' + CAST(n % 5 AS VARCHAR(1)), 'V1',
       'I',
       'SRC_' + PFX + '_' + RIGHT('0000' + CAST(kp AS VARCHAR(4)), 4),
       CASE kp % 4 WHEN 0 THEN 'FICHIER' WHEN 1 THEN 'TABLE' WHEN 2 THEN 'VUE' ELSE 'API' END, 'ZONE_' + CAST(kp % 3 AS VARCHAR(1)), 'V' + CAST(kp % 2 + 1 AS VARCHAR(1)),
       GETDATE(), GETDATE()
FROM Liens
UNION ALL
-- Successeurs : tables cibles CIB_<pfx>_xxxx
SELECT LNA_UID, 'LIN' + RIGHT('00000' + CAST(n AS VARCHAR(5)), 5),
       'TBL_' + PFX + '_' + RIGHT('000' + CAST(n % 50 AS VARCHAR(3)), 3), 'TABLE', 'SCHEMA_' + CAST(n % 5 AS VARCHAR(1)), 'V1',
       'O',
       'CIB_' + PFX + '_' + RIGHT('0000' + CAST(ks AS VARCHAR(4)), 4),
       CASE ks % 5 WHEN 0 THEN 'TABLE' WHEN 1 THEN 'VUE' WHEN 2 THEN 'FICHIER' WHEN 3 THEN 'CUBE' ELSE 'EXPORT' END, 'MART_' + CAST(ks % 4 AS VARCHAR(1)), 'V1',
       GETDATE(), GETDATE()
FROM Liens;
GO

-- Controle
SELECT h.EXE_PGM_NME, e.EDG_DIR, COUNT(*) AS NbLiens,
       COUNT(DISTINCT CONCAT(e.EDG_1, '|', e.EDG_2, '|', e.EDG_3, '|', e.EDG_4)) AS NbNoeudsDistincts
FROM dbo.LINE_VIS_HEA h
JOIN dbo.LINE_VIS_EDG e ON e.LNA_UID = h.LNA_UID
WHERE h.LNA_UID LIKE 'VOL[_]%'
GROUP BY h.EXE_PGM_NME, e.EDG_DIR
ORDER BY h.EXE_PGM_NME, e.EDG_DIR;
GO
