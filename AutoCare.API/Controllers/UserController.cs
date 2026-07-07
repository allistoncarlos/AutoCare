using System.Security.Claims;
using AutoCare.API.Data;
using AutoCare.API.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoCare.API.Controllers;

[ApiController]
[Route("user")]
public sealed class UserController : ControllerBase
{
    private readonly AutoCareStore store;
    private readonly IConfiguration configuration;

    public UserController(AutoCareStore store, IConfiguration configuration)
    {
        this.store = store;
        this.configuration = configuration;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public ActionResult<LoginResponse> Login([FromBody] LoginRequest request)
    {
        var user = store.Authenticate(request.Username, request.Password);
        if (user is null)
        {
            return Unauthorized();
        }

        var jwtKey = configuration["Jwt:Key"] ?? "AutoCare-Development-Secret-Key-32chars!";
        var accessToken = Program.CreateToken(user.Id, jwtKey);

        return new LoginResponse
        {
            Id = user.Id,
            FirstName = user.FirstName,
            LastName = user.LastName,
            AccessToken = accessToken,
            RefreshToken = Guid.NewGuid().ToString("N"),
            ExpiresIn = DateTime.UtcNow.AddHours(8)
        };
    }

    [HttpPost("refresh")]
    [AllowAnonymous]
    public ActionResult<LoginResponse> Refresh([FromBody] RefreshTokenRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            return Unauthorized();
        }

        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "user-1";
        var jwtKey = configuration["Jwt:Key"] ?? "AutoCare-Development-Secret-Key-32chars!";

        return new LoginResponse
        {
            Id = userId,
            FirstName = "Auto",
            LastName = "Care",
            AccessToken = Program.CreateToken(userId, jwtKey),
            RefreshToken = Guid.NewGuid().ToString("N"),
            ExpiresIn = DateTime.UtcNow.AddHours(8)
        };
    }
}
