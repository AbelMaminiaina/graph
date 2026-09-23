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
    Task<IEnumerable<LineVisLien>> GetLiensNoeudProgrammeAsync(string dta1, string dta2, string dta3, string dta4, string? exePgmNme);
    Task<IEnumerable<string>> GetProgrammesAsync();
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

    public async Task<IEnumerable<LineVisEdge>> GetPredecesseursAsync(string dta1, string dta2, string dta3, string dta4)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<LineVisEdge>(
            "sp_GetPredecesseurs",
            new { DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4 },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<LineVisEdge>> GetSuccesseursAsync(string dta1, string dta2, string dta3, string dta4)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<LineVisEdge>(
            "sp_GetSuccesseurs",
            new { DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4 },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<LineVisEdg?> GetDetailAsync(string dta1, string dta2, string dta3, string dta4)
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

    public async Task<IEnumerable<LineVisLien>> GetLiensNoeudProgrammeAsync(string dta1, string dta2, string dta3, string dta4, string? exePgmNme)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<LineVisLien>(
            "sp_GetLiensNoeudProgramme",
            new
            {
                DTA_1 = dta1, DTA_2 = dta2, DTA_3 = dta3, DTA_4 = dta4,
                EXE_PGM_NME = new DbString { Value = string.IsNullOrWhiteSpace(exePgmNme) ? null : exePgmNme.Trim(), IsAnsi = true, Length = 500 }
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<string>> GetProgrammesAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<string>(
            "sp_GetProgrammes",
            commandType: CommandType.StoredProcedure
        );
    }
}
