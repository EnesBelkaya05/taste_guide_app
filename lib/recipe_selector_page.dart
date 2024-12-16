import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/api_service.dart';

class RecipeSelectorPage extends StatefulWidget {
  const RecipeSelectorPage({super.key});

  @override
  _RecipeSelectorPageState createState() => _RecipeSelectorPageState();
}

ApiService apiService = new ApiService();

//Armin Büyük ADAMDIR.

class _RecipeSelectorPageState extends State<RecipeSelectorPage> {
  final List<String> recipeTypes = ['Vegetarian', 'Vegan', 'Meat', 'Dessert'];
  final List<String> selectedIngredients = [];
  String? selectedType;
  bool isLoading = false;
  List<dynamic> recipes = [];

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
    final String url = 'https://api.edamam.com/api/recipes/v2?type=public&q=$ingredients&app_id=${apiService.getApiId()}&app_key=${apiService.getApiKey()}&health=$selectedType';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = data['hits'] ?? [];
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeSuggestionsPage(recipes: recipes),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch recipes')),
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

class RecipeSuggestionsPage extends StatelessWidget {
  final List<dynamic> recipes;

  const RecipeSuggestionsPage({required this.recipes, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Suggestions'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index]['recipe'];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(recipe['label']),
              subtitle: Text('Calories: ${recipe['calories'].toStringAsFixed(2)}'),
              leading: Image.network(
                recipe['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              onTap: () {
                // Detay sayfasına yönlendirme yapılabilir
              },
            ),
          );
        },
      ),
    );
  }
}
