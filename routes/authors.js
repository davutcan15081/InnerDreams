const express = require('express');
const Author = require('../models/Author');
const { authorValidation, commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission } = require('../middleware/auth');
const { uploadSingle, processImage, handleUploadError } = require('../middleware/upload');

const router = express.Router();

// Get all authors
router.get('/', adminAuth, checkPermission('authors'), async (req, res) => {
  try {
    const { page = 1, limit = 10, search, specialization, isVerified, isActive } = req.query;
    
    let query = {};
    
    if (search) {
      query.$or = [
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } },
        { bio: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (specialization) query.specialization = specialization;
    if (isVerified !== undefined) query.isVerified = isVerified === 'true';
    if (isActive !== undefined) query.isActive = isActive === 'true';
    
    const authors = await Author.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Author.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        authors,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get authors error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single author
router.get('/:id', adminAuth, checkPermission('authors'), commonValidation.mongoId, async (req, res) => {
  try {
    const author = await Author.findById(req.params.id);
    
    if (!author) {
      return res.status(404).json({
        success: false,
        message: 'Author not found'
      });
    }
    
    res.json({
      success: true,
      data: {
        author
      }
    });
  } catch (error) {
    console.error('Get author error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Create new author
router.post('/', 
  adminAuth, 
  checkPermission('authors'),
  uploadSingle('profileImage'),
  processImage,
  authorValidation.create,
  handleUploadError,
  async (req, res) => {
    try {
      const authorData = req.body;
      
      if (req.file) {
        authorData.profileImage = req.file.url;
      }
      
      if (typeof authorData.specialization === 'string') {
        authorData.specialization = authorData.specialization.split(',').map(s => s.trim());
      }
      
      const author = new Author(authorData);
      await author.save();
      
      res.status(201).json({
        success: true,
        message: 'Author created successfully',
        data: {
          author
        }
      });
    } catch (error) {
      console.error('Create author error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during author creation'
      });
    }
  }
);

// Update author
router.put('/:id', 
  adminAuth, 
  checkPermission('authors'),
  uploadSingle('profileImage'),
  processImage,
  commonValidation.mongoId,
  handleUploadError,
  async (req, res) => {
    try {
      const authorData = req.body;
      
      if (req.file) {
        authorData.profileImage = req.file.url;
      }
      
      if (typeof authorData.specialization === 'string') {
        authorData.specialization = authorData.specialization.split(',').map(s => s.trim());
      }
      
      const author = await Author.findByIdAndUpdate(
        req.params.id,
        authorData,
        { new: true, runValidators: true }
      );
      
      if (!author) {
        return res.status(404).json({
          success: false,
          message: 'Author not found'
        });
      }
      
      res.json({
        success: true,
        message: 'Author updated successfully',
        data: {
          author
        }
      });
    } catch (error) {
      console.error('Update author error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during author update'
      });
    }
  }
);

// Delete author
router.delete('/:id', adminAuth, checkPermission('authors'), commonValidation.mongoId, async (req, res) => {
  try {
    const author = await Author.findByIdAndDelete(req.params.id);
    
    if (!author) {
      return res.status(404).json({
        success: false,
        message: 'Author not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Author deleted successfully'
    });
  } catch (error) {
    console.error('Delete author error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during author deletion'
    });
  }
});

module.exports = router;
