import React, { useState, useEffect } from 'react';
import {
  Smartphone,
  Wifi,
  Battery,
  ChevronRight,
  School,
  Calendar,
  CheckCircle2,
  Clock,
  AlertCircle,
  BarChart3,
  User,
  Bell,
  RefreshCw,
  LogOut,
  QrCode,
  ShieldCheck,
  Award,
  Layers,
  Sparkles,
  BookOpen
} from 'lucide-react';

export type UserRole = 'STUDENT' | 'TEACHER' | 'PARENT' | 'ADMIN';

interface MobileSimulatorProps {
  onDataChanged?: () => void;
}

export function MobileSimulator({ onDataChanged }: MobileSimulatorProps) {
  // Mobile device frame state
  const [deviceFrame, setDeviceFrame] = useState<'ios' | 'android'>('ios');
  
  // App state
  const [currentScreen, setCurrentScreen] = useState<'splash' | 'login' | 'dashboard'>('dashboard');
  const [activeTab, setActiveTab] = useState<'home' | 'attendance' | 'schedule' | 'grades' | 'profile'>('home');
  const [selectedRole, setSelectedRole] = useState<UserRole>('STUDENT');
  const [isCheckingIn, setIsCheckingIn] = useState(false);
  const [checkInSuccess, setCheckInSuccess] = useState(false);
  const [selectedDay, setSelectedDay] = useState<number>(1); // 1 = Monday
  const [showNotifications, setShowNotifications] = useState(false);

  // Live data fetched from shared API
  const [attendances, setAttendances] = useState<any[]>([]);
  const [schedules, setSchedules] = useState<any[]>([]);
  const [grades, setGrades] = useState<any[]>([]);
  const [announcements, setAnnouncements] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  const fetchAppData = async () => {
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
      console.error('Failed to fetch from shared API', err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchAppData();
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
          notes: 'Presensi Mandiri via Quick Schools Mobile (GPS Verified)',
        }),
      });
      const data = await res.json();
      if (data.success) {
        setCheckInSuccess(true);
        await fetchAppData();
        if (onDataChanged) onDataChanged();
        setTimeout(() => setCheckInSuccess(false), 3000);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setIsCheckingIn(false);
    }
  };

  // Mock User profile according to selected role
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
    <div className="flex flex-col items-center">
      {/* Device Controls Header */}
      <div className="flex items-center justify-between w-full max-w-[390px] mb-3 px-2">
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold uppercase tracking-wider text-slate-400">Model Frame:</span>
          <div className="inline-flex rounded-lg bg-slate-800/80 p-0.5 border border-slate-700/60 text-xs">
            <button
              onClick={() => setDeviceFrame('ios')}
              className={`px-2.5 py-1 rounded-md font-medium transition-all ${
                deviceFrame === 'ios' ? 'bg-[#531FFF] text-white shadow-sm' : 'text-slate-400 hover:text-white'
              }`}
            >
              iOS iPhone
            </button>
            <button
              onClick={() => setDeviceFrame('android')}
              className={`px-2.5 py-1 rounded-md font-medium transition-all ${
                deviceFrame === 'android' ? 'bg-[#531FFF] text-white shadow-sm' : 'text-slate-400 hover:text-white'
              }`}
            >
              Android Pixel
            </button>
          </div>
        </div>

        <button
          onClick={fetchAppData}
          title="Sinkronisasi Ulang Data"
          className="flex items-center gap-1.5 text-xs text-slate-400 hover:text-white bg-slate-800/80 hover:bg-slate-700 px-2.5 py-1 rounded-lg border border-slate-700/60 transition-colors"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin text-[#7B4DFF]' : ''}`} />
          <span>Sync</span>
        </button>
      </div>

      {/* Smartphone Device Shell */}
      <div
        className={`relative w-[380px] h-[780px] bg-slate-950 shadow-2xl transition-all duration-300 border-4 border-slate-800 flex flex-col overflow-hidden ${
          deviceFrame === 'ios' ? 'rounded-[48px] ring-1 ring-white/10' : 'rounded-[36px] ring-1 ring-white/10'
        }`}
      >
        {/* Dynamic Island / Camera Notch */}
        {deviceFrame === 'ios' ? (
          <div className="absolute top-2 left-1/2 -translate-x-1/2 w-28 h-6 bg-black rounded-full z-50 flex items-center justify-between px-3">
            <div className="w-2.5 h-2.5 rounded-full bg-slate-900 ring-1 ring-slate-800"></div>
            <div className="w-2.5 h-2.5 rounded-full bg-slate-900/60"></div>
          </div>
        ) : (
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-4 h-4 bg-black rounded-full z-50 ring-1 ring-slate-800"></div>
        )}

        {/* Mobile Status Bar */}
        <div className="h-10 pt-2 px-6 flex items-center justify-between text-[11px] font-semibold text-slate-900 bg-white z-40 select-none">
          <span>09:41</span>
          <div className="flex items-center gap-1.5 text-slate-700">
            <Wifi className="w-3.5 h-3.5" />
            <Battery className="w-4 h-4" />
          </div>
        </div>

        {/* Screen Content Container */}
        <div className="flex-1 bg-[#F8FAFC] overflow-y-auto flex flex-col relative text-slate-900 select-none">
          
          {/* SCREEN: SPLASH */}
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

          {/* SCREEN: LOGIN */}
          {currentScreen === 'login' && (
            <div className="flex-1 flex flex-col p-6 bg-white justify-between">
              <div>
                <div className="w-12 h-12 bg-[#531FFF] rounded-xl flex items-center justify-center shadow-md shadow-[#531FFF]/25 mb-5">
                  <School className="w-6 h-6 text-white" />
                </div>
                <h2 className="text-2xl font-bold text-slate-900 tracking-tight leading-tight">
                  Selamat Datang di<br />Quick Schools
                </h2>
                <p className="text-xs text-slate-500 mt-1 mb-6">Masuk menggunakan portal sekolah terpadu.</p>

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

          {/* SCREEN: DASHBOARD */}
          {currentScreen === 'dashboard' && (
            <div className="flex-1 flex flex-col justify-between overflow-hidden">
              
              {/* Top Navigation Bar inside Mobile Screen */}
              <div className="px-5 py-3.5 bg-white border-b border-slate-200/80 flex items-center justify-between z-10 shrink-0">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-full bg-[#F2EEFF] flex items-center justify-center text-xs font-extrabold text-[#531FFF]">
                    {currentUser.avatar}
                  </div>
                  <div>
                    <div className="flex items-center gap-1.5">
                      <span className="text-[10px] font-extrabold px-1.5 py-0.5 rounded bg-[#F2EEFF] text-[#531FFF] tracking-wider uppercase">
                        {selectedRole}
                      </span>
                    </div>
                    <h3 className="text-xs font-bold text-slate-900 leading-tight truncate max-w-[170px]">
                      {currentUser.name}
                    </h3>
                  </div>
                </div>

                <div className="flex items-center gap-1">
                  <button
                    onClick={() => setShowNotifications(!showNotifications)}
                    className="w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center relative text-slate-600"
                    title="Pengumuman"
                  >
                    <Bell className="w-4 h-4" />
                    <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-rose-500 rounded-full ring-2 ring-white"></span>
                  </button>
                </div>
              </div>

              {/* Scrollable Tab Views */}
              <div className="flex-1 overflow-y-auto p-4 space-y-4">
                
                {/* TAB 1: HOME */}
                {activeTab === 'home' && (
                  <div className="space-y-4">
                    {/* Hero Card with #531FFF identity */}
                    <div className="p-4 rounded-2xl bg-gradient-to-br from-[#531FFF] to-[#7B4DFF] text-white shadow-lg shadow-[#531FFF]/25 relative overflow-hidden">
                      <div className="absolute -right-6 -bottom-6 w-28 h-28 bg-white/10 rounded-full blur-xl pointer-events-none"></div>
                      <div className="flex items-center justify-between text-[10px] text-white/80 font-medium mb-3">
                        <span>{currentUser.school}</span>
                        <span className="flex items-center gap-1 bg-white/20 px-2 py-0.5 rounded-full font-semibold">
                          <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                          Next.js Sync
                        </span>
                      </div>
                      <div className="text-lg font-extrabold leading-tight mb-1">{currentUser.name}</div>
                      <div className="text-xs text-white/80 font-mono mb-4">{currentUser.idNumber}</div>

                      <div className="pt-3 border-t border-white/20 flex items-center justify-between text-[11px]">
                        <span className="text-white/90 font-medium">{currentUser.roleTitle}</span>
                        <span className="text-white/70">Semester Ganjil</span>
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
                        <div className="text-[10px] text-slate-400 mt-0.5">Hadir Tepat Waktu</div>
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
                            <div className="text-xs font-bold text-slate-900">Presensi Cepat</div>
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

                {/* TAB 2: ATTENDANCE */}
                {activeTab === 'attendance' && (
                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <h4 className="text-xs font-bold text-slate-900">Riwayat Presensi ({attendances.length})</h4>
                      <button
                        onClick={fetchAppData}
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
                              <span className="text-[12px] font-bold leading-none">{item.date.split('-')[2]}</span>
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

                {/* TAB 3: SCHEDULE */}
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

                {/* TAB 4: GRADES */}
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

                {/* TAB 5: PROFILE */}
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

                    {/* Role Switcher */}
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
        </div>

        {/* Home Indicator Bar */}
        <div className="h-5 bg-white flex items-center justify-center shrink-0 z-40">
          <div className="w-32 h-1 bg-slate-300 rounded-full"></div>
        </div>
      </div>
    </div>
  );
}
