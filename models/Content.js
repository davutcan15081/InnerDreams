const mongoose = require('mongoose');

const contentSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  slug: {
    type: String,
    unique: true,
    lowercase: true,
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
  type: {
    type: String,
    enum: [
      'article',
      'blog_post',
      'news',
      'guide',
      'tutorial',
      'faq',
      'announcement',
      'case_study',
      'research',
      'interview',
      'review',
      'other'
    ],
    required: true
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
      'therapy',
      'research',
      'news',
      'tips',
      'other'
    ]
  },
  subcategory: [{
    type: String,
    trim: true
  }],
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Author',
    required: true
  },
  featuredImage: {
    type: String
  },
  images: [{
    url: String,
    caption: String,
    alt: String
  }],
  videos: [{
    url: String,
    title: String,
    duration: Number,
    thumbnail: String,
    caption: String
  }],
  audio: [{
    url: String,
    title: String,
    duration: Number,
    caption: String
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
  keywords: [{
    type: String,
    trim: true
  }],
  readingTime: {
    type: Number // in minutes
  },
  wordCount: {
    type: Number
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
  scheduledAt: {
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
  shares: {
    type: Number,
    default: 0
  },
  comments: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    content: {
      type: String,
      required: true
    },
    isApproved: {
      type: Boolean,
      default: false
    },
    createdAt: {
      type: Date,
      default: Date.now
    },
    replies: [{
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      content: {
        type: String,
        required: true
      },
      createdAt: {
        type: Date,
        default: Date.now
      }
    }]
  }],
  rating: {
    average: { type: Number, default: 0 },
    count: { type: Number, default: 0 }
  },
  seo: {
    metaTitle: String,
    metaDescription: String,
    metaKeywords: [String],
    canonicalUrl: String,
    ogTitle: String,
    ogDescription: String,
    ogImage: String,
    twitterTitle: String,
    twitterDescription: String,
    twitterImage: String
  },
  relatedContent: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Content'
  }],
  featuredIn: [{
    type: String,
    enum: ['homepage', 'category_page', 'author_page', 'trending', 'recommended']
  }],
  order: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Generate slug before saving
contentSchema.pre('save', function(next) {
  if (this.isModified('title') && !this.slug) {
    this.slug = this.title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/(^-|-$)/g, '');
  }
  next();
});

// Index for search
contentSchema.index({ title: 'text', description: 'text', content: 'text', tags: 'text' });
contentSchema.index({ type: 1, category: 1 });
contentSchema.index({ author: 1 });
contentSchema.index({ isActive: 1, isPublished: 1 });
contentSchema.index({ publishedAt: -1 });
contentSchema.index({ slug: 1 });

module.exports = mongoose.model('Content', contentSchema);
