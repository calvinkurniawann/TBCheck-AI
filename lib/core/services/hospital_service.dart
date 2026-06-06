import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../models/clinic_data.dart';

class HospitalService {
  static const _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  static const _timeout = Duration(seconds: 15);
  final http.Client _client;

  HospitalService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ClinicData>> fetchNearbyHospitals({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    final query = '''
[out:json];
(
  node["amenity"="hospital"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="hospital"](around:$radiusMeters,$latitude,$longitude);
);
out body center;
''';

    for (final endpoint in _endpoints) {
      try {
        final uri = Uri.parse(endpoint).replace(
          queryParameters: {'data': query},
        );

        final response = await _client
            .get(uri, headers: {'User-Agent': 'TBCheck-AI/1.0'})
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final elements = data['elements'] as List<dynamic>? ?? [];
          final userPos = LatLng(latitude, longitude);
          final results = <ClinicData>[];

          for (final element in elements) {
            final clinic = ClinicData.fromOsmElement(element, userPos);
            if (clinic != null) results.add(clinic);
          }

          results.sort((a, b) => a.distance.compareTo(b.distance));
          return results;
        }

        if (response.statusCode == 429) continue;
      } on http.ClientException {
        continue;
      } catch (_) {
        continue;
      }
    }

    throw HospitalServiceException(
        'Tidak dapat terhubung ke server. Coba lagi nanti.');
  }

  void dispose() {
    _client.close();
  }
}

class HospitalServiceException implements Exception {
  final String message;
  const HospitalServiceException(this.message);

  @override
  String toString() => message;
}
