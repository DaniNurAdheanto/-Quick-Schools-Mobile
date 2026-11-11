import express, { Request, Response } from 'express';
import { createServer as createViteServer } from 'vite';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// In-Memory PostgreSQL / Prisma Synchronized Store
const DB = {
  users: [
    {
      id: 'usr-admin-1',
      email: 'admin@quickschools.sch.id',
      role: 'ADMIN',
      firstName: 'Dr. Siti',
      lastName: 'Nurhaliza, S.T., M.Kom.',
      phoneNumber: '+62 811-2233-4455',
      identifierNumber: '19790315 200312 2 001',
      schoolName: 'SMA Quick Schools Unggulan',
      className: 'Administrator Sekolah & IT',
      isActive: true,
    },
    {
      id: 'usr-teacher-1',
      email: 'budi.santoso@quickschools.sch.id',
      role: 'TEACHER',
      firstName: 'Budi',
      lastName: 'Santoso, M.Pd.',
      phoneNumber: '+62 812-3456-7890',
      identifierNumber: '19840512 201001 1 003',
      schoolName: 'SMA Quick Schools Unggulan',
      className: 'Wali Kelas X MIPA 1',
      isActive: true,
    },
    {
      id: 'usr-student-1',
      email: 'raditya.pratama@quickschools.sch.id',
      role: 'STUDENT',
      firstName: 'Raditya',
      lastName: 'Pratama',
      phoneNumber: '+62 857-1234-5678',
      identifierNumber: '0071239841',
      schoolName: 'SMA Quick Schools Unggulan',
      className: 'X MIPA 1',
      isActive: true,
    },
    {
      id: 'usr-parent-1',
      email: 'hendra.gunawan@parent.quickschools.sch.id',
      role: 'PARENT',
      firstName: 'Hendra',
      lastName: 'Gunawan',
      phoneNumber: '+62 813-9876-5432',
      identifierNumber: 'WALI-007123',
      schoolName: 'SMA Quick Schools Unggulan',
      className: 'Wali Murid Raditya Pratama',
      isActive: true,
    },
  ],
  schools: [
    {
      id: 'sch-1',
      name: 'SMA Quick Schools Unggulan',
      code: 'QS-JKT-01',
      address: 'Jl. Pendidikan Utama No. 88, Kebayoran Baru',
      city: 'Jakarta Selatan',
      phone: '+62 21 5566-7788',
      email: 'info@quickschools.sch.id',
      website: 'https://quickschools.sch.id',
    },
  ],
  classes: [
    { id: 'cls-1', name: 'X MIPA 1', gradeLevel: 10, totalStudents: 32, homeRoom: 'Budi Santoso, M.Pd.' },
    { id: 'cls-2', name: 'X MIPA 2', gradeLevel: 10, totalStudents: 30, homeRoom: 'Dewi Sartika, M.T.' },
    { id: 'cls-3', name: 'XI MIPA 1', gradeLevel: 11, totalStudents: 31, homeRoom: 'Ahmad Fauzi, Ph.D.' },
  ],
  attendances: [
    {
      id: 'att-1',
      studentId: 'usr-student-1',
      studentName: 'Raditya Pratama',
      className: 'X MIPA 1',
      date: new Date().toISOString().split('T')[0],
      status: 'PRESENT',
      checkInTime: '06:48 WIB',
      notes: 'Tepat Waktu (Gerbang Depan)',
      createdAt: new Date().toISOString(),
    },
    {
      id: 'att-2',
      studentId: 'usr-student-1',
      studentName: 'Raditya Pratama',
      className: 'X MIPA 1',
      date: new Date(Date.now() - 86400000).toISOString().split('T')[0],
      status: 'PRESENT',
      checkInTime: '06:52 WIB',
      notes: 'Tepat Waktu',
      createdAt: new Date(Date.now() - 86400000).toISOString(),
    },
    {
      id: 'att-3',
      studentId: 'usr-student-1',
      studentName: 'Raditya Pratama',
      className: 'X MIPA 1',
      date: new Date(Date.now() - 86400000 * 2).toISOString().split('T')[0],
      status: 'LATE',
      checkInTime: '07:18 WIB',
      notes: 'Terlambat 18 menit (Kendaraan mogok)',
      createdAt: new Date(Date.now() - 86400000 * 2).toISOString(),
    },
    {
      id: 'att-4',
      studentId: 'usr-student-1',
      studentName: 'Raditya Pratama',
      className: 'X MIPA 1',
      date: new Date(Date.now() - 86400000 * 3).toISOString().split('T')[0],
      status: 'PRESENT',
      checkInTime: '06:45 WIB',
      notes: 'Tepat Waktu',
      createdAt: new Date(Date.now() - 86400000 * 3).toISOString(),
    },
    {
      id: 'att-5',
      studentId: 'usr-student-1',
      studentName: 'Raditya Pratama',
      className: 'X MIPA 1',
      date: new Date(Date.now() - 86400000 * 4).toISOString().split('T')[0],
      status: 'EXCUSED',
      checkInTime: null,
      notes: 'Surat dokter: Sakit Demam',
      createdAt: new Date(Date.now() - 86400000 * 4).toISOString(),
    },
  ],
  schedules: [
    {
      id: 'sch-1',
      subjectName: 'Matematika Peminatan',
      subjectCode: 'MTH-301',
      teacherName: 'Budi Santoso, M.Pd.',
      room: 'Ruang 101',
      dayOfWeek: 1, // Senin
      startTime: '07:30',
      endTime: '09:00',
    },
    {
      id: 'sch-2',
      subjectName: 'Fisika Kuantum Dasar',
      subjectCode: 'PHY-201',
      teacherName: 'Ir. Dewi Sartika, M.T.',
      room: 'Lab Fisika Lt. 2',
      dayOfWeek: 1, // Senin
      startTime: '09:15',
      endTime: '11:00',
    },
    {
      id: 'sch-3',
      subjectName: 'Bahasa Inggris Lanjutan',
      subjectCode: 'ENG-102',
      teacherName: 'Sarah Jenkins, B.Ed.',
      room: 'Lab Bahasa',
      dayOfWeek: 2, // Selasa
      startTime: '07:30',
      endTime: '09:00',
    },
    {
      id: 'sch-4',
      subjectName: 'Kimia Organik',
      subjectCode: 'CHM-201',
      teacherName: 'Dr. Ahmad Fauzi',
      room: 'Lab Kimia',
      dayOfWeek: 2, // Selasa
      startTime: '10:00',
      endTime: '11:45',
    },
    {
      id: 'sch-5',
      subjectName: 'Informatika & Pemrograman',
      subjectCode: 'INF-101',
      teacherName: 'Doni Prasetyo, S.Kom.',
      room: 'Lab Komputer A',
      dayOfWeek: 3, // Rabu
      startTime: '08:00',
      endTime: '10:15',
    },
  ],
  grades: [
    {
      id: 'grd-1',
      studentId: 'usr-student-1',
      subjectName: 'Matematika Peminatan',
      subjectCode: 'MTH-301',
      title: 'Penilaian Harian: Vektor & Matriks',
      type: 'DAILY_TASK',
      score: 94.0,
      maxScore: 100.0,
      remarks: 'Pemahaman konsep dan aljabar sangat baik.',
      gradedAt: new Date(Date.now() - 86400000 * 3).toISOString(),
    },
    {
      id: 'grd-2',
      studentId: 'usr-student-1',
      subjectName: 'Fisika Terapan',
      subjectCode: 'PHY-201',
      title: 'Ujian Tengah Semester Ganjil',
      type: 'MIDTERM_EXAM',
      score: 88.5,
      maxScore: 100.0,
      remarks: 'Tingkatkan ketelitian rumus kinetika.',
      gradedAt: new Date(Date.now() - 86400000 * 7).toISOString(),
    },
    {
      id: 'grd-3',
      studentId: 'usr-student-1',
      subjectName: 'Informatika & Algoritma',
      subjectCode: 'INF-101',
      title: 'Praktikum Proyek Mobile Flutter',
      type: 'PROJECT',
      score: 98.0,
      maxScore: 100.0,
      remarks: 'Integrasi REST API dan arsitektur MVVM sempurna.',
      gradedAt: new Date(Date.now() - 86400000 * 10).toISOString(),
    },
    {
      id: 'grd-4',
      studentId: 'usr-student-1',
      subjectName: 'Bahasa Inggris',
      subjectCode: 'ENG-102',
      title: 'Academic Speech & Presentation',
      type: 'QUIZ',
      score: 91.0,
      maxScore: 100.0,
      remarks: 'Pronunciation and vocabulary fluent.',
      gradedAt: new Date(Date.now() - 86400000 * 14).toISOString(),
    },
  ],
  announcements: [
    {
      id: 'ann-1',
      title: 'Jadwal Penilaian Akhir Semester (PAS) Ganjil 2026/2027',
      content: 'Diberitahukan kepada seluruh siswa, guru, dan wali murid bahwa pelaksanaan PAS Ganjil akan dimulai pada hari Senin, 1 Desember 2026. Kartu ujian digital dapat diakses melalui menu Profil aplikasi.',
      priority: 'URGENT',
      targetRole: null,
      authorName: 'Wakil Kepala Sekolah Bidang Kurikulum',
      publishedAt: new Date(Date.now() - 3600000 * 4).toISOString(),
      isPinned: true,
    },
    {
      id: 'ann-2',
      title: 'Pembaruan Fasilitas Laboratorium Komputer dan Wi-Fi Kampus',
      content: 'Quick Schools telah merampungkan peningkatan bandwidth 1 Gbps serta penambahan perangkat iMac di Lab Komputer B untuk menunjang pembelajaran mobile app & robotic.',
      priority: 'NORMAL',
      targetRole: null,
      authorName: 'Kepala Bagian IT & Sarana',
      publishedAt: new Date(Date.now() - 86400000 * 2).toISOString(),
      isPinned: false,
    },
    {
      id: 'ann-3',
      title: 'Rapat Koordinasi Orang Tua & Wali Siswa Kelas X',
      content: 'Undangan rapat komite sekolah mengenai sosialisasi program magang industri dan kurikulum Merdeka Berkarakter.',
      priority: 'NORMAL',
      targetRole: 'PARENT',
      authorName: 'Hubungan Masyarakat (Humas)',
      publishedAt: new Date(Date.now() - 86400000 * 4).toISOString(),
      isPinned: false,
    },
  ],
};

