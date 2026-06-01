/// Central API configuration for backend connection.
/// Change [baseUrl] to match your Laravel backend address.
class ApiConfig {
  // For Android Emulator use: http://10.0.2.2:8000
  // For iOS Simulator / physical device on same network: http://<YOUR_IP>:8000
  // For web: http://localhost:8000
  static const String baseUrl = 'http://192.168.1.59:8000';

  // API Endpoints
  static const String screeningCalculate = '/api/screening/calculate';
  static String screeningHistory(int userId) => '/api/screening/history/$userId';

}