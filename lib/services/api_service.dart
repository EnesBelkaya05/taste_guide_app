import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = '995b24cbd81c5d77b32217aeecf96a1a';
  final String _appId = 'bf3a091f';
  final String _baseUrl = 'https://api.edamam.com/api/recipes/v2';

  String getApiKey(){
    return _apiKey;
  }

  String getApiId(){
    return _appId;
  }

  Future<List<dynamic>> fetchRecipeSuggestions(String type, List<String> ingredients) async {
    // Malzemeleri birleştir
    final query = ingredients.join(',');

    // API URL'si
    final url = '$_baseUrl?type=public&q=$query&app_id=$_appId&app_key=$_apiKey&health=${type.toLowerCase()}';

    try {
      // API isteği gönder
      final response = await http.get(Uri.parse(url));

      // Yanıt durumu kontrolü
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Tarif sonuçlarını döndür
        return data['hits'] ?? [];
      } else {
        // Yanıt hatası durumunda
        throw Exception('Failed to load recipes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Hata durumunda
      throw Exception('Error fetching data: $e');
    }
  }
}
