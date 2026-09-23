-- ===========================================
-- Script de création des procédures stockées
-- Tables: LINE_VIS_EDG (+ LINE_VIS_HEA jointe par LNA_UID, cf. ../LINE_VIS_HEA.sql)
-- ===========================================

-- Table de base (à créer si nécessaire)
/*
CREATE TABLE LINE_VIS_EDG (
    LNA_UID NVARCHAR(50) NOT NULL,
    LIN_UID NVARCHAR(50) NOT NULL,
    DTA_1 NVARCHAR(100),
    DTA_2 NVARCHAR(100),
    DTA_3 NVARCHAR(100),
    DTA_4 NVARCHAR(100),
    EDG_DIR NVARCHAR(10) NOT NULL, -- 'I' = Input (EDG est predecesseur de DTA), 'O' = Output (EDG est successeur de DTA)
    EDG_1 NVARCHAR(100),
    EDG_2 NVARCHAR(100),
    EDG_3 NVARCHAR(100),
    EDG_4 NVARCHAR(100),
    TXN_DTA DATETIME,
    PRX_TXN_DTA DATETIME,
    CONSTRAINT PK_LINE_VIS_EDG PRIMARY KEY (LNA_UID, LIN_UID, EDG_DIR)
);
*/

-- ===========================================
-- 1. Récupérer les données distinctes (Premier écran)
-- ===========================================
CREATE OR ALTER PROCEDURE sp_GetDistinctLineVis
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        DTA_1,
        DTA_2,
        DTA_3,
        DTA_4
    FROM LINE_VIS_EDG
    ORDER BY DTA_1, DTA_2, DTA_3, DTA_4;
END
GO

-- ===========================================
-- 2. Récupérer les prédécesseurs pour une ligne
-- ===========================================
CREATE OR ALTER PROCEDURE sp_GetPredecesseurs
    @DTA_1 NVARCHAR(100),
    @DTA_2 NVARCHAR(100),
    @DTA_3 NVARCHAR(100),
    @DTA_4 NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EDG_1,
        e.EDG_2,
        e.EDG_3,
        e.EDG_4,
        e.LNA_UID,
        h.RON_APP,
        h.PCK_PGM_NME,
        h.EXE_PGM_NME,
        h.VRS_EXE_PGM,
        h.APP_ENV,
        h.DLY_PGM_TSP,
        h.LNA_TSP,
        h.PGM_TEC,
        h.VRS_LNA_TOO,
        h.TUS_IND
    FROM LINE_VIS_EDG e
    LEFT JOIN LINE_VIS_HEA h ON h.LNA_UID = e.LNA_UID
    WHERE e.DTA_1 = @DTA_1
      AND e.DTA_2 = @DTA_2
      AND e.DTA_3 = @DTA_3
      AND e.DTA_4 = @DTA_4
      AND e.EDG_DIR = 'I'
    ORDER BY e.EDG_1, e.EDG_2, e.EDG_3, e.EDG_4;
END
GO

-- ===========================================
-- 3. Récupérer les successeurs pour une ligne
-- ===========================================
CREATE OR ALTER PROCEDURE sp_GetSuccesseurs
    @DTA_1 NVARCHAR(100),
    @DTA_2 NVARCHAR(100),
    @DTA_3 NVARCHAR(100),
    @DTA_4 NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EDG_1,
        e.EDG_2,
        e.EDG_3,
        e.EDG_4,
        e.LNA_UID,
        h.RON_APP,
        h.PCK_PGM_NME,
        h.EXE_PGM_NME,
        h.VRS_EXE_PGM,
        h.APP_ENV,
        h.DLY_PGM_TSP,
        h.LNA_TSP,
        h.PGM_TEC,
        h.VRS_LNA_TOO,
        h.TUS_IND
    FROM LINE_VIS_EDG e
    LEFT JOIN LINE_VIS_HEA h ON h.LNA_UID = e.LNA_UID
    WHERE e.DTA_1 = @DTA_1
      AND e.DTA_2 = @DTA_2
      AND e.DTA_3 = @DTA_3
      AND e.DTA_4 = @DTA_4
      AND e.EDG_DIR = 'O'
    ORDER BY e.EDG_1, e.EDG_2, e.EDG_3, e.EDG_4;
