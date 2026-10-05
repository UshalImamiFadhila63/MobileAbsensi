const express = require('express');
const router = express.Router();
const notifikasiController = require('../controllers/notifikasiController');
const { verifyToken } = require('../middleware/auth');

router.get('/', verifyToken, notifikasiController.getNotifikasi);
router.put('/read-all', verifyToken, notifikasiController.tandaiSemuaDibaca);
router.put('/:id/read', verifyToken, notifikasiController.tandaiDibaca);

module.exports = router;
