import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';

class RecentlyViewedWidget extends StatelessWidget {
  final List<dynamic> recentlyViewed;
  final bool isMealPlan;
  final bool isSearch;

  RecentlyViewedWidget({
    super.key,
    required List<dynamic> recentlyViewed,
    this.isMealPlan = false,
    this.isSearch = false,
  }) : recentlyViewed = recentlyViewed
            .where((recipe) => recipe['recipeId'] != null)
            .toList(); // Remove null recipeId at initialization

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title for Recently Viewed Foods
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Recently Viewed Recipes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        // If list is empty, show message
        recentlyViewed.isEmpty
            ? const Center(child: Text('No recently viewed recipes'))
            : Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SizedBox(
                  height: 300, // Adjust height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Horizontal scrolling
                    itemCount: recentlyViewed.length,
                    itemBuilder: (context, index) {
                      final recipe = recentlyViewed[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(
                                recipeId: int.parse(recipe['recipeId'].toString()),
                                isMealPlan: isMealPlan,
                                isSearch: isSearch,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 300, // Fixed width for the card
                          child: Card(
                            margin: const EdgeInsets.only(right: 16, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    // Recipe Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      child: recipe['image'] != null
                                          ? Image.network(
                                              recipe['image'],
                                              height: 200,
                                              width: 300,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 200,
                                                  width: 300,
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
                                              width: 300,
                                              color: Colors.grey,
                                              child: const Icon(
                                                Icons.fastfood,
                                                size: 60,
                                                color: Colors.white,
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }
}
