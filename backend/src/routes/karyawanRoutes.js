const router = require('express').Router();
const karyawanController = require('../controllers/karyawanController');
const { verifyToken, isAdmin } = require('../middleware/auth');

router.get('/', verifyToken, isAdmin, karyawanController.daftarKaryawan);
router.get('/:id', verifyToken, isAdmin, karyawanController.detailKaryawan);
router.post('/', verifyToken, isAdmin, karyawanController.tambahKaryawan);
router.put('/:id', verifyToken, isAdmin, karyawanController.updateKaryawan);
router.delete('/:id', verifyToken, isAdmin, karyawanController.hapusKaryawan);

module.exports = router;
