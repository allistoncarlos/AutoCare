import { Types } from 'mongoose';

export function resolveClientId(clientId?: string | null, id?: string | null): string {
  const normalizedClientId = clientId?.trim();
  if (normalizedClientId) {
    return normalizedClientId;
  }

  const normalizedId = id?.trim();
  if (normalizedId) {
    return normalizedId;
  }

  return new Types.ObjectId().toString();
}
