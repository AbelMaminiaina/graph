namespace LineVisApp.Models;

/// <summary>
/// Modèle de la table LINE_VIS_EDG
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
/// Données distinctes pour la liste (premier écran)
/// </summary>
public class LineVisDistinct
{
    public string? DTA_1 { get; set; }
    public string? DTA_2 { get; set; }
    public string? DTA_3 { get; set; }
    public string? DTA_4 { get; set; }
}

/// <summary>
/// Données des liens (prédécesseurs/successeurs)
/// </summary>
public class LineVisEdge
{
    public string? EDG_1 { get; set; }
    public string? EDG_2 { get; set; }
    public string? EDG_3 { get; set; }
    public string? EDG_4 { get; set; }
}

/// <summary>
/// Élément de navigation pour le graphe
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
    public int Order { get; set; } // Ordre du clic

    public string Key => $"{SourceKey}->{TargetKey}";
}

/// <summary>
/// Direction de l'arete
/// </summary>
public enum EdgeDirection
{
    ToPredecessor,  // Navigation vers un predecesseur (clic sur tableau predecesseur)
    ToSuccessor     // Navigation vers un successeur (clic sur tableau successeur)
}
