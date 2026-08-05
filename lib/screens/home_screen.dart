import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';
import '../core/models/driver_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import 'announcements_screen.dart';

class HomeScreen extends StatefulWidget {
  final String driverId;
  const HomeScreen({super.key, required this.driverId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isActive = false;
  DriverModel? _driver;
  int _parentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDriver();
    _loadParentCount();
  }

  Future<void> _loadDriver() async {
    final driver = await FirestoreService.getDriver(widget.driverId);
    setState(() => _driver = driver);
  }

  Future<void> _loadParentCount() async {
    final count = await FirestoreService.getParentCount(widget.driverId);
    setState(() => _parentCount = count);
  }

  Future<void> _toggle() async {
    if (!_isActive) {
      final permission = await LocationService.requestPermission();
      if (!permission) return;
      setState(() => _isActive = true);
      LocationService.startTracking(widget.driverId);
    } else {
      setState(() => _isActive = false);
      await LocationService.stopTracking(widget.driverId);
    }
  }

  @override
  void dispose() {
    if (_isActive) LocationService.stopTracking(widget.driverId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_driver?.name ?? 'Yükleniyor...'),
            if (_driver != null)
              Text(_driver!.plate,
                style: TextStyle(fontSize: 10, color: AppColors.primaryAccent)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnnouncementsScreen()),
              );
            },
            tooltip: 'Duyurular',
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _isActive ? AppColors.successLight : Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isActive ? '● Canlı' : 'Bekleniyor',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: _isActive ? AppColors.success : Colors.white70),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Büyük başlat/durdur butonu
            GestureDetector(
              onTap: _toggle,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: _isActive ? AppColors.dangerLight : AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isActive ? AppColors.danger : AppColors.success,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isActive ? Icons.stop_circle : Icons.play_circle,
                      size: 52,
                      color: _isActive ? AppColors.danger : AppColors.success,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isActive ? 'Servisi Bitir' : 'Servise Başla',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600,
                        color: _isActive ? AppColors.danger : AppColors.success),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isActive
                        ? 'Konum paylaşımı durur'
                        : 'Konum velilere gönderilecek',
                      style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bilgi kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bağlı veli',
                          style: TextStyle(fontSize: 11,
                            color: AppColors.textSecondary)),
                        Text('$_parentCount',
                          style: const TextStyle(fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Konum',
                            style: TextStyle(fontSize: 11,
                              color: AppColors.textSecondary)),
                          Text(
                            _isActive ? '● Gönderiliyor' : 'Pasif',
                            style: TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _isActive
                                ? AppColors.success
                                : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
