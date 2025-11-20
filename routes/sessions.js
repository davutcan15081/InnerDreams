const express = require('express');
const Session = require('../models/Session');
const Expert = require('../models/Expert');
const { sessionValidation, commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission } = require('../middleware/auth');
const { uploadMultiple, processImage, handleUploadError } = require('../middleware/upload');

const router = express.Router();

// Get all sessions
router.get('/', adminAuth, checkPermission('sessions'), async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search, 
      type, 
      category, 
      expert, 
      isActive, 
      isPublished,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;
    
    let query = {};
    
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (type) query.type = type;
    if (category) query.category = category;
    if (expert) query.expert = expert;
    if (isActive !== undefined) query.isActive = isActive === 'true';
    if (isPublished !== undefined) query.isPublished = isPublished === 'true';
    
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    const sessions = await Session.find(query)
      .populate('expert', 'firstName lastName profileImage')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Session.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        sessions,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single session
router.get('/:id', adminAuth, checkPermission('sessions'), commonValidation.mongoId, async (req, res) => {
  try {
    const session = await Session.findById(req.params.id)
      .populate('expert', 'firstName lastName bio profileImage');
    
    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found'
      });
    }
    
    res.json({
      success: true,
      data: {
        session
      }
    });
  } catch (error) {
    console.error('Get session error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Create new session
router.post('/', 
  adminAuth, 
  checkPermission('sessions'),
  uploadMultiple('images', 10),
  processImage,
  sessionValidation.create,
  handleUploadError,
  async (req, res) => {
    try {
      const sessionData = req.body;
      
      if (req.files) {
        sessionData.images = req.files.map(file => file.url);
        if (req.files[0]) {
          sessionData.thumbnail = req.files[0].thumbnailUrl;
        }
      }
      
      if (typeof sessionData.tags === 'string') {
        sessionData.tags = sessionData.tags.split(',').map(tag => tag.trim());
      }
      
      const session = new Session(sessionData);
      await session.save();
      
      const populatedSession = await Session.findById(session._id)
        .populate('expert', 'firstName lastName profileImage');
      
      res.status(201).json({
        success: true,
        message: 'Session created successfully',
        data: {
          session: populatedSession
        }
      });
    } catch (error) {
      console.error('Create session error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during session creation'
      });
    }
  }
);

// Update session
router.put('/:id', 
  adminAuth, 
  checkPermission('sessions'),
  uploadMultiple('images', 10),
  processImage,
  commonValidation.mongoId,
  handleUploadError,
  async (req, res) => {
    try {
      const sessionData = req.body;
      
      if (req.files && req.files.length > 0) {
        sessionData.images = req.files.map(file => file.url);
        if (req.files[0]) {
          sessionData.thumbnail = req.files[0].thumbnailUrl;
        }
      }
      
      if (typeof sessionData.tags === 'string') {
        sessionData.tags = sessionData.tags.split(',').map(tag => tag.trim());
      }
      
      const session = await Session.findByIdAndUpdate(
        req.params.id,
        sessionData,
        { new: true, runValidators: true }
      ).populate('expert', 'firstName lastName profileImage');
      
      if (!session) {
        return res.status(404).json({
          success: false,
          message: 'Session not found'
        });
      }
      
      res.json({
        success: true,
        message: 'Session updated successfully',
        data: {
          session
        }
      });
    } catch (error) {
      console.error('Update session error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during session update'
      });
    }
  }
);

// Delete session
router.delete('/:id', adminAuth, checkPermission('sessions'), commonValidation.mongoId, async (req, res) => {
  try {
    const session = await Session.findByIdAndDelete(req.params.id);
    
    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Session deleted successfully'
    });
  } catch (error) {
    console.error('Delete session error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during session deletion'
    });
  }
});

// Toggle session status
router.patch('/:id/toggle-status', adminAuth, checkPermission('sessions'), commonValidation.mongoId, async (req, res) => {
  try {
    const session = await Session.findById(req.params.id);
    
    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found'
      });
    }
    
    session.isActive = !session.isActive;
    await session.save();
    
    res.json({
      success: true,
      message: `Session ${session.isActive ? 'activated' : 'deactivated'} successfully`,
      data: {
        session: {
          id: session._id,
          isActive: session.isActive
        }
      }
    });
  } catch (error) {
    console.error('Toggle session status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Publish/Unpublish session
router.patch('/:id/publish', adminAuth, checkPermission('sessions'), commonValidation.mongoId, async (req, res) => {
  try {
    const session = await Session.findById(req.params.id);
    
    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found'
      });
    }
    
    session.isPublished = !session.isPublished;
    if (session.isPublished) {
      session.publishedAt = new Date();
    } else {
      session.publishedAt = null;
    }
    
    await session.save();
    
    res.json({
      success: true,
      message: `Session ${session.isPublished ? 'published' : 'unpublished'} successfully`,
      data: {
        session: {
          id: session._id,
          isPublished: session.isPublished,
          publishedAt: session.publishedAt
        }
      }
    });
  } catch (error) {
    console.error('Publish session error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
