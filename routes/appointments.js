const express = require('express');
const Appointment = require('../models/Appointment');
const { commonValidation } = require('../middleware/validation');
const { adminAuth, checkPermission } = require('../middleware/auth');

const router = express.Router();

// Get all appointments
router.get('/', adminAuth, checkPermission('appointments'), async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      status, 
      paymentStatus, 
      expert, 
      user,
      dateFrom,
      dateTo,
      sortBy = 'appointmentDate',
      sortOrder = 'desc'
    } = req.query;
    
    let query = {};
    
    if (status) query.status = status;
    if (paymentStatus) query.paymentStatus = paymentStatus;
    if (expert) query.expert = expert;
    if (user) query.user = user;
    
    if (dateFrom || dateTo) {
      query.appointmentDate = {};
      if (dateFrom) query.appointmentDate.$gte = new Date(dateFrom);
      if (dateTo) query.appointmentDate.$lte = new Date(dateTo);
    }
    
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;
    
    const appointments = await Appointment.find(query)
      .populate('user', 'firstName lastName email')
      .populate('expert', 'firstName lastName profileImage')
      .populate('session', 'title type category')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Appointment.countDocuments(query);
    
    res.json({
      success: true,
      data: {
        appointments,
        pagination: {
          current: parseInt(page),
          pages: Math.ceil(total / limit),
          total
        }
      }
    });
  } catch (error) {
    console.error('Get appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get single appointment
router.get('/:id', adminAuth, checkPermission('appointments'), commonValidation.mongoId, async (req, res) => {
  try {
    const appointment = await Appointment.findById(req.params.id)
      .populate('user', 'firstName lastName email phone')
      .populate('expert', 'firstName lastName email phone profileImage')
      .populate('session', 'title type category duration');
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    res.json({
      success: true,
      data: {
        appointment
      }
    });
  } catch (error) {
    console.error('Get appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Update appointment status
router.patch('/:id/status', adminAuth, checkPermission('appointments'), commonValidation.mongoId, async (req, res) => {
  try {
    const { status, notes } = req.body;
    
    if (!status) {
      return res.status(400).json({
        success: false,
        message: 'Status is required'
      });
    }
    
    const validStatuses = ['pending', 'confirmed', 'cancelled', 'completed', 'no_show'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }
    
    const appointment = await Appointment.findByIdAndUpdate(
      req.params.id,
      { 
        status,
        'notes.admin': notes || ''
      },
      { new: true, runValidators: true }
    );
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Appointment status updated successfully',
      data: {
        appointment
      }
    });
  } catch (error) {
    console.error('Update appointment status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Update payment status
router.patch('/:id/payment', adminAuth, checkPermission('appointments'), commonValidation.mongoId, async (req, res) => {
  try {
    const { paymentStatus, paymentMethod, paymentId } = req.body;
    
    if (!paymentStatus) {
      return res.status(400).json({
        success: false,
        message: 'Payment status is required'
      });
    }
    
    const validPaymentStatuses = ['pending', 'paid', 'refunded', 'failed'];
    if (!validPaymentStatuses.includes(paymentStatus)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment status'
      });
    }
    
    const updateData = { paymentStatus };
    if (paymentMethod) updateData.paymentMethod = paymentMethod;
    if (paymentId) updateData.paymentId = paymentId;
    
    const appointment = await Appointment.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Payment status updated successfully',
      data: {
        appointment
      }
    });
  } catch (error) {
    console.error('Update payment status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Cancel appointment
router.patch('/:id/cancel', adminAuth, checkPermission('appointments'), commonValidation.mongoId, async (req, res) => {
  try {
    const { reason, refundAmount } = req.body;
    
    const appointment = await Appointment.findById(req.params.id);
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    appointment.status = 'cancelled';
    appointment.cancellation = {
      reason: reason || 'Cancelled by admin',
      cancelledBy: 'admin',
      cancelledAt: new Date(),
      refundAmount: refundAmount || appointment.amount,
      refundStatus: 'pending'
    };
    
    await appointment.save();
    
    res.json({
      success: true,
      message: 'Appointment cancelled successfully',
      data: {
        appointment
      }
    });
  } catch (error) {
    console.error('Cancel appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Reschedule appointment
router.patch('/:id/reschedule', adminAuth, checkPermission('appointments'), commonValidation.mongoId, async (req, res) => {
  try {
    const { newDate, newTime, reason } = req.body;
    
    if (!newDate || !newTime) {
      return res.status(400).json({
        success: false,
        message: 'New date and time are required'
      });
    }
    
    const appointment = await Appointment.findById(req.params.id);
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    appointment.reschedule = {
      originalDate: appointment.appointmentDate,
      originalTime: appointment.startTime,
      newDate: new Date(newDate),
      newTime: newTime,
      reason: reason || 'Rescheduled by admin',
      requestedBy: 'admin',
      requestedAt: new Date(),
      approvedAt: new Date(),
      approvedBy: req.admin._id
    };
    
    appointment.appointmentDate = new Date(newDate);
    appointment.startTime = newTime;
    
    await appointment.save();
    
    res.json({
      success: true,
      message: 'Appointment rescheduled successfully',
      data: {
        appointment
      }
    });
  } catch (error) {
    console.error('Reschedule appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

// Get appointment statistics
router.get('/stats/overview', adminAuth, checkPermission('appointments'), async (req, res) => {
  try {
    const totalAppointments = await Appointment.countDocuments();
    const pendingAppointments = await Appointment.countDocuments({ status: 'pending' });
    const confirmedAppointments = await Appointment.countDocuments({ status: 'confirmed' });
    const completedAppointments = await Appointment.countDocuments({ status: 'completed' });
    const cancelledAppointments = await Appointment.countDocuments({ status: 'cancelled' });
    
    // Status distribution
    const statusStats = await Appointment.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // Payment status distribution
    const paymentStats = await Appointment.aggregate([
      { $group: { _id: '$paymentStatus', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // Monthly appointments
    const monthlyStats = await Appointment.aggregate([
      {
        $group: {
          _id: {
            year: { $year: '$appointmentDate' },
            month: { $month: '$appointmentDate' }
          },
          count: { $sum: 1 }
        }
      },
      { $sort: { '_id.year': -1, '_id.month': -1 } },
      { $limit: 12 }
    ]);
    
    res.json({
      success: true,
      data: {
        totalAppointments,
        pendingAppointments,
        confirmedAppointments,
        completedAppointments,
        cancelledAppointments,
        statusDistribution: statusStats,
        paymentDistribution: paymentStats,
        monthlyStats
      }
    });
  } catch (error) {
    console.error('Appointment stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
});

module.exports = router;
