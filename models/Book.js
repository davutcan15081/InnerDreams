const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  subtitle: {
    type: String,
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
  author: {
    type: String,
    required: true,
    trim: true
  },
  coAuthors: [{
    type: String,
    trim: true
  }],
  isbn: {
    type: String,
    unique: true,
    sparse: true
  },
  publisher: {
    type: String,
    trim: true
  },
  publicationYear: {
    type: Number
  },
  edition: {
    type: String,
    trim: true
  },
  language: {
    type: String,
    default: 'Turkish',
    trim: true
  },
  category: {
    type: String,
    required: true,
    enum: [
      'dream_psychology',
      'symbol_interpretation',
      'lucid_dreaming',
      'sleep_health',
      'meditation',
      'mindfulness',
      'psychology',
      'spirituality',
      'self_help',
      'biography',
      'fiction',
      'other'
    ]
  },
  subcategory: [{
    type: String,
    trim: true
  }],
  coverImage: {
    type: String
  },
  images: [{
    type: String
  }],
  pdfUrl: {
    type: String
  },
  epubUrl: {
    type: String
  },
  audiobookUrl: {
    type: String
  },
  pageCount: {
    type: Number
  },
  wordCount: {
    type: Number
  },
  readingTime: {
    type: Number // in minutes
  },
  tags: [{
    type: String,
    trim: true
  }],
  keywords: [{
    type: String,
    trim: true
  }],
  price: {
    type: Number,
    default: 0
  },
  currency: {
    type: String,
    default: 'TRY'
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
  downloads: {
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
  reviews: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    rating: {
      type: Number,
      min: 1,
      max: 5,
      required: true
    },
    comment: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  relatedBooks: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Book'
  }],
  recommendedBy: [{
    expert: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Expert'
    },
    reason: String,
    recommendedAt: {
      type: Date,
      default: Date.now
    }
  }],
  order: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Index for search
bookSchema.index({ title: 'text', description: 'text', author: 'text', tags: 'text' });
bookSchema.index({ category: 1, subcategory: 1 });
bookSchema.index({ isActive: 1, isPublished: 1 });
bookSchema.index({ rating: -1 });
bookSchema.index({ publishedAt: -1 });

module.exports = mongoose.model('Book', bookSchema);
