const mongoose = require('mongoose');

const dreamSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    trim: true
  },
  content: {
    type: String,
    required: true
  },
  dreamDate: {
    type: Date,
    required: true
  },
  sleepQuality: {
    type: String,
    enum: ['excellent', 'good', 'fair', 'poor'],
    default: 'good'
  },
  sleepDuration: {
    type: Number // in hours
  },
  mood: {
    type: String,
    enum: ['very_positive', 'positive', 'neutral', 'negative', 'very_negative'],
    default: 'neutral'
  },
  emotions: [{
    type: String,
    enum: [
      'joy', 'fear', 'anger', 'sadness', 'surprise', 'disgust',
      'anxiety', 'peace', 'excitement', 'confusion', 'love', 'hate',
      'curiosity', 'wonder', 'frustration', 'relief', 'guilt', 'shame'
    ]
  }],
  symbols: [{
    symbol: String,
    description: String,
    significance: String
  }],
  colors: [{
    type: String,
    trim: true
  }],
  people: [{
    name: String,
    relationship: String,
    description: String
  }],
  places: [{
    name: String,
    description: String,
    type: String
  }],
  objects: [{
    name: String,
    description: String,
    significance: String
  }],
  activities: [{
    activity: String,
    description: String
  }],
  isLucid: {
    type: Boolean,
    default: false
  },
  lucidityLevel: {
    type: Number,
    min: 0,
    max: 10
  },
  isRecurring: {
    type: Boolean,
    default: false
  },
  recurringPattern: {
    type: String,
    enum: ['daily', 'weekly', 'monthly', 'random']
  },
  tags: [{
    type: String,
    trim: true
  }],
  privacy: {
    type: String,
    enum: ['private', 'public', 'friends'],
    default: 'private'
  },
  interpretation: {
    aiInterpretation: {
      content: String,
      confidence: Number,
      generatedAt: Date,
      symbols: [{
        symbol: String,
        meaning: String,
        confidence: Number
      }],
      emotions: [{
        emotion: String,
        intensity: Number,
        description: String
      }],
      themes: [{
        theme: String,
        description: String,
        relevance: Number
      }]
    },
    expertInterpretation: {
      expert: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Expert'
      },
      content: String,
      sessionId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Appointment'
      },
      providedAt: Date,
      rating: Number
    }
  },
  isAnalyzed: {
    type: Boolean,
    default: false
  },
  analyzedAt: {
    type: Date
  },
  analysisCount: {
    type: Number,
    default: 0
  },
  isShared: {
    type: Boolean,
    default: false
  },
  sharedAt: {
    type: Date
  },
  likes: {
    type: Number,
    default: 0
  },
  comments: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    content: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  attachments: [{
    type: String, // file URLs
    description: String
  }],
  reminders: [{
    date: Date,
    message: String,
    isActive: {
      type: Boolean,
      default: true
    }
  }]
}, {
  timestamps: true
});

// Index for efficient queries
dreamSchema.index({ user: 1, dreamDate: -1 });
dreamSchema.index({ user: 1, isShared: 1 });
dreamSchema.index({ tags: 1 });
dreamSchema.index({ dreamDate: -1 });
dreamSchema.index({ 'interpretation.aiInterpretation.generatedAt': -1 });

module.exports = mongoose.model('Dream', dreamSchema);
