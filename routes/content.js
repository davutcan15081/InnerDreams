const express = require('express');
const Content = require('../models/Content');
const Author = require('../models/Author');
const { contentValidation, commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission } = require('../middleware/auth');
const { uploadMultiple, processImage, handleUploadError } = require('../middleware/upload');

const router = express.Router();

// Get all content
router.get('/', adminAuth, checkPermission('content'), async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search, 
      type, 
      category, 
      author, 
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
        { content: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (type) query.type = type;
    if (category) query.category = category;
    if (author) query.author = author;
    if (isActive !== undefined) query.isActive = isActive === 'true';
    if (isPublished !== undefined) query.isPublished = isPublished === 'true';
    
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    const content = await Content.find(query)
      .populate('author', 'firstName lastName profileImage')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Content.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        content,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get content error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single content
router.get('/:id', adminAuth, checkPermission('content'), commonValidation.mongoId, async (req, res) => {
  try {
    const content = await Content.findById(req.params.id)
      .populate('author', 'firstName lastName bio profileImage')
      .populate('relatedContent', 'title slug')
      .populate('comments.user', 'firstName lastName profileImage');
    
    if (!content) {
      return res.status(404).json({
        success: false,
        message: 'Content not found'
      });
    }
    
    res.json({
      success: true,
      data: {
        content
      }
    });
  } catch (error) {
    console.error('Get content error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Create new content
router.post('/', 
  adminAuth, 
  checkPermission('content'),
  uploadMultiple('files', 10),
  processImage,
  contentValidation.create,
  handleUploadError,
  async (req, res) => {
    try {
      const contentData = req.body;
      
      // Handle uploaded files
      if (req.files) {
        req.files.forEach(file => {
          if (file.fieldname === 'featuredImage') {
            contentData.featuredImage = file.url;
          } else if (file.fieldname === 'images') {
            if (!contentData.images) contentData.images = [];
            contentData.images.push({
              url: file.url,
              caption: '',
              alt: ''
            });
          } else if (file.fieldname === 'videos') {
            if (!contentData.videos) contentData.videos = [];
            contentData.videos.push({
              url: file.url,
              title: '',
              duration: 0,
              thumbnail: '',
              caption: ''
            });
          } else if (file.fieldname === 'audio') {
            if (!contentData.audio) contentData.audio = [];
            contentData.audio.push({
              url: file.url,
              title: '',
              duration: 0,
              caption: ''
            });
          } else if (file.fieldname === 'documents') {
            if (!contentData.documents) contentData.documents = [];
            contentData.documents.push({
              url: file.url,
              title: '',
              type: file.mimetype,
              size: file.size
            });
          }
        });
      }
      
      // Convert string arrays to actual arrays
      if (typeof contentData.tags === 'string') {
        contentData.tags = contentData.tags.split(',').map(tag => tag.trim());
      }
      if (typeof contentData.keywords === 'string') {
        contentData.keywords = contentData.keywords.split(',').map(keyword => keyword.trim());
      }
      if (typeof contentData.subcategory === 'string') {
        contentData.subcategory = contentData.subcategory.split(',').map(sub => sub.trim());
      }
      if (typeof contentData.relatedContent === 'string') {
        contentData.relatedContent = contentData.relatedContent.split(',').map(id => id.trim());
      }
      if (typeof contentData.featuredIn === 'string') {
        contentData.featuredIn = contentData.featuredIn.split(',').map(feature => feature.trim());
      }
      
      const content = new Content(contentData);
      await content.save();
      
      const populatedContent = await Content.findById(content._id)
        .populate('author', 'firstName lastName profileImage');
      
      res.status(201).json({
        success: true,
        message: 'Content created successfully',
        data: {
          content: populatedContent
        }
      });
    } catch (error) {
      console.error('Create content error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during content creation'
      });
    }
  }
);

// Update content
router.put('/:id', 
  adminAuth, 
  checkPermission('content'),
  uploadMultiple('files', 10),
  processImage,
  commonValidation.mongoId,
  handleUploadError,
  async (req, res) => {
    try {
      const contentData = req.body;
      
      // Handle uploaded files
      if (req.files) {
        req.files.forEach(file => {
          if (file.fieldname === 'featuredImage') {
            contentData.featuredImage = file.url;
          } else if (file.fieldname === 'images') {
            if (!contentData.images) contentData.images = [];
            contentData.images.push({
              url: file.url,
              caption: '',
              alt: ''
            });
          } else if (file.fieldname === 'videos') {
            if (!contentData.videos) contentData.videos = [];
            contentData.videos.push({
              url: file.url,
              title: '',
              duration: 0,
              thumbnail: '',
              caption: ''
            });
          } else if (file.fieldname === 'audio') {
            if (!contentData.audio) contentData.audio = [];
            contentData.audio.push({
              url: file.url,
              title: '',
              duration: 0,
              caption: ''
            });
          } else if (file.fieldname === 'documents') {
            if (!contentData.documents) contentData.documents = [];
            contentData.documents.push({
              url: file.url,
              title: '',
              type: file.mimetype,
              size: file.size
            });
          }
        });
      }
      
      // Convert string arrays to actual arrays
      if (typeof contentData.tags === 'string') {
        contentData.tags = contentData.tags.split(',').map(tag => tag.trim());
      }
      if (typeof contentData.keywords === 'string') {
        contentData.keywords = contentData.keywords.split(',').map(keyword => keyword.trim());
      }
      if (typeof contentData.subcategory === 'string') {
        contentData.subcategory = contentData.subcategory.split(',').map(sub => sub.trim());
      }
      if (typeof contentData.relatedContent === 'string') {
        contentData.relatedContent = contentData.relatedContent.split(',').map(id => id.trim());
      }
      if (typeof contentData.featuredIn === 'string') {
        contentData.featuredIn = contentData.featuredIn.split(',').map(feature => feature.trim());
      }
      
      const content = await Content.findByIdAndUpdate(
        req.params.id,
        contentData,
        { new: true, runValidators: true }
      ).populate('author', 'firstName lastName profileImage');
      
      if (!content) {
        return res.status(404).json({
          success: false,
          message: 'Content not found'
        });
      }
      
      res.json({
        success: true,
        message: 'Content updated successfully',
        data: {
          content
        }
      });
    } catch (error) {
      console.error('Update content error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during content update'
      });
    }
  }
);

// Delete content
router.delete('/:id', adminAuth, checkPermission('content'), commonValidation.mongoId, async (req, res) => {
  try {
    const content = await Content.findByIdAndDelete(req.params.id);
    
    if (!content) {
      return res.status(404).json({
        success: false,
        message: 'Content not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Content deleted successfully'
    });
  } catch (error) {
    console.error('Delete content error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during content deletion'
    });
  }
});

// Toggle content status
router.patch('/:id/toggle-status', adminAuth, checkPermission('content'), commonValidation.mongoId, async (req, res) => {
  try {
    const content = await Content.findById(req.params.id);
    
    if (!content) {
      return res.status(404).json({
        success: false,
        message: 'Content not found'
      });
    }
    
    content.isActive = !content.isActive;
    await content.save();
    
    res.json({
      success: true,
      message: `Content ${content.isActive ? 'activated' : 'deactivated'} successfully`,
      data: {
        content: {
          id: content._id,
          isActive: content.isActive
        }
      }
    });
  } catch (error) {
    console.error('Toggle content status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Publish/Unpublish content
router.patch('/:id/publish', adminAuth, checkPermission('content'), commonValidation.mongoId, async (req, res) => {
  try {
    const content = await Content.findById(req.params.id);
    
    if (!content) {
      return res.status(404).json({
        success: false,
        message: 'Content not found'
      });
    }
    
    content.isPublished = !content.isPublished;
    if (content.isPublished) {
      content.publishedAt = new Date();
    } else {
      content.publishedAt = null;
    }
    
    await content.save();
    
    res.json({
      success: true,
      message: `Content ${content.isPublished ? 'published' : 'unpublished'} successfully`,
      data: {
        content: {
          id: content._id,
          isPublished: content.isPublished,
          publishedAt: content.publishedAt
        }
      }
    });
  } catch (error) {
    console.error('Publish content error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Moderate comments
router.patch('/:id/comments/:commentId/moderate', adminAuth, checkPermission('content'), async (req, res) => {
  try {
    const { approved } = req.body;
    
    const content = await Content.findById(req.params.id);
    
    if (!content) {
      return res.status(404).json({
        success: false,
        message: 'Content not found'
      });
    }
    
    const comment = content.comments.id(req.params.commentId);
    
    if (!comment) {
      return res.status(404).json({
        success: false,
        message: 'Comment not found'
      });
    }
    
    comment.isApproved = approved;
    await content.save();
    
    res.json({
      success: true,
      message: `Comment ${approved ? 'approved' : 'rejected'} successfully`,
      data: {
        comment
      }
    });
  } catch (error) {
    console.error('Moderate comment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
