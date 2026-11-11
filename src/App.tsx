import React, { useState, useEffect } from 'react';
import {
  School,
  Wifi,
  Battery,
  Calendar,
  CheckCircle2,
  Clock,
  BarChart3,
  User,
  Bell,
  RefreshCw,
  LogOut,
  QrCode,
  Award,
  ChevronRight,
  Download,
  Shield,
  Smartphone,
  Check,
  AlertTriangle,
  ArrowLeft,
  X,
  FileCode,
  MapPin,
  Sparkles
} from 'lucide-react';
import JSZip from 'jszip';

export type UserRole = 'STUDENT' | 'TEACHER' | 'PARENT' | 'ADMIN';

export default function App() {
  // Mobile app state
  const [currentScreen, setCurrentScreen] = useState<'splash' | 'login' | 'dashboard'>('dashboard');
  const [activeTab, setActiveTab] = useState<'home' | 'attendance' | 'schedule' | 'grades' | 'profile'>('home');
  const [selectedRole, setSelectedRole] = useState<UserRole>('STUDENT');
  const [deviceFrame, setDeviceFrame] = useState<'ios' | 'android' | 'fullscreen'>('ios');
  
  // Real-time backend data with rich initial state
  const [attendances, setAttendances] = useState<any[]>([
    {
      id: 'att-1',
      studentName: 'Raditya Pratama',
      date: '2026-11-11',
      status: 'PRESENT',
      checkInTime: '06:48 WIB',
      notes: 'Tepat Waktu (Gerbang Depan)',
    },
    {
      id: 'att-2',
      studentName: 'Raditya Pratama',
      date: '2026-11-10',
      status: 'PRESENT',
      checkInTime: '06:52 WIB',
      notes: 'Tepat Waktu',
    },
    {
      id: 'att-3',
      studentName: 'Raditya Pratama',
      date: '2026-11-09',
      status: 'LATE',
      checkInTime: '07:18 WIB',
      notes: 'Terlambat 18 menit (Kendaraan mogok)',
    },
  ]);
  const [schedules, setSchedules] = useState<any[]>([
    {
      id: 'sch-1',
      subjectName: 'Matematika Peminatan',
      subjectCode: 'MTH-301',
      teacherName: 'Budi Santoso, M.Pd.',
      room: 'Ruang 101',
      dayOfWeek: 1,
      startTime: '07:30',
      endTime: '09:00',
    },
    {
      id: 'sch-2',
      subjectName: 'Fisika Kuantum Dasar',
      subjectCode: 'PHY-201',
      teacherName: 'Ir. Dewi Sartika, M.T.',
      room: 'Lab Fisika Lt. 2',
      dayOfWeek: 1,
      startTime: '09:15',
      endTime: '11:00',
    },
    {
      id: 'sch-3',
      subjectName: 'Bahasa Inggris Lanjutan',
      subjectCode: 'ENG-102',
      teacherName: 'Sarah Jenkins, B.Ed.',
      room: 'Lab Bahasa',
      dayOfWeek: 2,
      startTime: '07:30',
      endTime: '09:00',
    },
  ]);
  const [grades, setGrades] = useState<any[]>([
    {
      id: 'grd-1',
      subjectName: 'Matematika Peminatan',
      title: 'Penilaian Harian: Vektor & Matriks',
      score: 94.0,
      maxScore: 100.0,
      remarks: 'Pemahaman konsep aljabar sangat baik.',
    },
    {
      id: 'grd-2',
      subjectName: 'Fisika Terapan',
      title: 'Ujian Tengah Semester Ganjil',
      score: 88.5,
      maxScore: 100.0,
      remarks: 'Tingkatkan ketelitian kinetika.',
    },
    {
      id: 'grd-3',
      subjectName: 'Informatika & Pemrograman',
      title: 'Proyek Mobile Flutter',
      score: 98.0,
      maxScore: 100.0,
      remarks: 'Integrasi REST API sempurna.',
    },
  ]);
  const [announcements, setAnnouncements] = useState<any[]>([
    {
      id: 'ann-1',
      title: 'Jadwal Penilaian Akhir Semester (PAS) Ganjil',
      content: 'Pelaksanaan PAS Ganjil dimulai Senin, 1 Desember 2026. Kartu ujian digital dapat diakses di menu Profil.',
      priority: 'URGENT',
      authorName: 'Wakil Kepala Sekolah Bidang Kurikulum',
      publishedAt: new Date().toISOString(),
    },
    {
      id: 'ann-2',
      title: 'Peningkatan Fasilitas Lab Komputer & Wi-Fi',
      content: 'Peningkatan bandwidth 1 Gbps dan penambahan workstation untuk pembelajaran mobile app.',
      priority: 'NORMAL',
      authorName: 'Bagian IT & Sarana',
      publishedAt: new Date().toISOString(),
    },
  ]);
  const [isLoading, setIsLoading] = useState(false);
  const [isCheckingIn, setIsCheckingIn] = useState(false);
  const [checkInSuccess, setCheckInSuccess] = useState(false);
  const [selectedDay, setSelectedDay] = useState<number>(1); // 1 = Senin
  const [showAnnouncementsSheet, setShowAnnouncementsSheet] = useState(false);
  const [isExportingZip, setIsExportingZip] = useState(false);
  const [zipSuccess, setZipSuccess] = useState(false);

  // Fetch from shared Next.js backend
  const fetchBackendData = async () => {
    setIsLoading(true);
    try {
      const [attRes, schRes, grdRes, annRes] = await Promise.all([
        fetch('/api/attendance').then(r => r.json()),
        fetch('/api/schedules').then(r => r.json()),
        fetch('/api/grades').then(r => r.json()),
        fetch('/api/announcements').then(r => r.json()),
      ]);

      if (attRes.data) setAttendances(attRes.data);
      if (schRes.data) setSchedules(schRes.data);
      if (grdRes.data) setGrades(grdRes.data);
      if (annRes.data) setAnnouncements(annRes.data);
    } catch (err) {
      console.error('Error fetching backend data:', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchBackendData();
  }, []);

  // Handle Mark Attendance
  const handleMarkAttendance = async () => {
    setIsCheckingIn(true);
    try {
      const res = await fetch('/api/attendance/mark', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          studentId: selectedRole === 'STUDENT' ? 'usr-student-1' : 'usr-teacher-1',
          status: 'PRESENT',
          notes: 'Presensi Mandiri via Quick Schools Mobile (GPS Validated)',
        }),
      });
      const data = await res.json();
      if (data.success) {
        setCheckInSuccess(true);
        await fetchBackendData();
        setTimeout(() => setCheckInSuccess(false), 3000);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setIsCheckingIn(false);
    }
  };

  // Export full Flutter (Dart) project as ZIP archive
  const handleExportFlutterZip = async () => {
    setIsExportingZip(true);
    try {
      const res = await fetch('/api/flutter/files');
      const data = await res.json();
      const zip = new JSZip();
      const folder = zip.folder('quick-schools-mobile');

      const addNodesToZip = async (nodes: any[]) => {
        for (const node of nodes) {
          if (node.type === 'file') {
            try {
              const fileRes = await fetch(`/api/flutter/content?path=${encodeURIComponent(node.path)}`);
              const fileData = await fileRes.json();
              folder?.file(node.path, fileData.content || '');
            } catch (e) {
              console.error(e);
            }
          } else if (node.type === 'directory' && node.children) {
            await addNodesToZip(node.children);
          }
        }
      };

      if (data.tree) {
        await addNodesToZip(data.tree);
      }

      const blob = await zip.generateAsync({ type: 'blob' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'quick-schools-mobile.zip';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);

      setZipSuccess(true);
      setTimeout(() => setZipSuccess(false), 3000);
    } catch (err) {
      console.error('Failed to export Flutter project:', err);
    } finally {
      setIsExportingZip(false);
    }
  };

  // User Profiles according to active RBAC role
  const userProfiles: Record<UserRole, any> = {
    STUDENT: {
      name: 'Raditya Pratama',
      roleTitle: 'Siswa Kelas X MIPA 1',
      idNumber: 'NISN: 0071239841',
      avatar: 'RP',
      school: 'SMA Quick Schools Unggulan',
      email: 'raditya.pratama@quickschools.sch.id',
    },
    TEACHER: {
      name: 'Budi Santoso, M.Pd.',
      roleTitle: 'Wali Kelas X MIPA 1 & Guru Matematika',
      idNumber: 'NIP: 19840512 201001 1 003',
      avatar: 'BS',
      school: 'SMA Quick Schools Unggulan',
      email: 'budi.santoso@quickschools.sch.id',
    },
    PARENT: {
      name: 'Hendra Gunawan',
      roleTitle: 'Orang Tua Raditya Pratama (X MIPA 1)',
      idNumber: 'ID Wali: WALI-007123',
      avatar: 'HG',
      school: 'SMA Quick Schools Unggulan',
      email: 'hendra.gunawan@parent.quickschools.sch.id',
    },
    ADMIN: {
      name: 'Dr. Siti Nurhaliza, M.Kom.',
      roleTitle: 'Administrator Sekolah & IT',
      idNumber: 'NIP: 19790315 200312 2 001',
      avatar: 'SN',
      school: 'SMA Quick Schools Unggulan',
      email: 'admin@quickschools.sch.id',
    },
  };

  const currentUser = userProfiles[selectedRole];

  return (
    <div className="min-h-screen bg-[#070A12] text-slate-100 flex flex-col items-center justify-center p-0 sm:p-4 select-none font-sans">
      
      {/* Top Mobile Frame Controller (Only visible on tablet/desktop viewports) */}
      <div className="hidden sm:flex items-center justify-between w-full max-w-[400px] mb-2 px-3 text-xs">
        <div className="flex items-center gap-1.5 text-slate-400">
          <Smartphone className="w-3.5 h-3.5 text-[#7B4DFF]" />
          <span className="font-semibold text-white">Quick Schools Mobile</span>
        </div>

        <div className="flex items-center gap-1 bg-slate-900/90 p-0.5 rounded-lg border border-slate-800 text-[11px]">
          <button
            onClick={() => setDeviceFrame('ios')}
            className={`px-2 py-0.5 rounded-md font-medium transition-all ${
              deviceFrame === 'ios' ? 'bg-[#531FFF] text-white' : 'text-slate-400 hover:text-white'
            }`}
          >
            iPhone
          </button>
          <button
            onClick={() => setDeviceFrame('android')}
            className={`px-2 py-0.5 rounded-md font-medium transition-all ${
              deviceFrame === 'android' ? 'bg-[#531FFF] text-white' : 'text-slate-400 hover:text-white'
            }`}
          >
            Pixel
          </button>
          <button
            onClick={() => setDeviceFrame('fullscreen')}
            className={`px-2 py-0.5 rounded-md font-medium transition-all ${
              deviceFrame === 'fullscreen' ? 'bg-[#531FFF] text-white' : 'text-slate-400 hover:text-white'
            }`}
          >
            Layar Penuh
          </button>
        </div>
      </div>

      {/* Main Mobile App Container */}
      <div
        className={`relative bg-[#F8FAFC] text-slate-900 flex flex-col overflow-hidden transition-all duration-200 ${
          deviceFrame === 'fullscreen'
            ? 'w-full h-screen max-w-md'
            : 'w-full sm:w-[390px] h-screen sm:h-[810px] sm:rounded-[46px] sm:border-[6px] sm:border-slate-800 sm:shadow-2xl sm:ring-1 sm:ring-white/10'
        }`}
      >
        {/* iOS Dynamic Island / Android Punch Hole */}
        {deviceFrame === 'ios' ? (
          <div className="hidden sm:flex absolute top-2 left-1/2 -translate-x-1/2 w-28 h-6 bg-black rounded-full z-50 items-center justify-between px-3 pointer-events-none">
            <div className="w-2.5 h-2.5 rounded-full bg-slate-900 ring-1 ring-slate-800"></div>
            <div className="w-2.5 h-2.5 rounded-full bg-slate-900/60"></div>
          </div>
        ) : deviceFrame === 'android' ? (
          <div className="hidden sm:block absolute top-3 left-1/2 -translate-x-1/2 w-4 h-4 bg-black rounded-full z-50 ring-1 ring-slate-800 pointer-events-none"></div>
        ) : null}

        {/* Mobile Status Bar */}
        <div className="h-10 pt-2 px-6 flex items-center justify-between text-[11px] font-semibold text-slate-900 bg-white z-40 shrink-0">
          <span>09:41</span>
          <div className="flex items-center gap-1.5 text-slate-700">
            <Wifi className="w-3.5 h-3.5" />
            <Battery className="w-4 h-4" />
          </div>
        </div>

        {/* ================= SCREEN: SPLASH ================= */}
        {currentScreen === 'splash' && (
          <div className="flex-1 flex flex-col items-center justify-center p-6 bg-white animate-fade-in">
            <div className="w-20 h-20 bg-[#531FFF] rounded-2xl flex items-center justify-center shadow-lg shadow-[#531FFF]/30 mb-6">
              <School className="w-10 h-10 text-white" />
            </div>
            <h1 className="text-xl font-black text-[#531FFF] tracking-wider mb-1">QUICK SCHOOLS</h1>
            <p className="text-xs text-slate-500 font-medium mb-8">Mobile Academic Companion</p>
            <div className="w-5 h-5 border-2 border-[#531FFF] border-t-transparent rounded-full animate-spin"></div>
          </div>
        )}

        {/* ================= SCREEN: LOGIN ================= */}
        {currentScreen === 'login' && (
          <div className="flex-1 flex flex-col p-6 bg-white justify-between overflow-y-auto">
            <div>
              <div className="w-12 h-12 bg-[#531FFF] rounded-xl flex items-center justify-center shadow-md shadow-[#531FFF]/25 mb-5">
                <School className="w-6 h-6 text-white" />
              </div>
              <h2 className="text-2xl font-extrabold text-slate-900 tracking-tight leading-tight">
                Selamat Datang di<br />Quick Schools
              </h2>
              <p className="text-xs text-slate-500 mt-1 mb-6">Masuk menggunakan portal mobile sekolah terpadu.</p>

              <div className="space-y-4">
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Email / NISN</label>
                  <input
                    type="text"
                    readOnly
                    value={currentUser.email}
                    className="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 font-medium"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1">Kata Sandi</label>
                  <input
                    type="password"
                    readOnly
                    value="••••••••••••"
                    className="w-full text-xs px-3.5 py-3 rounded-xl border border-slate-200 bg-slate-50 font-medium tracking-widest"
                  />
                </div>
              </div>

              <button
                onClick={() => setCurrentScreen('dashboard')}
                className="w-full mt-6 py-3.5 px-4 bg-[#531FFF] hover:bg-[#4516DB] text-white text-xs font-bold rounded-xl shadow-md shadow-[#531FFF]/30 active:scale-[0.98] transition-all"
              >
                Masuk Sekarang
              </button>
            </div>

            {/* Fast Role Switcher */}
            <div className="pt-6 border-t border-slate-100">
              <span className="block text-center text-[10px] font-bold tracking-wider text-slate-400 uppercase mb-3">
                Pilih Akun Demo (RBAC)
              </span>
              <div className="grid grid-cols-2 gap-2">
                {(['STUDENT', 'TEACHER', 'PARENT', 'ADMIN'] as UserRole[]).map((role) => (
                  <button
                    key={role}
                    onClick={() => {
                      setSelectedRole(role);
                      setCurrentScreen('dashboard');
                    }}
                    className={`p-2 rounded-lg text-left border transition-all ${
                      selectedRole === role
                        ? 'border-[#531FFF] bg-[#F2EEFF] text-[#531FFF]'
                        : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300'
                    }`}
                  >
                    <div className="text-[11px] font-bold leading-tight">
                      {role === 'STUDENT' && '👨‍🎓 Siswa'}
                      {role === 'TEACHER' && '👩‍🏫 Guru'}
                      {role === 'PARENT' && '👨‍👩‍👧 Wali Murid'}
                      {role === 'ADMIN' && '🛡️ Admin'}
                    </div>
                    <div className="text-[9px] text-slate-400 mt-0.5 truncate">
                      {userProfiles[role].name}
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* ================= SCREEN: DASHBOARD & MAIN TABS ================= */}
        {currentScreen === 'dashboard' && (
          <div className="flex-1 flex flex-col justify-between overflow-hidden">
            
            {/* Top Mobile App Bar */}
            <div className="px-5 py-3.5 bg-white border-b border-slate-200/80 flex items-center justify-between z-10 shrink-0">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-full bg-[#F2EEFF] flex items-center justify-center text-xs font-extrabold text-[#531FFF]">
                  {currentUser.avatar}
                </div>
                <div>
                  <div className="flex items-center gap-1.5">
                    <span className="text-[10px] font-extrabold px-1.5 py-0.2 rounded bg-[#F2EEFF] text-[#531FFF] tracking-wider uppercase">
                      {selectedRole}
                    </span>
                  </div>
                  <h3 className="text-xs font-bold text-slate-900 leading-tight truncate max-w-[180px]">
                    {currentUser.name}
                  </h3>
                </div>
              </div>

              <div className="flex items-center gap-1">
                <button
                  onClick={() => setShowAnnouncementsSheet(true)}
                  className="w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center relative text-slate-600"
                  title="Pengumuman Sekolah"
                >
                  <Bell className="w-4 h-4" />
                  <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-rose-500 rounded-full ring-2 ring-white"></span>
                </button>
              </div>
            </div>

            {/* Scrollable Tab Content */}
            <div className="flex-1 overflow-y-auto p-4 space-y-4">
              
              {/* TAB 1: BERANDA (HOME) */}
              {activeTab === 'home' && (
                <div className="space-y-4">
                  {/* Hero Digital Card with #531FFF brand color */}
                  <div className="p-4 rounded-2xl bg-gradient-to-br from-[#531FFF] to-[#7B4DFF] text-white shadow-lg shadow-[#531FFF]/25 relative overflow-hidden">
                    <div className="absolute -right-6 -bottom-6 w-28 h-28 bg-white/10 rounded-full blur-xl pointer-events-none"></div>
                    <div className="flex items-center justify-between text-[10px] text-white/80 font-medium mb-3">
                      <span>{currentUser.school}</span>
                      <span className="flex items-center gap-1 bg-white/20 px-2 py-0.5 rounded-full font-semibold">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                        Next.js & DB Sync
                      </span>
                    </div>
                    <div className="text-lg font-extrabold leading-tight mb-1">{currentUser.name}</div>
                    <div className="text-xs text-white/80 font-mono mb-4">{currentUser.idNumber}</div>

                    <div className="pt-3 border-t border-white/20 flex items-center justify-between text-[11px]">
                      <span className="text-white/90 font-medium">{currentUser.roleTitle}</span>
                      <span className="text-white/70">Semester Ganjil 2026</span>
                    </div>
                  </div>

                  {/* Quick Stats Grid */}
                  <div className="grid grid-cols-2 gap-2.5">
                    <div className="bg-white p-3.5 rounded-xl border border-slate-200/80 shadow-xs">
                      <div className="flex items-center justify-between text-slate-400 mb-2">
                        <span className="text-[11px] font-semibold text-slate-500">Kehadiran</span>
                        <CheckCircle2 className="w-4 h-4 text-emerald-500" />
                      </div>
                      <div className="text-xl font-extrabold text-slate-900">96.5%</div>
                      <div className="text-[10px] text-slate-400 mt-0.5">Tepat Waktu</div>
                    </div>

                    <div className="bg-white p-3.5 rounded-xl border border-slate-200/80 shadow-xs">
                      <div className="flex items-center justify-between text-slate-400 mb-2">
                        <span className="text-[11px] font-semibold text-slate-500">Indeks Nilai</span>
                        <Award className="w-4 h-4 text-[#531FFF]" />
                      </div>
                      <div className="text-xl font-extrabold text-slate-900">3.82</div>
                      <div className="text-[10px] text-emerald-600 font-semibold mt-0.5">Predikat A</div>
                    </div>
                  </div>

                  {/* Quick Action: Presensi Masuk Hari Ini */}
                  <div className="bg-white p-3.5 rounded-xl border border-slate-200/80 shadow-xs">
                    <div className="flex items-center justify-between mb-2.5">
                      <div className="flex items-center gap-2">
                        <div className="w-7 h-7 rounded-lg bg-[#F2EEFF] flex items-center justify-center text-[#531FFF]">
                          <Clock className="w-3.5 h-3.5" />
                        </div>
                        <div>
                          <div className="text-xs font-bold text-slate-900">Presensi Mandiri</div>
                          <div className="text-[10px] text-slate-400">Tercatat di DB PostgreSQL</div>
                        </div>
                      </div>

                      {checkInSuccess && (
                        <span className="text-[10px] text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded font-bold">
                          Tersimpan!
                        </span>
                      )}
                    </div>

                    <button
                      onClick={handleMarkAttendance}
                      disabled={isCheckingIn}
                      className="w-full py-2.5 px-3 bg-[#531FFF] hover:bg-[#4516DB] text-white text-xs font-bold rounded-lg transition-all flex items-center justify-center gap-2 active:scale-[0.98]"
                    >
                      {isCheckingIn ? (
                        <span className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                      ) : (
                        <>
                          <CheckCircle2 className="w-4 h-4" />
                          <span>
                            {selectedRole === 'TEACHER' || selectedRole === 'ADMIN'
                              ? 'Rekap Kehadiran Kelas'
                              : 'Tap Hadir Sekarang'}
                          </span>
                        </>
                      )}
                    </button>
                  </div>

                  {/* Upcoming Schedule Snippet */}
                  <div className="bg-white p-3.5 rounded-xl border border-slate-200/80 shadow-xs">
                    <div className="flex items-center justify-between mb-3">
                      <span className="text-xs font-bold text-slate-900">Jadwal Terdekat Hari Ini</span>
                      <button
                        onClick={() => setActiveTab('schedule')}
                        className="text-[11px] font-semibold text-[#531FFF] hover:underline"
                      >
                        Semua
                      </button>
                    </div>

                    {schedules.length > 0 ? (
                      <div className="flex items-start gap-3 p-2.5 bg-slate-50 rounded-lg border border-slate-100">
                        <div className="px-2 py-1 rounded bg-[#F2EEFF] text-[#531FFF] text-[10px] font-extrabold text-center leading-tight">
                          {schedules[0].startTime}<br />
                          <span className="text-[9px] font-normal text-slate-500">{schedules[0].endTime}</span>
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="text-xs font-bold text-slate-900 truncate">
                            {schedules[0].subjectName}
                          </div>
                          <div className="text-[10px] text-slate-500 truncate mt-0.5">
                            {schedules[0].teacherName} · {schedules[0].room}
                          </div>
                        </div>
                      </div>
                    ) : (
                      <div className="text-xs text-slate-400 py-2 text-center">Tidak ada jadwal aktif.</div>
                    )}
                  </div>
                </div>
              )}

              {/* TAB 2: PRESENSI */}
              {activeTab === 'attendance' && (
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <h4 className="text-xs font-bold text-slate-900">Riwayat Presensi ({attendances.length})</h4>
                    <button
                      onClick={fetchBackendData}
                      className="text-[10px] font-semibold text-[#531FFF] hover:underline flex items-center gap-1"
                    >
                      <RefreshCw className="w-3 h-3" /> Refresh
                    </button>
                  </div>

                  <div className="space-y-2">
                    {attendances.map((item) => (
                      <div
                        key={item.id}
                        className="p-3 bg-white rounded-xl border border-slate-200/80 flex items-center justify-between"
                      >
                        <div className="flex items-center gap-2.5">
                          <div className="w-9 h-9 rounded-lg bg-slate-100 flex flex-col items-center justify-center text-slate-700">
                            <span className="text-[12px] font-bold leading-none">{item.date?.split('-')[2] || '11'}</span>
                            <span className="text-[9px] text-slate-400 uppercase leading-none mt-0.5">
                              {new Date(item.date).toLocaleString('id-ID', { month: 'short' })}
                            </span>
                          </div>
                          <div>
                            <div className="text-xs font-bold text-slate-900">{item.studentName}</div>
                            <div className="text-[10px] text-slate-400">{item.notes || 'Hadir Mandiri'}</div>
                            {item.checkInTime && (
                              <div className="text-[9px] text-slate-400 mt-0.5">Waktu: {item.checkInTime}</div>
                            )}
                          </div>
                        </div>

                        <span
                          className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                            item.status === 'PRESENT'
                              ? 'bg-emerald-50 text-emerald-600'
                              : item.status === 'LATE'
                              ? 'bg-amber-50 text-amber-600'
                              : item.status === 'EXCUSED'
                              ? 'bg-blue-50 text-blue-600'
                              : 'bg-rose-50 text-rose-600'
                          }`}
                        >
                          {item.status === 'PRESENT' && 'Hadir'}
                          {item.status === 'LATE' && 'Terlambat'}
                          {item.status === 'EXCUSED' && 'Izin'}
                          {item.status === 'ABSENT' && 'Alpa'}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* TAB 3: JADWAL */}
              {activeTab === 'schedule' && (
                <div className="space-y-3">
                  {/* Day selector */}
                  <div className="flex gap-1.5 overflow-x-auto pb-1 no-scrollbar">
                    {[
                      { day: 1, label: 'Senin' },
                      { day: 2, label: 'Selasa' },
                      { day: 3, label: 'Rabu' },
                      { day: 4, label: 'Kamis' },
                      { day: 5, label: 'Jumat' },
                    ].map((d) => (
                      <button
                        key={d.day}
                        onClick={() => setSelectedDay(d.day)}
                        className={`px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition-all ${
                          selectedDay === d.day
                            ? 'bg-[#531FFF] text-white shadow-xs'
                            : 'bg-white text-slate-600 border border-slate-200'
                        }`}
                      >
                        {d.label}
                      </button>
                    ))}
                  </div>

                  <div className="space-y-2">
                    {schedules.filter(s => s.dayOfWeek === selectedDay).length === 0 ? (
                      <div className="p-6 text-center text-xs text-slate-400 bg-white rounded-xl border border-slate-200">
                        Tidak ada mata pelajaran di hari ini.
                      </div>
                    ) : (
                      schedules
                        .filter(s => s.dayOfWeek === selectedDay)
                        .map((item) => (
                          <div
                            key={item.id}
                            className="p-3 bg-white rounded-xl border border-slate-200/80 flex items-start gap-3"
                          >
                            <div className="px-2 py-1.5 rounded-md bg-[#F2EEFF] text-[#531FFF] text-[10px] font-extrabold text-center leading-tight">
                              {item.startTime}<br />
                              <span className="text-[9px] font-medium text-slate-500">{item.endTime}</span>
                            </div>
                            <div className="flex-1 min-w-0">
                              <span className="text-[9px] font-bold text-[#531FFF] bg-[#F2EEFF] px-1.5 py-0.5 rounded">
                                {item.subjectCode}
                              </span>
                              <div className="text-xs font-bold text-slate-900 mt-1 truncate">
                                {item.subjectName}
                              </div>
                              <div className="text-[10px] text-slate-500 mt-0.5 truncate">
                                {item.teacherName} · {item.room}
                              </div>
                            </div>
                          </div>
                        ))
                    )}
                  </div>
                </div>
              )}

              {/* TAB 4: NILAI */}
              {activeTab === 'grades' && (
                <div className="space-y-3">
                  <div className="bg-white p-3.5 rounded-xl border border-slate-200/80 flex items-center justify-between">
                    <div>
                      <div className="text-xs font-bold text-slate-900">Indeks Prestasi Kumulatif</div>
                      <div className="text-[10px] text-slate-400">Semester Ganjil 2026/2027</div>
                    </div>
                    <div className="text-right">
                      <div className="text-xl font-extrabold text-[#531FFF]">3.82</div>
                      <div className="text-[10px] text-emerald-600 font-bold">Grade A (Sangat Baik)</div>
                    </div>
                  </div>

                  <h5 className="text-xs font-bold text-slate-900 pt-1">Rincian Evaluasi & Tugas</h5>

                  <div className="space-y-2">
                    {grades.map((grd) => (
                      <div
                        key={grd.id}
                        className="p-3 bg-white rounded-xl border border-slate-200/80 space-y-1.5"
                      >
                        <div className="flex items-center justify-between">
                          <span className="text-xs font-bold text-slate-900">{grd.subjectName}</span>
                          <span className="text-xs font-extrabold text-[#531FFF] bg-[#F2EEFF] px-2 py-0.5 rounded">
                            {grd.score} / {grd.maxScore}
                          </span>
                        </div>
                        <div className="text-[11px] text-slate-600 font-medium">{grd.title}</div>
                        {grd.remarks && (
                          <div className="text-[10px] text-slate-400 italic">"{grd.remarks}"</div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* TAB 5: PROFIL */}
              {activeTab === 'profile' && (
                <div className="space-y-4">
                  {/* Digital Student / Staff Card */}
                  <div className="p-4 rounded-2xl bg-gradient-to-br from-[#531FFF] to-[#3B0FC4] text-white shadow-lg shadow-[#531FFF]/25 relative overflow-hidden">
                    <div className="flex items-center justify-between text-[10px] font-bold tracking-widest uppercase mb-4">
                      <span className="flex items-center gap-1.5">
                        <School className="w-3.5 h-3.5" />
                        QUICK SCHOOLS DIGITAL ID
                      </span>
                      <span className="bg-white/20 px-2 py-0.5 rounded text-[9px]">{selectedRole}</span>
                    </div>

                    <div className="flex items-center gap-3 mb-4">
                      <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-base font-extrabold">
                        {currentUser.avatar}
                      </div>
                      <div>
                        <div className="text-sm font-extrabold">{currentUser.name}</div>
                        <div className="text-[10px] text-white/80">{currentUser.roleTitle}</div>
                        <div className="text-[10px] text-white/60 font-mono mt-0.5">{currentUser.idNumber}</div>
                      </div>
                    </div>

                    <div className="pt-3 border-t border-white/20 flex items-center justify-between">
                      <span className="text-[10px] text-white/70">Terverifikasi Database Quick Schools</span>
                      <QrCode className="w-6 h-6 text-white" />
                    </div>
                  </div>

                  {/* Switch Role */}
                  <div className="bg-white p-3.5 rounded-xl border border-slate-200/80">
                    <div className="text-xs font-bold text-slate-900 mb-2">Ganti Hak Akses Pengguna (RBAC)</div>
                    <div className="grid grid-cols-2 gap-2">
                      {(['STUDENT', 'TEACHER', 'PARENT', 'ADMIN'] as UserRole[]).map((r) => (
                        <button
                          key={r}
                          onClick={() => setSelectedRole(r)}
                          className={`p-2 rounded-lg text-left text-xs font-semibold border transition-all ${
                            selectedRole === r
                              ? 'border-[#531FFF] bg-[#F2EEFF] text-[#531FFF]'
                              : 'border-slate-200 text-slate-600 hover:bg-slate-50'
                          }`}
                        >
                          {r === 'STUDENT' && '👨‍🎓 Siswa'}
                          {r === 'TEACHER' && '👩‍🏫 Guru'}
                          {r === 'PARENT' && '👨‍👩‍👧 Wali'}
                          {r === 'ADMIN' && '🛡️ Admin'}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Download Flutter Source Code Zip Button */}
                  <div className="bg-white p-3.5 rounded-xl border border-slate-200/80">
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-2">
                        <FileCode className="w-4 h-4 text-[#531FFF]" />
                        <span className="text-xs font-bold text-slate-900">Flutter Mobile Project</span>
                      </div>
                      <span className="text-[10px] text-slate-500 font-mono">/quick-schools-mobile</span>
                    </div>
                    <p className="text-[11px] text-slate-500 mb-3">
                      Source code lengkap Flutter (Dart) untuk Android & iOS terintegrasi Next.js backend.
                    </p>
                    <button
                      onClick={handleExportFlutterZip}
                      disabled={isExportingZip}
                      className="w-full py-2.5 px-3 bg-[#531FFF] hover:bg-[#4516DB] text-white text-xs font-bold rounded-lg transition-all flex items-center justify-center gap-2"
                    >
                      <Download className="w-3.5 h-3.5" />
                      <span>{isExportingZip ? 'Menyiapkan ZIP...' : zipSuccess ? 'Berhasil Diunduh!' : 'Download Project ZIP'}</span>
                    </button>
                  </div>

                  {/* Logout */}
                  <button
                    onClick={() => setCurrentScreen('login')}
                    className="w-full py-2.5 px-3 rounded-xl border border-rose-200 text-rose-600 bg-rose-50 hover:bg-rose-100 text-xs font-bold flex items-center justify-center gap-2 transition-colors"
                  >
                    <LogOut className="w-3.5 h-3.5" />
                    <span>Keluar ke Layar Login</span>
                  </button>
                </div>
              )}
            </div>

            {/* Mobile Bottom Navigation Bar */}
            <div className="h-14 bg-white border-t border-slate-200/80 flex items-center justify-around px-2 shrink-0 z-10">
              <button
                onClick={() => setActiveTab('home')}
                className={`flex flex-col items-center gap-1 py-1 px-3 transition-colors ${
                  activeTab === 'home' ? 'text-[#531FFF]' : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                <School className="w-4 h-4" />
                <span className="text-[10px] font-bold">Beranda</span>
              </button>

              <button
                onClick={() => setActiveTab('attendance')}
                className={`flex flex-col items-center gap-1 py-1 px-3 transition-colors ${
                  activeTab === 'attendance' ? 'text-[#531FFF]' : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                <CheckCircle2 className="w-4 h-4" />
                <span className="text-[10px] font-bold">Presensi</span>
              </button>

              <button
                onClick={() => setActiveTab('schedule')}
                className={`flex flex-col items-center gap-1 py-1 px-3 transition-colors ${
                  activeTab === 'schedule' ? 'text-[#531FFF]' : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                <Calendar className="w-4 h-4" />
                <span className="text-[10px] font-bold">Jadwal</span>
              </button>

              <button
                onClick={() => setActiveTab('grades')}
                className={`flex flex-col items-center gap-1 py-1 px-3 transition-colors ${
                  activeTab === 'grades' ? 'text-[#531FFF]' : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                <BarChart3 className="w-4 h-4" />
                <span className="text-[10px] font-bold">Nilai</span>
              </button>

              <button
                onClick={() => setActiveTab('profile')}
                className={`flex flex-col items-center gap-1 py-1 px-3 transition-colors ${
                  activeTab === 'profile' ? 'text-[#531FFF]' : 'text-slate-400 hover:text-slate-600'
                }`}
              >
                <User className="w-4 h-4" />
                <span className="text-[10px] font-bold">Profil</span>
              </button>
            </div>
          </div>
        )}

        {/* Mobile Home Indicator Line */}
        <div className="h-5 bg-white flex items-center justify-center shrink-0 z-40">
          <div className="w-32 h-1 bg-slate-300 rounded-full"></div>
        </div>

        {/* Announcements Modal Sheet */}
        {showAnnouncementsSheet && (
          <div className="absolute inset-0 bg-black/50 z-50 flex flex-col justify-end">
            <div className="bg-white rounded-t-3xl max-h-[85%] flex flex-col p-4 animate-slide-up shadow-2xl">
              <div className="flex items-center justify-between pb-3 border-b border-slate-100">
                <div className="flex items-center gap-2">
                  <Bell className="w-4 h-4 text-[#531FFF]" />
                  <h4 className="text-xs font-bold text-slate-900">Pengumuman Sekolah</h4>
                </div>
                <button
                  onClick={() => setShowAnnouncementsSheet(false)}
                  className="w-7 h-7 rounded-full bg-slate-100 hover:bg-slate-200 flex items-center justify-center text-slate-500"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto py-3 space-y-2.5">
                {announcements.map((ann) => (
                  <div
                    key={ann.id}
                    className="p-3 rounded-xl border border-slate-200/80 bg-slate-50/50 space-y-1.5"
                  >
                    <div className="flex items-center gap-2">
                      {ann.priority === 'URGENT' && (
                        <span className="text-[9px] font-bold px-1.5 py-0.2 rounded bg-rose-100 text-rose-700">
                          PENTING
                        </span>
                      )}
                      <span className="text-xs font-bold text-slate-900 truncate">{ann.title}</span>
                    </div>
                    <p className="text-[11px] text-slate-600 leading-relaxed">{ann.content}</p>
                    <div className="text-[9px] text-slate-400 pt-1 border-t border-slate-200/60 flex items-center justify-between">
                      <span>{ann.authorName}</span>
                      <span>{new Date(ann.publishedAt).toLocaleDateString('id-ID')}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

      </div>
    </div>
  );
}
