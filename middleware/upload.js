const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');

// Ensure upload directories exist
const createUploadDirs = () => {
  const dirs = [
    'uploads',
    'uploads/images',
    'uploads/documents',
    'uploads/audio',
    'uploads/video',
    'uploads/thumbnails'
  ];
  
  dirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });
};

createUploadDirs();

// Storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    let uploadPath = 'uploads/';
    
    if (file.fieldname === 'images' || file.fieldname === 'thumbnail' || file.fieldname === 'profileImage' || file.fieldname === 'coverImage') {
      uploadPath += 'images/';
    } else if (file.fieldname === 'documents' || file.fieldname === 'pdf' || file.fieldname === 'epub') {
      uploadPath += 'documents/';
    } else if (file.fieldname === 'audio' || file.fieldname === 'audiobook') {
      uploadPath += 'audio/';
    } else if (file.fieldname === 'video') {
      uploadPath += 'video/';
    }
    
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedImageTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
  const allowedDocTypes = ['application/pdf', 'application/epub+zip', 'text/plain'];
  const allowedAudioTypes = ['audio/mpeg', 'audio/wav', 'audio/mp3', 'audio/ogg'];
  const allowedVideoTypes = ['video/mp4', 'video/webm', 'video/ogg'];
  
  if (file.fieldname === 'images' || file.fieldname === 'thumbnail' || file.fieldname === 'profileImage' || file.fieldname === 'coverImage') {
    if (allowedImageTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only image files (JPEG, PNG, GIF, WebP) are allowed'), false);
    }
  } else if (file.fieldname === 'documents' || file.fieldname === 'pdf' || file.fieldname === 'epub') {
    if (allowedDocTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only document files (PDF, EPUB, TXT) are allowed'), false);
    }
  } else if (file.fieldname === 'audio' || file.fieldname === 'audiobook') {
    if (allowedAudioTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only audio files (MP3, WAV, OGG) are allowed'), false);
    }
  } else if (file.fieldname === 'video') {
    if (allowedVideoTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only video files (MP4, WebM, OGG) are allowed'), false);
    }
  } else {
    cb(new Error('Invalid file type'), false);
  }
};

// Multer configuration
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024, // 10MB default
    files: 10 // Maximum 10 files per request
  }
});

// Image processing middleware
const processImage = async (req, res, next) => {
  if (!req.files || req.files.length === 0) {
    return next();
  }

  try {
    const processedFiles = [];
    
    for (const file of req.files) {
      if (file.fieldname.includes('image') || file.fieldname.includes('thumbnail') || file.fieldname.includes('profile') || file.fieldname.includes('cover')) {
        const processedPath = file.path.replace('.', '_processed.');
        
        // Resize and optimize image
        await sharp(file.path)
          .resize(1200, 1200, { 
            fit: 'inside',
            withoutEnlargement: true 
          })
          .jpeg({ quality: 85 })
          .toFile(processedPath);
        
        // Create thumbnail
        const thumbnailPath = file.path.replace('.', '_thumb.');
        await sharp(file.path)
          .resize(300, 300, { 
            fit: 'cover' 
          })
          .jpeg({ quality: 80 })
          .toFile(thumbnailPath);
        
        // Update file info
        file.processedPath = processedPath;
        file.thumbnailPath = thumbnailPath;
        file.url = `/uploads/images/${path.basename(processedPath)}`;
        file.thumbnailUrl = `/uploads/images/${path.basename(thumbnailPath)}`;
        
        // Remove original file
        fs.unlinkSync(file.path);
        
        processedFiles.push(file);
      } else {
        // For non-image files, just add URL
        file.url = `/uploads/${file.fieldname}/${path.basename(file.path)}`;
        processedFiles.push(file);
      }
    }
    
    req.files = processedFiles;
    next();
  } catch (error) {
    console.error('Image processing error:', error);
    res.status(500).json({
      success: false,
      message: 'Error processing uploaded files'
    });
  }
};

// Single file upload middleware
const uploadSingle = (fieldName) => {
  return upload.single(fieldName);
};

// Multiple files upload middleware
const uploadMultiple = (fieldName, maxCount = 10) => {
  return upload.array(fieldName, maxCount);
};

// Mixed files upload middleware
const uploadMixed = (fields) => {
  return upload.fields(fields);
};

// Error handling middleware
const handleUploadError = (error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'File too large. Maximum size is 10MB.'
      });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        success: false,
        message: 'Too many files. Maximum 10 files allowed.'
      });
    }
    if (error.code === 'LIMIT_UNEXPECTED_FILE') {
      return res.status(400).json({
        success: false,
        message: 'Unexpected file field.'
      });
    }
  }
  
  if (error.message.includes('Only')) {
    return res.status(400).json({
      success: false,
      message: error.message
    });
  }
  
  next(error);
};

module.exports = {
  upload,
  uploadSingle,
  uploadMultiple,
  uploadMixed,
  processImage,
  handleUploadError
};
