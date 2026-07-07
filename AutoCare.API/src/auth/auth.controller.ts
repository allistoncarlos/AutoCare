import {
  Body,
  Controller,
  Get,
  HttpStatus,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiBody, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import {
  LoginResponseDto,
  LogoutResponseDto,
  RefreshResponseDto,
  UserResponseDto,
} from './dto/login-response.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtAuthGuard, LocalAuthGuard } from './guards/auth.guards';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @ApiOperation({ summary: 'Login do usuário' })
  @ApiBody({ type: LoginDto })
  @ApiResponse({ status: HttpStatus.OK, type: LoginResponseDto })
  @UseGuards(LocalAuthGuard)
  login(@Request() req: { user: Parameters<AuthService['login']>[0] }) {
    return this.authService.login(req.user);
  }

  @Post('refresh')
  @ApiOperation({ summary: 'Renovar access token' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({ status: HttpStatus.OK, type: RefreshResponseDto })
  refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshToken(dto.refreshToken);
  }

  @Post('logout')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Logout do usuário' })
  @ApiResponse({ status: HttpStatus.OK, type: LogoutResponseDto })
  @UseGuards(JwtAuthGuard)
  logout(@Request() req: { user: { userId: string } }) {
    return this.authService.logout(req.user.userId);
  }

  @Get('profile')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Perfil do usuário autenticado' })
  @ApiResponse({ status: HttpStatus.OK, type: UserResponseDto })
  @UseGuards(JwtAuthGuard)
  getProfile(@Request() req: { user: UserResponseDto & { userId: string } }) {
    return {
      id: req.user.userId,
      username: req.user.username,
      firstName: req.user.firstName,
      lastName: req.user.lastName,
    };
  }
}
