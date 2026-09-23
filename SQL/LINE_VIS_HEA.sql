-- ===========================================
-- Table d'en-tete LINE_VIS_HEA (1 ligne par LNA_UID)
-- Jointe a LINE_VIS_EDG par LNA_UID dans sp_GetPredecesseurs / sp_GetSuccesseurs
-- Schema repris de restitutiondonnees/Sql-procedure-table/LINE_VIS_HEA.sql
-- (LNA_UID en NVARCHAR(100) pour avoir le meme type que LINE_VIS_EDG.LNA_UID)
-- ===========================================

-- 1. Creation de la table si elle n'existe pas
IF OBJECT_ID(N'dbo.LINE_VIS_HEA') IS NULL
BEGIN
    CREATE TABLE dbo.LINE_VIS_HEA (
        LNA_UID       NVARCHAR(100) NOT NULL,
        RON_APP       VARCHAR(4),
        PCK_PGM_NME   VARCHAR(500),
        EXE_PGM_NME   VARCHAR(500),
        VRS_EXE_PGM   VARCHAR(100),
        APP_ENV       VARCHAR(20),
        DLY_PGM_TSP   DATETIME2,
        LNA_TSP       DATETIME2,
        PGM_TEC       VARCHAR(20),
        VRS_LNA_TOO   VARCHAR(100),
        TUS_IND       INT,
        CONSTRAINT PK_LINE_VIS_HEA PRIMARY KEY (LNA_UID)
    );
END
GO

-- 2. Donnees de test : une ligne par LNA_UID de LINE_VIS_EDG absent de LINE_VIS_HEA
--    (valeurs derivees de LNA_UID, donc deterministes ; les lignes existantes ne sont pas touchees)
INSERT INTO dbo.LINE_VIS_HEA
    (LNA_UID, RON_APP, PCK_PGM_NME, EXE_PGM_NME, VRS_EXE_PGM, APP_ENV,
     DLY_PGM_TSP, LNA_TSP, PGM_TEC, VRS_LNA_TOO, TUS_IND)
SELECT
    d.LNA_UID,
    LEFT('R' + CAST(ABS(CHECKSUM(d.LNA_UID)) % 1000 AS VARCHAR(3)), 4),
    'PCK_' + d.LNA_UID,
    'EXE_' + d.LNA_UID,
    'v' + CAST(ABS(CHECKSUM(d.LNA_UID)) % 20 AS VARCHAR(2)) + '.0',
    CASE ABS(CHECKSUM(d.LNA_UID)) % 3 WHEN 0 THEN 'PROD'
                                     WHEN 1 THEN 'RECETTE'
                                     ELSE 'DEV' END,
    DATEADD(DAY, -(ABS(CHECKSUM(d.LNA_UID)) % 365), SYSDATETIME()),
    DATEADD(HOUR, -(ABS(CHECKSUM(d.LNA_UID)) % 48), SYSDATETIME()),
    LEFT('TEC_' + d.LNA_UID, 20),
    'lna' + CAST(ABS(CHECKSUM(d.LNA_UID)) % 10 AS VARCHAR(2)),
    ABS(CHECKSUM(d.LNA_UID)) % 5
FROM (SELECT DISTINCT LNA_UID FROM dbo.LINE_VIS_EDG) AS d
WHERE NOT EXISTS (SELECT 1 FROM dbo.LINE_VIS_HEA h WHERE h.LNA_UID = d.LNA_UID);
GO
