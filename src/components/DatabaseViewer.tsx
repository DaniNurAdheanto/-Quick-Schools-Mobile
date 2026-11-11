import React, { useState, useEffect } from 'react';
import { Database, Table, RefreshCw, Layers, ShieldCheck, CheckCircle2, Clock } from 'lucide-react';

interface DatabaseViewerProps {
  lastUpdated?: number;
}

export function DatabaseViewer({ lastUpdated }: DatabaseViewerProps) {
  const [activeTable, setActiveTable] = useState<string>('attendances');
  const [tablesData, setTablesData] = useState<any>({});
  const [counts, setCounts] = useState<any>({});
  const [isLoading, setIsLoading] = useState(false);

  const fetchTables = async () => {
    setIsLoading(true);
    try {
      const res = await fetch('/api/database/tables');
      const data = await res.json();
      if (data.tables) {
        setTablesData(data.tables);
        setCounts(data.counts || {});
      }
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchTables();
  }, [lastUpdated]);

  const tableList = [
    { key: 'attendances', label: 'attendances', count: counts.attendances || 0 },
    { key: 'users', label: 'users', count: counts.users || 0 },
    { key: 'classes', label: 'class_rooms', count: counts.classes || 0 },
    { key: 'schedules', label: 'schedules', count: counts.schedules || 0 },
    { key: 'grades', label: 'grades', count: counts.grades || 0 },
    { key: 'announcements', label: 'announcements', count: counts.announcements || 0 },
    { key: 'schools', label: 'schools', count: counts.schools || 0 },
  ];

  const currentRows: any[] = tablesData[activeTable] || [];

  return (
    <div className="flex flex-col h-full bg-slate-900 rounded-2xl border border-slate-800 overflow-hidden shadow-xl">
      {/* Header */}
      <div className="p-3.5 bg-slate-950 border-b border-slate-800 flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-lg bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center text-emerald-400">
            <Database className="w-4 h-4" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-xs font-bold text-white uppercase tracking-wider">
                PostgreSQL Database (Prisma ORM)
              </h3>
              <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 font-medium border border-emerald-500/20">
                Single Source of Truth
              </span>
            </div>
            <p className="text-[11px] text-slate-400">
              Shared secara real-time antara Web Portal & Mobile Flutter
            </p>
          </div>
        </div>

        <button
          onClick={fetchTables}
          className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-medium transition-colors"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin text-[#7B4DFF]' : ''}`} />
          <span>Refresh DB</span>
        </button>
      </div>

      {/* Table Selector Tabs */}
      <div className="px-3 py-2 bg-slate-950/70 border-b border-slate-800 flex items-center gap-1.5 overflow-x-auto no-scrollbar">
        {tableList.map((t) => (
          <button
            key={t.key}
            onClick={() => setActiveTable(t.key)}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all ${
              activeTable === t.key
                ? 'bg-[#531FFF] text-white shadow-xs'
                : 'bg-slate-800/60 text-slate-400 hover:text-slate-200 hover:bg-slate-800'
            }`}
          >
            <Table className="w-3 h-3" />
            <span>{t.label}</span>
            <span
              className={`text-[10px] px-1.5 py-0.2 rounded-full ${
                activeTable === t.key ? 'bg-white/20 text-white' : 'bg-slate-700 text-slate-300'
              }`}
            >
              {t.count}
            </span>
          </button>
        ))}
      </div>

      {/* Table Data View */}
      <div className="flex-1 overflow-auto p-4 bg-[#0B0F19]">
        {currentRows.length === 0 ? (
          <div className="p-8 text-center text-xs text-slate-500">Tidak ada baris data pada tabel ini.</div>
        ) : (
          <div className="border border-slate-800 rounded-xl overflow-hidden">
            <table className="w-full text-left text-xs font-mono">
              <thead className="bg-slate-950 text-slate-400 text-[11px] uppercase tracking-wider border-b border-slate-800">
                <tr>
                  {Object.keys(currentRows[0]).map((col) => (
                    <th key={col} className="px-3.5 py-2.5 font-bold whitespace-nowrap">
                      {col}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/80 bg-slate-900/50 text-slate-300">
                {currentRows.map((row, idx) => (
                  <tr key={idx} className="hover:bg-slate-800/40 transition-colors">
                    {Object.entries(row).map(([k, val]: any, colIdx) => (
                      <td key={colIdx} className="px-3.5 py-2.5 whitespace-nowrap">
                        {k === 'status' ? (
                          <span
                            className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                              val === 'PRESENT'
                                ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                                : val === 'LATE'
                                ? 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
                                : 'bg-blue-500/10 text-blue-400 border border-blue-500/20'
                            }`}
                          >
                            {val}
                          </span>
                        ) : k === 'role' ? (
                          <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-[#531FFF]/20 text-[#7B4DFF] border border-[#531FFF]/30">
                            {val}
                          </span>
                        ) : typeof val === 'boolean' ? (
                          val ? 'true' : 'false'
                        ) : val !== null && val !== undefined ? (
                          String(val)
                        ) : (
                          <span className="text-slate-600">null</span>
                        )}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Sync Status Banner */}
      <div className="p-3 bg-slate-950 border-t border-slate-800 flex items-center justify-between text-xs text-slate-400">
        <div className="flex items-center gap-2">
          <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
          <span>Real-time Sync: Input presensi via Mobile langsung tercatat di tabel <strong>attendances</strong></span>
        </div>
        <span className="text-[11px] font-mono text-slate-500">prisma/schema.prisma</span>
      </div>
    </div>
  );
}
