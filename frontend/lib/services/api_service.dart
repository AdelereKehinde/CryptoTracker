import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://cryptotracker-yof6.onrender.com/', // Change this to your backend URL if needed
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // -------- AUTH --------
  static Future<Response> login(String username, String password) async {
    return await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
  }

  // -------- COINS --------
  static Future<Response> getMarkets() async {
    return await _dio.get('/coins/markets');
  }

  static Future<Response> getCoinDetail(String id) async {
    return await _dio.get('/coins/$id');
  }

  // -------- PORTFOLIO --------
  static Future<Response> getPortfolio(String token) async {
    return await _dio.get(
      '/portfolio',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // 👇 Add this universal POST method (used for adding holdings)
  static Future<Response> post(String endpoint,
      {Map<String, dynamic>? data, String? token}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      return response;
    } on DioException catch (e) {
      print('POST error: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }
}