END
GO

-- ===========================================
-- 4. Récupérer les détails complets d'une ligne
-- ===========================================
CREATE OR ALTER PROCEDURE sp_GetLineVisDetail
    @DTA_1 NVARCHAR(100),
    @DTA_2 NVARCHAR(100),
    @DTA_3 NVARCHAR(100),
    @DTA_4 NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        LNA_UID,
        LIN_UID,
        DTA_1,
        DTA_2,
        DTA_3,
        DTA_4,
        EDG_DIR,
        EDG_1,
        EDG_2,
        EDG_3,
        EDG_4,
        TXN_DTA,
        PRX_TXN_DTA
    FROM LINE_VIS_EDG
    WHERE DTA_1 = @DTA_1
      AND DTA_2 = @DTA_2
      AND DTA_3 = @DTA_3
      AND DTA_4 = @DTA_4;
END
GO

-- ===========================================
-- 5. Vérifier si une donnée existe (pour navigation depuis EDG)
-- ===========================================
CREATE OR ALTER PROCEDURE sp_CheckLineVisExists
    @DTA_1 NVARCHAR(100),
    @DTA_2 NVARCHAR(100),
    @DTA_3 NVARCHAR(100),
    @DTA_4 NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM LINE_VIS_EDG
            WHERE DTA_1 = @DTA_1
              AND DTA_2 = @DTA_2
              AND DTA_3 = @DTA_3
              AND DTA_4 = @DTA_4
        ) THEN 1
        ELSE 0
    END AS [Exists];
END
GO

-- ===========================================
-- 6. Predecesseurs + successeurs d'un noeud pour un programme (page Recherche)
--    @EXE_PGM_NME NULL = tous les programmes
--    EDG_DIR : 'I' = predecesseur, 'O' = successeur
-- ===========================================
CREATE OR ALTER PROCEDURE sp_GetLiensNoeudProgramme
    @DTA_1 NVARCHAR(100),
    @DTA_2 NVARCHAR(100),
    @DTA_3 NVARCHAR(100),
    @DTA_4 NVARCHAR(100),
    @EXE_PGM_NME VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.EDG_DIR,
        e.EDG_1,
        e.EDG_2,
        e.EDG_3,
        e.EDG_4,
        e.LNA_UID,
        h.RON_APP,
        h.PCK_PGM_NME,
        h.EXE_PGM_NME,
        h.VRS_EXE_PGM,
        h.APP_ENV,
        h.DLY_PGM_TSP,
        h.LNA_TSP,
        h.PGM_TEC,
        h.VRS_LNA_TOO,
        h.TUS_IND
    FROM LINE_VIS_EDG e
    LEFT JOIN LINE_VIS_HEA h ON h.LNA_UID = e.LNA_UID
    WHERE e.DTA_1 = @DTA_1
      AND e.DTA_2 = @DTA_2
      AND e.DTA_3 = @DTA_3
      AND e.DTA_4 = @DTA_4
      AND (@EXE_PGM_NME IS NULL OR h.EXE_PGM_NME = @EXE_PGM_NME)
    ORDER BY e.EDG_DIR, e.EDG_1, e.EDG_2, e.EDG_3, e.EDG_4;
END
GO

-- ===========================================
-- 7. Liste des programmes connus (suggestions du champ EXE_PGM_NME)
-- ===========================================
CREATE OR ALTER PROCEDURE sp_GetProgrammes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT EXE_PGM_NME
    FROM LINE_VIS_HEA
    WHERE EXE_PGM_NME IS NOT NULL
    ORDER BY EXE_PGM_NME;
END
GO
