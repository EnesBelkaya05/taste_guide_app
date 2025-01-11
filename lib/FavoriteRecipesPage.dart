import 'package:flutter/material.dart';

class FavoriteRecipesPage extends StatelessWidget {
  final List<dynamic> favoriteRecipes;

  const FavoriteRecipesPage({super.key, required this.favoriteRecipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
      ),
      body: favoriteRecipes.isEmpty
          ? const Center(
        child: Text('No favorite recipes yet.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Image.network(
                recipe['image'] ?? '',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(recipe['title'] ?? 'No title available'),
            ),
          );
        },
      ),
    );
  }
}
