const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  revenueTransactionId: {
    type: String,
    required: true,
    unique: true
  },
  subscriptionId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Subscription'
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
  status: {
    type: String,
    enum: ['completed', 'failed', 'pending', 'refunded'],
    required: true
  },
  paymentMethod: {
    type: String
  },
  description: {
    type: String
  },
  customData: {
    type: mongoose.Schema.Types.Mixed
  }
}, {
  timestamps: true
});

// Index'ler
transactionSchema.index({ userId: 1 });
transactionSchema.index({ revenueTransactionId: 1 });
transactionSchema.index({ status: 1 });
transactionSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Transaction', transactionSchema);

