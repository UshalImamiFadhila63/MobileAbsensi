const router = require('express').Router();
const absensiController = require('../controllers/absensiController');
const { verifyToken, isAdmin } = require('../middleware/auth');
const { makeUploader } = require('../middleware/upload');

const uploadAbsen = makeUploader('absensi');

router.post('/masuk', verifyToken, uploadAbsen.single('foto'), absensiController.absenMasuk);
router.post('/pulang', verifyToken, uploadAbsen.single('foto'), absensiController.absenPulang);
router.get('/status-hari-ini', verifyToken, absensiController.statusHariIni);
router.get('/riwayat', verifyToken, absensiController.riwayatSaya);
router.get('/rekap', verifyToken, isAdmin, absensiController.rekapAdmin);

module.exports = router;
