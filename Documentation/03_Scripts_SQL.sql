-- ============================================================================
-- SCRIPTS SQL COMPLETS POUR LE SYSTEME DE TRACE LINE_VIS
-- ============================================================================
-- Base de donnees: LINE_VIS
-- Table: LINE_VIS_EDG
-- ============================================================================

-- ============================================================================
-- PARTIE 1: CREATION DE LA BASE ET DE LA TABLE
-- ============================================================================

-- Creer la base de donnees si elle n'existe pas
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'LINE_VIS')
BEGIN
    CREATE DATABASE LINE_VIS;
END
GO

USE LINE_VIS;
GO

-- Supprimer la table si elle existe (pour reinstallation)
IF OBJECT_ID('dbo.LINE_VIS_EDG', 'U') IS NOT NULL
    DROP TABLE dbo.LINE_VIS_EDG;
GO

-- Creer la table LINE_VIS_EDG
CREATE TABLE LINE_VIS_EDG (
    -- Cles primaires
    LNA_UID        NVARCHAR(50)   NOT NULL,
    LIN_UID        NVARCHAR(50)   NOT NULL,
    EDG_DIR        NVARCHAR(10)   NOT NULL,  -- 'I' = Input (predecesseur), 'O' = Output (successeur)

    -- Donnees du noeud courant
    DTA_1          NVARCHAR(100)  NULL,
    DTA_2          NVARCHAR(100)  NULL,
    DTA_3          NVARCHAR(100)  NULL,
    DTA_4          NVARCHAR(100)  NULL,

    -- Donnees du noeud lie (predecesseur ou successeur)
    EDG_1          NVARCHAR(100)  NULL,
    EDG_2          NVARCHAR(100)  NULL,
    EDG_3          NVARCHAR(100)  NULL,
    EDG_4          NVARCHAR(100)  NULL,

    -- Metadonnees
    TXN_DTA        DATETIME       NULL,
    PRX_TXN_DTA    DATETIME       NULL,

    -- Contrainte de cle primaire composite
    CONSTRAINT PK_LINE_VIS_EDG PRIMARY KEY (LNA_UID, LIN_UID, EDG_DIR)
);
GO

-- Index pour ameliorer les performances des requetes
CREATE INDEX IX_LINE_VIS_EDG_DTA ON LINE_VIS_EDG (DTA_1, DTA_2, DTA_3, DTA_4);
CREATE INDEX IX_LINE_VIS_EDG_EDG ON LINE_VIS_EDG (EDG_1, EDG_2, EDG_3, EDG_4);
CREATE INDEX IX_LINE_VIS_EDG_DIR ON LINE_VIS_EDG (EDG_DIR);
GO

-- ============================================================================
-- PARTIE 2: PROCEDURES STOCKEES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 sp_GetDistinctLineVis: Recuperer les donnees distinctes (Premier ecran)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 2.2 sp_GetPredecesseurs: Recuperer les predecesseurs (EDG_DIR = 'I')
-- ----------------------------------------------------------------------------
-- Logique: Si EDG_DIR = 'I', alors EDG_1,2,3,4 est le predecesseur de DTA_1,2,3,4
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

-- ----------------------------------------------------------------------------
-- 2.3 sp_GetSuccesseurs: Recuperer les successeurs (EDG_DIR = 'O')
-- ----------------------------------------------------------------------------
-- Logique: Si EDG_DIR = 'O', alors EDG_1,2,3,4 est le successeur de DTA_1,2,3,4
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

-- ----------------------------------------------------------------------------
-- 2.4 sp_GetLineVisDetail: Recuperer les details complets d'une ligne
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 2.5 sp_CheckLineVisExists: Verifier si une donnee existe
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- 2.6 sp_GetAllRelations: Recuperer toutes les relations d'un noeud
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GetAllRelations
    @DTA_1 NVARCHAR(100),
    @DTA_2 NVARCHAR(100),
    @DTA_3 NVARCHAR(100),
    @DTA_4 NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Predecesseurs
    SELECT
        'Predecesseur' AS RelationType,
        EDG_1, EDG_2, EDG_3, EDG_4
    FROM LINE_VIS_EDG
    WHERE DTA_1 = @DTA_1 AND DTA_2 = @DTA_2 AND DTA_3 = @DTA_3 AND DTA_4 = @DTA_4
      AND EDG_DIR = 'I'

    UNION ALL

    -- Successeurs
    SELECT
        'Successeur' AS RelationType,
        EDG_1, EDG_2, EDG_3, EDG_4
    FROM LINE_VIS_EDG
    WHERE DTA_1 = @DTA_1 AND DTA_2 = @DTA_2 AND DTA_3 = @DTA_3 AND DTA_4 = @DTA_4
      AND EDG_DIR = 'O'

    ORDER BY RelationType, EDG_1, EDG_2, EDG_3, EDG_4;
