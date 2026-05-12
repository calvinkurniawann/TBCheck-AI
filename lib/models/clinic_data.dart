class ClinicData {
  final String id;
  final String name;
  final String address;
  final double distance;
  final String phone;
  final bool isDots;
  final double rating;
  final String operationalHours;

  const ClinicData({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.phone,
    this.isDots = false,
    required this.rating,
    required this.operationalHours,
  });

  String get distanceLabel {
    if (distance < 1.0) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
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
