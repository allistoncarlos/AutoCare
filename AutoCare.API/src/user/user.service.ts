import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private readonly userModel: Model<UserDocument>) {}

  findByUsername(username: string) {
    return this.userModel.findOne({ Username: username }).exec();
  }

  findById(id: string) {
    if (!Types.ObjectId.isValid(id)) {
      return null;
    }

    return this.userModel.findOne({ _id: new Types.ObjectId(id) }).exec();
  }

  findByRefreshToken(refreshToken: string) {
    return this.userModel.findOne({ RefreshToken: refreshToken }).exec();
  }

  async validatePassword(plainPassword: string, user: UserDocument) {
    const salt = user.PasswordSalt.toString('base64');
    const passwordWithSalt = plainPassword + salt;
    return bcrypt.compare(passwordWithSalt, user.PasswordHash.toString());
  }

  async updateRefreshToken(userId: string, refreshToken: string) {
    const expirationDate = new Date();
    expirationDate.setDate(expirationDate.getDate() + 7);

    await this.userModel.findByIdAndUpdate(userId, {
      RefreshToken: refreshToken,
      RefreshTokenExpiration: expirationDate,
    });
  }

  async removeRefreshToken(userId: string) {
    await this.userModel.findByIdAndUpdate(userId, {
      $unset: { RefreshToken: 1, RefreshTokenExpiration: 1 },
    });
  }

  async validateRefreshToken(userId: string, refreshToken: string) {
    const user = await this.findById(userId);
    if (!user?.RefreshToken || !user.RefreshTokenExpiration) {
      return false;
    }

    const isTokenValid = user.RefreshToken === refreshToken;
    const isTokenExpired = new Date() > user.RefreshTokenExpiration;
    return isTokenValid && !isTokenExpired;
  }

  count() {
    return this.userModel.countDocuments().exec();
  }

  create(user: Partial<User>) {
    return this.userModel.create(user);
  }
}
