import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_suggestions_page.dart';

class RecipeSelectorPage extends StatefulWidget {
  const RecipeSelectorPage({super.key});

  @override
  _RecipeSelectorPageState createState() => _RecipeSelectorPageState();
}

class _RecipeSelectorPageState extends State<RecipeSelectorPage> {
  final List<String> recipeTypes = ['Vegetarian', 'Vegan', 'Meat', 'Dessert'];
  final List<String> selectedIngredients = [];
  String? selectedType;
  bool isLoading = false;

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
    final String url =
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=b4ed831429f1480aab3428592ef29776&query=$ingredients&diet=$selectedType&number=10';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recipes = data['results'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeSuggestionsPage(
              recipes: recipes,
              selectedType: selectedType,
              ingredients: selectedIngredients,
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
        title: const Text('Recipe Selector', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Arka plan görseli
          Positioned.fill(
            child: Image.asset(
              'assets/image.jpeg.jpg', // Burada doğru dosya yolunu belirtin
              fit: BoxFit.cover,
            ),
          ),
          // İçerik
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Recipe Type:',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedType,
                      hint: const Text('Choose a type', style: TextStyle(color: Colors.white)),
                      dropdownColor: Colors.grey[800], // Açılır menü arka planı
                      style: const TextStyle(color: Colors.white), // Açılır menü yazı rengi
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
                    const Text(
                      'Enter Ingredients:',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onSubmitted: (value) {
                        setState(() {
                          selectedIngredients.add(value);
                        });
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white70,
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
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : fetchRecipes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                          'Find Recipes',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
