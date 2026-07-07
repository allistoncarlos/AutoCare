import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

@Schema({ collection: 'Users' })
export class User {
  _id: Types.ObjectId;

  @Prop({ required: true })
  FirstName: string;

  @Prop({ required: true })
  LastName: string;

  @Prop({ required: true, unique: true })
  Username: string;

  @Prop({ required: true, type: Buffer })
  PasswordHash: Buffer;

  @Prop({ required: true, type: Buffer })
  PasswordSalt: Buffer;

  @Prop({ type: String })
  RefreshToken?: string;

  @Prop({ type: Date })
  RefreshTokenExpiration?: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);
