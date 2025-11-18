import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';

class AllRecipesScreen extends StatefulWidget {
  final List<dynamic> recipes;
  late List<int> initialLikeCounts;
  late List<bool> isLiked;

  AllRecipesScreen({super.key, required this.recipes, required this.initialLikeCounts, required this.isLiked});

  @override
  _AllRecipesScreenState createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends State<AllRecipesScreen> {
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  bool isSearch=false;
  void toggleLike(int index) {
    setState(() {
      widget.isLiked[index] = !widget.isLiked[index];
      widget.initialLikeCounts[index] += widget.isLiked[index] ? 1 : -1;
    });
  }

  void _navigateToRecipeDetails(int index) {
  final recipe = widget.recipes[index];
  int recipeIdStr = recipe['id'] ?? '';

  // Check if recipeId is a valid number
  try {
   
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipeId: recipeIdStr, isMealPlan: false,isSearch:isSearch),
      ),
    );
  } catch (e) {
    // Handle the case where recipeId is invalid
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid Recipe ID!')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Latest Recipes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: customPurple,
      ),
      body: widget.recipes.isEmpty
          ? const Center(child: Text('No recipes available.'))
          : ListView.builder(
              itemCount: widget.recipes.length,
              itemBuilder: (context, index) {
                final recipe = widget.recipes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () => _navigateToRecipeDetails(index), // Navigate to details on tap
                    child: SizedBox(
                      height: 280,
                      child: Card(
                        margin: const EdgeInsets.only(top: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: recipe['image'] != null
                                      ? Image.network(
                                          recipe['image'],
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              width: double.infinity,
                                              color: Colors.grey,
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 60,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          height: 200,
                                          width: double.infinity,
                                          color: Colors.grey,
                                          child: const Icon(
                                            Icons.fastfood,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                // Time overlay in the top-left corner
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.timer,
                                            size: 14, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          recipe['preparationMinutes'] != null &&
                                                  recipe['preparationMinutes'] > 0
                                              ? '${recipe['preparationMinutes']} mins'
                                              : recipe['readyInMinutes'] != null
                                                  ? '${recipe['readyInMinutes']} mins'
                                                  : 'N/A',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Favorite Icon (Like Button)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => toggleLike(index), // Pass index here
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Row(
                                        children: [
                                          // Icon(
                                          //   Icons.thumb_up,
                                          //   size: 14,
                                          //   color: widget.isLiked[index]
                                          //       ? const Color.fromARGB(255, 93, 167, 199)
                                          //       : Colors.white, // Change icon color based on the like state
                                          // ),
                                          // const SizedBox(width: 4),
                                          // Text(
                                          //   '${widget.initialLikeCounts[index]}', // Use the specific like count for this item
                                          //   style: const TextStyle(
                                          //       fontSize: 12, color: Colors.white),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Recipe Title
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                recipe['title'] ?? 'No Title',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


