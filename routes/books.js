const express = require('express');
const Book = require('../models/Book');
const { bookValidation, commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission } = require('../middleware/auth');
const { uploadSingle, uploadMultiple, processImage, handleUploadError } = require('../middleware/upload');

const router = express.Router();

// Get all books
router.get('/', adminAuth, checkPermission('books'), async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search, 
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
        { author: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (category) query.category = category;
    if (author) query.author = { $regex: author, $options: 'i' };
    if (isActive !== undefined) query.isActive = isActive === 'true';
    if (isPublished !== undefined) query.isPublished = isPublished === 'true';
    
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    const books = await Book.find(query)
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Book.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        books,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get books error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single book
router.get('/:id', adminAuth, checkPermission('books'), commonValidation.mongoId, async (req, res) => {
  try {
    const book = await Book.findById(req.params.id)
      .populate('relatedBooks', 'title author')
      .populate('recommendedBy.expert', 'firstName lastName');
    
    if (!book) {
      return res.status(404).json({
        success: false,
        message: 'Book not found'
      });
    }
    
    res.json({
      success: true,
      data: {
        book
      }
    });
  } catch (error) {
    console.error('Get book error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Create new book
router.post('/', 
  adminAuth, 
  checkPermission('books'),
  uploadMultiple('files', 5),
  processImage,
  bookValidation.create,
  handleUploadError,
  async (req, res) => {
    try {
      const bookData = req.body;
      
      // Handle uploaded files
      if (req.files) {
        req.files.forEach(file => {
          if (file.fieldname === 'coverImage') {
            bookData.coverImage = file.url;
          } else if (file.fieldname === 'pdf') {
            bookData.pdfUrl = file.url;
          } else if (file.fieldname === 'epub') {
            bookData.epubUrl = file.url;
          } else if (file.fieldname === 'audiobook') {
            bookData.audiobookUrl = file.url;
          } else if (file.fieldname === 'images') {
            if (!bookData.images) bookData.images = [];
            bookData.images.push(file.url);
          }
        });
      }
      
      // Convert string arrays to actual arrays
      if (typeof bookData.tags === 'string') {
        bookData.tags = bookData.tags.split(',').map(tag => tag.trim());
      }
      if (typeof bookData.keywords === 'string') {
        bookData.keywords = bookData.keywords.split(',').map(keyword => keyword.trim());
      }
      if (typeof bookData.subcategory === 'string') {
        bookData.subcategory = bookData.subcategory.split(',').map(sub => sub.trim());
      }
      if (typeof bookData.coAuthors === 'string') {
        bookData.coAuthors = bookData.coAuthors.split(',').map(author => author.trim());
      }
      if (typeof bookData.relatedBooks === 'string') {
        bookData.relatedBooks = bookData.relatedBooks.split(',').map(id => id.trim());
      }
      
      const book = new Book(bookData);
      await book.save();
      
      res.status(201).json({
        success: true,
        message: 'Book created successfully',
        data: {
          book
        }
      });
    } catch (error) {
      console.error('Create book error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during book creation'
      });
    }
  }
);

// Update book
router.put('/:id', 
  adminAuth, 
  checkPermission('books'),
  uploadMultiple('files', 5),
  processImage,
  commonValidation.mongoId,
  handleUploadError,
  async (req, res) => {
    try {
      const bookData = req.body;
      
      // Handle uploaded files
      if (req.files) {
        req.files.forEach(file => {
          if (file.fieldname === 'coverImage') {
            bookData.coverImage = file.url;
          } else if (file.fieldname === 'pdf') {
            bookData.pdfUrl = file.url;
          } else if (file.fieldname === 'epub') {
            bookData.epubUrl = file.url;
          } else if (file.fieldname === 'audiobook') {
            bookData.audiobookUrl = file.url;
          } else if (file.fieldname === 'images') {
            if (!bookData.images) bookData.images = [];
            bookData.images.push(file.url);
          }
        });
      }
      
      // Convert string arrays to actual arrays
      if (typeof bookData.tags === 'string') {
        bookData.tags = bookData.tags.split(',').map(tag => tag.trim());
      }
      if (typeof bookData.keywords === 'string') {
        bookData.keywords = bookData.keywords.split(',').map(keyword => keyword.trim());
      }
      if (typeof bookData.subcategory === 'string') {
        bookData.subcategory = bookData.subcategory.split(',').map(sub => sub.trim());
      }
      if (typeof bookData.coAuthors === 'string') {
        bookData.coAuthors = bookData.coAuthors.split(',').map(author => author.trim());
      }
      if (typeof bookData.relatedBooks === 'string') {
        bookData.relatedBooks = bookData.relatedBooks.split(',').map(id => id.trim());
      }
      
      const book = await Book.findByIdAndUpdate(
        req.params.id,
        bookData,
        { new: true, runValidators: true }
      );
      
      if (!book) {
        return res.status(404).json({
          success: false,
          message: 'Book not found'
        });
      }
      
      res.json({
        success: true,
        message: 'Book updated successfully',
        data: {
          book
        }
      });
    } catch (error) {
      console.error('Update book error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error during book update'
      });
    }
  }
);

// Delete book
router.delete('/:id', adminAuth, checkPermission('books'), commonValidation.mongoId, async (req, res) => {
  try {
    const book = await Book.findByIdAndDelete(req.params.id);
    
    if (!book) {
      return res.status(404).json({
        success: false,
        message: 'Book not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Book deleted successfully'
    });
  } catch (error) {
    console.error('Delete book error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during book deletion'
    });
  }
});

// Toggle book status
router.patch('/:id/toggle-status', adminAuth, checkPermission('books'), commonValidation.mongoId, async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    
    if (!book) {
      return res.status(404).json({
        success: false,
        message: 'Book not found'
      });
    }
    
    book.isActive = !book.isActive;
    await book.save();
    
    res.json({
      success: true,
      message: `Book ${book.isActive ? 'activated' : 'deactivated'} successfully`,
      data: {
        book: {
          id: book._id,
          isActive: book.isActive
        }
      }
    });
  } catch (error) {
    console.error('Toggle book status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Publish/Unpublish book
router.patch('/:id/publish', adminAuth, checkPermission('books'), commonValidation.mongoId, async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    
    if (!book) {
      return res.status(404).json({
        success: false,
        message: 'Book not found'
      });
    }
    
    book.isPublished = !book.isPublished;
    if (book.isPublished) {
      book.publishedAt = new Date();
    } else {
      book.publishedAt = null;
    }
    
    await book.save();
    
    res.json({
      success: true,
      message: `Book ${book.isPublished ? 'published' : 'unpublished'} successfully`,
      data: {
        book: {
          id: book._id,
          isPublished: book.isPublished,
          publishedAt: book.publishedAt
        }
      }
    });
  } catch (error) {
    console.error('Publish book error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
