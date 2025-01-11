import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipeSuggestionsPage extends StatefulWidget {
  final List<dynamic> recipes;  // Accept recipes as a named parameter
  final String? selectedType;
  final List<String> ingredients;

  const RecipeSuggestionsPage({super.key, required this.recipes, this.selectedType, required this.ingredients});

  @override
  State<RecipeSuggestionsPage> createState() => _RecipeSuggestionsPageState();
}

class _RecipeSuggestionsPageState extends State<RecipeSuggestionsPage> {
  List<dynamic> recipes = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    final String appKey = 'b4ed831429f1480aab3428592ef29776';

    // Malzemeleri virgülle ayırarak birleştirin
    final String ingredientsQuery = widget.ingredients.join(',');

    // API isteği için URL
    final String apiUrl = 'https://api.spoonacular.com/recipes/complexSearch?apiKey=$appKey&query=$ingredientsQuery&diet=${widget.selectedType?.toLowerCase()}&number=10';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("API Response: $data");  // Yanıtı console'a yazdırıyoruz

        setState(() {
          // Verileri güvenli bir şekilde alıyoruz
          recipes = data['results'] ?? [];
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Suggestions'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text('Failed to fetch recipes. Please try again.'))
          : recipes.isEmpty
          ? const Center(child: Text('No recipes found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];

          // Null kontrolü ile map işlemini güvenli hale getiriyoruz
          final ingredients = recipe['ingredientLines'] ?? []; // ingredientLines null kontrolü

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Image.network(
                recipe['image'] ?? '', // Görsel URL'si için null kontrolü
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(recipe['title'] ?? 'No title available'), // Title için null kontrolü
              subtitle: Text('Calories: ${recipe['calories']?.toStringAsFixed(2) ?? 'N/A'}'), // Calories için null kontrolü
              onTap: () {
                // Detay sayfasına gitme fonksiyonu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(recipe: recipe),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final dynamic recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    // API yanıtında ilgili anahtarların olup olmadığını kontrol ediyoruz
    final String title = recipe['title'] ?? 'No title available';
    final String image = recipe['image'] ?? '';
    final String readyInMinutes = recipe['readyInMinutes']?.toString() ?? 'N/A'; // Null kontrolü
    final List<dynamic> extendedIngredients = recipe['extendedIngredients'] ?? []; // Null kontrolü

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(image),  // Görseli ekliyoruz
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Ready in: $readyInMinutes minutes'), // Süreyi ekliyoruz
            const SizedBox(height: 16),
            const Text('Ingredients:', style: TextStyle(fontSize: 18)),
            ...extendedIngredients.map((ingredient) {
              return Text('- ${ingredient['originalString'] ?? 'N/A'}'); // Null kontrolü
            }).toList(),
            const SizedBox(height: 16),
            const Text('Instructions:', style: TextStyle(fontSize: 18)),
            Text(recipe['instructions'] ?? 'No instructions available'), // Talimatlar için null kontrolü
          ],
        ),
      ),
    );
  }
}
