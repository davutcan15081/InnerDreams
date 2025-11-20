const mongoose = require('mongoose');

const subscriptionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  revenuePurchaseId: {
    type: String,
    required: true,
    unique: true
  },
  status: {
    type: String,
    enum: ['active', 'cancelled', 'past_due', 'paused'],
    required: true
  },
  productId: {
    type: String,
    required: true
  },
  priceId: {
    type: String,
    required: true
  },
  amount: {
    type: Number,
    required: true
  },
  currency: {
    type: String,
    required: true,
    default: 'TRY'
  },
  nextPaymentDate: {
    type: Date
  },
  lastPaymentDate: {
    type: Date
  },
  cancelledAt: {
    type: Date
  },
  customData: {
    type: mongoose.Schema.Types.Mixed
  }
}, {
  timestamps: true
});

// Index'ler
subscriptionSchema.index({ userId: 1 });
subscriptionSchema.index({ revenuePurchaseId: 1 });
subscriptionSchema.index({ status: 1 });

module.exports = mongoose.model('Subscription', subscriptionSchema);

