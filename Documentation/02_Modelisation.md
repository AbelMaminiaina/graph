# Modelisation du Systeme de Trace

## 1. Diagramme de Classes UML

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DIAGRAMME DE CLASSES                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐       ┌─────────────────────────────┐
│       LineVisEdg            │       │       LineVisDistinct       │
│         (Entity)            │       │         (DTO)               │
├─────────────────────────────┤       ├─────────────────────────────┤
│ + LNA_UID: string           │       │ + DTA_1: string?            │
│ + LIN_UID: string           │       │ + DTA_2: string?            │
│ + DTA_1: string?            │       │ + DTA_3: string?            │
│ + DTA_2: string?            │       │ + DTA_4: string?            │
│ + DTA_3: string?            │       └─────────────────────────────┘
│ + DTA_4: string?            │
│ + EDG_DIR: string           │       ┌─────────────────────────────┐
│ + EDG_1: string?            │       │       LineVisEdge           │
│ + EDG_2: string?            │       │         (DTO)               │
│ + EDG_3: string?            │       ├─────────────────────────────┤
│ + EDG_4: string?            │       │ + EDG_1: string?            │
│ + TXN_DTA: DateTime?        │       │ + EDG_2: string?            │
│ + PRX_TXN_DTA: DateTime?    │       │ + EDG_3: string?            │
└─────────────────────────────┘       │ + EDG_4: string?            │
                                      └─────────────────────────────┘

┌─────────────────────────────┐       ┌─────────────────────────────┐
│        GraphNode            │       │        GraphEdge            │
│    (Noeud du graphe)        │       │    (Arete du graphe)        │
├─────────────────────────────┤       ├─────────────────────────────┤
│ + Id: int                   │       │ + Id: int                   │
│ + Label: string             │       │ + SourceKey: string         │
│ + DTA_1: string?            │       │ + TargetKey: string         │
│ + DTA_2: string?            │       │ + Direction: EdgeDirection  │
│ + DTA_3: string?            │       │ + Order: int                │
│ + DTA_4: string?            │       ├─────────────────────────────┤
│ + IsActive: bool            │       │ + Key: string {readonly}    │
├─────────────────────────────┤       └─────────────────────────────┘
│ + Key: string {readonly}    │                    │
│ + Equals(obj): bool         │                    │
│ + GetHashCode(): int        │                    │
└─────────────────────────────┘                    │
         │                                         │
         │ 1                                       │ *
         │                                         │
         └───────────────┬─────────────────────────┘
                         │
                         │ utilise
                         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     NavigationHistoryService                                │
│                          (Service Scoped)                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ - _nodes: List<GraphNode>                                                   │
│ - _edges: List<GraphEdge>                                                   │
│ - _nodeIdCounter: int                                                       │
│ - _edgeIdCounter: int                                                       │
│ - _currentNodeKey: string?                                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ + Nodes: IReadOnlyList<GraphNode> {readonly}                                │
│ + Edges: IReadOnlyList<GraphEdge> {readonly}                                │
│ + NodeCount: int {readonly}                                                 │
│ + EdgeCount: int {readonly}                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ + AddNode(dta1, dta2, dta3, dta4): GraphNode                                │
│ + NavigateTo(dta1, dta2, dta3, dta4, direction): GraphNode                  │
│ + ContainsNode(dta1, dta2, dta3, dta4): bool                                │
│ + GetNode(key): GraphNode?                                                  │
│ + GetActiveNode(): GraphNode?                                               │
│ + Clear(): void                                                             │
│ + GetOutgoingEdges(nodeKey): IEnumerable<GraphEdge>                         │
│ + GetIncomingEdges(nodeKey): IEnumerable<GraphEdge>                         │
│ + GetStats(): (int, int, int, int)                                          │
│ - SetActiveNode(key): void                                                  │
└─────────────────────────────────────────────────────────────────────────────┘
                         │
                         │ injecte dans
                         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        LineVisDetail.razor                                  │
│                         (Composant Blazor)                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│ @inject NavigationHistoryService NavHistory                                 │
│ @inject ILineVisService LineVisService                                      │
│ @inject NavigationManager Navigation                                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ [Parameter] DTA1, DTA2, DTA3, DTA4: string                                  │
│ - _predecesseurs: IEnumerable<LineVisEdge>                                  │
│ - _successeurs: IEnumerable<LineVisEdge>                                    │
│ - _loading: bool                                                            │
├─────────────────────────────────────────────────────────────────────────────┤
│ # OnParametersSetAsync(): Task                                              │
│ - LoadDataAsync(): Task                                                     │
│ - NavigateToPredecessor(edge): void                                         │
│ - NavigateToSuccessor(edge): void                                           │
│ - NavigateToNode(node): void                                                │
│ - GenerateGraphSvg(): string                                                │
│ - ClearHistory(): void                                                      │
└─────────────────────────────────────────────────────────────────────────────┘