END
GO

-- ----------------------------------------------------------------------------
-- 2.7 sp_GetGraphData: Recuperer les donnees pour construire un graphe complet
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GetGraphData
AS
BEGIN
    SET NOCOUNT ON;

    -- Tous les noeuds uniques
    SELECT 'NODES' AS DataType;
    SELECT DISTINCT
        DTA_1, DTA_2, DTA_3, DTA_4
    FROM LINE_VIS_EDG
    ORDER BY DTA_1, DTA_2, DTA_3, DTA_4;

    -- Toutes les aretes
    SELECT 'EDGES' AS DataType;
    SELECT
        DTA_1 AS Source_1, DTA_2 AS Source_2, DTA_3 AS Source_3, DTA_4 AS Source_4,
        EDG_1 AS Target_1, EDG_2 AS Target_2, EDG_3 AS Target_3, EDG_4 AS Target_4,
        EDG_DIR AS Direction
    FROM LINE_VIS_EDG
    ORDER BY DTA_1, EDG_DIR, EDG_1;
END
GO

-- ============================================================================
-- PARTIE 3: DONNEES DE TEST
-- ============================================================================

-- Vider les donnees existantes
DELETE FROM LINE_VIS_EDG;
GO

-- Inserer les donnees de test
-- Structure du graphe de test:
--
--     NoeudX
--        │
--        ▼ (predecesseur de A)
--     NoeudA
--      /   \
--     ▼     ▼ (successeurs de A)
--  NoeudB  NoeudC
--   / \       \
--  ▼   ▼       ▼
-- D    E       F
--  \         /
--   ▼       ▼
--     NoeudG

-- NoeudA: predecesseur=NoeudX, successeurs=NoeudB,NoeudC
INSERT INTO LINE_VIS_EDG VALUES ('LNA001', 'LIN001', 'I', 'NoeudA', 'TypeA', 'Cat1', 'V1', 'NoeudX', 'TypeX', 'Cat1', 'V1', GETDATE(), GETDATE());
INSERT INTO LINE_VIS_EDG VALUES ('LNA001', 'LIN002', 'O', 'NoeudA', 'TypeA', 'Cat1', 'V1', 'NoeudB', 'TypeB', 'Cat1', 'V1', GETDATE(), GETDATE());
INSERT INTO LINE_VIS_EDG VALUES ('LNA001', 'LIN003', 'O', 'NoeudA', 'TypeA', 'Cat1', 'V1', 'NoeudC', 'TypeC', 'Cat1', 'V1', GETDATE(), GETDATE());

-- NoeudB: predecesseur=NoeudA, successeurs=NoeudD,NoeudE
INSERT INTO LINE_VIS_EDG VALUES ('LNA002', 'LIN001', 'I', 'NoeudB', 'TypeB', 'Cat1', 'V1', 'NoeudA', 'TypeA', 'Cat1', 'V1', GETDATE(), GETDATE());
INSERT INTO LINE_VIS_EDG VALUES ('LNA002', 'LIN002', 'O', 'NoeudB', 'TypeB', 'Cat1', 'V1', 'NoeudD', 'TypeD', 'Cat2', 'V1', GETDATE(), GETDATE());
INSERT INTO LINE_VIS_EDG VALUES ('LNA002', 'LIN003', 'O', 'NoeudB', 'TypeB', 'Cat1', 'V1', 'NoeudE', 'TypeE', 'Cat2', 'V1', GETDATE(), GETDATE());

