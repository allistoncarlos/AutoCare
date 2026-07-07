import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';
import { addSyncFieldsHooks } from '../../common/validators/syncFields.helper';

export type VehicleTypeDocument = HydratedDocument<VehicleType>;

@Schema({ collection: 'VehicleType' })
export class VehicleType {
  @Prop({ required: true, unique: true })
  key: string;

  @Prop({ required: true })
  name: string;

  @Prop({ required: true })
  emoji: string;

  @Prop({ required: true, index: true })
  clientId: string;

  @Prop({ default: () => new Date() })
  createdAt: Date;

  @Prop({ default: () => new Date() })
  updatedAt: Date;

  @Prop({ default: false })
  deleted: boolean;

  @Prop({ default: null })
  deletedAt: Date | null;
}

export const VehicleTypeSchema = SchemaFactory.createForClass(VehicleType);
addSyncFieldsHooks(VehicleTypeSchema);
