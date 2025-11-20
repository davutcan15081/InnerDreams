const mongoose = require('mongoose');

const usageLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  service: {
    type: String,
    enum: ['anythingllm', 'openrouter', 'paddle'],
    required: true
  },
  action: {
    type: String,
    required: true
  },
  tokensUsed: {
    type: Number,
    default: 0
  },
  cost: {
    type: Number,
    default: 0
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed
  }
}, {
  timestamps: true
});

// Index'ler
usageLogSchema.index({ userId: 1, createdAt: -1 });
usageLogSchema.index({ service: 1, createdAt: -1 });
usageLogSchema.index({ userId: 1, service: 1 });

module.exports = mongoose.model('UsageLog', usageLogSchema);

