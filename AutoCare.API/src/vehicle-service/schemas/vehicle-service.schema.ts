import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { addSyncFieldsHooks } from '../../common/validators/syncFields.helper';

export type VehicleServiceDocument = HydratedDocument<VehicleServiceRecord>;

@Schema({ collection: 'VehicleService' })
export class VehicleServiceRecord {
  @Prop({ required: true })
  date: Date;

  @Prop({ required: true, default: 0 })
  odometer: number;

  @Prop({ required: true })
  type: string;

  @Prop({ required: true })
  subtype: string;

  @Prop({ required: true, default: 0 })
  totalCost: number;

  @Prop({ default: '' })
  comment: string;

  @Prop({ required: true })
  vehicleId: string;

  @Prop({ required: true, type: Types.ObjectId, ref: 'User' })
  userId: Types.ObjectId;

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

export const VehicleServiceSchema = SchemaFactory.createForClass(VehicleServiceRecord);
addSyncFieldsHooks(VehicleServiceSchema);
