import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'package:mobile_app/Screens/recipe_details_screen.dart';
import 'package:mobile_app/Services/api_services.dart';

class RecipeListScreen extends StatefulWidget {
  final List<String> selectedIngredients;
  const RecipeListScreen({super.key, required this.selectedIngredients});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}
 
class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<List<Map<String, dynamic>>> _recipes;
  bool isMealPlan = false;
  bool isSearch=false;
  @override
  void initState() {
    super.initState();
    ApiService apiService = ApiService(); 
    _recipes = apiService.fetchRecipesByIngredients(widget.selectedIngredients);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No recipes found. Please try again later.",
                style: TextStyle(fontSize: 16, color: isDarkMode? Colors.white : Colors.black),
              ),
            );
          }

          final recipes = snapshot.data!;
          
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final randomLikes = (100 + index * 10).toString();

return GestureDetector(
  onTap: () {
    final recipeId = recipe['id'];
    if (recipeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(
            recipeId: recipeId,
            isMealPlan: isMealPlan,isSearch:isSearch,
          ),
        ),
      );
    } else {
      print('Recipe ID is null. Cannot navigate.');
    }
  },
  child: Card(
    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        // Row layout for image and title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  recipe['image'] ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  recipe['title'] ?? 'Recipe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode? Colors.white : Colors.black,
                  ),
                  maxLines: 2, // To handle long titles
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDarkMode? Colors.white : Colors.black,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Allow the bottom sheet to be scrollable
                    builder: (BuildContext context) {
                      return Container(
                        height: 400, // Fixed height for the bottom sheet
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView( // Scrollable content
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Missed Ingredients: ${recipe['missedIngredientCount']}',
                                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),
                              ),
                              SizedBox(height: 8),
                              // ListView for missed ingredients
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: recipe['missedIngredients']?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final ingredient = recipe['missedIngredients'][index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Fixed image size for all ingredients
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.network(
                                            ingredient['image'] ?? '',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(child: CircularProgressIndicator());
                                            },
                                            errorBuilder: (context, error, stackTrace) => const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Ingredient title aligned
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ingredient['name'] ?? 'Unknown Ingredient',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                ingredient['original'] ?? 'No details available',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Used Ingredients: ${recipe['usedIngredientCount']}',
                                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold,),
                              ),
                              SizedBox(height: 8),
                              // ListView for used ingredients
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: recipe['usedIngredients']?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final ingredient = recipe['usedIngredients'][index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Fixed image size for all ingredients
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.network(
                                            ingredient['image'] ?? '',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(child: CircularProgressIndicator());
                                            },
                                            errorBuilder: (context, error, stackTrace) => const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Ingredient title aligned
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ingredient['name'] ?? 'Unknown Ingredient',
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                ingredient['original'] ?? 'No details available',
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);


            },
          );
        },
      ),
    );
  }
}
