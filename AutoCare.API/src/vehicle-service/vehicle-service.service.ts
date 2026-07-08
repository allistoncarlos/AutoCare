import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { resolveClientId } from '../common/validators/resolveClientId.helper';
import { CreateVehicleServiceDto, UpdateVehicleServiceDto } from './dto/vehicle-service.dto';
import { VehicleServiceDocument, VehicleServiceRecord } from './schemas/vehicle-service.schema';

@Injectable()
export class VehicleServiceService {
  constructor(
    @InjectModel(VehicleServiceRecord.name)
    private readonly vehicleServiceModel: Model<VehicleServiceDocument>,
  ) {}

  async create(dto: CreateVehicleServiceDto, userId: string) {
    const clientId = resolveClientId(dto.clientId);
    const existing = await this.vehicleServiceModel
      .findOne({
        clientId,
        userId: new Types.ObjectId(userId),
      })
      .exec();

    if (existing) {
      return this.update(existing._id.toString(), dto, userId);
    }

    const service = new this.vehicleServiceModel({
      ...dto,
      clientId,
      userId: new Types.ObjectId(userId),
    });

    return service.save();
  }

  findAll(userId: string, vehicleId?: string) {
    const filter: Record<string, unknown> = {
      userId: new Types.ObjectId(userId),
      deleted: { $ne: true },
    };

    if (vehicleId) {
      filter.vehicleId = vehicleId;
    }

    return this.vehicleServiceModel.find(filter).sort({ date: -1 }).exec();
  }

  async findOne(id: string, userId: string) {
    const service = await this.findOwned(id, userId);
    if (!service || service.deleted) {
      throw new NotFoundException('Serviço não encontrado');
    }

    return service;
  }

  async update(id: string, dto: UpdateVehicleServiceDto, userId: string) {
    const service = await this.vehicleServiceModel
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

    if (!service) {
      throw new NotFoundException('Serviço não encontrado');
    }

    return service;
  }

  async remove(id: string, userId: string) {
    const service = await this.vehicleServiceModel
      .findOneAndUpdate(
        {
          _id: new Types.ObjectId(id),
          userId: new Types.ObjectId(userId),
        },
        { $set: { deleted: true, deletedAt: new Date() } },
        { new: true },
      )
      .exec();

    if (!service) {
      throw new NotFoundException('Serviço não encontrado');
    }

    return service;
  }

  findChanges(userId: string, since: Date) {
    return this.vehicleServiceModel
      .find({
        userId: new Types.ObjectId(userId),
        $or: [{ updatedAt: { $gt: since } }, { deletedAt: { $gt: since } }],
      })
      .sort({ updatedAt: 1 })
      .exec();
  }

  toResponse(service: VehicleServiceDocument) {
    return {
      id: service._id.toString(),
      clientId: resolveClientId(service.clientId, service._id.toString()),
      date: service.date,
      odometer: service.odometer,
      type: service.type,
      subtype: service.subtype,
      totalCost: service.totalCost,
      comment: service.comment,
      vehicleId: service.vehicleId,
      userId: service.userId.toString(),
      createdAt: service.createdAt,
      updatedAt: service.updatedAt,
      deleted: service.deleted,
      deletedAt: service.deletedAt,
    };
  }

  private findOwned(id: string, userId: string) {
    if (!Types.ObjectId.isValid(id)) {
      return null;
    }

    return this.vehicleServiceModel
      .findOne({
        _id: new Types.ObjectId(id),
        userId: new Types.ObjectId(userId),
      })
      .exec();
  }
}
