import React, { useState } from 'react';
import { Send, Server, CheckCircle2, Play, Terminal, ArrowRight } from 'lucide-react';

export function ApiConsole() {
  const [selectedEndpoint, setSelectedEndpoint] = useState<string>('/api/auth/login');
  const [method, setMethod] = useState<'GET' | 'POST'>('POST');
  const [requestBody, setRequestBody] = useState<string>(
    JSON.stringify(
      {
        email: 'raditya.pratama@quickschools.sch.id',
        password: 'password123',
      },
      null,
      2
    )
  );
  const [responseOutput, setResponseOutput] = useState<string>('// Tekan "Kirim Request" untuk menguji API...');
  const [responseStatus, setResponseStatus] = useState<number | null>(null);
  const [responseTime, setResponseTime] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const endpoints = [
    {
      name: 'Login (JWT & RBAC)',
      method: 'POST',
      url: '/api/auth/login',
      defaultBody: {
        email: 'raditya.pratama@quickschools.sch.id',
        password: 'password123',
      },
    },
    {
      name: 'Get Current Session',
      method: 'GET',
      url: '/api/auth/me',
      defaultBody: null,
    },
    {
      name: 'List Presensi Terkini',
      method: 'GET',
      url: '/api/attendance',
      defaultBody: null,
    },
    {
      name: 'Input Presensi Baru',
      method: 'POST',
      url: '/api/attendance/mark',
      defaultBody: {
        studentId: 'usr-student-1',
        status: 'PRESENT',
        notes: 'Presensi API Test via Next.js Route Handler',
      },
    },
    {
      name: 'Jadwal Pelajaran',
      method: 'GET',
      url: '/api/schedules',
      defaultBody: null,
    },
    {
      name: 'Daftar Nilai Siswa',
      method: 'GET',
      url: '/api/grades',
      defaultBody: null,
    },
    {
      name: 'Pengumuman Sekolah',
      method: 'GET',
      url: '/api/announcements',
      defaultBody: null,
    },
    {
      name: 'Health Check Backend',
      method: 'GET',
      url: '/api/health',
      defaultBody: null,
    },
  ];

  const handleSelectEndpoint = (ep: any) => {
    setSelectedEndpoint(ep.url);
    setMethod(ep.method);
    setRequestBody(ep.defaultBody ? JSON.stringify(ep.defaultBody, null, 2) : '');
  };

  const executeRequest = async () => {
    setIsLoading(true);
    const start = performance.now();
    try {
      const options: RequestInit = {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer sample_quick_schools_jwt_token',
        },
      };

      if (method === 'POST' && requestBody.trim()) {
        options.body = requestBody;
      }

      const res = await fetch(selectedEndpoint, options);
      const duration = Math.round(performance.now() - start);
      setResponseStatus(res.status);
      setResponseTime(duration);

      const json = await res.json();
      setResponseOutput(JSON.stringify(json, null, 2));
    } catch (err: any) {
      setResponseStatus(500);
      setResponseOutput(JSON.stringify({ error: err.message }, null, 2));
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex flex-col h-full bg-slate-900 rounded-2xl border border-slate-800 overflow-hidden shadow-xl">
      {/* Header */}
      <div className="p-3.5 bg-slate-950 border-b border-slate-800 flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-lg bg-sky-500/20 border border-sky-500/40 flex items-center justify-center text-sky-400">
            <Server className="w-4 h-4" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-xs font-bold text-white uppercase tracking-wider">
                Shared Next.js Route Handlers (API)
              </h3>
              <span className="text-[10px] px-2 py-0.5 rounded-full bg-sky-500/10 text-sky-400 font-medium border border-sky-500/20">
                REST API Active
              </span>
            </div>
            <p className="text-[11px] text-slate-400">
              Digunakan bersama oleh Website Next.js & Mobile App Flutter
            </p>
          </div>
        </div>

        <button
          onClick={executeRequest}
          disabled={isLoading}
          className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-[#531FFF] hover:bg-[#4516DB] text-white text-xs font-semibold shadow-xs transition-colors"
        >
          {isLoading ? (
            <span className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
          ) : (
            <Play className="w-3.5 h-3.5 fill-white" />
          )}
          <span>Kirim Request</span>
        </button>
      </div>

      <div className="flex-1 flex overflow-hidden">
        {/* Left Endpoint List */}
        <div className="w-64 border-r border-slate-800 bg-slate-950/60 p-2 overflow-y-auto shrink-0 space-y-1">
          <div className="px-2 py-1 text-[10px] font-bold uppercase tracking-wider text-slate-500">
            Endpoints Tersedia
          </div>
          {endpoints.map((ep) => (
            <button
              key={ep.url + ep.method}
              onClick={() => handleSelectEndpoint(ep)}
              className={`w-full flex items-center justify-between p-2 rounded-lg text-left text-xs transition-all ${
                selectedEndpoint === ep.url && method === ep.method
                  ? 'bg-slate-800 text-white font-medium border-l-2 border-[#531FFF]'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/40'
              }`}
            >
              <span className="truncate">{ep.name}</span>
              <span
                className={`text-[9px] px-1.5 py-0.5 rounded font-bold shrink-0 ml-1 ${
                  ep.method === 'POST' ? 'bg-amber-500/20 text-amber-400' : 'bg-emerald-500/20 text-emerald-400'
                }`}
              >
                {ep.method}
              </span>
            </button>
          ))}
        </div>

        {/* Right Request & Response Panes */}
        <div className="flex-1 flex flex-col overflow-hidden bg-slate-900">
          {/* URL bar */}
          <div className="p-3 bg-slate-950/80 border-b border-slate-800 flex items-center gap-2">
            <span
              className={`text-xs px-2 py-1 rounded font-bold ${
                method === 'POST' ? 'bg-amber-500/20 text-amber-400' : 'bg-emerald-500/20 text-emerald-400'
              }`}
            >
              {method}
            </span>
            <input
              type="text"
              readOnly
              value={selectedEndpoint}
              className="flex-1 bg-slate-900 border border-slate-800 rounded-lg px-3 py-1 text-xs text-white font-mono"
            />
          </div>

          <div className="flex-1 grid grid-cols-2 divide-x divide-slate-800 overflow-hidden">
            {/* Request Payload */}
            <div className="flex flex-col overflow-hidden p-3 bg-[#0B0F19]">
              <div className="flex items-center justify-between mb-2">
                <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                  Request Body (JSON)
                </span>
                <span className="text-[10px] text-slate-500 font-mono">Bearer Token Auto-Injected</span>
              </div>
              <textarea
                value={requestBody}
                onChange={(e) => setRequestBody(e.target.value)}
                placeholder="No request body required for GET..."
                className="flex-1 w-full p-2.5 rounded-lg bg-slate-950 border border-slate-800 text-xs font-mono text-slate-200 resize-none focus:outline-hidden focus:border-[#531FFF]"
              />
            </div>

            {/* Response Output */}
            <div className="flex flex-col overflow-hidden p-3 bg-[#090D16]">
              <div className="flex items-center justify-between mb-2">
                <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                  Response Output
                </span>
                {responseStatus !== null && (
                  <div className="flex items-center gap-2 text-[11px] font-mono">
                    <span
                      className={`px-1.5 py-0.5 rounded font-bold ${
                        responseStatus >= 200 && responseStatus < 300
                          ? 'bg-emerald-500/20 text-emerald-400'
                          : 'bg-rose-500/20 text-rose-400'
                      }`}
                    >
                      Status {responseStatus}
                    </span>
                    <span className="text-slate-500">{responseTime}ms</span>
                  </div>
                )}
              </div>
              <pre className="flex-1 p-2.5 rounded-lg bg-slate-950 border border-slate-800 text-xs font-mono text-emerald-400 overflow-auto">
                <code>{responseOutput}</code>
              </pre>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
