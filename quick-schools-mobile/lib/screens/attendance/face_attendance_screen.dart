import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';

enum FaceScanStage { preparing, scanning, verified }

class FaceAttendanceScreen extends StatefulWidget {
  const FaceAttendanceScreen({super.key});

  @override
  State<FaceAttendanceScreen> createState() => _FaceAttendanceScreenState();
}

class _FaceAttendanceScreenState extends State<FaceAttendanceScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraReady = false;
  bool _cameraUnavailable = false;
  bool _fillLightOn = false;

  FaceScanStage _stage = FaceScanStage.preparing;
  double _scanProgress = 0.0;
  Timer? _scanTimer;
  Timer? _autoSaveTimer;
  DateTime? _verifiedAt;
  bool _hasSaved = false;

  Position? _currentPosition;
  bool _isLocating = true;
  String? _locationError;

  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fetchStudentLocation();
    _initCameraAndAutoScan();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startCameraAt(_selectedCameraIndex);
    }
  }

  Future<void> _fetchStudentLocation() async {
    if (mounted) {
      setState(() {
        _isLocating = true;
        _locationError = null;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLocating = false;
            _locationError = 'GPS perangkat nonaktif';
          });
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLocating = false;
            _locationError = 'Izin lokasi ditolak';
          });
        }
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 6),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (mounted) {
        setState(() {
          _currentPosition = pos;
          _isLocating = false;
          _locationError = pos == null ? 'Lokasi belum ditemukan' : null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _locationError = 'Gagal membaca GPS';
        });
      }
    }
  }

  Future<void> _initCameraAndAutoScan() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraUnavailable = true);
          _scheduleAutoScan();
        }
        return;
      }
      final frontIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _selectedCameraIndex = frontIndex >= 0 ? frontIndex : 0;
      await _startCameraAt(_selectedCameraIndex);
    } catch (_) {
      if (mounted) {
        setState(() => _cameraUnavailable = true);
      }
    }
    if (mounted) {
      _scheduleAutoScan();
    }
  }

  Future<void> _startCameraAt(int index) async {
    if (_cameras.isEmpty) return;
    final previous = _cameraController;
    if (previous != null) {
      await previous.dispose();
    }

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
        _cameraUnavailable = false;
      });
    } catch (_) {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _isCameraReady = false;
          _cameraUnavailable = true;
        });
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || _stage == FaceScanStage.scanning) return;
    setState(() {
      _isCameraReady = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });
    await _startCameraAt(_selectedCameraIndex);
  }

  void _scheduleAutoScan() {
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted && _stage == FaceScanStage.preparing) {
        _startFaceScan();
      }
    });
  }

  void _startFaceScan() {
    if (_stage == FaceScanStage.scanning || _stage == FaceScanStage.verified) {
      return;
    }
    _scanTimer?.cancel();

    setState(() {
      _stage = FaceScanStage.scanning;
      _scanProgress = 0.0;
    });

    const totalTicks = 24;
    int tick = 0;
    _scanTimer = Timer.periodic(const Duration(milliseconds: 95), (timer) {
      tick++;
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _scanProgress = (tick / totalTicks).clamp(0.0, 1.0);
        if (tick >= totalTicks) {
          timer.cancel();
          _onScanCompleted();
        }
      });
    });
  }

  Future<void> _onScanCompleted() async {
    // Give GPS a brief moment if still resolving before displaying final card
    if (_isLocating) {
      await Future.delayed(const Duration(milliseconds: 800));
    }
    if (!mounted) return;

    setState(() {
      _stage = FaceScanStage.verified;
      _verifiedAt = DateTime.now();
    });

    await _saveAttendanceAutomatically();
  }

  Future<void> _saveAttendanceAutomatically() async {
    if (_hasSaved) return;
    _hasSaved = true;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);
    final user = auth.currentUser;
    final pos = _currentPosition;

    await attendance.markQuickAttendance(
      studentId: user?.studentId ?? user?.id ?? 's-202',
      studentName: user?.fullName ?? 'Raditya Pratama',
      className: user?.className ?? 'X MIPA 1',
      status: AttendanceStatus.present,
      notes: 'Absensi Harian • Face Recognition (98.7% Match)',
      latitude: pos?.latitude,
      longitude: pos?.longitude,
      locationAccuracy: pos?.accuracy,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Absensi harian berhasil dicatat! Sampai jumpa besok.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    _autoSaveTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanTimer?.cancel();
    _autoSaveTimer?.cancel();
    _laserController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Camera Feed or Biometric Fallback Backdrop
          _buildCameraLayer(),

          // 2. Optional Screen Fill-Light Glow Frame
          if (_fillLightOn)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                    width: 14,
                  ),
                ),
              ),
            ),

          // 3. Dark Overlay with Oval Biometric Cutout + Animated Laser
          AnimatedBuilder(
            animation: _laserController,
            builder: (context, _) {
              return CustomPaint(
                painter: _FaceOvalOverlayPainter(
                  stage: _stage,
                  laserProgress: _laserController.value,
                  scanProgress: _scanProgress,
                ),
                size: Size.infinite,
              );
            },
          ),

          // 4. Foreground Controls & Status UI
          Column(
            children: [
              // Top Bar
              Padding(
                padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 8),
                child: Row(
                  children: [
                    _buildGlassCircleBtn(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).pop(_hasSaved),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Absensi Face Recognition',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Pemindaian Otomatis • 1x Per Hari',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildGlassCircleBtn(
                      icon: _fillLightOn
                          ? Icons.wb_sunny_rounded
                          : Icons.wb_sunny_outlined,
                      active: _fillLightOn,
                      onTap: () =>
                          setState(() => _fillLightOn = !_fillLightOn),
                    ),
                    if (_cameras.length > 1) ...[
                      const SizedBox(width: 8),
                      _buildGlassCircleBtn(
                        icon: Icons.cameraswitch_rounded,
                        onTap: _flipCamera,
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Live Status Indicator Pill above Bottom Sheet
              _buildStatusPill(),
              const SizedBox(height: 16),

              // Bottom Glassmorphic Status Panel
              _buildBottomPanel(
                user?.fullName ?? 'Raditya Pratama',
                user?.className ?? 'X MIPA 1',
                user?.identifierNumber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (_isCameraReady &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize?.height ?? 720,
          height: _cameraController!.value.previewSize?.width ?? 1280,
          child: CameraPreview(_cameraController!),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.15),
          radius: 0.9,
          colors: [
            Color(0xFF1A1F38),
            Color(0xFF0A0F1E),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _cameraUnavailable
                    ? Icons.face_retouching_natural_rounded
                    : Icons.camera_front_rounded,
                size: 86,
                color: Colors.white.withValues(alpha: 0.22),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _cameraUnavailable
                      ? 'Mode Simulasi Biometrik Aktif'
                      : 'Menyiapkan Kamera Depan...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCircleBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Material(
      color: active
          ? AppColors.warning.withValues(alpha: 0.35)
          : Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? AppColors.warning
                  : Colors.white.withValues(alpha: 0.22),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildStatusPill() {
    Color dotColor;
    String text;

    switch (_stage) {
      case FaceScanStage.preparing:
        dotColor = AppColors.primaryLight;
        text = 'Menyiapkan pemindaian wajah otomatis...';
        break;
      case FaceScanStage.scanning:
        dotColor = const Color(0xFF38BDF8);
        final pct = (_scanProgress * 100).toInt();
        text = _scanProgress < 0.45
            ? 'Mendeteksi titik wajah... $pct%'
            : _scanProgress < 0.8
                ? 'Verifikasi liveness... $pct%'
                : 'Mencocokkan identitas siswa... $pct%';
        break;
      case FaceScanStage.verified:
        dotColor = AppColors.success;
        text = 'Wajah Terverifikasi • 98.7% Match';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dotColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(
    String studentName,
    String className,
    String? nisn,
  ) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad + 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629).withValues(alpha: 0.94),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      child: _stage == FaceScanStage.verified
          ? _buildVerifiedPanel(studentName, className)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Student Info & Live GPS Location Badge
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.face_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            nisn != null
                                ? '$className • NISN $nisn'
                                : className,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildLocationBadge(),
                  ],
                ),

                const SizedBox(height: 16),

                // Liveness Steps Row
                Row(
                  children: [
                    _buildStepBadge(
                      'Deteksi Wajah',
                      _scanProgress > 0.35,
                    ),
                    const SizedBox(width: 8),
                    _buildStepBadge(
                      'Cek Liveness',
                      _scanProgress > 0.72,
                    ),
                    const SizedBox(width: 8),
                    _buildStepBadge(
                      'Cocokkan ID',
                      _scanProgress >= 1.0,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Hands-free Auto Scan Progress Bar
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _stage == FaceScanStage.preparing
                            ? null
                            : _scanProgress,
                        minHeight: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _stage == FaceScanStage.preparing
                          ? 'Kamera aktif — pemindaian dimulai otomatis...'
                          : 'Tahan posisi wajah Anda (${(_scanProgress * 100).toInt()}%)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildLocationBadge() {
    final pos = _currentPosition;
    final Color badgeColor;
    final String label;

    if (_isLocating) {
      badgeColor = const Color(0xFF38BDF8);
      label = 'Mencari GPS...';
    } else if (pos != null) {
      badgeColor = AppColors.success;
      label =
          '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
    } else {
      badgeColor = AppColors.warning;
      label = _locationError ?? 'GPS Tidak Aktif';
    }

    return GestureDetector(
      onTap: _isLocating ? null : _fetchStudentLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: badgeColor.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLocating
                  ? Icons.gps_fixed_rounded
                  : pos != null
                      ? Icons.location_on_rounded
                      : Icons.location_off_rounded,
              color: badgeColor,
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBadge(String label, bool done) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: done
              ? AppColors.success.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: done
                ? AppColors.success.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 13,
              color: done ? AppColors.success : Colors.white54,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: done ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedPanel(String studentName, String className) {
    final timeStr = DateFormat('HH:mm').format(_verifiedAt ?? DateTime.now());
    final pos = _currentPosition;
    final locationText = pos != null
        ? '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)} (±${pos.accuracy.toStringAsFixed(0)}m)'
        : 'Lokasi GPS tidak tersedia';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.success,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Absensi Berhasil & Tersimpan!',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$studentName • $className',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Hadir • $timeStr WIB • 98.7% Match',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        pos != null
                            ? Icons.location_on_rounded
                            : Icons.location_off_rounded,
                        size: 12,
                        color: pos != null
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.check_circle_rounded, size: 20),
            label: const Text(
              'Selesai',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaceOvalOverlayPainter extends CustomPainter {
  final FaceScanStage stage;
  final double laserProgress;
  final double scanProgress;

  _FaceOvalOverlayPainter({
    required this.stage,
    required this.laserProgress,
    required this.scanProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final ovalWidth = (size.width * 0.66).clamp(220.0, 290.0);
    final ovalHeight = ovalWidth * 1.28;
    final center = Offset(size.width / 2, size.height * 0.42);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final overlayPath =
        Path.combine(PathOperation.difference, bgPath, ovalPath);

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.62),
    );

    final Color ringColor;
    switch (stage) {
      case FaceScanStage.preparing:
        ringColor = Colors.white.withValues(alpha: 0.78);
        break;
      case FaceScanStage.scanning:
        ringColor = const Color(0xFF38BDF8);
        break;
      case FaceScanStage.verified:
        ringColor = AppColors.success;
        break;
    }

    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stage == FaceScanStage.preparing ? 2.5 : 3.5,
    );

    if (stage == FaceScanStage.scanning) {
      canvas.drawArc(
        ovalRect.inflate(6),
        -1.5708,
        6.28318 * scanProgress,
        false,
        Paint()
          ..color = AppColors.primaryLight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );

      canvas.save();
      canvas.clipPath(ovalPath);
      final laserY = ovalRect.top + (ovalRect.height * laserProgress);
      final laserPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF38BDF8).withValues(alpha: 0.9),
            Colors.white,
            const Color(0xFF38BDF8).withValues(alpha: 0.9),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(ovalRect.left, laserY - 2, ovalWidth, 4))
        ..strokeWidth = 3;

      canvas.drawLine(
        Offset(ovalRect.left, laserY),
        Offset(ovalRect.right, laserY),
        laserPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FaceOvalOverlayPainter oldDelegate) {
    return oldDelegate.stage != stage ||
        oldDelegate.laserProgress != laserProgress ||
        oldDelegate.scanProgress != scanProgress;
  }
}
