-- ===========================================
-- Script de création des procédures stockées
-- Table: LINE_VIS_EDG
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
        EDG_1,
        EDG_2,
        EDG_3,
        EDG_4
    FROM LINE_VIS_EDG
    WHERE DTA_1 = @DTA_1
      AND DTA_2 = @DTA_2
      AND DTA_3 = @DTA_3
      AND DTA_4 = @DTA_4
      AND EDG_DIR = 'I'
    ORDER BY EDG_1, EDG_2, EDG_3, EDG_4;
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
        EDG_1,
        EDG_2,
        EDG_3,
        EDG_4
    FROM LINE_VIS_EDG
    WHERE DTA_1 = @DTA_1
      AND DTA_2 = @DTA_2
      AND DTA_3 = @DTA_3
      AND DTA_4 = @DTA_4
      AND EDG_DIR = 'O'
    ORDER BY EDG_1, EDG_2, EDG_3, EDG_4;
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
