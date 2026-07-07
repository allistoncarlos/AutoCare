import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import ms from 'ms';
import { UsersService } from '../user/user.service';

export interface AuthUserPayload {
  userId: string;
  username: string;
  firstName: string;
  lastName: string;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async validateUser(username: string, password: string): Promise<AuthUserPayload | null> {
    const user = await this.usersService.findByUsername(username);
    if (!user) {
      return null;
    }

    const isPasswordValid = await this.usersService.validatePassword(password, user);
    if (!isPasswordValid) {
      return null;
    }

    return {
      userId: user._id.toString(),
      username: user.Username,
      firstName: user.FirstName,
      lastName: user.LastName,
    };
  }

  async login(user: AuthUserPayload) {
    const payload = { username: user.username, sub: user.userId };
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.generateRefreshToken();

    await this.usersService.updateRefreshToken(user.userId, refreshToken);

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: new Date(Date.now() + ms(this.configService.get<string>('JWT_EXPIRES_IN') || '8h')),
      user: {
        id: user.userId,
        username: user.username,
        firstName: user.firstName,
        lastName: user.lastName,
      },
    };
  }

  async refreshToken(refreshToken: string) {
    const user = await this.usersService.findByRefreshToken(refreshToken);
    if (!user) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const userId = user._id.toString();
    const isValid = await this.usersService.validateRefreshToken(userId, refreshToken);
    if (!isValid) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const payload = { username: user.Username, sub: userId };
    const newAccessToken = this.jwtService.sign(payload);
    const newRefreshToken = this.generateRefreshToken();

    await this.usersService.updateRefreshToken(userId, newRefreshToken);

    return {
      access_token: newAccessToken,
      refresh_token: newRefreshToken,
    };
  }

  async logout(userId: string) {
    await this.usersService.removeRefreshToken(userId);
    return { message: 'Logged out successfully' };
  }

  private generateRefreshToken() {
    return crypto.randomBytes(32).toString('base64');
  }
}
