const express = require('express');
const bcrypt = require('bcryptjs');
const Admin = require('../models/Admin');
const { adminValidation, commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission, checkRole } = require('../middleware/auth');

const router = express.Router();

// Get all admins (Super Admin only)
router.get('/', adminAuth, checkRole('super_admin'), async (req, res) => {
  try {
    const { page = 1, limit = 10, search, role, isActive } = req.query;
    
    let query = {};
    
    // Search functionality
    if (search) {
      query.$or = [
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    
    // Filter by role
    if (role) {
      query.role = role;
    }
    
    // Filter by active status
    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }
    
    const admins = await Admin.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Admin.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        admins,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get admins error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single admin
router.get('/:id', adminAuth, checkRole(['super_admin', 'admin']), commonValidation.mongoId, async (req, res) => {
  try {
    const admin = await Admin.findById(req.params.id).select('-password');
    
    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }
    
    // Check if current admin can view this admin
    if (req.admin.role !== 'super_admin' && req.admin._id.toString() !== req.params.id) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }
    
    res.json({
      success: true,
      data: {
        admin
      }
    });
  } catch (error) {
    console.error('Get admin error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Create new admin (Super Admin only)
router.post('/', adminAuth, checkRole('super_admin'), adminValidation.create, async (req, res) => {
  try {
    const { email, password, firstName, lastName, role = 'admin', permissions } = req.body;
    
    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({
        success: false,
        message: 'Admin with this email already exists'
      });
    }
    
    // Create admin
    const admin = new Admin({
      email,
      password,
      firstName,
      lastName,
      role,
      permissions: permissions || {}
    });
    
    await admin.save();
    
    res.status(201).json({
      success: true,
      message: 'Admin created successfully',
      data: {
        admin: {
          id: admin._id,
          email: admin.email,
          firstName: admin.firstName,
          lastName: admin.lastName,
          role: admin.role,
          permissions: admin.permissions,
          isActive: admin.isActive,
          createdAt: admin.createdAt
        }
      }
    });
  } catch (error) {
    console.error('Create admin error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during admin creation'
    });
  }
});

// Update admin
router.put('/:id', adminAuth, checkRole(['super_admin', 'admin']), commonValidation.mongoId, async (req, res) => {
  try {
    const { firstName, lastName, email, role, permissions, isActive } = req.body;
    
    // Check if admin exists
    const admin = await Admin.findById(req.params.id);
    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }
    
    // Check permissions
    if (req.admin.role !== 'super_admin') {
      if (req.admin._id.toString() !== req.params.id) {
        return res.status(403).json({
          success: false,
          message: 'Access denied'
        });
      }
      // Regular admins can only update their own basic info
      if (role || permissions || isActive !== undefined) {
        return res.status(403).json({
          success: false,
          message: 'Insufficient permissions'
        });
      }
    }
    
    // Check if email is already taken by another admin
    if (email && email !== admin.email) {
      const existingAdmin = await Admin.findOne({ email });
      if (existingAdmin) {
        return res.status(400).json({
          success: false,
          message: 'Email already taken by another admin'
        });
      }
    }
    
    // Update admin
    const updateData = {};
    if (firstName !== undefined) updateData.firstName = firstName;
    if (lastName !== undefined) updateData.lastName = lastName;
    if (email !== undefined) updateData.email = email;
    if (role !== undefined) updateData.role = role;
    if (permissions !== undefined) updateData.permissions = permissions;
    if (isActive !== undefined) updateData.isActive = isActive;
    
    const updatedAdmin = await Admin.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');
    
    res.json({
      success: true,
      message: 'Admin updated successfully',
      data: {
        admin: updatedAdmin
      }
    });
  } catch (error) {
    console.error('Update admin error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during admin update'
    });
  }
});

// Delete admin (Super Admin only)
router.delete('/:id', adminAuth, checkRole('super_admin'), commonValidation.mongoId, async (req, res) => {
  try {
    // Prevent self-deletion
    if (req.admin._id.toString() === req.params.id) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete your own account'
      });
    }
    
    const admin = await Admin.findByIdAndDelete(req.params.id);
    
    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Admin deleted successfully'
    });
  } catch (error) {
    console.error('Delete admin error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during admin deletion'
    });
  }
});

// Toggle admin active status (Super Admin only)
router.patch('/:id/toggle-status', adminAuth, checkRole('super_admin'), commonValidation.mongoId, async (req, res) => {
  try {
    // Prevent self-deactivation
    if (req.admin._id.toString() === req.params.id) {
      return res.status(400).json({
        success: false,
        message: 'Cannot deactivate your own account'
      });
    }
    
    const admin = await Admin.findById(req.params.id);
    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }
    
    admin.isActive = !admin.isActive;
    await admin.save();
    
    res.json({
      success: true,
      message: `Admin ${admin.isActive ? 'activated' : 'deactivated'} successfully`,
      data: {
        admin: {
          id: admin._id,
          isActive: admin.isActive
        }
      }
    });
  } catch (error) {
    console.error('Toggle admin status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get admin statistics
router.get('/stats/overview', adminAuth, checkRole('super_admin'), async (req, res) => {
  try {
    const totalAdmins = await Admin.countDocuments();
    const activeAdmins = await Admin.countDocuments({ isActive: true });
    const superAdmins = await Admin.countDocuments({ role: 'super_admin' });
    const regularAdmins = await Admin.countDocuments({ role: 'admin' });
    const moderators = await Admin.countDocuments({ role: 'moderator' });
    const contentManagers = await Admin.countDocuments({ role: 'content_manager' });
    
    // Recent logins (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const recentLogins = await Admin.countDocuments({
      lastLogin: { $gte: sevenDaysAgo }
    });
    
    res.json({
      success: true,
      data: {
        totalAdmins,
        activeAdmins,
        inactiveAdmins: totalAdmins - activeAdmins,
        roleDistribution: {
          superAdmins,
          regularAdmins,
          moderators,
          contentManagers
        },
        recentLogins
      }
    });
  } catch (error) {
    console.error('Admin stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
