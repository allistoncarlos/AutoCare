import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsDate, IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateVehicleServiceDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  clientId: string;

  @ApiProperty()
  @Type(() => Date)
  @IsDate()
  date: Date;

  @ApiProperty()
  @IsNumber()
  odometer: number;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  type: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  subtype: string;

  @ApiProperty()
  @IsNumber()
  totalCost: number;

  @ApiProperty()
  @IsString()
  comment: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  vehicleId: string;
}

export class UpdateVehicleServiceDto {
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
  odometer?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  type?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  subtype?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsNumber()
  totalCost?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  comment?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  vehicleId?: string;
}
