import { Injectable, OnModuleInit } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { UsersService } from './user.service';

@Injectable()
export class UserSeedService implements OnModuleInit {
  constructor(private readonly usersService: UsersService) {}

  async onModuleInit() {
    const count = await this.usersService.count();
    if (count > 0) {
      return;
    }

    const saltBuffer = crypto.randomBytes(16);
    const saltBase64 = saltBuffer.toString('base64');
    const passwordWithSalt = `admin${saltBase64}`;
    const passwordHash = await bcrypt.hash(passwordWithSalt, 10);

    await this.usersService.create({
      FirstName: 'Auto',
      LastName: 'Care',
      Username: 'admin',
      PasswordHash: Buffer.from(passwordHash),
      PasswordSalt: saltBuffer,
    });
  }
}
