namespace AutoCare.API.Models;

public sealed class UserAccount
{
    public required string Id { get; set; }
    public required string Username { get; set; }
    public required string Password { get; set; }
    public required string FirstName { get; set; }
    public required string LastName { get; set; }
}

public sealed class LoginRequest
{
    public required string Username { get; set; }
    public required string Password { get; set; }
}

public sealed class LoginResponse
{
    public required string Id { get; set; }
    public required string FirstName { get; set; }
    public required string LastName { get; set; }
    public required string AccessToken { get; set; }
    public required string RefreshToken { get; set; }
    public required DateTime ExpiresIn { get; set; }
}

public sealed class RefreshTokenRequest
{
    public required string RefreshToken { get; set; }
}

public sealed class VehicleTypeDto
{
    public required string Id { get; set; }
    public required string Name { get; set; }
    public required string Emoji { get; set; }
}

public sealed class VehicleDto
{
    public string Id { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public required string Name { get; set; }
    public required string Brand { get; set; }
    public required string Model { get; set; }
    public required string Year { get; set; }
    public required string LicensePlate { get; set; }
    public int Odometer { get; set; }
    public bool IsDefault { get; set; }
    public required string VehicleTypeId { get; set; }
    public VehicleTypeDto VehicleType { get; set; } = new() { Id = "car", Name = "Carro", Emoji = "🚗" };
}

public sealed class VehicleMileageDto
{
    public string Id { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public decimal TotalCost { get; set; }
    public int Odometer { get; set; }
    public int OdometerDifference { get; set; }
    public decimal Liters { get; set; }
    public decimal FuelCost { get; set; }
    public decimal CalculatedMileage { get; set; }
    public bool Complete { get; set; }
    public required string VehicleId { get; set; }
}

public sealed class VehicleServiceDto
{
    public string Id { get; set; } = string.Empty;
    public string UserId { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public int Odometer { get; set; }
    public required string Type { get; set; }
    public required string Subtype { get; set; }
    public decimal TotalCost { get; set; }
    public string Comment { get; set; } = string.Empty;
    public required string VehicleId { get; set; }
}
