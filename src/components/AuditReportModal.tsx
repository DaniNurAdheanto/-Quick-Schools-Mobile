import React from 'react';
import {
  ShieldCheck,
  CheckCircle2,
  FileCode,
  Database,
  Server,
  Smartphone,
  ExternalLink,
  Layers,
  X
} from 'lucide-react';

interface AuditReportModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function AuditReportModal({ isOpen, onClose }: AuditReportModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-fade-in">
      <div className="bg-slate-900 border border-slate-800 w-full max-w-3xl rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="p-4 bg-slate-950 border-b border-slate-800 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center text-emerald-400">
              <ShieldCheck className="w-4 h-4" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-white">Laporan Audit & Rencana Integrasi Quick Schools</h3>
              <p className="text-xs text-slate-400">Pondasi Flutter Mobile & Shared Next.js Backend</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white flex items-center justify-center transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6 text-slate-300 text-xs leading-relaxed">
          {/* Executive Summary */}
          <div className="p-4 rounded-xl bg-[#531FFF]/10 border border-[#531FFF]/30">
            <h4 className="text-sm font-bold text-white mb-2 flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-[#7B4DFF]" />
              Status Audit: Sistem Siap Terintegrasi Penuh
            </h4>
            <p className="text-slate-300">
              Folder project mobile <strong>quick-schools-mobile</strong> telah dibuat di dalam root directory Quick Schools tanpa mengganggu struktur website existing. Seluruh rancangan database, relasi tabel, business logic, dan hak akses RBAC (Admin, Guru, Siswa, Orang Tua) dipertahankan 100% dan terhubung ke shared API.
            </p>
          </div>

          {/* Matrix Verification Checklist */}
          <div>
            <h4 className="text-xs font-bold text-slate-200 uppercase tracking-wider mb-3">
              Hasil Audit & Verifikasi Ketentuan Utama
            </h4>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-white text-xs">Folder Project quick-schools-mobile</div>
                  <div className="text-slate-400 text-[11px] mt-0.5">
                    Tersedia di root directory dengan berkas <code>pubspec.yaml</code>, <code>lib/main.dart</code>, dan arsitektur MVVM.
                  </div>
                </div>
              </div>

              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-white text-xs">Shared Next.js Backend & API Routes</div>
                  <div className="text-slate-400 text-[11px] mt-0.5">
                    Route Handlers <code>/api/auth/*</code>, <code>/api/attendance/*</code>, <code>/api/grades</code> digunakan bersama oleh Web dan Mobile.
                  </div>
                </div>
              </div>

              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-white text-xs">PostgreSQL & Prisma Schema</div>
                  <div className="text-slate-400 text-[11px] mt-0.5">
                    Tunggal (Single Source of Truth) via <code>prisma/schema.prisma</code>. Tidak ada database duplikat.
                  </div>
                </div>
              </div>

              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-white text-xs">Role-Based Access Control (RBAC)</div>
                  <div className="text-slate-400 text-[11px] mt-0.5">
                    Hak akses terverifikasi: Admin (Full), Guru (Presensi/Nilai), Siswa (Mandiri/Jadwal), Wali (Monitoring Anak).
                  </div>
                </div>
              </div>

              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-white text-xs">Visual Brand Identity #531FFF</div>
                  <div className="text-slate-400 text-[11px] mt-0.5">
                    Diterapkan pada <code>AppColors.primary (0xFF531FFF)</code>, tema Material 3, gradasi digital ID, dan simulator mobile.
                  </div>
                </div>
              </div>

              <div className="p-3 bg-slate-950 rounded-xl border border-slate-800 flex items-start gap-2.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold text-white text-xs">Two-Way Data Sync</div>
                  <div className="text-slate-400 text-[11px] mt-0.5">
                    Perubahan data via Website langsung dapat diakses Mobile App, begitu juga input presensi via Mobile langsung tercatat di DB.
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Architecture flow diagram */}
          <div>
            <h4 className="text-xs font-bold text-slate-200 uppercase tracking-wider mb-2">
              Alur Arsitektur Integrasi
            </h4>
            <div className="p-4 bg-slate-950 rounded-xl border border-slate-800 font-mono text-slate-300 text-xs">
              <div className="text-slate-400 mb-1">// Quick Schools Integrated Topology</div>
              <div className="text-[#7B4DFF]">Website Next.js</div>
              <div className="text-slate-500 pl-4">└─► Shared API (/api/*) ─► Prisma ORM ─► PostgreSQL Database</div>
              <div className="text-[#7B4DFF] mt-2">Mobile App Flutter (Dart)</div>
              <div className="text-slate-500 pl-4">└─► Shared API (/api/*) ─► Prisma ORM ─► PostgreSQL Database</div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 bg-slate-950 border-t border-slate-800 flex items-center justify-between">
          <span className="text-[11px] text-slate-400">
            Quick Schools Architecture Audit Complete · Standard Flutter 3.19+ & Next.js
          </span>
          <button
            onClick={onClose}
            className="px-4 py-2 rounded-lg bg-[#531FFF] hover:bg-[#4516DB] text-white text-xs font-semibold transition-colors"
          >
            Tutup & Lanjutkan Eksplorasi
          </button>
        </div>
      </div>
    </div>
  );
}
