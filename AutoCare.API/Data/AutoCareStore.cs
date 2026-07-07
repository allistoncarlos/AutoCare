using AutoCare.API.Models;

namespace AutoCare.API.Data;

public sealed class AutoCareStore
{
    private readonly object sync = new();
    private readonly Dictionary<string, UserAccount> users = new()
    {
        ["admin"] = new UserAccount
        {
            Id = "user-1",
            Username = "admin",
            Password = "admin",
            FirstName = "Auto",
            LastName = "Care"
        }
    };

    private readonly List<VehicleTypeDto> vehicleTypes =
    [
        new() { Id = "car", Name = "Carro", Emoji = "🚗" },
        new() { Id = "moto", Name = "Moto", Emoji = "🏍️" }
    ];

    private readonly List<VehicleDto> vehicles = [];
    private readonly List<VehicleMileageDto> mileages = [];
    private readonly List<VehicleServiceDto> services = [];

    public UserAccount? Authenticate(string username, string password)
    {
        lock (sync)
        {
            return users.TryGetValue(username, out var user) && user.Password == password
                ? user
                : null;
        }
    }

    public IReadOnlyList<VehicleTypeDto> GetVehicleTypes()
    {
        lock (sync) { return vehicleTypes.ToList(); }
    }

    public IReadOnlyList<VehicleDto> GetVehicles(string userId)
    {
        lock (sync) { return vehicles.Where(v => v.UserId == userId).ToList(); }
    }

    public VehicleDto? GetVehicle(string userId, string id)
    {
        lock (sync) { return vehicles.FirstOrDefault(v => v.UserId == userId && v.Id == id); }
    }

    public VehicleDto SaveVehicle(string userId, VehicleDto request)
    {
        lock (sync)
        {
            if (string.IsNullOrWhiteSpace(request.Id))
            {
                request.Id = Guid.NewGuid().ToString("N");
                request.UserId = userId;
                vehicles.Add(request);
                return request;
            }

            var existing = vehicles.FirstOrDefault(v => v.UserId == userId && v.Id == request.Id)
                ?? throw new KeyNotFoundException("Vehicle not found");

            existing.Name = request.Name;
            existing.Brand = request.Brand;
            existing.Model = request.Model;
            existing.Year = request.Year;
            existing.LicensePlate = request.LicensePlate;
            existing.Odometer = request.Odometer;
            existing.IsDefault = request.IsDefault;
            existing.VehicleTypeId = request.VehicleTypeId;
            return existing;
        }
    }

    public IReadOnlyList<VehicleMileageDto> GetMileages(string userId, string vehicleId)
    {
        lock (sync)
        {
            return mileages
                .Where(m => m.UserId == userId && m.VehicleId == vehicleId)
                .OrderByDescending(m => m.Date)
                .ToList();
        }
    }

    public VehicleMileageDto SaveMileage(string userId, VehicleMileageDto request)
    {
        lock (sync)
        {
            if (string.IsNullOrWhiteSpace(request.Id))
            {
                request.Id = Guid.NewGuid().ToString("N");
                request.UserId = userId;
                mileages.Add(request);
                return request;
            }

            var existing = mileages.FirstOrDefault(m => m.UserId == userId && m.Id == request.Id)
                ?? throw new KeyNotFoundException("Mileage not found");

            existing.Date = request.Date;
            existing.TotalCost = request.TotalCost;
            existing.Odometer = request.Odometer;
            existing.OdometerDifference = request.OdometerDifference;
            existing.Liters = request.Liters;
            existing.FuelCost = request.FuelCost;
            existing.CalculatedMileage = request.CalculatedMileage;
            existing.Complete = request.Complete;
            existing.VehicleId = request.VehicleId;
            return existing;
        }
    }

    public IReadOnlyList<VehicleServiceDto> GetServices(string userId, string vehicleId)
    {
        lock (sync)
        {
            return services
                .Where(s => s.UserId == userId && s.VehicleId == vehicleId)
                .OrderByDescending(s => s.Date)
                .ToList();
        }
    }

    public VehicleServiceDto SaveService(string userId, VehicleServiceDto request)
    {
        lock (sync)
        {
            if (string.IsNullOrWhiteSpace(request.Id))
            {
                request.Id = Guid.NewGuid().ToString("N");
                request.UserId = userId;
                services.Add(request);
                return request;
            }

            var existing = services.FirstOrDefault(s => s.UserId == userId && s.Id == request.Id)
                ?? throw new KeyNotFoundException("Service not found");

            existing.Date = request.Date;
            existing.Odometer = request.Odometer;
            existing.Type = request.Type;
            existing.Subtype = request.Subtype;
            existing.TotalCost = request.TotalCost;
            existing.Comment = request.Comment;
            existing.VehicleId = request.VehicleId;
            return existing;
        }
    }
}
