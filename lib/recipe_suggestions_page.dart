import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipeSuggestionsPage extends StatefulWidget {
  final String? selectedType;
  final List<String> ingredients;

  const RecipeSuggestionsPage({super.key, this.selectedType, required this.ingredients});

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
    final String appId = 'bf3a091f'; // Edamam API'den aldığınız App ID
    final String appKey = '995b24cbd81c5d77b32217aeecf96a1a'; // Edamam API'den aldığınız App Key

    // Malzemeleri virgülle ayırarak birleştirin
    final String ingredientsQuery = widget.ingredients.join(',');

    // API isteği için URL
    final String apiUrl =
        'https://api.edamam.com/search?q=$ingredientsQuery&app_id=$appId&app_key=$appKey&health=${widget.selectedType?.toLowerCase()}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = data['hits'];
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
          final recipe = recipes[index]['recipe'];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Image.network(
                recipe['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(recipe['label']),
              subtitle: Text('Calories: ${recipe['calories'].toStringAsFixed(2)}'),
              onTap: () {
                // Detay sayfasına gitme fonksiyonu (opsiyonel)
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
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['label']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe['image']),
            const SizedBox(height: 16),
            Text(
              recipe['label'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Calories: ${recipe['calories'].toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Text('Ingredients:', style: const TextStyle(fontSize: 18)),
            ...recipe['ingredientLines'].map((line) => Text('- $line')).toList(),
          ],
        ),
      ),
    );
  }
}
