using LineVisApp.Models;

namespace LineVisApp.Services;

/// <summary>
/// Service Scoped pour stocker l'historique de navigation par utilisateur
/// Trace les noeuds visites et les aretes (liens) entre eux
/// </summary>
public class NavigationHistoryService
{
    private readonly List<GraphNode> _nodes = new();
    private readonly List<GraphEdge> _edges = new();
    private readonly Stack<string> _navigationStack = new(); // Pile de navigation (pour Precedent)
    private int _nodeIdCounter = 0;
    private int _edgeIdCounter = 0;
    private string? _currentNodeKey = null;

    public IReadOnlyList<GraphNode> Nodes => _nodes;
    public IReadOnlyList<GraphEdge> Edges => _edges;
    public int NodeCount => _nodes.Count;
    public int EdgeCount => _edges.Count;
    public bool CanGoBack => _navigationStack.Count > 1;
    public bool CanUndo => _edges.Count > 0;

    /// <summary>
    /// Ajoute un noeud au graphe (premier acces depuis la liste)
    /// </summary>
    public GraphNode AddNode(string? dta1, string? dta2, string? dta3, string? dta4)
    {
        var key = $"{dta1}|{dta2}|{dta3}|{dta4}";
        var existingNode = _nodes.FirstOrDefault(n => n.Key == key);

        if (existingNode == null)
        {
            existingNode = new GraphNode
            {
                Id = ++_nodeIdCounter,
                Label = dta1 ?? "N/A",
                DTA_1 = dta1,
                DTA_2 = dta2,
                DTA_3 = dta3,
                DTA_4 = dta4,
                IsActive = true
            };
            _nodes.Add(existingNode);
        }

        // Mettre a jour l'etat actif
        SetActiveNode(key);
        _currentNodeKey = key;

        // Ajouter a la pile de navigation
        _navigationStack.Push(key);

        return existingNode;
    }

    /// <summary>
    /// Navigue vers un noeud et cree une arete
    /// </summary>
    public GraphNode NavigateTo(string? dta1, string? dta2, string? dta3, string? dta4, EdgeDirection direction)
    {
        var targetKey = $"{dta1}|{dta2}|{dta3}|{dta4}";

        // Ajouter le noeud cible s'il n'existe pas
        var targetNode = _nodes.FirstOrDefault(n => n.Key == targetKey);
        if (targetNode == null)
        {
            targetNode = new GraphNode
            {
                Id = ++_nodeIdCounter,
                Label = dta1 ?? "N/A",
                DTA_1 = dta1,
                DTA_2 = dta2,
                DTA_3 = dta3,
                DTA_4 = dta4,
                IsActive = true
            };
            _nodes.Add(targetNode);
        }

        // Creer l'arete si on a un noeud source
        if (_currentNodeKey != null && _currentNodeKey != targetKey)
        {
            var edgeKey = $"{_currentNodeKey}->{targetKey}";
            var existingEdge = _edges.FirstOrDefault(e => e.Key == edgeKey);

            if (existingEdge == null)
            {
                _edges.Add(new GraphEdge
                {
                    Id = ++_edgeIdCounter,
                    SourceKey = _currentNodeKey,
                    TargetKey = targetKey,
                    Direction = direction,
                    Order = _edges.Count + 1
                });
            }
        }

        // Mettre a jour l'etat actif
        SetActiveNode(targetKey);
        _currentNodeKey = targetKey;

        // Ajouter a la pile de navigation
        _navigationStack.Push(targetKey);

        return targetNode;
    }

    /// <summary>
    /// Revient au noeud precedent (sans supprimer l'arete)
    /// </summary>
    public GraphNode? GoBack()
    {
        if (_navigationStack.Count <= 1)
            return null;

        // Retirer le noeud actuel
        _navigationStack.Pop();

        // Obtenir le noeud precedent
        var previousKey = _navigationStack.Peek();
        var previousNode = GetNode(previousKey);

        if (previousNode != null)
        {
            SetActiveNode(previousKey);
            _currentNodeKey = previousKey;
        }

        return previousNode;
    }

