const bcrypt = require('bcryptjs');
const sequelize = require('../src/config/db');
const User = require('../src/models/User');

async function createAdmin() {
  try {
    await sequelize.authenticate();
    console.log('DB connected');

    const password = process.env.ADMIN_PASS || 'admin123';
    const hashed = await bcrypt.hash(password, 10);

    const [user, created] = await User.findOrCreate({
      where: { email: process.env.ADMIN_EMAIL || 'admin@example.com' },
      defaults: {
        nama: process.env.ADMIN_NAME || 'Admin',
        email: process.env.ADMIN_EMAIL || 'admin@example.com',
        password: hashed,
        role: 'admin',
      },
    });

    if (created) console.log('Admin user created:', user.email);
    else console.log('Admin user already exists:', user.email);

    process.exit(0);
  } catch (err) {
    console.error('Failed to create admin:', err.message);
    process.exit(1);
  }
}

createAdmin();
