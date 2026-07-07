import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { addSyncFieldsHooks } from '../../common/validators/syncFields.helper';

export type VehicleDocument = HydratedDocument<Vehicle>;

@Schema({ collection: 'Vehicle' })
export class Vehicle {
  @Prop({ required: true })
  name: string;

  @Prop({ required: true })
  brand: string;

  @Prop({ required: true })
  model: string;

  @Prop({ required: true })
  year: string;

  @Prop({ required: true })
  licensePlate: string;

  @Prop({ required: true, default: 0 })
  odometer: number;

  @Prop({ required: true, default: false })
  isDefault: boolean;

  @Prop({ required: true })
  vehicleTypeId: string;

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

export const VehicleSchema = SchemaFactory.createForClass(Vehicle);
addSyncFieldsHooks(VehicleSchema);
