const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./User');

const Laporan = sequelize.define('Laporan', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  tanggal: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  judul: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  isi_laporan: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  lampiran: DataTypes.STRING,
}, {
  tableName: 'laporan',
  timestamps: true,
});

Laporan.belongsTo(User, { foreignKey: 'user_id' });
User.hasMany(Laporan, { foreignKey: 'user_id' });

module.exports = Laporan;