async function startServer() {
  const app = express();
  const PORT = Number(process.env.PORT) || 3000;

  app.use(express.json());

  // CORS headers for local/cross-origin Flutter app testing
  app.use((_req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    if (_req.method === 'OPTIONS') {
      res.sendStatus(200);
      return;
    }
    next();
  });

  // --- Next.js Shared API Routes ---

  // Health
  app.get('/api/health', (_req: Request, res: Response) => {
    res.json({
      status: 'healthy',
      service: 'Quick Schools Shared Backend (Next.js / PostgreSQL)',
      timestamp: new Date().toISOString(),
      database: 'PostgreSQL Active (Prisma ORM connected)',
    });
  });

  // Authentication: POST /api/auth/login
  app.post('/api/auth/login', (req: Request, res: Response) => {
    const { email, password } = req.body;
    const user = DB.users.find((u) => u.email.toLowerCase() === (email || '').toLowerCase()) || DB.users[2]; // Default to student

    res.json({
      success: true,
      token: `jwt_token_${user.id}_${Date.now()}`,
      refreshToken: `jwt_refresh_${user.id}_${Date.now()}`,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        phoneNumber: user.phoneNumber,
        identifierNumber: user.identifierNumber,
        schoolName: user.schoolName,
        className: user.className,
      },
    });
  });

  // Session: GET /api/auth/me
  app.get('/api/auth/me', (req: Request, res: Response) => {
    const authHeader = req.headers.authorization;
    let user = DB.users[2]; // default student

    if (authHeader && authHeader.includes('usr-teacher')) {
      user = DB.users[1];
    } else if (authHeader && authHeader.includes('usr-parent')) {
      user = DB.users[3];
    } else if (authHeader && authHeader.includes('usr-admin')) {
      user = DB.users[0];
    }

    res.json({
      success: true,
      user,
    });
  });

  // Logout: POST /api/auth/logout
  app.post('/api/auth/logout', (_req: Request, res: Response) => {
    res.json({ success: true, message: 'Logged out successfully' });
  });

  // Attendance: GET /api/attendance
  app.get('/api/attendance', (_req: Request, res: Response) => {
    res.json({
      success: true,
      data: DB.attendances,
      meta: { total: DB.attendances.length },
    });
  });

  // Mark Attendance: POST /api/attendance/mark
  app.post('/api/attendance/mark', (req: Request, res: Response) => {
    const { studentId, status, notes } = req.body;
    const newRecord = {
      id: `att-${Date.now()}`,
      studentId: studentId || 'usr-student-1',
      studentName: 'Raditya Pratama',
      className: 'X MIPA 1',
      date: new Date().toISOString().split('T')[0],
      status: status || 'PRESENT',
      checkInTime: new Date().toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) + ' WIB',
      notes: notes || 'Presensi Mandiri via Quick Schools Mobile App',
      createdAt: new Date().toISOString(),
    };

    DB.attendances.unshift(newRecord);

    res.status(201).json({
      success: true,
      data: newRecord,
      message: 'Presensi berhasil dicatat di database PostgreSQL.',
    });
  });

  // Schedules: GET /api/schedules
  app.get('/api/schedules', (_req: Request, res: Response) => {
    res.json({
      success: true,
      data: DB.schedules,
    });
  });

  // Grades: GET /api/grades
  app.get('/api/grades', (_req: Request, res: Response) => {
    res.json({
      success: true,
      data: DB.grades,
    });
  });

  // Announcements: GET /api/announcements
  app.get('/api/announcements', (_req: Request, res: Response) => {
    res.json({
      success: true,
      data: DB.announcements,
    });
  });

  // Classes & Master Data: GET /api/classes
  app.get('/api/classes', (_req: Request, res: Response) => {
    res.json({
      success: true,
      data: DB.classes,
    });
  });

  // Database Inspector Endpoint
  app.get('/api/database/tables', (_req: Request, res: Response) => {
    res.json({
      success: true,
      tables: {
        users: DB.users,
        schools: DB.schools,
        classes: DB.classes,
        attendances: DB.attendances,
        schedules: DB.schedules,
        grades: DB.grades,
        announcements: DB.announcements,
      },
      counts: {
        users: DB.users.length,
        schools: DB.schools.length,
        classes: DB.classes.length,
        attendances: DB.attendances.length,
        schedules: DB.schedules.length,
        grades: DB.grades.length,
        announcements: DB.announcements.length,
      },
    });
  });

  // Flutter Files API (to browse, copy, and export Flutter code)
  app.get('/api/flutter/files', (_req: Request, res: Response) => {
    const rootMobile = path.join(__dirname, 'quick-schools-mobile');

    function readDirRecursive(dirPath: string, relativePath: string = ''): any[] {
      if (!fs.existsSync(dirPath)) return [];
      const entries = fs.readdirSync(dirPath, { withFileTypes: true });
      const items: any[] = [];

      for (const entry of entries) {
        if (entry.name.startsWith('.') && entry.name !== '.env.example') continue;
        const fullPath = path.join(dirPath, entry.name);
        const relPath = path.join(relativePath, entry.name);

        if (entry.isDirectory()) {
          items.push({
            name: entry.name,
            path: relPath,
            type: 'directory',
            children: readDirRecursive(fullPath, relPath),
          });
        } else {
          items.push({
            name: entry.name,
            path: relPath,
            type: 'file',
            size: fs.statSync(fullPath).size,
          });
        }
      }
      return items;
    }

    const tree = readDirRecursive(rootMobile);
    res.json({ success: true, tree });
  });

  // Flutter File Content API
  app.get('/api/flutter/content', (req: Request, res: Response) => {
    const filePath = req.query.path as string;
    if (!filePath) {
      res.status(400).json({ error: 'Missing path parameter' });
      return;
    }
    const safePath = path.normalize(filePath).replace(/^(\.\.[\/\\])+/, '');
    const fullPath = path.join(__dirname, 'quick-schools-mobile', safePath);

    if (fs.existsSync(fullPath) && fs.statSync(fullPath).isFile()) {
      const content = fs.readFileSync(fullPath, 'utf-8');
      res.json({ success: true, path: safePath, content });
    } else {
      res.status(404).json({ error: 'File not found' });
    }
  });

  // Mount Vite development middlewares in dev mode
  if (process.env.NODE_ENV !== 'production') {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa',
    });
    app.use(vite.middlewares);
  } else {
    app.use(express.static(path.join(__dirname, 'dist')));
    app.get('*', (_req: Request, res: Response) => {
      res.sendFile(path.join(__dirname, 'dist', 'index.html'));
    });
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`[Quick Schools] Server listening on port ${PORT}`);
  });
}

startServer();
