import {
  Body,
  Controller,
  Delete,
  Get,
  HttpStatus,
  Param,
  Post,
  Put,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/auth.guards';
import { CreateVehicleMileageDto, UpdateVehicleMileageDto } from './dto/vehicle-mileage.dto';
import { VehicleMileageService } from './vehicle-mileage.service';

@ApiTags('Vehicle Mileage')
@ApiBearerAuth('JWT-auth')
@Controller('vehicle-mileage')
@UseGuards(JwtAuthGuard)
export class VehicleMileageController {
  constructor(private readonly vehicleMileageService: VehicleMileageService) {}

  @Post()
  @ApiOperation({ summary: 'Criar abastecimento' })
  @ApiResponse({ status: HttpStatus.CREATED })
  async create(@Body() dto: CreateVehicleMileageDto, @Request() req: { user: { userId: string } }) {
    const mileage = await this.vehicleMileageService.create(dto, req.user.userId);
    return this.vehicleMileageService.toResponse(mileage);
  }

  @Get()
  @ApiOperation({ summary: 'Listar abastecimentos' })
  @ApiQuery({ name: 'vehicleId', required: false })
  @ApiResponse({ status: HttpStatus.OK })
  async findAll(
    @Request() req: { user: { userId: string } },
    @Query('vehicleId') vehicleId?: string,
  ) {
    const mileages = await this.vehicleMileageService.findAll(req.user.userId, vehicleId);
    return mileages.map((mileage) => this.vehicleMileageService.toResponse(mileage));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar abastecimento por ID' })
  @ApiResponse({ status: HttpStatus.OK })
  async findOne(@Param('id') id: string, @Request() req: { user: { userId: string } }) {
    const mileage = await this.vehicleMileageService.findOne(id, req.user.userId);
    return this.vehicleMileageService.toResponse(mileage);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Atualizar abastecimento' })
  @ApiResponse({ status: HttpStatus.OK })
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateVehicleMileageDto,
    @Request() req: { user: { userId: string } },
  ) {
    const mileage = await this.vehicleMileageService.update(id, dto, req.user.userId);
    return this.vehicleMileageService.toResponse(mileage);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Remover abastecimento (soft delete)' })
  @ApiResponse({ status: HttpStatus.OK })
  async remove(@Param('id') id: string, @Request() req: { user: { userId: string } }) {
    const mileage = await this.vehicleMileageService.remove(id, req.user.userId);
    return this.vehicleMileageService.toResponse(mileage);
  }
}
