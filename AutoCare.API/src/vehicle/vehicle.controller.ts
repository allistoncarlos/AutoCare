import {
  Body,
  Controller,
  Delete,
  Get,
  HttpStatus,
  Param,
  Post,
  Put,
  Request,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/auth.guards';
import { CreateVehicleDto, UpdateVehicleDto } from './dto/vehicle.dto';
import { VehicleService } from './vehicle.service';

@ApiTags('Vehicle')
@ApiBearerAuth('JWT-auth')
@Controller('vehicle')
@UseGuards(JwtAuthGuard)
export class VehicleController {
  constructor(private readonly vehicleService: VehicleService) {}

  @Post()
  @ApiOperation({ summary: 'Criar veículo' })
  @ApiResponse({ status: HttpStatus.CREATED })
  async create(@Body() dto: CreateVehicleDto, @Request() req: { user: { userId: string } }) {
    const vehicle = await this.vehicleService.create(dto, req.user.userId);
    return this.vehicleService.toResponse(vehicle);
  }

  @Get()
  @ApiOperation({ summary: 'Listar veículos do usuário' })
  @ApiResponse({ status: HttpStatus.OK })
  async findAll(@Request() req: { user: { userId: string } }) {
    const vehicles = await this.vehicleService.findAll(req.user.userId);
    return Promise.all(vehicles.map((vehicle) => this.vehicleService.toResponse(vehicle)));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar veículo por ID' })
  @ApiResponse({ status: HttpStatus.OK })
  async findOne(@Param('id') id: string, @Request() req: { user: { userId: string } }) {
    const vehicle = await this.vehicleService.findOne(id, req.user.userId);
    return this.vehicleService.toResponse(vehicle);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Atualizar veículo' })
  @ApiResponse({ status: HttpStatus.OK })
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateVehicleDto,
    @Request() req: { user: { userId: string } },
  ) {
    const vehicle = await this.vehicleService.update(id, dto, req.user.userId);
    return this.vehicleService.toResponse(vehicle);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Remover veículo (soft delete)' })
  @ApiResponse({ status: HttpStatus.OK })
  async remove(@Param('id') id: string, @Request() req: { user: { userId: string } }) {
    const vehicle = await this.vehicleService.remove(id, req.user.userId);
    return this.vehicleService.toResponse(vehicle);
  }
}
