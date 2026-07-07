import { Schema } from 'mongoose';

export function addSyncFieldsHooks(schema: Schema): void {
  schema.pre('save', function (next) {
    const now = new Date();
    if (this.isNew) {
      if (!this.createdAt) {
        this.createdAt = now;
      }
      this.updatedAt = now;
      this.deleted = this.deleted ?? false;
      this.deletedAt = this.deleted === true ? this.deletedAt ?? now : null;
    } else {
      this.updatedAt = now;
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
