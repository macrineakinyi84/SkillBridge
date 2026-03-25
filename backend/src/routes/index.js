const express = require('express');

const authRoutes = require('./auth.routes');
const assessmentRoutes = require('./assessment.routes');
const userRoutes = require('./user.routes');
const adminRoutes = require('./admin.routes');
const portfolioRoutes = require('./portfolio.routes');
const employerRoutes = require('./employer.routes');

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/assessments', assessmentRoutes);
router.use('/users', userRoutes);
router.use('/admin', adminRoutes);
router.use('/portfolio', portfolioRoutes);
router.use('/employer', employerRoutes);

module.exports = router;

