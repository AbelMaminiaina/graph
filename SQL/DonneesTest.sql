-- ===========================================
-- Script d'insertion de donnees de test
-- Table: LINE_VIS_EDG
-- ===========================================

-- Creer la table si elle n'existe pas
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='LINE_VIS_EDG' AND xtype='U')
BEGIN
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
END
GO

-- Vider la table pour les tests
DELETE FROM LINE_VIS_EDG;
GO

-- Insertion des donnees de test
-- Noeud A avec predecesseurs et successeurs
INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA001', 'LIN001', 'NoeudA', 'TypeA', 'Cat1', 'V1', 'I', 'NoeudX', 'TypeX', 'Cat1', 'V1', GETDATE(), GETDATE());

INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA001', 'LIN002', 'NoeudA', 'TypeA', 'Cat1', 'V1', 'O', 'NoeudB', 'TypeB', 'Cat1', 'V1', GETDATE(), GETDATE());

INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA001', 'LIN003', 'NoeudA', 'TypeA', 'Cat1', 'V1', 'O', 'NoeudC', 'TypeC', 'Cat1', 'V1', GETDATE(), GETDATE());

-- Noeud B avec predecesseurs et successeurs
INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA002', 'LIN001', 'NoeudB', 'TypeB', 'Cat1', 'V1', 'I', 'NoeudA', 'TypeA', 'Cat1', 'V1', GETDATE(), GETDATE());

INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA002', 'LIN002', 'NoeudB', 'TypeB', 'Cat1', 'V1', 'O', 'NoeudD', 'TypeD', 'Cat2', 'V1', GETDATE(), GETDATE());

INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA002', 'LIN003', 'NoeudB', 'TypeB', 'Cat1', 'V1', 'O', 'NoeudE', 'TypeE', 'Cat2', 'V1', GETDATE(), GETDATE());

-- Noeud C avec predecesseurs et successeurs
INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA003', 'LIN001', 'NoeudC', 'TypeC', 'Cat1', 'V1', 'I', 'NoeudA', 'TypeA', 'Cat1', 'V1', GETDATE(), GETDATE());

INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA003', 'LIN002', 'NoeudC', 'TypeC', 'Cat1', 'V1', 'O', 'NoeudF', 'TypeF', 'Cat3', 'V2', GETDATE(), GETDATE());

-- Noeud D avec predecesseurs
INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA004', 'LIN001', 'NoeudD', 'TypeD', 'Cat2', 'V1', 'I', 'NoeudB', 'TypeB', 'Cat1', 'V1', GETDATE(), GETDATE());

INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA004', 'LIN002', 'NoeudD', 'TypeD', 'Cat2', 'V1', 'O', 'NoeudG', 'TypeG', 'Cat3', 'V2', GETDATE(), GETDATE());

-- Noeud E avec predecesseurs
INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA005', 'LIN001', 'NoeudE', 'TypeE', 'Cat2', 'V1', 'I', 'NoeudB', 'TypeB', 'Cat1', 'V1', GETDATE(), GETDATE());

-- Noeud F avec predecesseurs et successeurs
INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA006', 'LIN001', 'NoeudF', 'TypeF', 'Cat3', 'V2', 'I', 'NoeudC', 'TypeC', 'Cat1', 'V1', GETDATE(), GETDATE());

INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA006', 'LIN002', 'NoeudF', 'TypeF', 'Cat3', 'V2', 'O', 'NoeudG', 'TypeG', 'Cat3', 'V2', GETDATE(), GETDATE());

-- Noeud G avec predecesseurs multiples (point de convergence)
INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA007', 'LIN001', 'NoeudG', 'TypeG', 'Cat3', 'V2', 'I', 'NoeudD', 'TypeD', 'Cat2', 'V1', GETDATE(), GETDATE());

INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA007', 'LIN002', 'NoeudG', 'TypeG', 'Cat3', 'V2', 'I', 'NoeudF', 'TypeF', 'Cat3', 'V2', GETDATE(), GETDATE());

-- Noeud X (racine sans predecesseur)
INSERT INTO LINE_VIS_EDG (LNA_UID, LIN_UID, DTA_1, DTA_2, DTA_3, DTA_4, EDG_DIR, EDG_1, EDG_2, EDG_3, EDG_4, TXN_DTA, PRX_TXN_DTA)
VALUES ('LNA008', 'LIN001', 'NoeudX', 'TypeX', 'Cat1', 'V1', 'O', 'NoeudA', 'TypeA', 'Cat1', 'V1', GETDATE(), GETDATE());

GO

-- Verifier les donnees
SELECT 'Donnees distinctes:' AS Info;
SELECT DISTINCT DTA_1, DTA_2, DTA_3, DTA_4 FROM LINE_VIS_EDG ORDER BY DTA_1;

SELECT 'Toutes les donnees:' AS Info;
SELECT * FROM LINE_VIS_EDG ORDER BY DTA_1, EDG_DIR;
GO
