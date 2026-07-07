import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { VehicleType, VehicleTypeDocument } from './schemas/vehicle-type.schema';

const DEFAULT_TYPES = [
  { key: 'car', name: 'Carro', emoji: '🚗', clientId: 'car' },
  { key: 'moto', name: 'Moto', emoji: '🏍️', clientId: 'moto' },
];

@Injectable()
export class VehicleTypeService implements OnModuleInit {
  constructor(
    @InjectModel(VehicleType.name)
    private readonly vehicleTypeModel: Model<VehicleTypeDocument>,
  ) {}

  async onModuleInit() {
    const count = await this.vehicleTypeModel.countDocuments().exec();
    if (count > 0) {
      return;
    }

    await this.vehicleTypeModel.insertMany(DEFAULT_TYPES);
  }

  findAll() {
    return this.vehicleTypeModel.find({ deleted: { $ne: true } }).sort({ name: 1 }).exec();
  }

  findOneByKey(key: string) {
    return this.vehicleTypeModel.findOne({ key, deleted: { $ne: true } }).exec();
  }
}
