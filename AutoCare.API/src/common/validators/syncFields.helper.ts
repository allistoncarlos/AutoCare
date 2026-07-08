import { Schema, Types } from 'mongoose';
import { resolveClientId } from './resolveClientId.helper';

export function addSyncFieldsHooks(schema: Schema): void {
  schema.pre('save', function (next) {
    const now = new Date();
    const document = this as {
      clientId?: string;
      _id?: Types.ObjectId;
      isNew: boolean;
      createdAt?: Date;
      updatedAt?: Date;
      deleted?: boolean;
      deletedAt?: Date | null;
    };

    document.clientId = resolveClientId(document.clientId, document._id?.toString());

    if (document.isNew) {
      if (!document.createdAt) {
        document.createdAt = now;
      }
      document.updatedAt = now;
      document.deleted = document.deleted ?? false;
      document.deletedAt = document.deleted === true ? document.deletedAt ?? now : null;
    } else {
      document.updatedAt = now;
    }
    next();
  });

  schema.pre('findOneAndUpdate', function (next) {
    const now = new Date();
    const update = this.getUpdate() as Record<string, unknown> | null;
    if (!update) {
      return next();
    }

    if (!update.$set) {
      update.$set = {};
    }

    (update.$set as Record<string, unknown>).updatedAt = now;

    if (update.$set && (update.$set as Record<string, unknown>).deleted === true) {
      (update.$set as Record<string, unknown>).deleted = true;
      (update.$set as Record<string, unknown>).deletedAt = now;
    }

    this.setUpdate(update);
    next();
  });
}
