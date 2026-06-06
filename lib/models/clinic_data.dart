import 'package:latlong2/latlong.dart';

class ClinicData {
  final String id;
  final String name;
  final String address;
  final double distance;
  final String phone;
  final bool isDots;
  final double rating;
  final String operationalHours;
  final double latitude;
  final double longitude;

  const ClinicData({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.phone,
    this.isDots = false,
    required this.rating,
    required this.operationalHours,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  String get distanceLabel {
    if (distance < 1.0) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  static ClinicData? fromOsmElement(Map<String, dynamic> element, LatLng userPos) {
    final tags = element['tags'] as Map<String, dynamic>?;
    if (tags == null) return null;

    final name = tags['name'] as String?;
    if (name == null || name.isEmpty) return null;

    final type = element['type'] as String?;
    final hasCoords = type == 'node' ||
        (type == 'way' && element['center'] != null);
    if (!hasCoords) return null;

    final addrFull = tags['addr:full'] as String?;
    if (addrFull != null && addrFull.isNotEmpty) {
      return _buildClinic(element, userPos, tags, addrFull);
    }

    final street = tags['addr:street'] as String? ?? '';
    final place = tags['addr:place'] as String? ?? tags['addr:suburb'] as String? ?? '';
    final district = tags['addr:district'] as String? ?? tags['addr:subdistrict'] as String? ?? '';
    final city = tags['addr:city'] as String? ?? '';
    final province = tags['addr:province'] as String? ?? tags['addr:state'] as String? ?? '';

    final fullAddress = [street, place, district, city, province]
        .where((s) => s.isNotEmpty)
        .join(', ');

    final isHospital = tags['amenity'] == 'hospital';
    final fallbackAddress = isHospital ? 'Rumah Sakit' : 'Klinik';

    return _buildClinic(element, userPos, tags,
        fullAddress.isNotEmpty ? fullAddress : fallbackAddress);
  }

  static ClinicData _buildClinic(
    Map<String, dynamic> element,
    LatLng userPos,
    Map<String, dynamic> tags,
    String address,
  ) {
    final name = tags['name'] as String;
    final isHospital = tags['amenity'] == 'hospital';
    final phone = tags['phone'] as String? ?? tags['contact:phone'] as String? ?? '';

    double lat, lon;
    final type = element['type'] as String?;
    if (type == 'node') {
      lat = (element['lat'] as num).toDouble();
      lon = (element['lon'] as num).toDouble();
    } else if (type == 'way' && element['center'] != null) {
      lat = (element['center']['lat'] as num).toDouble();
      lon = (element['center']['lon'] as num).toDouble();
    } else {
      lat = 0;
      lon = 0;
    }

    final distKm = const Distance().as(LengthUnit.Kilometer, userPos, LatLng(lat, lon));

    return ClinicData(
      id: '${element['type']}_${element['id']}',
      name: name,
      address: address,
      distance: distKm,
      phone: phone,
      isDots: isHospital,
      rating: 0,
      operationalHours: tags['opening_hours'] as String? ?? '-',
      latitude: lat,
      longitude: lon,
    );
  }

  static List<ClinicData> mockData() {
    return const [
      ClinicData(
        id: '1',
        name: 'Puskesmas Kecamatan Menteng',
        address: 'Jl. Pegangsaan Timur No.19, Menteng',
        distance: 1.2,
        phone: '(021) 3903916',
        isDots: true,
        rating: 4.3,
        operationalHours: '08:00 - 16:00',
      ),
      ClinicData(
        id: '2',
        name: 'RS Persahabatan',
        address: 'Jl. Persahabatan Raya No.1, Rawamangun',
        distance: 3.5,
        phone: '(021) 4891708',
        isDots: true,
        rating: 4.5,
        operationalHours: '24 Jam',
      ),
      ClinicData(
        id: '3',
        name: 'Puskesmas Cempaka Putih',
        address: 'Jl. Cempaka Putih Tengah I No.1',
        distance: 4.8,
        phone: '(021) 4244375',
        isDots: true,
        rating: 4.1,
        operationalHours: '08:00 - 15:00',
      ),
      ClinicData(
        id: '4',
        name: 'Klinik Medika Utama',
        address: 'Jl. Salemba Raya No.28',
        distance: 5.2,
        phone: '(021) 3904422',
        isDots: false,
        rating: 4.0,
        operationalHours: '09:00 - 21:00',
      ),
      ClinicData(
        id: '5',
        name: 'Puskesmas Senen',
        address: 'Jl. Senen Raya No.135, Senen',
        distance: 6.1,
        phone: '(021) 3451234',
        isDots: true,
        rating: 4.2,
        operationalHours: '08:00 - 16:00',
      ),
    ];
  }
}
