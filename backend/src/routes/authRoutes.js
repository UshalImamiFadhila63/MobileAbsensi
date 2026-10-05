const router = require('express').Router();
const authController = require('../controllers/authController');
const { verifyToken } = require('../middleware/auth');
const { makeUploader } = require('../middleware/upload');

const uploadProfil = makeUploader('profil');

router.post('/login', authController.login);
router.post('/logout', verifyToken, authController.logout);
router.get('/profile', verifyToken, authController.getProfile);
router.put('/profile', verifyToken, uploadProfil.single('foto'), authController.updateProfile);
router.put('/ubah-password', verifyToken, authController.ubahPassword);

module.exports = router;

