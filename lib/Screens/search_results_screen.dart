import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';
import 'package:mobile_app/services/api_services.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;
  final List<dynamic> recipes;
  final bool isMealPlan;
  const SearchResultsScreen({
    super.key,
    required this.searchQuery,
    required this.recipes,
    required this.isMealPlan,
  });

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  bool isSearch=false;
  // Function to fetch the readyInMinutes for a recipe using its recipeId
  Future<Map<String, dynamic>> _fetchRecipeDetails(int recipeId) async {
    ApiService apiService = ApiService();
    final details = await apiService.fetchRecipeDetails(recipeId); // Fetch details for the recipeId
    return details;
  }

void addToMealPlanner(Map<String, dynamic> recipe)  {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$recipe added successfully'),
      duration: const Duration(seconds: 2), // Adjust the duration if needed
    ),
  );
 
 
  // Delay the navigation to allow the SnackBar to show
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context, recipe);
  });
} 

void navigateToReceipeDetails(Map<String, dynamic> recipe) async {
    final selectedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(recipeId: recipe['id'],isMealPlan:widget.isMealPlan,isSearch:isSearch),
      ),
    );

    if (selectedFood != null) {
      Navigator.pop(context, selectedFood); // Pass the selected food back to MealPlannerScreen
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "${widget.searchQuery}"',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),),
        backgroundColor: customPurple,
      ),
      body: widget.recipes.isEmpty
          ? Center(child: Text('No results found for "${widget.searchQuery}"'))
          : ListView.builder(
              itemCount: widget.recipes.length,
              itemBuilder: (context, index) {
                final recipe = widget.recipes[index];
                final recipeId = recipe['id']; // Get the recipeId (integer)

                return FutureBuilder<Map<String, dynamic>>(
                  future: _fetchRecipeDetails(recipeId), // Fetch details asynchronously
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: recipe['image'] != null
                            ? Image.network(recipe['image'], width: 50, height: 50)
                            : null,
                        trailing: widget.isMealPlan
                            ? IconButton(
                                icon: const Icon(Icons.add, color: Color.fromARGB(255, 96, 26, 182)),
                                onPressed: () { 
                                  // Add recipe to meal planner
                                  addToMealPlanner(recipe); // Implement this function to handle meal planner logic
                                },
                              )
                            : null,
                        title: Text(recipe['title']),
                        subtitle: Text('Loading...'), // Display 'Loading...' until data is fetched
                      );


                    } else if (snapshot.hasError) {
                      return ListTile(
                        leading: recipe['image'] != null
                            ? Image.network(recipe['image'], width: 50, height: 50)
                            : null,
                        trailing: widget.isMealPlan
                            ? IconButton(
                                icon: const Icon(Icons.add, color: Color.fromARGB(255, 96, 26, 182)),
                                onPressed: () {
                                  // Add recipe to meal planner
                                  addToMealPlanner(recipe); // Implement this function to handle meal planner logic
                                },
                              )
                            : null,
                        title: Text(recipe['title']),
                        subtitle: Text('Error loading data'),
                      );


                    } else if (snapshot.hasData) {
                      final recipeDetails = snapshot.data;
                      final readyInMinutes = recipeDetails?['readyInMinutes'] ?? 'No time info';
                      return ListTile(
                        leading: recipe['image'] != null
                            ? Image.network(recipe['image'], width: 50, height: 50)
                            : null,

                        trailing: widget.isMealPlan
                        ? IconButton(
                            icon: const Icon(Icons.add, color: Color.fromARGB(255, 96, 26, 182)),
                            onPressed: () {
                              // Add recipe to meal planner
                              addToMealPlanner(recipe); // Implement this function to handle meal planner logic
                            },
                          )
                        : null,
                        title: Text(recipe['title']),
                        subtitle: Text('Ready in $readyInMinutes minutes'),
                        onTap: () {
                           
                          navigateToReceipeDetails(recipe);
                        },
                      );
                    } else {
                      return ListTile(
                        leading: recipe['image'] != null
                            ? Image.network(recipe['image'], width: 50, height: 50)
                            : null,
                        trailing: widget.isMealPlan
                            ? IconButton(
                                icon: const Icon(Icons.add, color: Color.fromARGB(255, 96, 26, 182)),
                                onPressed: () {
                                  // Add recipe to meal planner
                                  addToMealPlanner(recipe); // Implement this function to handle meal planner logic

                                 
                                },
                              )
                            : null,
                        title: Text(recipe['title']),
                        subtitle: Text('No data available'),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
