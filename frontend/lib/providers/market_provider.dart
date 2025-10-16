import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final marketProvider = FutureProvider((ref) async {
  final response = await ApiService.getMarkets();
  return response.data;
});