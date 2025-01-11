import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'FavoriteRecipesPage.dart'; // Doğru dosya yolunu yazın

class RecipeSuggestionsPage extends StatefulWidget {
  final List<dynamic> recipes;
  final String? selectedType;
  final List<String> ingredients;

  const RecipeSuggestionsPage({
    super.key,
    required this.recipes,
    this.selectedType,
    required this.ingredients,
  });

  @override
  State<RecipeSuggestionsPage> createState() => _RecipeSuggestionsPageState();
}

class _RecipeSuggestionsPageState extends State<RecipeSuggestionsPage> {
  List<dynamic> recipes = [];
  bool isLoading = true;
  bool hasError = false;
  final List<dynamic> favoriteRecipes = []; // Favori tarifleri saklamak için liste

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    final String appKey = 'b4ed831429f1480aab3428592ef29776';
    final String ingredientsQuery = widget.ingredients.join(',');
    final String apiUrl =
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$appKey&query=$ingredientsQuery&diet=${widget.selectedType?.toLowerCase()}&number=10';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
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

  void toggleFavorite(Map<String, dynamic> recipe) {
    setState(() {
      if (favoriteRecipes.contains(recipe)) {
        favoriteRecipes.remove(recipe);
      } else {
        favoriteRecipes.add(recipe);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Recipe Suggestions',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteRecipesPage(
                    favoriteRecipes: favoriteRecipes, // Favori tarifler listesi
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arka plan görseli
          Positioned.fill(
            child: Image.asset(
              'assets/image.jpeg.jpg', // Görselin yolu
              fit: BoxFit.cover,
            ),
          ),
          // İçerik
          isLoading
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
              final isFavorite = favoriteRecipes.contains(recipe);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                color: Colors.white.withOpacity(0.8), // Yarı saydam beyaz arka plan
                child: ListTile(
                  leading: Image.network(
                    recipe['image'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    recipe['title'] ?? 'No title available',
                    style: const TextStyle(color: Colors.black), // Metin rengi
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => toggleFavorite(recipe),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
