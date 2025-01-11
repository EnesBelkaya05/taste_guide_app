import 'package:flutter/material.dart';

class FavoriteRecipesPage extends StatelessWidget {
  final List<dynamic> favoriteRecipes;

  const FavoriteRecipesPage({super.key, required this.favoriteRecipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Geri butonu
          onPressed: () {
            Navigator.pop(context); // Geri gitmek için
          },
        ),
        title: const Text(
          'Favorite Recipes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Arka plan resmi
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image.jpeg.jpg'), // Arka plan resmi
                fit: BoxFit.cover,
              ),
            ),
          ),
          // İçerik
          SafeArea(
            child: Column(
              children: [
                // Başlık
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.black.withOpacity(0.7), // Yarı saydam arka plan
                  child: const Center(
                    child: Text(
                      'Favorite Recipes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Tarif listesi veya boş mesaj
                Expanded(
                  child: favoriteRecipes.isEmpty
                      ? const Center(
                    child: Text(
                      'No favorite recipes yet.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: favoriteRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = favoriteRecipes[index];
                      return Card(
                        color: Colors.white.withOpacity(0.6), // Kart arka plan rengi
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              recipe['image'] ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            recipe['title'] ?? 'No title available',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
