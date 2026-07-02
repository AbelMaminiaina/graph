# Algorithme de Trace de Navigation

## 1. Vue d'ensemble

Le système trace toutes les navigations de l'utilisateur pour construire un graphe orienté représentant son parcours dans les données LINE_VIS.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE DU SYSTEME DE TRACE                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌──────────┐     ┌──────────────┐     ┌─────────────────────────┐    │
│   │  Liste   │────>│   Detail     │────>│  NavigationHistory      │    │
│   │  (UI)    │     │   (UI)       │     │  Service (Scoped)       │    │
│   └──────────┘     └──────────────┘     └─────────────────────────┘    │
│        │                  │                        │                    │
│        │                  │                        ▼                    │
│        │                  │              ┌─────────────────────┐       │
│        │                  │              │  Graphe en memoire  │       │
│        │                  │              │  - Nodes[]          │       │
│        │                  │              │  - Edges[]          │       │
│        │                  │              │  - CurrentNode      │       │
│        │                  │              └─────────────────────┘       │
│        │                  │                        │                    │
│        │                  ▼                        ▼                    │
│        │           ┌──────────────┐      ┌─────────────────────┐       │
│        │           │  SQL Server  │      │  Rendu SVG Graphe   │       │
│        │           │  LINE_VIS_EDG│      │  (Visualisation)    │       │
│        │           └──────────────┘      └─────────────────────┘       │
│        │                                                                │
└────────┼────────────────────────────────────────────────────────────────┘
         │
         ▼
    POINT D'ENTREE
```

## 2. Structures de Donnees

### 2.1 GraphNode (Noeud du graphe)
```
GraphNode {
    Id: int                    // Identifiant unique auto-incremente
    Key: string                // Cle composite "DTA_1|DTA_2|DTA_3|DTA_4"
    Label: string              // Libelle affiche (DTA_1)
    DTA_1: string              // Donnee 1
    DTA_2: string              // Donnee 2
    DTA_3: string              // Donnee 3
    DTA_4: string              // Donnee 4
    IsActive: bool             // Noeud actuellement selectionne
}
```

### 2.2 GraphEdge (Arete du graphe)
```
GraphEdge {
    Id: int                    // Identifiant unique auto-incremente
    SourceKey: string          // Cle du noeud source
    TargetKey: string          // Cle du noeud cible
    Direction: EdgeDirection   // ToPredecessor | ToSuccessor
    Order: int                 // Ordre chronologique du clic (1, 2, 3...)
    Key: string                // Cle composite "SourceKey->TargetKey"
}
```

### 2.3 EdgeDirection (Direction de navigation)
```
EdgeDirection {
    ToPredecessor = 0          // Clic sur tableau predecesseur (JAUNE)
    ToSuccessor = 1            // Clic sur tableau successeur (VERT)
}
```

## 3. Algorithme Principal

### 3.1 Initialisation (Premier acces)
```
FONCTION AddNode(dta1, dta2, dta3, dta4):
    key = CONCATENER(dta1, "|", dta2, "|", dta3, "|", dta4)

    SI key N'EXISTE PAS dans Nodes:
        node = CREER GraphNode {
            Id = ++nodeIdCounter,
            Key = key,
            Label = dta1,
            DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4,
            IsActive = true
        }
        AJOUTER node a Nodes
    FIN SI

    SetActiveNode(key)
    currentNodeKey = key

    RETOURNER node
FIN FONCTION
```

### 3.2 Navigation avec Tracage
```
FONCTION NavigateTo(dta1, dta2, dta3, dta4, direction):
    targetKey = CONCATENER(dta1, "|", dta2, "|", dta3, "|", dta4)

    // Etape 1: Ajouter le noeud cible s'il n'existe pas
    SI targetKey N'EXISTE PAS dans Nodes:
        targetNode = CREER GraphNode {
            Id = ++nodeIdCounter,
            Key = targetKey,
            Label = dta1,
            DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4,
            IsActive = true
        }
        AJOUTER targetNode a Nodes
    FIN SI

    // Etape 2: Creer l'arete si on a un noeud source different
    SI currentNodeKey != NULL ET currentNodeKey != targetKey:
        edgeKey = CONCATENER(currentNodeKey, "->", targetKey)

        SI edgeKey N'EXISTE PAS dans Edges:
            edge = CREER GraphEdge {
                Id = ++edgeIdCounter,
                SourceKey = currentNodeKey,
                TargetKey = targetKey,
                Direction = direction,
                Order = TAILLE(Edges) + 1
            }
            AJOUTER edge a Edges
        FIN SI
    FIN SI

    // Etape 3: Mettre a jour l'etat
    SetActiveNode(targetKey)
    currentNodeKey = targetKey

    RETOURNER targetNode
FIN FONCTION
```

### 3.3 Mise a jour du noeud actif
```
FONCTION SetActiveNode(key):
    POUR CHAQUE node dans Nodes:
        node.IsActive = (node.Key == key)
    FIN POUR
