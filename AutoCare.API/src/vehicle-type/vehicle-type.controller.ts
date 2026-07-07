import { Controller, Get, HttpStatus, NotFoundException, Param, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/auth.guards';
import { VehicleTypeService } from './vehicle-type.service';

@ApiTags('Vehicle Type')
@ApiBearerAuth('JWT-auth')
@Controller('vehicle-type')
@UseGuards(JwtAuthGuard)
export class VehicleTypeController {
  constructor(private readonly vehicleTypeService: VehicleTypeService) {}

  @Get()
  @ApiOperation({ summary: 'Listar tipos de veículo' })
  @ApiResponse({ status: HttpStatus.OK })
  async findAll() {
    const types = await this.vehicleTypeService.findAll();
    return types.map((type) => ({
      id: type.key,
      name: type.name,
      emoji: type.emoji,
    }));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar tipo de veículo por ID' })
  @ApiResponse({ status: HttpStatus.OK })
  async findOne(@Param('id') id: string) {
    const type = await this.vehicleTypeService.findOneByKey(id);
    if (!type) {
      throw new NotFoundException('Tipo de veículo não encontrado');
    }

    return {
      id: type.key,
      name: type.name,
      emoji: type.emoji,
    };
  }
}
