import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsBoolean, IsDate, IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateVehicleMileageDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  clientId?: string;

  @ApiProperty()
  @Type(() => Date)
  @IsDate()
  date: Date;

  @ApiProperty()
  @IsNumber()
  totalCost: number;

  @ApiProperty()
  @IsNumber()
  odometer: number;

  @ApiProperty()
  @IsNumber()
  odometerDifference: number;

  @ApiProperty()
  @IsNumber()
  liters: number;

  @ApiProperty()
  @IsNumber()
  fuelCost: number;

  @ApiProperty()
  @IsNumber()
  calculatedMileage: number;

  @ApiProperty()
  @IsBoolean()
  complete: boolean;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  vehicleId: string;
}

export class UpdateVehicleMileageDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  clientId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  date?: Date;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  totalCost?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  odometer?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  odometerDifference?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  liters?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  fuelCost?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  calculatedMileage?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  complete?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  vehicleId?: string;
}
