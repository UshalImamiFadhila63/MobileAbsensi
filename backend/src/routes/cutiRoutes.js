const router = require('express').Router();
const cutiController = require('../controllers/cutiController');
const { verifyToken, isAdmin } = require('../middleware/auth');
const { makeUploader } = require('../middleware/upload');

const uploadCuti = makeUploader('cuti');

// karyawan
router.post('/', verifyToken, uploadCuti.single('lampiran'), cutiController.ajukanCuti);
router.get('/saya', verifyToken, cutiController.informasiCutiSaya);

// admin
router.get('/', verifyToken, isAdmin, cutiController.daftarPengajuan);
router.get('/:id', verifyToken, isAdmin, cutiController.detailPengajuan);
router.put('/:id/proses', verifyToken, isAdmin, cutiController.prosesPengajuan);

module.exports = router;