FIN FONCTION
```

## 4. Diagramme de Flux

```
                    ┌─────────────────┐
                    │     DEBUT       │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Utilisateur     │
                    │ clique sur      │
                    │ une ligne       │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
     ┌─────────────────┐          ┌─────────────────┐
     │ Depuis Liste?   │          │ Depuis Detail?  │
     │ (Premier acces) │          │ (Navigation)    │
     └────────┬────────┘          └────────┬────────┘
              │                             │
              ▼                             ▼
     ┌─────────────────┐          ┌─────────────────┐
     │   AddNode()     │          │ Predecesseur    │
     │   (Pas d'arete) │          │ ou Successeur?  │
     └────────┬────────┘          └────────┬────────┘
              │                             │
              │               ┌─────────────┴─────────────┐
              │               │                           │
              │               ▼                           ▼
              │      ┌─────────────────┐        ┌─────────────────┐
              │      │ NavigateTo(     │        │ NavigateTo(     │
              │      │  ToPredecessor) │        │  ToSuccessor)   │
              │      │  JAUNE          │        │  VERT           │
              │      └────────┬────────┘        └────────┬────────┘
              │               │                           │
              │               └─────────────┬─────────────┘
              │                             │
              └──────────────┬──────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Noeud existe?   │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │ NON                         │ OUI
              ▼                             ▼
     ┌─────────────────┐          ┌─────────────────┐
     │ Creer nouveau   │          │ Recuperer       │
     │ GraphNode       │          │ GraphNode       │
     └────────┬────────┘          └────────┬────────┘
              │                             │
              └──────────────┬──────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Arete existe?   │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │ NON                         │ OUI
              ▼                             ▼
     ┌─────────────────┐          ┌─────────────────┐
     │ Creer nouvelle  │          │ Ne rien faire   │
     │ GraphEdge       │          │ (deja tracee)   │
     └────────┬────────┘          └────────┬────────┘
              │                             │
              └──────────────┬──────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Mettre a jour   │
                    │ currentNodeKey  │
                    │ et IsActive     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Redessiner      │
                    │ Graphe SVG      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │      FIN        │
                    └─────────────────┘
```

## 5. Exemple de Trace

```
Etat Initial: Nodes=[], Edges=[], currentNodeKey=null

Action 1: Clic sur "NoeudA" depuis la liste
  -> AddNode("NoeudA", "TypeA", "Cat1", "V1")
  -> Nodes=[{Id:1, Key:"NoeudA|TypeA|Cat1|V1", IsActive:true}]
  -> Edges=[]
  -> currentNodeKey="NoeudA|TypeA|Cat1|V1"

Action 2: Clic sur predecesseur "NoeudX"
  -> NavigateTo("NoeudX", "TypeX", "Cat1", "V1", ToPredecessor)
  -> Nodes=[{Id:1, NoeudA, IsActive:false}, {Id:2, NoeudX, IsActive:true}]
  -> Edges=[{Id:1, Source:NoeudA, Target:NoeudX, Dir:ToPred, Order:1}]
  -> currentNodeKey="NoeudX|TypeX|Cat1|V1"

Action 3: Clic sur successeur "NoeudA"
  -> NavigateTo("NoeudA", "TypeA", "Cat1", "V1", ToSuccessor)
  -> Nodes=[{Id:1, NoeudA, IsActive:true}, {Id:2, NoeudX, IsActive:false}]
  -> Edges=[{..., Order:1}, {Id:2, Source:NoeudX, Target:NoeudA, Dir:ToSucc, Order:2}]
  -> currentNodeKey="NoeudA|TypeA|Cat1|V1"

Action 4: Clic sur successeur "NoeudB"
  -> NavigateTo("NoeudB", "TypeB", "Cat1", "V1", ToSuccessor)
  -> Nodes=[..., {Id:3, NoeudB, IsActive:true}]
  -> Edges=[..., {Id:3, Source:NoeudA, Target:NoeudB, Dir:ToSucc, Order:3}]
  -> currentNodeKey="NoeudB|TypeB|Cat1|V1"
```

## 6. Complexite

| Operation | Complexite | Description |
|-----------|------------|-------------|
| AddNode | O(n) | Recherche dans la liste des noeuds |
| NavigateTo | O(n+m) | Recherche noeud + recherche arete |
| SetActiveNode | O(n) | Parcours de tous les noeuds |
| GetNode | O(n) | Recherche par cle |
| ContainsNode | O(n) | Verification d'existence |

Ou n = nombre de noeuds, m = nombre d'aretes

## 7. Optimisations Possibles

1. **Utiliser un Dictionary<string, GraphNode>** au lieu de List pour O(1) en recherche
2. **Utiliser un HashSet<string>** pour les cles d'aretes
3. **Indexer par Id** pour acces direct
