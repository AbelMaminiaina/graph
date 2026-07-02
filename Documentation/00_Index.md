# Documentation Complete - Systeme de Trace de Navigation LINE_VIS

## Vue d'ensemble

Ce systeme permet de tracer la navigation d'un utilisateur dans les donnees LINE_VIS et de visualiser son parcours sous forme de graphe oriente.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SYSTEME DE TRACE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────┐    ┌──────────────┐    ┌─────────────────┐    ┌──────────┐  │
│  │          │    │              │    │                 │    │          │  │
│  │  Liste   │───>│   Detail     │───>│  NavHistory     │───>│  Graphe  │  │
│  │  DTA     │    │   + Pred     │    │  Service        │    │  SVG     │  │
│  │          │    │   + Succ     │    │  (Trace)        │    │          │  │
│  └──────────┘    └──────────────┘    └─────────────────┘    └──────────┘  │
│       │                │                    │                    │         │
│       │                │                    │                    │         │
│       ▼                ▼                    ▼                    ▼         │
│   AddNode()      NavigateTo()        Nodes + Edges         Visualisation  │
│   (pas d'arete)  (cree arete)        (en memoire)          (temps reel)   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Documents

| # | Fichier | Description |
|---|---------|-------------|
| 1 | [01_Algorithme_Trace.md](01_Algorithme_Trace.md) | Algorithme complet avec pseudo-code et diagrammes de flux |
| 2 | [02_Modelisation.md](02_Modelisation.md) | Diagrammes UML, entite-relation, sequences |
| 3 | [03_Scripts_SQL.sql](03_Scripts_SQL.sql) | Scripts SQL complets (table, procedures, donnees test) |
| 4 | [04_Code_CSharp.md](04_Code_CSharp.md) | Code C# complet (modeles, services, configuration) |

## Architecture

```
LineVisApp/
├── Documentation/
│   ├── 00_Index.md                    # Ce fichier
│   ├── 01_Algorithme_Trace.md         # Algorithme
│   ├── 02_Modelisation.md             # UML et diagrammes
│   ├── 03_Scripts_SQL.sql             # Scripts SQL
│   └── 04_Code_CSharp.md              # Code C#
├── Models/
│   └── LineVisEdg.cs                  # GraphNode, GraphEdge, EdgeDirection
├── Services/
│   ├── LineVisService.cs              # Acces base de donnees
│   └── NavigationHistoryService.cs    # Tracage navigation (SCOPED)
├── Pages/
│   ├── LineVisList.razor              # Premier ecran (liste)
│   └── LineVisDetail.razor            # Deuxieme ecran (detail + graphe)
├── SQL/
│   ├── DonneesTest.sql                # Donnees de test
│   └── StoredProcedures/
│       └── ProceduresStockees.sql     # Procedures stockees
└── Program.cs                         # Configuration DI
```

## Resume de l'Algorithme

### 1. Structures de donnees
```
GraphNode {Id, Key, Label, DTA_1..4, IsActive}
GraphEdge {Id, SourceKey, TargetKey, Direction, Order}
EdgeDirection {ToPredecessor, ToSuccessor}
```

### 2. Operations principales
```
AddNode(dta1, dta2, dta3, dta4)
  -> Cree un noeud sans arete (premier acces)
  -> Met a jour currentNodeKey

NavigateTo(dta1, dta2, dta3, dta4, direction)
  -> Cree le noeud cible si necessaire
  -> Cree l'arete (currentNode -> targetNode)
  -> Met a jour currentNodeKey
```

### 3. Visualisation
- **Noeud bleu** = noeud actif (courant)
- **Noeud gris** = noeud visite
- **Arete jaune** = navigation vers predecesseur
- **Arete verte** = navigation vers successeur
- **Numero sur arete** = ordre chronologique du clic

## Technologies

| Composant | Technologie |
|-----------|-------------|
| Frontend | Blazor Server (.NET 9) |
| Backend | C# / ASP.NET Core |
| Base de donnees | SQL Server |
| ORM | Dapper |
| Visualisation | SVG inline |

## Execution

```bash
# 1. Configurer la connexion SQL Server dans appsettings.json
# 2. Executer les scripts SQL
sqlcmd -S .\SQLEXPRESS02 -E -i Documentation/03_Scripts_SQL.sql

# 3. Lancer l'application
dotnet run --urls "http://localhost:5000"

# 4. Ouvrir http://localhost:5000
```

## Auteur

Application Blazor pour CM-CIC - Projet LINE_VIS
