import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthModule } from './auth/auth.module';
import { ChangesModule } from './changes/changes.module';
import { UserModule } from './user/user.module';
import { VehicleTypeModule } from './vehicle-type/vehicle-type.module';
import { VehicleModule } from './vehicle/vehicle.module';
import { VehicleMileageModule } from './vehicle-mileage/vehicle-mileage.module';
import { VehicleServiceModule } from './vehicle-service/vehicle-service.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    MongooseModule.forRoot(process.env.DATABASE_URL || 'mongodb://localhost:27017/autocare'),
    AuthModule,
    UserModule,
    VehicleTypeModule,
    VehicleModule,
    VehicleMileageModule,
    VehicleServiceModule,
    ChangesModule,
  ],
})
export class AppModule {}
