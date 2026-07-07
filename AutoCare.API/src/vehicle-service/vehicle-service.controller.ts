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
import { CreateVehicleServiceDto, UpdateVehicleServiceDto } from './dto/vehicle-service.dto';
import { VehicleServiceService } from './vehicle-service.service';

@ApiTags('Vehicle Service')
@ApiBearerAuth('JWT-auth')
@Controller('vehicle-service')
@UseGuards(JwtAuthGuard)
export class VehicleServiceController {
  constructor(private readonly vehicleServiceService: VehicleServiceService) {}

  @Post()
  @ApiOperation({ summary: 'Criar serviço' })
  @ApiResponse({ status: HttpStatus.CREATED })
  async create(@Body() dto: CreateVehicleServiceDto, @Request() req: { user: { userId: string } }) {
    const service = await this.vehicleServiceService.create(dto, req.user.userId);
    return this.vehicleServiceService.toResponse(service);
  }

  @Get()
  @ApiOperation({ summary: 'Listar serviços' })
  @ApiQuery({ name: 'vehicleId', required: false })
  @ApiResponse({ status: HttpStatus.OK })
  async findAll(
    @Request() req: { user: { userId: string } },
    @Query('vehicleId') vehicleId?: string,
  ) {
    const services = await this.vehicleServiceService.findAll(req.user.userId, vehicleId);
    return services.map((service) => this.vehicleServiceService.toResponse(service));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar serviço por ID' })
  @ApiResponse({ status: HttpStatus.OK })
  async findOne(@Param('id') id: string, @Request() req: { user: { userId: string } }) {
    const service = await this.vehicleServiceService.findOne(id, req.user.userId);
    return this.vehicleServiceService.toResponse(service);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Atualizar serviço' })
  @ApiResponse({ status: HttpStatus.OK })
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateVehicleServiceDto,
    @Request() req: { user: { userId: string } },
  ) {
    const service = await this.vehicleServiceService.update(id, dto, req.user.userId);
    return this.vehicleServiceService.toResponse(service);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Remover serviço (soft delete)' })
  @ApiResponse({ status: HttpStatus.OK })
  async remove(@Param('id') id: string, @Request() req: { user: { userId: string } }) {
    const service = await this.vehicleServiceService.remove(id, req.user.userId);
    return this.vehicleServiceService.toResponse(service);
  }
}
