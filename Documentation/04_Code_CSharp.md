# Code C# Complet du Systeme de Trace

## 1. Modeles (Models/LineVisEdg.cs)

```csharp
namespace LineVisApp.Models;

/// <summary>
/// Modele de la table LINE_VIS_EDG
/// </summary>
public class LineVisEdg
{
    public string LNA_UID { get; set; } = string.Empty;
    public string LIN_UID { get; set; } = string.Empty;
    public string? DTA_1 { get; set; }
    public string? DTA_2 { get; set; }
    public string? DTA_3 { get; set; }
    public string? DTA_4 { get; set; }
    public string EDG_DIR { get; set; } = string.Empty;
    public string? EDG_1 { get; set; }
    public string? EDG_2 { get; set; }
    public string? EDG_3 { get; set; }
    public string? EDG_4 { get; set; }
    public DateTime? TXN_DTA { get; set; }
    public DateTime? PRX_TXN_DTA { get; set; }
}

/// <summary>
/// Donnees distinctes pour la liste (premier ecran)
/// </summary>
public class LineVisDistinct
{
    public string? DTA_1 { get; set; }
    public string? DTA_2 { get; set; }
    public string? DTA_3 { get; set; }
    public string? DTA_4 { get; set; }
}

/// <summary>
/// Donnees des liens (predecesseurs/successeurs)
/// </summary>
public class LineVisEdge
{
    public string? EDG_1 { get; set; }
    public string? EDG_2 { get; set; }
    public string? EDG_3 { get; set; }
    public string? EDG_4 { get; set; }
}

/// <summary>
/// Noeud du graphe de navigation
/// </summary>
public class GraphNode
{
    public int Id { get; set; }
    public string Label { get; set; } = string.Empty;
    public string? DTA_1 { get; set; }
    public string? DTA_2 { get; set; }
    public string? DTA_3 { get; set; }
    public string? DTA_4 { get; set; }
    public bool IsActive { get; set; }

    /// <summary>
    /// Cle unique pour identifier le noeud
    /// </summary>
    public string Key => $"{DTA_1}|{DTA_2}|{DTA_3}|{DTA_4}";

    public override bool Equals(object? obj)
    {
        if (obj is GraphNode other)
            return Key == other.Key;
        return false;
    }

    public override int GetHashCode() => Key.GetHashCode();
}

/// <summary>
/// Arete du graphe avec direction
/// </summary>
public class GraphEdge
{
    public int Id { get; set; }
    public string SourceKey { get; set; } = string.Empty;
    public string TargetKey { get; set; } = string.Empty;
    public EdgeDirection Direction { get; set; }
    public int Order { get; set; }

    public string Key => $"{SourceKey}->{TargetKey}";
}

/// <summary>
/// Direction de l'arete
/// </summary>
public enum EdgeDirection
{
    ToPredecessor,  // Navigation vers un predecesseur (JAUNE)
    ToSuccessor     // Navigation vers un successeur (VERT)
}
```

## 2. Service de Donnees (Services/LineVisService.cs)

```csharp
using Dapper;
using LineVisApp.Models;
using Microsoft.Data.SqlClient;
using System.Data;

namespace LineVisApp.Services;

public interface ILineVisService
{
    Task<IEnumerable<LineVisDistinct>> GetDistinctLinesAsync();
    Task<IEnumerable<LineVisEdge>> GetPredecesseursAsync(string dta1, string dta2, string dta3, string dta4);
    Task<IEnumerable<LineVisEdge>> GetSuccesseursAsync(string dta1, string dta2, string dta3, string dta4);
    Task<LineVisEdg?> GetDetailAsync(string dta1, string dta2, string dta3, string dta4);
    Task<bool> ExistsAsync(string dta1, string dta2, string dta3, string dta4);
}

public class LineVisService : ILineVisService
{
    private readonly string _connectionString;

    public LineVisService(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string not found");
    }

    public async Task<IEnumerable<LineVisDistinct>> GetDistinctLinesAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<LineVisDistinct>(
            "sp_GetDistinctLineVis",
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<LineVisEdge>> GetPredecesseursAsync(
        string dta1, string dta2, string dta3, string dta4)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<LineVisEdge>(
            "sp_GetPredecesseurs",
            new { DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4 },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<LineVisEdge>> GetSuccesseursAsync(
        string dta1, string dta2, string dta3, string dta4)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<LineVisEdge>(
            "sp_GetSuccesseurs",
            new { DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4 },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<LineVisEdg?> GetDetailAsync(
        string dta1, string dta2, string dta3, string dta4)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryFirstOrDefaultAsync<LineVisEdg>(
            "sp_GetLineVisDetail",
            new { DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4 },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<bool> ExistsAsync(string dta1, string dta2, string dta3, string dta4)
    {
        using var connection = new SqlConnection(_connectionString);
        var result = await connection.QueryFirstOrDefaultAsync<int>(
            "sp_CheckLineVisExists",
            new { DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4 },
            commandType: CommandType.StoredProcedure
        );
        return result == 1;
    }
}
```

