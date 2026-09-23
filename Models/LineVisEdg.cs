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
/// Données des liens (prédécesseurs/successeurs), avec l'en-tête LINE_VIS_HEA joint par LNA_UID
/// </summary>
public class LineVisEdge
{
    public string? EDG_1 { get; set; }
    public string? EDG_2 { get; set; }
    public string? EDG_3 { get; set; }
    public string? EDG_4 { get; set; }

    // Colonnes de LINE_VIS_HEA (null si aucun en-tête pour ce LNA_UID)
    public string? LNA_UID { get; set; }
    public string? RON_APP { get; set; }
    public string? PCK_PGM_NME { get; set; }
    public string? EXE_PGM_NME { get; set; }
    public string? VRS_EXE_PGM { get; set; }
    public string? APP_ENV { get; set; }
    public DateTime? DLY_PGM_TSP { get; set; }
    public DateTime? LNA_TSP { get; set; }
    public string? PGM_TEC { get; set; }
    public string? VRS_LNA_TOO { get; set; }
    public int? TUS_IND { get; set; }
}

/// <summary>
/// Lien avec sa direction (page Recherche) : 'I' = prédécesseur, 'O' = successeur
/// </summary>
public class LineVisLien : LineVisEdge
{
    public string EDG_DIR { get; set; } = string.Empty;
}

/// <summary>
/// Groupe de l'arbre de la page Programme (EDG_2 > EDG_3 > EDG_4 > EDG_1)
/// </summary>
public class LineVisGroupe
{
    public string Valeur { get; set; } = string.Empty;
    public int NbNoeuds { get; set; }
    public int TotalCount { get; set; }
    public int TotalNoeuds { get; set; }
}

/// <summary>
/// Une page de résultats et le nombre total de lignes
/// </summary>
public record PageResultat<T>(List<T> Lignes, int Total);

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
