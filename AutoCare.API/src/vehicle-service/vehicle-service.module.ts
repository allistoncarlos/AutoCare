import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { VehicleServiceRecord, VehicleServiceSchema } from './schemas/vehicle-service.schema';
import { VehicleServiceController } from './vehicle-service.controller';
import { VehicleServiceService } from './vehicle-service.service';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: VehicleServiceRecord.name, schema: VehicleServiceSchema }]),
  ],
  controllers: [VehicleServiceController],
  providers: [VehicleServiceService],
  exports: [VehicleServiceService],
})
export class VehicleServiceModule {}
