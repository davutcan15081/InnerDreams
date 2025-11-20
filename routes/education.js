const express = require('express');
const Education = require('../models/Education');
const Author = require('../models/Author');
const { educationValidation, commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission } = require('../middleware/auth');
const { uploadMultiple, processImage, handleUploadError } = require('../middleware/upload');

const router = express.Router();

// Get all educations
router.get('/', adminAuth, checkPermission('education'), async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search, 
      category, 
      level, 
      author, 
      isActive, 
      isPublished,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;
    
    let query = {};
    
    // Search functionality
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } }
      ];
    }
    
    // Filters
    if (category) query.category = category;
    if (level) query.level = level;
    if (author) query.author = author;
    if (isActive !== undefined) query.isActive = isActive === 'true';
    if (isPublished !== undefined) query.isPublished = isPublished === 'true';
    
    // Sort
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    const educations = await Education.find(query)
      .populate('author', 'firstName lastName profileImage')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Education.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        educations,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get educations error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single education
router.get('/:id', adminAuth, checkPermission('education'), commonValidation.mongoId, async (req, res) => {
  try {
    const education = await Education.findById(req.params.id)
      .populate('author', 'firstName lastName bio profileImage')
      .populate('prerequisites', 'title')
      .populate('relatedEducations', 'title');
    
    if (!education) {
      return res.status(404).json({
        success: false,
        message: 'Education not found'
      });
    }
    
    res.json({
      success: true,
      data: {
        education
      }
    });
  } catch (error) {
    console.error('Get education error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Create new education
router.post('/', 
  adminAuth, 
  checkPermission('education'),
  uploadMultiple('images', 10),
  processImage,
  educationValidation.create,
  handleUploadError,
  async (req, res) => {
    try {
      const educationData = req.body;
      
      // Handle uploaded files
      if (req.files) {
        educationData.images = req.files.map(file => file.url);
        if (req.files[0]) {
          educationData.thumbnail = req.files[0].thumbnailUrl;
        }
      }
      
      // Convert string arrays to actual arrays
      if (typeof educationData.tags === 'string') {
        educationData.tags = educationData.tags.split(',').map(tag => tag.trim());
      }
      if (typeof educationData.prerequisites === 'string') {
        educationData.prerequisites = educationData.prerequisites.split(',').map(id => id.trim());
      }
      if (typeof educationData.relatedEducations === 'string') {
        educationData.relatedEducations = educationData.relatedEducations.split(',').map(id => id.trim());
      }
      
      const education = new Education(educationData);
      await education.save();
      
      // Update author's education count
      await Author.findByIdAndUpdate(educationData.author, {
        $inc: { educationCount: 1 }
      });
      
      const populatedEducation = await Education.findById(education._id)
        .populate('author', 'firstName lastName profileImage');
      
      res.status(201).json({
        success: true,
        message: 'Education created successfully',
        data: {
          education: populatedEducation
        }
      });
    } catch (error) {
      console.error('Create education error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during education creation'
      });
    }
  }
);

// Update education
router.put('/:id', 
  adminAuth, 
  checkPermission('education'),
  uploadMultiple('images', 10),
  processImage,
  commonValidation.mongoId,
  handleUploadError,
  async (req, res) => {
    try {
      const educationData = req.body;
      
      // Handle uploaded files
      if (req.files && req.files.length > 0) {
        educationData.images = req.files.map(file => file.url);
        if (req.files[0]) {
          educationData.thumbnail = req.files[0].thumbnailUrl;
        }
      }
      
      // Convert string arrays to actual arrays
      if (typeof educationData.tags === 'string') {
        educationData.tags = educationData.tags.split(',').map(tag => tag.trim());
      }
      if (typeof educationData.prerequisites === 'string') {
        educationData.prerequisites = educationData.prerequisites.split(',').map(id => id.trim());
      }
      if (typeof educationData.relatedEducations === 'string') {
        educationData.relatedEducations = educationData.relatedEducations.split(',').map(id => id.trim());
      }
      
      const education = await Education.findByIdAndUpdate(
        req.params.id,
        educationData,
        { new: true, runValidators: true }
      ).populate('author', 'firstName lastName profileImage');
      
      if (!education) {
        return res.status(404).json({
          success: false,
          message: 'Education not found'
        });
      }
      
      res.json({
        success: true,
        message: 'Education updated successfully',
        data: {
          education
        }
      });
    } catch (error) {
      console.error('Update education error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during education update'
      });
    }
  }
);

// Delete education
router.delete('/:id', adminAuth, checkPermission('education'), commonValidation.mongoId, async (req, res) => {
  try {
    const education = await Education.findByIdAndDelete(req.params.id);
    
    if (!education) {
      return res.status(404).json({
        success: false,
        message: 'Education not found'
      });
    }
    
    // Update author's education count
    await Author.findByIdAndUpdate(education.author, {
      $inc: { educationCount: -1 }
    });
    
    res.json({
      success: true,
      message: 'Education deleted successfully'
    });
  } catch (error) {
    console.error('Delete education error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during education deletion'
    });
  }
});

// Toggle education status
router.patch('/:id/toggle-status', adminAuth, checkPermission('education'), commonValidation.mongoId, async (req, res) => {
  try {
    const education = await Education.findById(req.params.id);
    
    if (!education) {
      return res.status(404).json({
        success: false,
        message: 'Education not found'
      });
    }
    
    education.isActive = !education.isActive;
    await education.save();
    
    res.json({
      success: true,
      message: `Education ${education.isActive ? 'activated' : 'deactivated'} successfully`,
      data: {
        education: {
          id: education._id,
          isActive: education.isActive
        }
      }
    });
  } catch (error) {
    console.error('Toggle education status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Publish/Unpublish education
router.patch('/:id/publish', adminAuth, checkPermission('education'), commonValidation.mongoId, async (req, res) => {
  try {
    const education = await Education.findById(req.params.id);
    
    if (!education) {
      return res.status(404).json({
        success: false,
        message: 'Education not found'
      });
    }
    
    education.isPublished = !education.isPublished;
    if (education.isPublished) {
      education.publishedAt = new Date();
    } else {
      education.publishedAt = null;
    }
    
    await education.save();
    
    res.json({
      success: true,
      message: `Education ${education.isPublished ? 'published' : 'unpublished'} successfully`,
      data: {
        education: {
          id: education._id,
          isPublished: education.isPublished,
          publishedAt: education.publishedAt
        }
      }
    });
  } catch (error) {
    console.error('Publish education error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get education statistics
router.get('/stats/overview', adminAuth, checkPermission('education'), async (req, res) => {
  try {
    const totalEducations = await Education.countDocuments();
    const publishedEducations = await Education.countDocuments({ isPublished: true });
    const activeEducations = await Education.countDocuments({ isActive: true });
    const premiumEducations = await Education.countDocuments({ isPremium: true });
    
    // Category distribution
    const categoryStats = await Education.aggregate([
      { $group: { _id: '$category', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // Level distribution
    const levelStats = await Education.aggregate([
      { $group: { _id: '$level', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // Top authors by education count
    const topAuthors = await Education.aggregate([
      { $group: { _id: '$author', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 },
      { $lookup: {
        from: 'authors',
        localField: '_id',
        foreignField: '_id',
        as: 'author'
      }},
      { $unwind: '$author' },
      { $project: {
        authorName: { $concat: ['$author.firstName', ' ', '$author.lastName'] },
        count: 1
      }}
    ]);
    
    res.json({
      success: true,
      data: {
        totalEducations,
        publishedEducations,
        unpublishedEducations: totalEducations - publishedEducations,
        activeEducations,
        inactiveEducations: totalEducations - activeEducations,
        premiumEducations,
        freeEducations: totalEducations - premiumEducations,
        categoryDistribution: categoryStats,
        levelDistribution: levelStats,
        topAuthors
      }
    });
  } catch (error) {
    console.error('Education stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
