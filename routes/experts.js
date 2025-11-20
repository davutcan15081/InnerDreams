const express = require('express');
const Expert = require('../models/Expert');
const { expertValidation, commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission } = require('../middleware/auth');
const { uploadSingle, processImage, handleUploadError } = require('../middleware/upload');

const router = express.Router();

// Get all experts
router.get('/', adminAuth, checkPermission('experts'), async (req, res) => {
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
    
    const experts = await Expert.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Expert.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        experts,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get experts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single expert
router.get('/:id', adminAuth, checkPermission('experts'), commonValidation.mongoId, async (req, res) => {
  try {
    const expert = await Expert.findById(req.params.id);
    
    if (!expert) {
      return res.status(404).json({
        success: false,
        message: 'Expert not found'
      });
    }
    
    res.json({
      success: true,
      data: {
        expert
      }
    });
  } catch (error) {
    console.error('Get expert error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Create new expert
router.post('/', 
  adminAuth, 
  checkPermission('experts'),
  uploadSingle('profileImage'),
  processImage,
  expertValidation.create,
  handleUploadError,
  async (req, res) => {
    try {
      const expertData = req.body;
      
      if (req.file) {
        expertData.profileImage = req.file.url;
      }
      
      if (typeof expertData.specialization === 'string') {
        expertData.specialization = expertData.specialization.split(',').map(s => s.trim());
      }
      
      const expert = new Expert(expertData);
      await expert.save();
      
      res.status(201).json({
        success: true,
        message: 'Expert created successfully',
        data: {
          expert
        }
      });
    } catch (error) {
      console.error('Create expert error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during expert creation'
      });
    }
  }
);

// Update expert
router.put('/:id', 
  adminAuth, 
  checkPermission('experts'),
  uploadSingle('profileImage'),
  processImage,
  commonValidation.mongoId,
  handleUploadError,
  async (req, res) => {
    try {
      const expertData = req.body;
      
      if (req.file) {
        expertData.profileImage = req.file.url;
      }
      
      if (typeof expertData.specialization === 'string') {
        expertData.specialization = expertData.specialization.split(',').map(s => s.trim());
      }
      
      const expert = await Expert.findByIdAndUpdate(
        req.params.id,
        expertData,
        { new: true, runValidators: true }
      );
      
      if (!expert) {
        return res.status(404).json({
          success: false,
          message: 'Expert not found'
        });
      }
      
      res.json({
        success: true,
        message: 'Expert updated successfully',
        data: {
          expert
        }
      });
    } catch (error) {
      console.error('Update expert error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during expert update'
      });
    }
  }
);

// Delete expert
router.delete('/:id', adminAuth, checkPermission('experts'), commonValidation.mongoId, async (req, res) => {
  try {
    const expert = await Expert.findByIdAndDelete(req.params.id);
    
    if (!expert) {
      return res.status(404).json({
        success: false,
        message: 'Expert not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Expert deleted successfully'
    });
  } catch (error) {
    console.error('Delete expert error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during expert deletion'
    });
  }
});

module.exports = router;
