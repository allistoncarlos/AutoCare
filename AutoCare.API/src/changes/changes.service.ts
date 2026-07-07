import { Injectable } from '@nestjs/common';
import { mapDocToChange } from '../common/mappers/sync-response.mapper';
import { VehicleMileageService } from '../vehicle-mileage/vehicle-mileage.service';
import { VehicleServiceService } from '../vehicle-service/vehicle-service.service';
import { VehicleTypeService } from '../vehicle-type/vehicle-type.service';
import { VehicleService } from '../vehicle/vehicle.service';

@Injectable()
export class ChangesService {
  constructor(
    private readonly vehicleTypeService: VehicleTypeService,
    private readonly vehicleService: VehicleService,
    private readonly vehicleMileageService: VehicleMileageService,
    private readonly vehicleServiceService: VehicleServiceService,
  ) {}

  async getChanges(userId: string, since: Date) {
    const [vehicleTypes, vehicles, vehicleMileages, vehicleServices] = await Promise.all([
      this.vehicleTypeService.findChanges(since),
      this.vehicleService.findChanges(userId, since),
      this.vehicleMileageService.findChanges(userId, since),
      this.vehicleServiceService.findChanges(userId, since),
    ]);

    return {
      vehicleTypes: vehicleTypes.map((doc) =>
        mapDocToChange({
          ...doc.toObject(),
          id: doc.key,
        }),
      ),
      vehicles: vehicles.map((doc) => mapDocToChange(doc.toObject())),
      vehicleMileages: vehicleMileages.map((doc) => mapDocToChange(doc.toObject())),
      vehicleServices: vehicleServices.map((doc) => mapDocToChange(doc.toObject())),
    };
  }
}
