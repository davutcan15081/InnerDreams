const express = require('express');
const path = require('path');
const fs = require('fs');
const { adminAuth } = require('../middleware/auth');
const { uploadSingle, uploadMultiple, handleUploadError } = require('../middleware/upload');

const router = express.Router();

// Single file upload
router.post('/single', 
  adminAuth,
  uploadSingle('file'),
  handleUploadError,
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No file uploaded'
        });
      }

      res.json({
        success: true,
        message: 'File uploaded successfully',
        data: {
          file: {
            originalName: req.file.originalname,
            filename: req.file.filename,
            url: req.file.url,
            size: req.file.size,
            mimetype: req.file.mimetype,
            fieldname: req.file.fieldname
          }
        }
      });
    } catch (error) {
      console.error('Single upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during file upload'
      });
    }
  }
);

// Multiple files upload
router.post('/multiple', 
  adminAuth,
  uploadMultiple('files', 10),
  handleUploadError,
  async (req, res) => {
    try {
      if (!req.files || req.files.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No files uploaded'
        });
      }

      const uploadedFiles = req.files.map(file => ({
        originalName: file.originalname,
        filename: file.filename,
        url: file.url,
        size: file.size,
        mimetype: file.mimetype,
        fieldname: file.fieldname
      }));

      res.json({
        success: true,
        message: 'Files uploaded successfully',
        data: {
          files: uploadedFiles,
          count: uploadedFiles.length
        }
      });
    } catch (error) {
      console.error('Multiple upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during files upload'
      });
    }
  }
);

// Image upload with processing
router.post('/image', 
  adminAuth,
  uploadSingle('image'),
  handleUploadError,
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No image uploaded'
        });
      }

      res.json({
        success: true,
        message: 'Image uploaded and processed successfully',
        data: {
          image: {
            originalName: req.file.originalname,
            filename: req.file.filename,
            url: req.file.url,
            thumbnailUrl: req.file.thumbnailUrl,
            size: req.file.size,
            mimetype: req.file.mimetype
          }
        }
      });
    } catch (error) {
      console.error('Image upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during image upload'
      });
    }
  }
);

// Document upload
router.post('/document', 
  adminAuth,
  uploadSingle('document'),
  handleUploadError,
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No document uploaded'
        });
      }

      res.json({
        success: true,
        message: 'Document uploaded successfully',
        data: {
          document: {
            originalName: req.file.originalname,
            filename: req.file.filename,
            url: req.file.url,
            size: req.file.size,
            mimetype: req.file.mimetype
          }
        }
      });
    } catch (error) {
      console.error('Document upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during document upload'
      });
    }
  }
);

// Audio upload
router.post('/audio', 
  adminAuth,
  uploadSingle('audio'),
  handleUploadError,
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No audio file uploaded'
        });
      }

      res.json({
        success: true,
        message: 'Audio file uploaded successfully',
        data: {
          audio: {
            originalName: req.file.originalname,
            filename: req.file.filename,
            url: req.file.url,
            size: req.file.size,
            mimetype: req.file.mimetype
          }
        }
      });
    } catch (error) {
      console.error('Audio upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during audio upload'
      });
    }
  }
);

// Video upload
router.post('/video', 
  adminAuth,
  uploadSingle('video'),
  handleUploadError,
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No video file uploaded'
        });
      }

      res.json({
        success: true,
        message: 'Video file uploaded successfully',
        data: {
          video: {
            originalName: req.file.originalname,
            filename: req.file.filename,
            url: req.file.url,
            size: req.file.size,
            mimetype: req.file.mimetype
          }
        }
      });
    } catch (error) {
      console.error('Video upload error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during video upload'
      });
    }
  }
);

// Delete file
router.delete('/:filename', adminAuth, async (req, res) => {
  try {
    const filename = req.params.filename;
    const filePath = path.join(__dirname, '../uploads', filename);
    
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        message: 'File not found'
      });
    }
    
    // Delete file
    fs.unlinkSync(filePath);
    
    res.json({
      success: true,
      message: 'File deleted successfully'
    });
  } catch (error) {
    console.error('Delete file error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during file deletion'
    });
  }
});

// Get upload statistics
router.get('/stats', adminAuth, async (req, res) => {
  try {
    const uploadsDir = path.join(__dirname, '../uploads');
    const stats = {
      totalFiles: 0,
      totalSize: 0,
      byType: {
        images: { count: 0, size: 0 },
        documents: { count: 0, size: 0 },
        audio: { count: 0, size: 0 },
        video: { count: 0, size: 0 }
      }
    };
    
    const scanDirectory = (dir) => {
      const files = fs.readdirSync(dir);
      
      files.forEach(file => {
        const filePath = path.join(dir, file);
        const stat = fs.statSync(filePath);
        
        if (stat.isDirectory()) {
          scanDirectory(filePath);
        } else {
          stats.totalFiles++;
          stats.totalSize += stat.size;
          
          const ext = path.extname(file).toLowerCase();
          if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].includes(ext)) {
            stats.byType.images.count++;
            stats.byType.images.size += stat.size;
          } else if (['.pdf', '.epub', '.txt', '.doc', '.docx'].includes(ext)) {
            stats.byType.documents.count++;
            stats.byType.documents.size += stat.size;
          } else if (['.mp3', '.wav', '.ogg', '.m4a'].includes(ext)) {
            stats.byType.audio.count++;
            stats.byType.audio.size += stat.size;
          } else if (['.mp4', '.webm', '.ogg', '.avi'].includes(ext)) {
            stats.byType.video.count++;
            stats.byType.video.size += stat.size;
          }
        }
      });
    };
    
    if (fs.existsSync(uploadsDir)) {
      scanDirectory(uploadsDir);
    }
    
    // Convert bytes to MB
    const formatSize = (bytes) => {
      return (bytes / (1024 * 1024)).toFixed(2);
    };
    
    res.json({
      success: true,
      data: {
        totalFiles: stats.totalFiles,
        totalSize: formatSize(stats.totalSize),
        totalSizeBytes: stats.totalSize,
        byType: {
          images: {
            count: stats.byType.images.count,
            size: formatSize(stats.byType.images.size)
          },
          documents: {
            count: stats.byType.documents.count,
            size: formatSize(stats.byType.documents.size)
          },
          audio: {
            count: stats.byType.audio.count,
            size: formatSize(stats.byType.audio.size)
          },
          video: {
            count: stats.byType.video.count,
            size: formatSize(stats.byType.video.size)
          }
        }
      }
    });
  } catch (error) {
    console.error('Upload stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