-- NoeudC: predecesseur=NoeudA, successeur=NoeudF
INSERT INTO LINE_VIS_EDG VALUES ('LNA003', 'LIN001', 'I', 'NoeudC', 'TypeC', 'Cat1', 'V1', 'NoeudA', 'TypeA', 'Cat1', 'V1', GETDATE(), GETDATE());
INSERT INTO LINE_VIS_EDG VALUES ('LNA003', 'LIN002', 'O', 'NoeudC', 'TypeC', 'Cat1', 'V1', 'NoeudF', 'TypeF', 'Cat3', 'V2', GETDATE(), GETDATE());

-- NoeudD: predecesseur=NoeudB, successeur=NoeudG
INSERT INTO LINE_VIS_EDG VALUES ('LNA004', 'LIN001', 'I', 'NoeudD', 'TypeD', 'Cat2', 'V1', 'NoeudB', 'TypeB', 'Cat1', 'V1', GETDATE(), GETDATE());
INSERT INTO LINE_VIS_EDG VALUES ('LNA004', 'LIN002', 'O', 'NoeudD', 'TypeD', 'Cat2', 'V1', 'NoeudG', 'TypeG', 'Cat3', 'V2', GETDATE(), GETDATE());

-- NoeudE: predecesseur=NoeudB (feuille)
INSERT INTO LINE_VIS_EDG VALUES ('LNA005', 'LIN001', 'I', 'NoeudE', 'TypeE', 'Cat2', 'V1', 'NoeudB', 'TypeB', 'Cat1', 'V1', GETDATE(), GETDATE());

-- NoeudF: predecesseur=NoeudC, successeur=NoeudG
INSERT INTO LINE_VIS_EDG VALUES ('LNA006', 'LIN001', 'I', 'NoeudF', 'TypeF', 'Cat3', 'V2', 'NoeudC', 'TypeC', 'Cat1', 'V1', GETDATE(), GETDATE());
INSERT INTO LINE_VIS_EDG VALUES ('LNA006', 'LIN002', 'O', 'NoeudF', 'TypeF', 'Cat3', 'V2', 'NoeudG', 'TypeG', 'Cat3', 'V2', GETDATE(), GETDATE());

-- NoeudG: predecesseurs=NoeudD,NoeudF (point de convergence)
INSERT INTO LINE_VIS_EDG VALUES ('LNA007', 'LIN001', 'I', 'NoeudG', 'TypeG', 'Cat3', 'V2', 'NoeudD', 'TypeD', 'Cat2', 'V1', GETDATE(), GETDATE());
INSERT INTO LINE_VIS_EDG VALUES ('LNA007', 'LIN002', 'I', 'NoeudG', 'TypeG', 'Cat3', 'V2', 'NoeudF', 'TypeF', 'Cat3', 'V2', GETDATE(), GETDATE());

-- NoeudX: successeur=NoeudA (racine)
INSERT INTO LINE_VIS_EDG VALUES ('LNA008', 'LIN001', 'O', 'NoeudX', 'TypeX', 'Cat1', 'V1', 'NoeudA', 'TypeA', 'Cat1', 'V1', GETDATE(), GETDATE());

GO

-- ============================================================================
-- PARTIE 4: VERIFICATION
-- ============================================================================

PRINT '=== VERIFICATION DES DONNEES ===';
PRINT '';

PRINT 'Noeuds distincts:';
EXEC sp_GetDistinctLineVis;

PRINT '';
PRINT 'Predecesseurs de NoeudA:';
EXEC sp_GetPredecesseurs 'NoeudA', 'TypeA', 'Cat1', 'V1';

PRINT '';
PRINT 'Successeurs de NoeudA:';
EXEC sp_GetSuccesseurs 'NoeudA', 'TypeA', 'Cat1', 'V1';

PRINT '';
PRINT 'Toutes les relations de NoeudB:';
EXEC sp_GetAllRelations 'NoeudB', 'TypeB', 'Cat1', 'V1';

PRINT '';
PRINT 'Verification existence NoeudA:';
EXEC sp_CheckLineVisExists 'NoeudA', 'TypeA', 'Cat1', 'V1';

PRINT '';
PRINT 'Verification existence NoeudZ (inexistant):';
EXEC sp_CheckLineVisExists 'NoeudZ', 'TypeZ', 'Cat9', 'V9';

GO
