import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  final String _apiKey = 'b4ed831429f1480aab3428592ef29776'; // Replace with your Spoonacular API key
  final String _baseUrl = 'https://api.spoonacular.com/recipes/complexSearch';

  String getApiKey() {
    return _apiKey;
  }

  Future<List<dynamic>> fetchRecipeSuggestions(String type, List<String> ingredients) async {
    // Malzemeleri birleştir
    final query = ingredients.join(',');

    // API URL'si
    final url = '$_baseUrl?apiKey=$_apiKey&query=$query&diet=$type&number=10';

    try {
      // API isteği gönder
      final response = await http.get(Uri.parse(url));

      // Yanıt durumu kontrolü
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Tarif sonuçlarını döndür
        return data['results'] ?? [];
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
