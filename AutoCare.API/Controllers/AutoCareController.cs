using System.Security.Claims;
using AutoCare.API.Data;
using AutoCare.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoCare.API.Controllers;

[ApiController]
[Authorize]
[Route("autocare")]
public sealed class AutoCareController : ControllerBase
{
    private readonly AutoCareStore store;

    public AutoCareController(AutoCareStore store)
    {
        this.store = store;
    }

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "user-1";

    [HttpGet("vehicleType")]
    public ActionResult<IEnumerable<VehicleTypeDto>> GetVehicleTypes() =>
        Ok(store.GetVehicleTypes());

    [HttpGet("vehicle")]
    public ActionResult<IEnumerable<VehicleDto>> GetVehicles() =>
        Ok(store.GetVehicles(UserId));

    [HttpGet("vehicle/{id}")]
    public ActionResult<VehicleDto> GetVehicle(string id)
    {
        var vehicle = store.GetVehicle(UserId, id);
        return vehicle is null ? NotFound() : Ok(vehicle);
    }

    [HttpPost("vehicle")]
    public ActionResult<VehicleDto> CreateVehicle([FromBody] VehicleDto request) =>
        Ok(store.SaveVehicle(UserId, request));

    [HttpPut("vehicle/{id}")]
    public ActionResult<VehicleDto> UpdateVehicle(string id, [FromBody] VehicleDto request)
    {
        request.Id = id;
        return Ok(store.SaveVehicle(UserId, request));
    }

    [HttpGet("vehicleMileage/{vehicleId}")]
    public ActionResult<IEnumerable<VehicleMileageDto>> GetMileages(string vehicleId) =>
        Ok(store.GetMileages(UserId, vehicleId));

    [HttpPost("vehicleMileage")]
    public ActionResult<VehicleMileageDto> CreateMileage([FromBody] VehicleMileageDto request) =>
        Ok(store.SaveMileage(UserId, request));

    [HttpPut("vehicleMileage/{id}")]
    public ActionResult<VehicleMileageDto> UpdateMileage(string id, [FromBody] VehicleMileageDto request)
    {
        request.Id = id;
        return Ok(store.SaveMileage(UserId, request));
    }

    [HttpGet("vehicleService/{vehicleId}")]
    public ActionResult<IEnumerable<VehicleServiceDto>> GetServices(string vehicleId) =>
        Ok(store.GetServices(UserId, vehicleId));

    [HttpPost("vehicleService")]
    public ActionResult<VehicleServiceDto> CreateService([FromBody] VehicleServiceDto request) =>
        Ok(store.SaveService(UserId, request));

    [HttpPut("vehicleService/{id}")]
    public ActionResult<VehicleServiceDto> UpdateService(string id, [FromBody] VehicleServiceDto request)
    {
        request.Id = id;
        return Ok(store.SaveService(UserId, request));
    }
}