    /// <summary>
    /// Annule la derniere action (supprime la derniere arete et le noeud si orphelin)
    /// </summary>
    public GraphNode? Undo()
    {
        if (_edges.Count == 0)
            return null;

        // Supprimer la derniere arete
        var lastEdge = _edges[_edges.Count - 1];
        _edges.RemoveAt(_edges.Count - 1);

        // Verifier si le noeud cible est orphelin (pas d'autres aretes)
        var targetKey = lastEdge.TargetKey;
        var hasOtherEdges = _edges.Any(e => e.SourceKey == targetKey || e.TargetKey == targetKey);

        if (!hasOtherEdges && _nodes.Count > 1)
        {
            // Supprimer le noeud orphelin
            var orphanNode = _nodes.FirstOrDefault(n => n.Key == targetKey);
            if (orphanNode != null)
            {
                _nodes.Remove(orphanNode);
            }
        }

        // Revenir au noeud source
        var sourceKey = lastEdge.SourceKey;
        var sourceNode = GetNode(sourceKey);

        if (sourceNode != null)
        {
            SetActiveNode(sourceKey);
            _currentNodeKey = sourceKey;

            // Mettre a jour la pile de navigation
            if (_navigationStack.Count > 0 && _navigationStack.Peek() == targetKey)
            {
                _navigationStack.Pop();
            }
        }

        // Renumeroter les aretes
        for (int i = 0; i < _edges.Count; i++)
        {
            _edges[i].Order = i + 1;
        }

        return sourceNode;
    }

    /// <summary>
    /// Verifie si un noeud existe
    /// </summary>
    public bool ContainsNode(string? dta1, string? dta2, string? dta3, string? dta4)
    {
        var key = $"{dta1}|{dta2}|{dta3}|{dta4}";
        return _nodes.Any(n => n.Key == key);
    }

    /// <summary>
    /// Obtient un noeud par sa cle
    /// </summary>
    public GraphNode? GetNode(string key)
    {
        return _nodes.FirstOrDefault(n => n.Key == key);
    }

    /// <summary>
    /// Obtient le noeud actif
    /// </summary>
    public GraphNode? GetActiveNode()
    {
        return _nodes.FirstOrDefault(n => n.IsActive);
    }

    /// <summary>
    /// Obtient le noeud precedent sans naviguer
    /// </summary>
    public GraphNode? PeekPrevious()
    {
        if (_navigationStack.Count <= 1)
            return null;

        var stackArray = _navigationStack.ToArray();
        if (stackArray.Length > 1)
        {
            return GetNode(stackArray[1]); // Index 1 car ToArray inverse la pile
        }
        return null;
    }

    /// <summary>
    /// Efface tout l'historique
    /// </summary>
    public void Clear()
    {
        _nodes.Clear();
        _edges.Clear();
        _navigationStack.Clear();
        _nodeIdCounter = 0;
        _edgeIdCounter = 0;
        _currentNodeKey = null;
    }

    /// <summary>
    /// Obtient les aretes sortantes d'un noeud
    /// </summary>
    public IEnumerable<GraphEdge> GetOutgoingEdges(string nodeKey)
    {
        return _edges.Where(e => e.SourceKey == nodeKey);
    }

    /// <summary>
    /// Obtient les aretes entrantes d'un noeud
    /// </summary>
    public IEnumerable<GraphEdge> GetIncomingEdges(string nodeKey)
    {
        return _edges.Where(e => e.TargetKey == nodeKey);
    }

    /// <summary>
    /// Obtient les statistiques du graphe
    /// </summary>
    public (int nodes, int edges, int predecessorEdges, int successorEdges) GetStats()
    {
        return (
            _nodes.Count,
            _edges.Count,
            _edges.Count(e => e.Direction == EdgeDirection.ToPredecessor),
            _edges.Count(e => e.Direction == EdgeDirection.ToSuccessor)
        );
    }

    /// <summary>
    /// Obtient l'historique de navigation
    /// </summary>
    public IEnumerable<GraphNode> GetNavigationHistory()
    {
        return _navigationStack
            .Select(key => GetNode(key))
            .Where(n => n != null)
            .Cast<GraphNode>()
            .Reverse();
    }

    private void SetActiveNode(string key)
    {
        foreach (var node in _nodes)
        {
            node.IsActive = (node.Key == key);
        }
    }
}
