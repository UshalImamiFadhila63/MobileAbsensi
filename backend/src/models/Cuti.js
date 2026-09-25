const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./User');

const Cuti = sequelize.define('Cuti', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  jenis_cuti: {
    type: DataTypes.STRING, // misal: sakit, tahunan, izin, dll
    allowNull: false,
  },
  tanggal_mulai: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  tanggal_selesai: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  alasan: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  lampiran: DataTypes.STRING, // path file pendukung (opsional)
  status: {
    type: DataTypes.ENUM('menunggu', 'diterima', 'ditolak'),
    defaultValue: 'menunggu',
  },
  catatan_admin: DataTypes.TEXT,
  diproses_oleh: DataTypes.INTEGER, // user_id admin
}, {
  tableName: 'cuti',
  timestamps: true,
});

Cuti.belongsTo(User, { foreignKey: 'user_id' });
User.hasMany(Cuti, { foreignKey: 'user_id' });

module.exports = Cuti;
