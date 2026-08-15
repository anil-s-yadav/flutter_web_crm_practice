require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');

async function seedUsers() {
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });

    console.log('Connected to Database. Seeding clean users with VMU format and real profile images...');

    const users = [
      {
        id: 'VMU0001',
        name: 'System Admin',
        email: 'admin@example.com',
        password: 'password123',
        role: 'admin',
        phone: '9820000001',
        alternate_phone: '9820000002',
        profile_image_url: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80',
      },
      {
        id: 'VMU0002',
        name: 'Ajay Gupta',
        email: 'sales@example.com',
        password: 'password123',
        role: 'sales',
        phone: '9820000003',
        alternate_phone: '9820000004',
        profile_image_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      },
      {
        id: 'VMU0003',
        name: 'Anil Shah',
        email: 'sourcing@example.com',
        password: 'password123',
        role: 'sourcing',
        phone: '9820000005',
        alternate_phone: '9820000006',
        profile_image_url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80',
      },
      {
        id: 'VMU0004',
        name: 'Deepak Laale',
        email: 'executive@example.com',
        password: 'password123',
        role: 'executive',
        phone: '9820000007',
        alternate_phone: '9820000008',
        profile_image_url: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&auto=format&fit=crop&q=80',
      },
    ];

    for (const u of users) {
      const hash = await bcrypt.hash(u.password, 10);
      await connection.execute(
        `INSERT INTO users (id, name, email, password_hash, role, phone, alternate_phone, profile_image_url) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?) 
         ON DUPLICATE KEY UPDATE name=?, role=?, password_hash=?, phone=?, alternate_phone=?, profile_image_url=?`,
        [u.id, u.name, u.email, hash, u.role, u.phone, u.alternate_phone, u.profile_image_url, u.name, u.role, hash, u.phone, u.alternate_phone, u.profile_image_url]
      );
      console.log(`Configured user: ${u.id} - ${u.name} (${u.role}) - ${u.email} with avatar ${u.profile_image_url}`);
    }

    console.log('User seeding complete!');
    await connection.end();
  } catch (err) {
    console.error('Error seeding users:', err);
  }
}

if (require.main === module) {
  seedUsers();
}

module.exports = seedUsers;
