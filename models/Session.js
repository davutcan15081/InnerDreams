const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['individual', 'group', 'online', 'offline'],
    required: true
  },
  category: {
    type: String,
    enum: [
      'dream_interpretation',
      'dream_analysis',
      'lucid_dreaming',
      'sleep_coaching',
      'meditation',
      'mindfulness',
      'therapy',
      'consultation',
      'other'
    ],
    required: true
  },
  expert: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Expert',
    required: true
  },
  duration: {
    type: Number, // in minutes
    required: true
  },
  maxParticipants: {
    type: Number,
    default: 1
  },
  currentParticipants: {
    type: Number,
    default: 0
  },
  price: {
    type: Number,
    required: true
  },
  currency: {
    type: String,
    default: 'TRY'
  },
  thumbnail: {
    type: String
  },
  images: [{
    type: String
  }],
  videos: [{
    url: String,
    title: String,
    duration: Number,
    thumbnail: String
  }],
  materials: [{
    title: String,
    url: String,
    type: String,
    size: Number
  }],
  tags: [{
    type: String,
    trim: true
  }],
  prerequisites: [{
    type: String
  }],
  objectives: [{
    type: String
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  isPublished: {
    type: Boolean,
    default: false
  },
  publishedAt: {
    type: Date
  },
  views: {
    type: Number,
    default: 0
  },
  bookings: {
    type: Number,
    default: 0
  },
  rating: {
    average: { type: Number, default: 0 },
    count: { type: Number, default: 0 }
  },
  schedule: {
    startDate: Date,
    endDate: Date,
    recurring: {
      type: String,
      enum: ['none', 'daily', 'weekly', 'monthly'],
      default: 'none'
    },
    timeSlots: [{
      day: String,
      startTime: String,
      endTime: String,
      isAvailable: { type: Boolean, default: true }
    }]
  }
}, {
  timestamps: true
});

// Index for search
sessionSchema.index({ title: 'text', description: 'text', tags: 'text' });
sessionSchema.index({ type: 1, category: 1 });
sessionSchema.index({ expert: 1 });
sessionSchema.index({ isActive: 1, isPublished: 1 });

module.exports = mongoose.model('Session', sessionSchema);
