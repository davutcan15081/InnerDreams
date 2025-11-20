const mongoose = require('mongoose');

const authorSchema = new mongoose.Schema({
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
  coverImage: {
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
  socialMedia: {
    website: String,
    linkedin: String,
    twitter: String,
    instagram: String,
    youtube: String
  },
  languages: [{
    type: String,
    trim: true
  }],
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
  educationCount: {
    type: Number,
    default: 0
  },
  totalViews: {
    type: Number,
    default: 0
  },
  totalLikes: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Virtual for full name
authorSchema.virtual('fullName').get(function() {
  return `${this.firstName} ${this.lastName}`;
});

// Index for search
authorSchema.index({ firstName: 'text', lastName: 'text', bio: 'text' });
authorSchema.index({ specialization: 1 });
authorSchema.index({ isActive: 1, isVerified: 1 });

module.exports = mongoose.model('Author', authorSchema);
