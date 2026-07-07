import { Module } from '@nestjs/common';
import { VehicleMileageModule } from '../vehicle-mileage/vehicle-mileage.module';
import { VehicleServiceModule } from '../vehicle-service/vehicle-service.module';
import { VehicleTypeModule } from '../vehicle-type/vehicle-type.module';
import { VehicleModule } from '../vehicle/vehicle.module';
import { ChangesController } from './changes.controller';
import { ChangesService } from './changes.service';

@Module({
  imports: [VehicleTypeModule, VehicleModule, VehicleMileageModule, VehicleServiceModule],
  controllers: [ChangesController],
  providers: [ChangesService],
})
export class ChangesModule {}
