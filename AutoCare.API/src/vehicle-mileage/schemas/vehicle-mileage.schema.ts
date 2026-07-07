import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { addSyncFieldsHooks } from '../../common/validators/syncFields.helper';

export type VehicleMileageDocument = HydratedDocument<VehicleMileage>;

@Schema({ collection: 'VehicleMileage' })
export class VehicleMileage {
  @Prop({ required: true })
  date: Date;

  @Prop({ required: true, default: 0 })
  totalCost: number;

  @Prop({ required: true, default: 0 })
  odometer: number;

  @Prop({ required: true, default: 0 })
  odometerDifference: number;

  @Prop({ required: true, default: 0 })
  liters: number;

  @Prop({ required: true, default: 0 })
  fuelCost: number;

  @Prop({ required: true, default: 0 })
  calculatedMileage: number;

  @Prop({ required: true, default: true })
  complete: boolean;

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

export const VehicleMileageSchema = SchemaFactory.createForClass(VehicleMileage);
addSyncFieldsHooks(VehicleMileageSchema);
