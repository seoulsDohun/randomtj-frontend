import 'dart:convert';

import 'package:randomtj/model/sing_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String basicUrl = 'https://api.manana.kr/karaoke';
  static const String popularUrl = '$basicUrl/popular/tj/daily.json';

  static Future<List<SingModel>> getKaraokeOpenApi() async {
    final response = await http.get(Uri.parse(popularUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => SingModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load data');
  }
}