## 3. Service de Navigation (Services/NavigationHistoryService.cs)

```csharp
using LineVisApp.Models;

namespace LineVisApp.Services;

/// <summary>
/// Service Scoped pour stocker l'historique de navigation par utilisateur
/// Trace les noeuds visites et les aretes (liens) entre eux
/// </summary>
public class NavigationHistoryService
{
    // Collections en memoire
    private readonly List<GraphNode> _nodes = new();
    private readonly List<GraphEdge> _edges = new();

    // Compteurs auto-incrementes
    private int _nodeIdCounter = 0;
    private int _edgeIdCounter = 0;

    // Noeud courant (source de la prochaine arete)
    private string? _currentNodeKey = null;

    // Proprietes publiques en lecture seule
    public IReadOnlyList<GraphNode> Nodes => _nodes;
    public IReadOnlyList<GraphEdge> Edges => _edges;
    public int NodeCount => _nodes.Count;
    public int EdgeCount => _edges.Count;

    /// <summary>
    /// Ajoute un noeud au graphe (premier acces depuis la liste)
    /// Ne cree pas d'arete car il n'y a pas de noeud source
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

        SetActiveNode(key);
        _currentNodeKey = key;

        return existingNode;
    }

    /// <summary>
    /// Navigue vers un noeud et cree une arete
    /// </summary>
    /// <param name="dta1">DTA_1 du noeud cible</param>
    /// <param name="dta2">DTA_2 du noeud cible</param>
    /// <param name="dta3">DTA_3 du noeud cible</param>
    /// <param name="dta4">DTA_4 du noeud cible</param>
    /// <param name="direction">Direction de navigation (ToPredecessor ou ToSuccessor)</param>
    /// <returns>Le noeud cible</returns>
    public GraphNode NavigateTo(
        string? dta1, string? dta2, string? dta3, string? dta4,
        EdgeDirection direction)
    {
        var targetKey = $"{dta1}|{dta2}|{dta3}|{dta4}";

        // Etape 1: Ajouter le noeud cible s'il n'existe pas
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

        // Etape 2: Creer l'arete si on a un noeud source different
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

        // Etape 3: Mettre a jour l'etat
        SetActiveNode(targetKey);
        _currentNodeKey = targetKey;

        return targetNode;
    }

    /// <summary>
    /// Verifie si un noeud existe dans le graphe
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
    /// Obtient le noeud actuellement actif
    /// </summary>
    public GraphNode? GetActiveNode()
    {
        return _nodes.FirstOrDefault(n => n.IsActive);
    }

    /// <summary>
    /// Efface tout l'historique
    /// </summary>
    public void Clear()
    {
        _nodes.Clear();
        _edges.Clear();
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
    /// Met a jour le noeud actif
    /// </summary>
    private void SetActiveNode(string key)
    {
        foreach (var node in _nodes)
        {
            node.IsActive = (node.Key == key);
        }
    }
}
```

## 4. Configuration (Program.cs)

```csharp
using LineVisApp.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

// Services metier
builder.Services.AddScoped<ILineVisService, LineVisService>();
builder.Services.AddScoped<NavigationHistoryService>();  // SCOPED = 1 instance par utilisateur

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
```

## 5. Configuration (appsettings.json)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.\\SQLEXPRESS02;Database=LINE_VIS;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

## 6. Utilisation dans Blazor (extrait)

```csharp
@inject NavigationHistoryService NavHistory

// Premier acces (depuis la liste)
NavHistory.AddNode(dta1, dta2, dta3, dta4);

// Clic sur predecesseur
NavHistory.NavigateTo(dta1, dta2, dta3, dta4, EdgeDirection.ToPredecessor);

// Clic sur successeur
NavHistory.NavigateTo(dta1, dta2, dta3, dta4, EdgeDirection.ToSuccessor);

// Afficher les statistiques
var stats = NavHistory.GetStats();
// stats.nodes, stats.edges, stats.predecessorEdges, stats.successorEdges

// Parcourir les noeuds
foreach (var node in NavHistory.Nodes)
{
    // node.Id, node.Label, node.IsActive
}

// Parcourir les aretes
foreach (var edge in NavHistory.Edges)
{
    // edge.Order, edge.SourceKey, edge.TargetKey, edge.Direction
}
```
