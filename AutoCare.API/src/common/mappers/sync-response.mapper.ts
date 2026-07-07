export function mapDocToChange(doc: unknown): Record<string, unknown> {
  const obj = doc as Record<string, unknown>;

  const remoteId = (obj._id as { toString(): string } | undefined)?.toString() ?? '';
  const deleted = obj.deleted === true;

  let updatedAtDate: Date;
  if (obj.updatedAt) {
    updatedAtDate = new Date(obj.updatedAt as string | Date);
  } else if (obj.deletedAt) {
    updatedAtDate = new Date(obj.deletedAt as string | Date);
  } else if (obj.createdAt) {
    updatedAtDate = new Date(obj.createdAt as string | Date);
  } else if (obj._id && typeof (obj._id as { getTimestamp?: () => Date }).getTimestamp === 'function') {
    try {
      updatedAtDate = (obj._id as { getTimestamp: () => Date }).getTimestamp();
    } catch {
      updatedAtDate = new Date(0);
    }
  } else {
    updatedAtDate = new Date(0);
  }

  const updatedAtISO = updatedAtDate.toISOString();
  const deletedAtValue = deleted
    ? obj.deletedAt
      ? new Date(obj.deletedAt as string | Date).toISOString()
      : updatedAtISO
    : null;

  const change: Record<string, unknown> = {
    id: remoteId,
    clientId: obj.clientId,
    updatedAt: updatedAtISO,
    deleted,
    deletedAt: deletedAtValue,
  };

  const forbidden = ['_id', '__v', 'userId', 'clientId', 'updatedAt', 'deleted', 'deletedAt'];
  for (const key of Object.keys(obj)) {
    if (forbidden.includes(key)) {
      continue;
    }
    change[key] = obj[key];
  }

  return change;
}

export function mapEntityResponse(entity: unknown, extra?: Record<string, unknown>) {
  const record = entity as Record<string, unknown>;
  const id = (record._id as { toString(): string } | undefined)?.toString() ?? '';

  return {
    id,
    clientId: record.clientId,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
    deleted: record.deleted ?? false,
    deletedAt: record.deletedAt ?? null,
    ...extra,
  };
}
