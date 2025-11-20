const { body, param, query, validationResult } = require('express-validator');

// Validation result handler
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  next();
};

// Admin validation rules
const adminValidation = {
  login: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Please provide a valid email'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters long'),
    handleValidationErrors
  ],
  
  create: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Please provide a valid email'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters long'),
    body('firstName')
      .trim()
      .isLength({ min: 2 })
      .withMessage('First name must be at least 2 characters long'),
    body('lastName')
      .trim()
      .isLength({ min: 2 })
      .withMessage('Last name must be at least 2 characters long'),
    body('role')
      .optional()
      .isIn(['super_admin', 'admin', 'moderator', 'content_manager'])
      .withMessage('Invalid role'),
    handleValidationErrors
  ]
};

// User validation rules
const userValidation = {
  create: [
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Please provide a valid email'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Password must be at least 6 characters long'),
    body('firstName')
      .trim()
      .isLength({ min: 2 })
      .withMessage('First name must be at least 2 characters long'),
    body('lastName')
      .trim()
      .isLength({ min: 2 })
      .withMessage('Last name must be at least 2 characters long'),
    handleValidationErrors
  ]
};

// Education validation rules
const educationValidation = {
  create: [
    body('title')
      .trim()
      .isLength({ min: 3 })
      .withMessage('Title must be at least 3 characters long'),
    body('description')
      .trim()
      .isLength({ min: 10 })
      .withMessage('Description must be at least 10 characters long'),
    body('content')
      .trim()
      .isLength({ min: 50 })
      .withMessage('Content must be at least 50 characters long'),
    body('category')
      .isIn([
        'dream_psychology',
        'symbol_interpretation',
        'lucid_dreaming',
        'dream_analysis',
        'sleep_health',
        'meditation',
        'mindfulness',
        'other'
      ])
      .withMessage('Invalid category'),
    body('level')
      .optional()
      .isIn(['beginner', 'intermediate', 'advanced'])
      .withMessage('Invalid level'),
    body('duration')
      .isInt({ min: 1 })
      .withMessage('Duration must be a positive integer'),
    body('author')
      .isMongoId()
      .withMessage('Invalid author ID'),
    handleValidationErrors
  ]
};

// Author validation rules
const authorValidation = {
  create: [
    body('firstName')
      .trim()
      .isLength({ min: 2 })
      .withMessage('First name must be at least 2 characters long'),
    body('lastName')
      .trim()
      .isLength({ min: 2 })
      .withMessage('Last name must be at least 2 characters long'),
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Please provide a valid email'),
    body('bio')
      .trim()
      .isLength({ min: 50 })
      .withMessage('Bio must be at least 50 characters long'),
    handleValidationErrors
  ]
};

// Expert validation rules
const expertValidation = {
  create: [
    body('firstName')
      .trim()
      .isLength({ min: 2 })
      .withMessage('First name must be at least 2 characters long'),
    body('lastName')
      .trim()
      .isLength({ min: 2 })
      .withMessage('Last name must be at least 2 characters long'),
    body('email')
      .isEmail()
      .normalizeEmail()
      .withMessage('Please provide a valid email'),
    body('phone')
      .trim()
      .isLength({ min: 10 })
      .withMessage('Phone number must be at least 10 characters long'),
    body('bio')
      .trim()
      .isLength({ min: 50 })
      .withMessage('Bio must be at least 50 characters long'),
    handleValidationErrors
  ]
};

// Session validation rules
const sessionValidation = {
  create: [
    body('title')
      .trim()
      .isLength({ min: 3 })
      .withMessage('Title must be at least 3 characters long'),
    body('description')
      .trim()
      .isLength({ min: 10 })
      .withMessage('Description must be at least 10 characters long'),
    body('type')
      .isIn(['individual', 'group', 'online', 'offline'])
      .withMessage('Invalid session type'),
    body('category')
      .isIn([
        'dream_interpretation',
        'dream_analysis',
        'lucid_dreaming',
        'sleep_coaching',
        'meditation',
        'mindfulness',
        'therapy',
        'consultation',
        'other'
      ])
      .withMessage('Invalid category'),
    body('expert')
      .isMongoId()
      .withMessage('Invalid expert ID'),
    body('duration')
      .isInt({ min: 15 })
      .withMessage('Duration must be at least 15 minutes'),
    body('price')
      .isFloat({ min: 0 })
      .withMessage('Price must be a positive number'),
    handleValidationErrors
  ]
};

// Book validation rules
const bookValidation = {
  create: [
    body('title')
      .trim()
      .isLength({ min: 3 })
      .withMessage('Title must be at least 3 characters long'),
    body('description')
      .trim()
      .isLength({ min: 10 })
      .withMessage('Description must be at least 10 characters long'),
    body('author')
      .trim()
      .isLength({ min: 2 })
      .withMessage('Author name must be at least 2 characters long'),
    body('category')
      .isIn([
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
      ])
      .withMessage('Invalid category'),
    handleValidationErrors
  ]
};

// Content validation rules
const contentValidation = {
  create: [
    body('title')
      .trim()
      .isLength({ min: 3 })
      .withMessage('Title must be at least 3 characters long'),
    body('description')
      .trim()
      .isLength({ min: 10 })
      .withMessage('Description must be at least 10 characters long'),
    body('content')
      .trim()
      .isLength({ min: 50 })
      .withMessage('Content must be at least 50 characters long'),
    body('type')
      .isIn([
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
      ])
      .withMessage('Invalid content type'),
    body('category')
      .isIn([
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
      ])
      .withMessage('Invalid category'),
    body('author')
      .isMongoId()
      .withMessage('Invalid author ID'),
    handleValidationErrors
  ]
};

// Common validation rules
const commonValidation = {
  mongoId: [
    param('id')
      .isMongoId()
      .withMessage('Invalid ID format'),
    handleValidationErrors
  ],
  
  pagination: [
    query('page')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Page must be a positive integer'),
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 })
      .withMessage('Limit must be between 1 and 100'),
    handleValidationErrors
  ]
};

module.exports = {
  adminValidation,
  userValidation,
  educationValidation,
  authorValidation,
  expertValidation,
  sessionValidation,
  bookValidation,
  contentValidation,
  commonValidation,
  handleValidationErrors
};
