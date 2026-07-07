import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { VehicleTypeService } from '../vehicle-type/vehicle-type.service';
import { CreateVehicleDto, UpdateVehicleDto } from './dto/vehicle.dto';
import { Vehicle, VehicleDocument } from './schemas/vehicle.schema';

@Injectable()
export class VehicleService {
  constructor(
    @InjectModel(Vehicle.name) private readonly vehicleModel: Model<VehicleDocument>,
    private readonly vehicleTypeService: VehicleTypeService,
  ) {}

  async create(dto: CreateVehicleDto, userId: string) {
    const existing = await this.vehicleModel
      .findOne({
        clientId: dto.clientId,
        userId: new Types.ObjectId(userId),
      })
      .exec();

    if (existing) {
      return this.update(existing._id.toString(), dto, userId);
    }

    const vehicle = new this.vehicleModel({
      ...dto,
      userId: new Types.ObjectId(userId),
    });

    return vehicle.save();
  }

  findAll(userId: string) {
    return this.vehicleModel
      .find({
        userId: new Types.ObjectId(userId),
        deleted: { $ne: true },
      })
      .sort({ name: 1 })
      .exec();
  }

  async findOne(id: string, userId: string) {
    const vehicle = await this.findOwnedVehicle(id, userId);
    if (!vehicle || vehicle.deleted) {
      throw new NotFoundException('Veículo não encontrado');
    }

    return vehicle;
  }

  async update(id: string, dto: UpdateVehicleDto, userId: string) {
    const vehicle = await this.vehicleModel
      .findOneAndUpdate(
        {
          _id: new Types.ObjectId(id),
          userId: new Types.ObjectId(userId),
          deleted: { $ne: true },
        },
        { $set: dto },
        { new: true },
      )
      .exec();

    if (!vehicle) {
      throw new NotFoundException('Veículo não encontrado');
    }

    return vehicle;
  }

  async remove(id: string, userId: string) {
    const vehicle = await this.vehicleModel
      .findOneAndUpdate(
        {
          _id: new Types.ObjectId(id),
          userId: new Types.ObjectId(userId),
        },
        { $set: { deleted: true, deletedAt: new Date() } },
        { new: true },
      )
      .exec();

    if (!vehicle) {
      throw new NotFoundException('Veículo não encontrado');
    }

    return vehicle;
  }

  findChanges(userId: string, since: Date) {
    return this.vehicleModel
      .find({
        userId: new Types.ObjectId(userId),
        $or: [{ updatedAt: { $gt: since } }, { deletedAt: { $gt: since } }],
      })
      .sort({ updatedAt: 1 })
      .exec();
  }

  async toResponse(vehicle: VehicleDocument) {
    const vehicleType = await this.vehicleTypeService.findOneByKey(vehicle.vehicleTypeId);

    return {
      id: vehicle._id.toString(),
      clientId: vehicle.clientId,
      name: vehicle.name,
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
      licensePlate: vehicle.licensePlate,
      odometer: vehicle.odometer,
      isDefault: vehicle.isDefault,
      vehicleTypeId: vehicle.vehicleTypeId,
      vehicleType: vehicleType
        ? {
            id: vehicleType.key,
            name: vehicleType.name,
            emoji: vehicleType.emoji,
          }
        : {
            id: vehicle.vehicleTypeId,
            name: vehicle.vehicleTypeId,
            emoji: '🚗',
          },
      userId: vehicle.userId.toString(),
      createdAt: vehicle.createdAt,
      updatedAt: vehicle.updatedAt,
      deleted: vehicle.deleted,
      deletedAt: vehicle.deletedAt,
    };
  }

  private async findOwnedVehicle(id: string, userId: string) {
    if (!Types.ObjectId.isValid(id)) {
      return null;
    }

    return this.vehicleModel
      .findOne({
        _id: new Types.ObjectId(id),
        userId: new Types.ObjectId(userId),
      })
      .exec();
  }
}
