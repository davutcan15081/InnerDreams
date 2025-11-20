const mongoose = require('mongoose');

const educationSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  shortDescription: {
    type: String,
    maxlength: 200
  },
  content: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true,
    enum: [
      'dream_psychology',
      'symbol_interpretation',
      'lucid_dreaming',
      'dream_analysis',
      'sleep_health',
      'meditation',
      'mindfulness',
      'other'
    ]
  },
  level: {
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'beginner'
  },
  duration: {
    type: Number, // in minutes
    required: true
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
  audio: [{
    url: String,
    title: String,
    duration: Number
  }],
  documents: [{
    url: String,
    title: String,
    type: String,
    size: Number
  }],
  tags: [{
    type: String,
    trim: true
  }],
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Author',
    required: true
  },
  isPremium: {
    type: Boolean,
    default: false
  },
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
  likes: {
    type: Number,
    default: 0
  },
  rating: {
    average: { type: Number, default: 0 },
    count: { type: Number, default: 0 }
  },
  order: {
    type: Number,
    default: 0
  },
  prerequisites: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Education'
  }],
  relatedEducations: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Education'
  }]
}, {
  timestamps: true
});

// Index for search
educationSchema.index({ title: 'text', description: 'text', tags: 'text' });
educationSchema.index({ category: 1, level: 1 });
educationSchema.index({ isActive: 1, isPublished: 1 });

module.exports = mongoose.model('Education', educationSchema);
