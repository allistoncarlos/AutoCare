import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { resolveClientId } from '../common/validators/resolveClientId.helper';
import { CreateVehicleMileageDto, UpdateVehicleMileageDto } from './dto/vehicle-mileage.dto';
import { VehicleMileage, VehicleMileageDocument } from './schemas/vehicle-mileage.schema';

@Injectable()
export class VehicleMileageService {
  constructor(
    @InjectModel(VehicleMileage.name)
    private readonly vehicleMileageModel: Model<VehicleMileageDocument>,
  ) {}

  async create(dto: CreateVehicleMileageDto, userId: string) {
    const clientId = resolveClientId(dto.clientId);
    const existing = await this.vehicleMileageModel
      .findOne({
        clientId,
        userId: new Types.ObjectId(userId),
      })
      .exec();

    if (existing) {
      return this.update(existing._id.toString(), dto, userId);
    }

    const mileage = new this.vehicleMileageModel({
      ...dto,
      clientId,
      userId: new Types.ObjectId(userId),
    });

    return mileage.save();
  }

  findAll(userId: string, vehicleId?: string) {
    const filter: Record<string, unknown> = {
      userId: new Types.ObjectId(userId),
      deleted: { $ne: true },
    };

    if (vehicleId) {
      filter.vehicleId = vehicleId;
    }

    return this.vehicleMileageModel.find(filter).sort({ date: -1 }).exec();
  }

  async findOne(id: string, userId: string) {
    const mileage = await this.findOwned(id, userId);
    if (!mileage || mileage.deleted) {
      throw new NotFoundException('Abastecimento não encontrado');
    }

    return mileage;
  }

  async update(id: string, dto: UpdateVehicleMileageDto, userId: string) {
    const mileage = await this.vehicleMileageModel
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

    if (!mileage) {
      throw new NotFoundException('Abastecimento não encontrado');
    }

    return mileage;
  }

  async remove(id: string, userId: string) {
    const mileage = await this.vehicleMileageModel
      .findOneAndUpdate(
        {
          _id: new Types.ObjectId(id),
          userId: new Types.ObjectId(userId),
        },
        { $set: { deleted: true, deletedAt: new Date() } },
        { new: true },
      )
      .exec();

    if (!mileage) {
      throw new NotFoundException('Abastecimento não encontrado');
    }

    return mileage;
  }

  findChanges(userId: string, since: Date) {
    return this.vehicleMileageModel
      .find({
        userId: new Types.ObjectId(userId),
        $or: [{ updatedAt: { $gt: since } }, { deletedAt: { $gt: since } }],
      })
      .sort({ updatedAt: 1 })
      .exec();
  }

  toResponse(mileage: VehicleMileageDocument) {
    return {
      id: mileage._id.toString(),
      clientId: resolveClientId(mileage.clientId, mileage._id.toString()),
      date: mileage.date,
      totalCost: mileage.totalCost,
      odometer: mileage.odometer,
      odometerDifference: mileage.odometerDifference,
      liters: mileage.liters,
      fuelCost: mileage.fuelCost,
      calculatedMileage: mileage.calculatedMileage,
      complete: mileage.complete,
      vehicleId: mileage.vehicleId,
      userId: mileage.userId.toString(),
      createdAt: mileage.createdAt,
      updatedAt: mileage.updatedAt,
      deleted: mileage.deleted,
      deletedAt: mileage.deletedAt,
    };
  }

  private findOwned(id: string, userId: string) {
    if (!Types.ObjectId.isValid(id)) {
      return null;
    }

    return this.vehicleMileageModel
      .findOne({
        _id: new Types.ObjectId(id),
        userId: new Types.ObjectId(userId),
      })
      .exec();
  }
}