┌───────────────────────┐
│    EdgeDirection      │
│     (Enumeration)     │
├───────────────────────┤
│ ToPredecessor = 0     │
│ ToSuccessor = 1       │
└───────────────────────┘
```

## 2. Diagramme Entite-Relation (Base de Donnees)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DIAGRAMME ENTITE-RELATION                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            LINE_VIS_EDG                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ PK  LNA_UID        NVARCHAR(50)    NOT NULL                                 │
│ PK  LIN_UID        NVARCHAR(50)    NOT NULL                                 │
│ PK  EDG_DIR        NVARCHAR(10)    NOT NULL    -- 'I' ou 'O'                │
│     DTA_1          NVARCHAR(100)   NULL                                     │
│     DTA_2          NVARCHAR(100)   NULL                                     │
│     DTA_3          NVARCHAR(100)   NULL                                     │
│     DTA_4          NVARCHAR(100)   NULL                                     │
│     EDG_1          NVARCHAR(100)   NULL                                     │
│     EDG_2          NVARCHAR(100)   NULL                                     │
│     EDG_3          NVARCHAR(100)   NULL                                     │
│     EDG_4          NVARCHAR(100)   NULL                                     │
│     TXN_DTA        DATETIME        NULL                                     │
│     PRX_TXN_DTA    DATETIME        NULL                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Relation logique
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         RELATIONS LOGIQUES                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Si EDG_DIR = 'I' (Input):                                                  │
│  ┌──────────────────┐         ┌──────────────────┐                         │
│  │ EDG_1,2,3,4      │ ──────> │ DTA_1,2,3,4      │                         │
│  │ (Predecesseur)   │         │ (Noeud courant)  │                         │
│  └──────────────────┘         └──────────────────┘                         │
│                                                                             │
│  Si EDG_DIR = 'O' (Output):                                                 │
│  ┌──────────────────┐         ┌──────────────────┐                         │
│  │ DTA_1,2,3,4      │ ──────> │ EDG_1,2,3,4      │                         │
│  │ (Noeud courant)  │         │ (Successeur)     │                         │
│  └──────────────────┘         └──────────────────┘                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 3. Diagramme de Sequence

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      DIAGRAMME DE SEQUENCE                                  │
│                   Navigation vers un Successeur                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌────────┐     ┌─────────────┐     ┌────────────┐     ┌──────────────┐
│  User  │     │LineVisDetail│     │NavHistory  │     │LineVisService│
└───┬────┘     └──────┬──────┘     └─────┬──────┘     └──────┬───────┘
    │                 │                  │                   │
    │ Clic Successeur │                  │                   │
    │────────────────>│                  │                   │
    │                 │                  │                   │
    │                 │ NavigateTo(dta,  │                   │
    │                 │  ToSuccessor)    │                   │
    │                 │─────────────────>│                   │
    │                 │                  │                   │
    │                 │                  │ Creer/Get Node    │
    │                 │                  │─────────┐         │
    │                 │                  │         │         │
    │                 │                  │<────────┘         │
    │                 │                  │                   │
    │                 │                  │ Creer Edge        │
    │                 │                  │─────────┐         │
    │                 │                  │         │         │
    │                 │                  │<────────┘         │
    │                 │                  │                   │
    │                 │      node        │                   │
    │                 │<─────────────────│                   │
    │                 │                  │                   │
    │                 │ ExistsAsync(dta) │                   │
    │                 │─────────────────────────────────────>│
    │                 │                  │                   │
    │                 │                  │          bool     │
    │                 │<─────────────────────────────────────│
    │                 │                  │                   │
    │                 │ NavigateTo(url)  │                   │
    │                 │─────────┐        │                   │
    │                 │         │        │                   │
    │                 │<────────┘        │                   │
    │                 │                  │                   │
    │   Page Detail   │                  │                   │
    │   (nouveau DTA) │                  │                   │
    │<────────────────│                  │                   │
    │                 │                  │                   │
```

