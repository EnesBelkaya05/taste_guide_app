import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/api_service.dart';
import 'recipe_suggestions_page.dart'; // Import the new page

class RecipeSelectorPage extends StatefulWidget {
  const RecipeSelectorPage({super.key});

  @override
  _RecipeSelectorPageState createState() => _RecipeSelectorPageState();
}

ApiService apiService = new ApiService();

class _RecipeSelectorPageState extends State<RecipeSelectorPage> {
  final List<String> recipeTypes = ['Vegetarian', 'Vegan', 'Meat', 'Dessert'];
  final List<String> selectedIngredients = [];
  String? selectedType;
  bool isLoading = false;

  // This function will fetch the recipes and navigate to RecipeSuggestionsPage
  Future<void> fetchRecipes() async {
    if (selectedType == null || selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipe type and add ingredients')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String ingredients = selectedIngredients.join(',');

    // Burada API URL'sini doğru API anahtarıyla güncellediğinizden emin olun
    final String url = 'https://api.spoonacular.com/recipes/complexSearch?apiKey=b4ed831429f1480aab3428592ef29776&query=$ingredients&diet=$selectedType&number=10';

    try {
      final response = await http.get(Uri.parse(url));

      // API yanıtını kontrol et
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recipes = data['results'];

        // Tarife yönlendirme
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeSuggestionsPage(
              recipes: recipes,  // Tarifleri burada geçiriyoruz
              selectedType: selectedType,  // Seçilen diyet türünü geçiriyoruz
              ingredients: selectedIngredients,  // Seçilen malzemeleri geçiriyoruz
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch recipes. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Selector'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Recipe Type:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedType,
              hint: const Text('Choose a type'),
              items: recipeTypes.map((type) {
                return DropdownMenuItem(
                  value: type.toLowerCase(),
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Enter Ingredients:', style: TextStyle(fontSize: 18)),
            TextField(
              onSubmitted: (value) {
                setState(() {
                  selectedIngredients.add(value);
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter an ingredient and press enter',
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: selectedIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  onDeleted: () {
                    setState(() {
                      selectedIngredients.remove(ingredient);
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading ? null : fetchRecipes,
              child: isLoading ? const CircularProgressIndicator() : const Text('Find Recipes'),
            ),
          ],
        ),
      ),
    );
  }
}
