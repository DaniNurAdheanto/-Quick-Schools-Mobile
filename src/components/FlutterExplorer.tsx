import React, { useState, useEffect } from 'react';
import {
  Folder,
  FileCode,
  Download,
  Copy,
  Check,
  ChevronRight,
  ChevronDown,
  Terminal,
  ExternalLink,
  Layers,
  FileText
} from 'lucide-react';
import JSZip from 'jszip';

interface FileNode {
  name: string;
  path: string;
  type: 'file' | 'directory';
  size?: number;
  children?: FileNode[];
}

export function FlutterExplorer() {
  const [tree, setTree] = useState<FileNode[]>([]);
  const [selectedFile, setSelectedFile] = useState<string>('lib/main.dart');
  const [fileContent, setFileContent] = useState<string>('// Loading Flutter Dart code...');
  const [copied, setCopied] = useState(false);
  const [isExporting, setIsExporting] = useState(false);
  const [expandedFolders, setExpandedFolders] = useState<Record<string, boolean>>({
    'lib': true,
    'lib/core': true,
    'lib/screens': true,
    'lib/providers': true,
    'lib/models': true,
  });

  // Fetch file tree from server
  const loadTree = async () => {
    try {
      const res = await fetch('/api/flutter/files');
      const data = await res.json();
      if (data.tree) {
        setTree(data.tree);
      }
    } catch (err) {
      console.error(err);
    }
  };

  // Fetch content of selected file
  const loadFileContent = async (filePath: string) => {
    setSelectedFile(filePath);
    try {
      const res = await fetch(`/api/flutter/content?path=${encodeURIComponent(filePath)}`);
      const data = await res.json();
      if (data.content) {
        setFileContent(data.content);
      } else {
        setFileContent('// File is empty or binary');
      }
    } catch (err) {
      setFileContent('// Error loading file content');
    }
  };

  useEffect(() => {
    loadTree();
    loadFileContent('lib/main.dart');
  }, []);

  const toggleFolder = (path: string) => {
    setExpandedFolders(prev => ({ ...prev, [path]: !prev[path] }));
  };

  const copyCode = () => {
    navigator.clipboard.writeText(fileContent);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  // Export full project as ZIP
  const exportZip = async () => {
    setIsExporting(true);
    try {
      const zip = new JSZip();
      const folder = zip.folder('quick-schools-mobile');

      // Helper to add files recursively
      const addNodesToZip = async (nodes: FileNode[]) => {
        for (const node of nodes) {
          if (node.type === 'file') {
            try {
              const res = await fetch(`/api/flutter/content?path=${encodeURIComponent(node.path)}`);
              const data = await res.json();
              folder?.file(node.path, data.content || '');
            } catch (e) {
              console.error(e);
            }
          } else if (node.type === 'directory' && node.children) {
            await addNodesToZip(node.children);
          }
        }
      };

      await addNodesToZip(tree);
      const blob = await zip.generateAsync({ type: 'blob' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'quick-schools-mobile.zip';
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (err) {
      console.error('Failed to export ZIP', err);
    } finally {
      setIsExporting(false);
    }
  };

  const renderTree = (nodes: FileNode[], depth = 0) => {
    return nodes.map((node) => {
      const isExpanded = !!expandedFolders[node.path];
      const isSelected = selectedFile === node.path;

      if (node.type === 'directory') {
        return (
          <div key={node.path}>
            <button
              onClick={() => toggleFolder(node.path)}
              className="w-full flex items-center gap-1.5 px-2 py-1.5 text-xs text-slate-300 hover:text-white hover:bg-slate-800/60 rounded-md text-left transition-colors"
              style={{ paddingLeft: `${depth * 14 + 8}px` }}
            >
              {isExpanded ? (
                <ChevronDown className="w-3.5 h-3.5 text-slate-400 shrink-0" />
              ) : (
                <ChevronRight className="w-3.5 h-3.5 text-slate-400 shrink-0" />
              )}
              <Folder className="w-3.5 h-3.5 text-[#7B4DFF] shrink-0" />
              <span className="font-medium truncate">{node.name}</span>
            </button>
            {isExpanded && node.children && renderTree(node.children, depth + 1)}
          </div>
        );
      }

      return (
        <button
          key={node.path}
          onClick={() => loadFileContent(node.path)}
          className={`w-full flex items-center gap-2 px-2 py-1.5 text-xs rounded-md text-left transition-all ${
            isSelected
              ? 'bg-[#531FFF]/25 text-white font-semibold border-l-2 border-[#531FFF]'
              : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/40'
          }`}
          style={{ paddingLeft: `${depth * 14 + 20}px` }}
        >
          {node.name.endsWith('.dart') ? (
            <FileCode className="w-3.5 h-3.5 text-sky-400 shrink-0" />
          ) : node.name.endsWith('.yaml') || node.name.endsWith('.json') ? (
            <FileText className="w-3.5 h-3.5 text-amber-400 shrink-0" />
          ) : (
            <FileText className="w-3.5 h-3.5 text-slate-400 shrink-0" />
          )}
          <span className="truncate">{node.name}</span>
        </button>
      );
    });
  };

  return (
    <div className="flex flex-col h-full bg-slate-900 rounded-2xl border border-slate-800 overflow-hidden shadow-xl">
      {/* Top Action Bar */}
      <div className="p-3.5 bg-slate-950 border-b border-slate-800 flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <div className="w-7 h-7 rounded-lg bg-[#531FFF]/20 border border-[#531FFF]/40 flex items-center justify-center text-[#7B4DFF]">
            <Layers className="w-4 h-4" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="text-xs font-bold text-white uppercase tracking-wider">quick-schools-mobile</h3>
              <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 font-medium border border-emerald-500/20">
                Flutter 3.19+ Ready
              </span>
            </div>
            <p className="text-[11px] text-slate-400">Arsitektur Clean & Provider MVVM</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={exportZip}
            disabled={isExporting}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#531FFF] hover:bg-[#4516DB] text-white text-xs font-semibold shadow-xs transition-colors"
          >
            <Download className="w-3.5 h-3.5" />
            <span>{isExporting ? 'Mempersiapkan ZIP...' : 'Download Project ZIP'}</span>
          </button>
        </div>
      </div>

      {/* Main Dual Pane: Tree & Code Viewer */}
      <div className="flex-1 flex overflow-hidden">
        {/* Left Tree Explorer */}
        <div className="w-64 border-r border-slate-800 bg-slate-950/60 p-2 overflow-y-auto shrink-0 space-y-0.5">
          <div className="px-2 py-1 text-[10px] font-bold uppercase tracking-wider text-slate-500">
            Explorer File Flutter
          </div>
          {tree.length === 0 ? (
            <div className="p-4 text-xs text-slate-500">Memuat berkas project...</div>
          ) : (
            renderTree(tree)
          )}
        </div>

        {/* Right Code Viewer */}
        <div className="flex-1 flex flex-col bg-slate-900 overflow-hidden">
          {/* File Tab Info & Copy Button */}
          <div className="px-4 py-2 bg-slate-950/80 border-b border-slate-800 flex items-center justify-between text-xs">
            <span className="font-mono text-slate-300 font-medium truncate">
              quick-schools-mobile/{selectedFile}
            </span>
            <button
              onClick={copyCode}
              className="flex items-center gap-1.5 px-2.5 py-1 rounded bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-xs transition-colors"
            >
              {copied ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
              <span>{copied ? 'Tersalin' : 'Salin Kode'}</span>
            </button>
          </div>

          {/* Code Area */}
          <div className="flex-1 overflow-auto p-4 font-mono text-xs text-slate-200 leading-relaxed bg-[#0B0F19]">
            <pre className="whitespace-pre">
              <code>{fileContent}</code>
            </pre>
          </div>

          {/* Quick Terminal Guide */}
          <div className="p-3 bg-slate-950 border-t border-slate-800 flex items-center justify-between text-xs text-slate-400">
            <div className="flex items-center gap-2">
              <Terminal className="w-3.5 h-3.5 text-[#7B4DFF]" />
              <span className="font-mono text-slate-300">cd quick-schools-mobile && flutter run</span>
            </div>
            <span className="text-[11px] text-slate-500">Platform: Android (Kotlin) & iOS (Swift)</span>
          </div>
        </div>
      </div>
    </div>
  );
}