## 4. Diagramme d'Etats du Graphe

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      DIAGRAMME D'ETATS                                      │
└─────────────────────────────────────────────────────────────────────────────┘

                            ┌─────────────────┐
                            │     VIDE        │
                            │  Nodes=0        │
                            │  Edges=0        │
                            └────────┬────────┘
                                     │
                                     │ AddNode()
                                     ▼
                            ┌─────────────────┐
                            │   UN NOEUD      │
                            │  Nodes=1        │
                            │  Edges=0        │
                            └────────┬────────┘
                                     │
                                     │ NavigateTo()
                                     ▼
                            ┌─────────────────┐
                            │  MULTI-NOEUDS   │◄─────────────┐
                            │  Nodes>=2       │              │
                            │  Edges>=1       │──────────────┘
                            └────────┬────────┘ NavigateTo()
                                     │
                                     │ Clear()
                                     ▼
                            ┌─────────────────┐
                            │     VIDE        │
                            └─────────────────┘


TRANSITIONS D'ETAT DU NOEUD ACTIF:

    ┌──────────┐  NavigateTo(B)   ┌──────────┐
    │ A actif  │ ───────────────> │ B actif  │
    │ B inactif│                  │ A inactif│
    └──────────┘                  └──────────┘
         ▲                             │
         │      NavigateTo(A)          │
         └─────────────────────────────┘
```

## 5. Structure du Graphe en Memoire

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    STRUCTURE EN MEMOIRE                                     │
└─────────────────────────────────────────────────────────────────────────────┘

NavigationHistoryService
│
├── _nodes: List<GraphNode>
│   │
│   ├── [0] GraphNode
│   │       Id = 1
│   │       Key = "NoeudA|TypeA|Cat1|V1"
│   │       Label = "NoeudA"
│   │       IsActive = false
│   │
│   ├── [1] GraphNode
│   │       Id = 2
│   │       Key = "NoeudX|TypeX|Cat1|V1"
│   │       Label = "NoeudX"
│   │       IsActive = false
│   │
│   └── [2] GraphNode
│           Id = 3
│           Key = "NoeudB|TypeB|Cat1|V1"
│           Label = "NoeudB"
│           IsActive = true  ◄── Noeud actuel
│
├── _edges: List<GraphEdge>
│   │
│   ├── [0] GraphEdge
│   │       Id = 1
│   │       SourceKey = "NoeudA|TypeA|Cat1|V1"
│   │       TargetKey = "NoeudX|TypeX|Cat1|V1"
│   │       Direction = ToPredecessor  (JAUNE)
│   │       Order = 1
│   │
│   └── [1] GraphEdge
│           Id = 2
│           SourceKey = "NoeudX|TypeX|Cat1|V1"
│           TargetKey = "NoeudB|TypeB|Cat1|V1"
│           Direction = ToSuccessor  (VERT)
│           Order = 2
│
├── _nodeIdCounter = 3
├── _edgeIdCounter = 2
└── _currentNodeKey = "NoeudB|TypeB|Cat1|V1"


REPRESENTATION GRAPHIQUE:

       [1] NoeudA
           │
           │ (1) JAUNE - ToPredecessor
           ▼
       [2] NoeudX
           │
           │ (2) VERT - ToSuccessor
           ▼
       [3] NoeudB ◄── ACTIF
```

## 6. Injection de Dependances

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INJECTION DE DEPENDANCES                                 │
└─────────────────────────────────────────────────────────────────────────────┘

Program.cs:
┌─────────────────────────────────────────────────────────────────────────────┐
│ builder.Services.AddScoped<ILineVisService, LineVisService>();              │
│ builder.Services.AddScoped<NavigationHistoryService>();                     │
│                      │                    │                                 │
│                      │                    │                                 │
│               ┌──────┴──────┐      ┌──────┴──────┐                         │
│               │   SCOPED    │      │   SCOPED    │                         │
│               │             │      │             │                         │
│               │ Une instance│      │ Une instance│                         │
│               │ par circuit │      │ par circuit │                         │
│               │ Blazor      │      │ Blazor      │                         │
│               │ (utilisateur│      │ (utilisateur│                         │
│               └─────────────┘      └─────────────┘                         │
└─────────────────────────────────────────────────────────────────────────────┘

Cycle de vie SCOPED:
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  User A                              User B                                 │
│  ┌─────────────────────┐            ┌─────────────────────┐                │
│  │ Circuit Blazor A    │            │ Circuit Blazor B    │                │
│  │                     │            │                     │                │
│  │ NavHistoryService   │            │ NavHistoryService   │                │
│  │ Instance #1         │            │ Instance #2         │                │
│  │ - Nodes: [A,B,C]    │            │ - Nodes: [X,Y]      │                │
│  │ - Edges: [1,2,3]    │            │ - Edges: [1]        │                │
│  └─────────────────────┘            └─────────────────────┘                │
│                                                                             │
│  ISOLE - Chaque utilisateur a son propre historique                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```
