const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./User');

const Notifikasi = sequelize.define('Notifikasi', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  tipe: {
    type: DataTypes.STRING, // 'absen' | 'cuti' | 'laporan' | 'info'
    allowNull: false,
    defaultValue: 'info',
  },
  judul: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  pesan: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  cta_text: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  data: {
    type: DataTypes.TEXT, // JSON stringified data
    allowNull: true,
  },
  is_read: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  tableName: 'notifikasi',
  timestamps: true,
});

Notifikasi.belongsTo(User, { foreignKey: 'user_id' });
User.hasMany(Notifikasi, { foreignKey: 'user_id' });

module.exports = Notifikasi;
