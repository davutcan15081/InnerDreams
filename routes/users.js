const express = require('express');
const User = require('../models/User');
const Dream = require('../models/Dream');
const { commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission } = require('../middleware/auth');

const router = express.Router();

// Get all users
router.get('/', adminAuth, checkPermission('users'), async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search, 
      subscriptionStatus, 
      isActive,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;
    
    let query = {};
    
    if (search) {
      query.$or = [
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (subscriptionStatus) query.subscriptionStatus = subscriptionStatus;
    if (isActive !== undefined) query.isActive = isActive === 'true';
    
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    const users = await User.find(query)
      .select('-password')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await User.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        users,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single user
router.get('/:id', adminAuth, checkPermission('users'), commonValidation.mongoId, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.json({
      success: true,
      data: {
        user
      }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Update user
router.put('/:id', adminAuth, checkPermission('users'), commonValidation.mongoId, async (req, res) => {
  try {
    const { firstName, lastName, email, phone, subscriptionStatus, isActive } = req.body;
    
    const updateData = {};
    if (firstName !== undefined) updateData.firstName = firstName;
    if (lastName !== undefined) updateData.lastName = lastName;
    if (email !== undefined) updateData.email = email;
    if (phone !== undefined) updateData.phone = phone;
    if (subscriptionStatus !== undefined) updateData.subscriptionStatus = subscriptionStatus;
    if (isActive !== undefined) updateData.isActive = isActive;
    
    // Check if email is already taken by another user
    if (email) {
      const existingUser = await User.findOne({ email, _id: { $ne: req.params.id } });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'Email already taken by another user'
        });
      }
    }
    
    const user = await User.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'User updated successfully',
      data: {
        user
      }
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during user update'
    });
  }
});

// Delete user
router.delete('/:id', adminAuth, checkPermission('users'), commonValidation.mongoId, async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    // Also delete user's dreams
    await Dream.deleteMany({ user: req.params.id });
    
    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during user deletion'
    });
  }
});

// Toggle user status
router.patch('/:id/toggle-status', adminAuth, checkPermission('users'), commonValidation.mongoId, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    user.isActive = !user.isActive;
    await user.save();
    
    res.json({
      success: true,
      message: `User ${user.isActive ? 'activated' : 'deactivated'} successfully`,
      data: {
        user: {
          id: user._id,
          isActive: user.isActive
        }
      }
    });
  } catch (error) {
    console.error('Toggle user status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Update subscription status
router.patch('/:id/subscription', adminAuth, checkPermission('users'), commonValidation.mongoId, async (req, res) => {
  try {
    const { subscriptionStatus, subscriptionExpiry } = req.body;
    
    if (!subscriptionStatus) {
      return res.status(400).json({
        success: false,
        message: 'Subscription status is required'
      });
    }
    
    const validStatuses = ['free', 'premium'];
    if (!validStatuses.includes(subscriptionStatus)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid subscription status'
      });
    }
    
    const updateData = { subscriptionStatus };
    if (subscriptionExpiry) {
      updateData.subscriptionExpiry = new Date(subscriptionExpiry);
    }
    
    const user = await User.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Subscription status updated successfully',
      data: {
        user
      }
    });
  } catch (error) {
    console.error('Update subscription error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get user's dreams
router.get('/:id/dreams', adminAuth, checkPermission('users'), commonValidation.mongoId, async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    
    const dreams = await Dream.find({ user: req.params.id })
      .sort({ dreamDate: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Dream.countDocuments({ user: req.params.id });
    
    res.json({
      success: true,
      data: {
        dreams,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get user dreams error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get user statistics
router.get('/stats/overview', adminAuth, checkPermission('users'), async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ isActive: true });
    const premiumUsers = await User.countDocuments({ subscriptionStatus: 'premium' });
    const freeUsers = await User.countDocuments({ subscriptionStatus: 'free' });
    
    // Recent registrations (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const recentRegistrations = await User.countDocuments({
      createdAt: { $gte: sevenDaysAgo }
    });
    
    // Users with dreams
    const usersWithDreams = await User.countDocuments({
      dreamCount: { $gt: 0 }
    });
    
    // Average dreams per user
    const avgDreamsPerUser = await User.aggregate([
      { $group: { _id: null, avgDreams: { $avg: '$dreamCount' } } }
    ]);
    
    res.json({
      success: true,
      data: {
        totalUsers,
        activeUsers,
        inactiveUsers: totalUsers - activeUsers,
        premiumUsers,
        freeUsers,
        recentRegistrations,
        usersWithDreams,
        usersWithoutDreams: totalUsers - usersWithDreams,
        avgDreamsPerUser: avgDreamsPerUser[0]?.avgDreams || 0
      }
    });
  } catch (error) {
    console.error('User stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
