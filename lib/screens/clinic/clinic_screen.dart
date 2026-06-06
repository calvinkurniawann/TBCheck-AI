import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/hospital_service.dart';
import '../../models/clinic_data.dart';

class ClinicScreen extends StatefulWidget {
  const ClinicScreen({super.key});

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen>
    with SingleTickerProviderStateMixin {
  final _hospitalService = HospitalService();
  final _searchController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  List<ClinicData> _hospitals = [];
  LatLng? _userLocation;
  bool _isLoading = true;
  String? _errorMessage;
  bool _locationDenied = false;
  String _searchQuery = '';

  static const _searchRadius = 5000;

  List<ClinicData> get _filteredHospitals {
    if (_searchQuery.isEmpty) return _hospitals;
    final q = _searchQuery.toLowerCase();
    return _hospitals.where((h) {
      return h.name.toLowerCase().contains(q) ||
          h.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
    _loadData();
  }

  @override
  void dispose() {
    _hospitalService.dispose();
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _locationDenied = false;
    });

    try {
      Position position;
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (!mounted) return;
          setState(() {
            _errorMessage =
                'Layanan lokasi dimatikan. Aktifkan GPS untuk menemukan klinik terdekat.';
            _isLoading = false;
          });
          return;
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (!mounted) return;
          setState(() {
            _locationDenied = true;
            _errorMessage =
                'Izin lokasi diperlukan untuk menemukan klinik terdekat.';
            _isLoading = false;
          });
          return;
        }
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } on MissingPluginException {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        );
      }

      final userPos = LatLng(position.latitude, position.longitude);
      _userLocation = userPos;

      final hospitals = await _hospitalService.fetchNearbyHospitals(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusMeters: _searchRadius,
      );

      if (!mounted) return;
      setState(() {
        _hospitals = hospitals;
        _isLoading = false;
      });
    } on HospitalServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  void _openDirections(double lat, double lon, String name) async {
    final encodedName = Uri.encodeComponent(name);
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${lat.toStringAsFixed(7)},${lon.toStringAsFixed(7)}&destination_name=$encodedName',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  void _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Column(
          children: [
            _buildMapSection(),
            Expanded(child: _buildBottomSheet()),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.38,
      width: double.infinity,
      color: AppColors.bgLightGray,
      child: Stack(
        children: [
          if (_userLocation != null)
            Positioned.fill(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _userLocation!,
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.doubleTapZoom |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.tbcheck_ai',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),
                  MarkerLayer(markers: _buildMarkers()),
                  MarkerLayer(markers: [_buildUserMarker()]),
                ],
              ),
            )
          else
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter()),
            ),
          if (_userLocation == null && !_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDarkBlue.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      size: 36,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Peta Klinik Terdekat',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.iconGray, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        enabled: !_isLoading && _hospitals.isNotEmpty,
                        decoration: InputDecoration(
                          hintText: _isLoading
                              ? 'Mencari klinik terdekat...'
                              : 'Cari nama atau alamat...',
                          hintStyle:
                              AppTextStyles.caption.copyWith(fontSize: 14),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryDarkBlue,
                        ),
                      )
                    else if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.bgLightGray,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: AppColors.iconGray),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 16,
            child: GestureDetector(
              onTap: _loadData,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: AppColors.primaryDarkBlue, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final list = _searchQuery.isEmpty ? _hospitals : _filteredHospitals;
    return list.map((h) {
      return Marker(
        point: LatLng(h.latitude, h.longitude),
        width: 36,
        height: 36,
        child: GestureDetector(
          onTap: () => _showHospitalDetails(h),
          child: Container(
            decoration: BoxDecoration(
              color: h.isDots ? AppColors.accentTeal : AppColors.primaryDarkBlue,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: AppColors.white, size: 18),
          ),
        ),
      );
    }).toList();
  }

  Marker _buildUserMarker() {
    return Marker(
      point: _userLocation!,
      width: 24,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryMediumBlue,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMediumBlue.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  void _showHospitalDetails(ClinicData clinic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      clinic.name,
                      style: AppTextStyles.heading3,
                    ),
                  ),
                  if (clinic.isDots)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentTealLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'RS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentTeal,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(clinic.address, style: AppTextStyles.bodyRegular),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.place_rounded,
                      size: 16, color: AppColors.primaryMediumBlue),
                  const SizedBox(width: 4),
                  Text(clinic.distanceLabel,
                      style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openDirections(
                        clinic.latitude, clinic.longitude, clinic.name);
                  },
                  icon: const Icon(Icons.directions_rounded, size: 18),
                  label: const Text('Buka Rute'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheet() {
    final displayCount =
        _searchQuery.isEmpty ? _hospitals.length : _filteredHospitals.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Faskes Terdekat',
                        style: AppTextStyles.heading3),
                    const SizedBox(height: 2),
                    Text(
                      _isLoading
                          ? 'Mencari...'
                          : '$displayCount lokasi ditemukan',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryDarkBlue),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _locationDenied
                  ? Icons.location_off_rounded
                  : Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.iconGray,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular,
            ),
            const SizedBox(height: 20),
            if (_locationDenied) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openAppSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Buka Pengaturan Izin'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _openLocationSettings,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDarkBlue,
                    side: const BorderSide(color: AppColors.primaryDarkBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Aktifkan GPS'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final list = _searchQuery.isEmpty ? _hospitals : _filteredHospitals;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off_rounded
                  : Icons.location_off_rounded,
              size: 56,
              color: AppColors.iconGray,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada faskes yang cocok\n dengan "$_searchQuery"'
                  : 'Tidak ada klinik atau rumah sakit\nditemukan di sekitar Anda',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular,
            ),
            const SizedBox(height: 4),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Coba kata kunci lain'
                  : 'Coba perluas jangkauan atau pindah lokasi',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildClinicCard(list[index]);
      },
    );
  }

  Widget _buildClinicCard(ClinicData clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showHospitalDetails(clinic),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: clinic.isDots
                        ? AppColors.accentTeal.withValues(alpha: 0.1)
                        : AppColors.primaryLightBlue.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    clinic.isDots
                        ? Icons.local_hospital_rounded
                        : Icons.medical_services_outlined,
                    color: clinic.isDots
                        ? AppColors.accentTeal
                        : AppColors.primaryMediumBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              clinic.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: clinic.isDots
                                  ? AppColors.accentTealLight
                                  : AppColors.bgLightGray,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              clinic.isDots ? 'RS' : 'Klinik',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: clinic.isDots
                                    ? AppColors.accentTeal
                                    : AppColors.textGray,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clinic.address,
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoTag(
                            Icons.place_rounded,
                            clinic.distanceLabel,
                            AppColors.primaryMediumBlue,
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _openDirections(
                                clinic.latitude, clinic.longitude, clinic.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLightBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.directions_rounded,
                                      size: 14,
                                      color: AppColors.primaryDarkBlue),
                                  SizedBox(width: 4),
                                  Text(
                                    'Rute',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryDarkBlue,
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDarkBlue.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
