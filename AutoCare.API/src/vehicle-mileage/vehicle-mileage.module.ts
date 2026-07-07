import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { VehicleMileage, VehicleMileageSchema } from './schemas/vehicle-mileage.schema';
import { VehicleMileageController } from './vehicle-mileage.controller';
import { VehicleMileageService } from './vehicle-mileage.service';

@Module({
  imports: [MongooseModule.forFeature([{ name: VehicleMileage.name, schema: VehicleMileageSchema }])],
  controllers: [VehicleMileageController],
  providers: [VehicleMileageService],
  exports: [VehicleMileageService],
})
export class VehicleMileageModule {}
