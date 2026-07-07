import { Controller, Get, HttpStatus, Query, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/auth.guards';
import { ChangesService } from './changes.service';

@ApiTags('Changes')
@ApiBearerAuth('JWT-auth')
@Controller('changes')
@UseGuards(JwtAuthGuard)
export class ChangesController {
  constructor(private readonly changesService: ChangesService) {}

  @Get()
  @ApiOperation({ summary: 'Buscar alterações incrementais desde uma data' })
  @ApiQuery({ name: 'since', required: false, description: 'ISO date string' })
  @ApiResponse({ status: HttpStatus.OK })
  async getChanges(@Request() req: { user: { userId: string } }, @Query('since') since?: string) {
    const serverTime = new Date();
    let sinceDate = new Date(0);

    if (since) {
      const parsed = new Date(since);
      if (!Number.isNaN(parsed.getTime())) {
        sinceDate = parsed;
      }
    }

    const changes = await this.changesService.getChanges(req.user.userId, sinceDate);

    return {
      serverTime: serverTime.toISOString(),
      changes: {
        vehicleTypes: changes.vehicleTypes ?? [],
        vehicles: changes.vehicles ?? [],
        vehicleMileages: changes.vehicleMileages ?? [],
        vehicleServices: changes.vehicleServices ?? [],
      },
    };
  }
}
