const mongoose = require('mongoose');

const expertSchema = new mongoose.Schema({
  firstName: {
    type: String,
    required: true,
    trim: true
  },
  lastName: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  phone: {
    type: String,
    required: true,
    trim: true
  },
  bio: {
    type: String,
    required: true
  },
  shortBio: {
    type: String,
    maxlength: 200
  },
  profileImage: {
    type: String
  },
  specialization: [{
    type: String,
    trim: true
  }],
  qualifications: [{
    title: String,
    institution: String,
    year: Number,
    description: String
  }],
  experience: {
    years: Number,
    description: String
  },
  languages: [{
    type: String,
    trim: true
  }],
  availability: {
    timezone: {
      type: String,
      default: 'Europe/Istanbul'
    },
    workingHours: {
      start: { type: String, default: '09:00' },
      end: { type: String, default: '18:00' }
    },
    workingDays: [{
      type: String,
      enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    }],
    isAvailable: {
      type: Boolean,
      default: true
    }
  },
  sessionTypes: [{
    type: String,
    enum: ['individual', 'group', 'online', 'offline'],
    default: 'individual'
  }],
  sessionDuration: {
    type: Number, // in minutes
    default: 60
  },
  pricing: {
    individual: { type: Number, default: 0 },
    group: { type: Number, default: 0 },
    online: { type: Number, default: 0 },
    offline: { type: Number, default: 0 }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  verifiedAt: {
    type: Date
  },
  rating: {
    average: { type: Number, default: 0 },
    count: { type: Number, default: 0 }
  },
  totalSessions: {
    type: Number,
    default: 0
  },
  totalClients: {
    type: Number,
    default: 0
  },
  totalEarnings: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Virtual for full name
expertSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

// Index for search
expertSchema.index({ firstName: 'text', lastName: 'text', bio: 'text' });
expertSchema.index({ specialization: 1 });
expertSchema.index({ isActive: 1, isVerified: 1 });

module.exports = mongoose.model('Expert', expertSchema);
