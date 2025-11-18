import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/category_screen.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';
import 'package:mobile_app/Screens/search_results_screen.dart';
import 'package:mobile_app/Services/api_services.dart';

class AddFoodScreen extends StatefulWidget {
  final String userId;

  const AddFoodScreen({super.key, required this.userId});

  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final ApiService _apiService = ApiService(); // Replace with your actual API service
  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _recentlyViewed = [];
  bool isMealPlan = true; bool isSearch =false;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

void navigateToReceipeDetails(Map<String, dynamic> recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(recipeId: recipe['id'],isMealPlan:isMealPlan,isSearch:true),
      ),
    );
    if (result != null) {
      final selectedFood = result['recipe']; // Get the selected food
      final selectedCategory = result['category']; // Get the selected category
      if (selectedFood != null) {
        Navigator.pop(context,{'food':selectedFood, 'category':selectedCategory} ); // Pass the selected food back to MealPlannerScreen
      }
    }
    
  }
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _suggestions = [];
        });
        return;
      }

      try {
        final results = await _apiService.fetchAutocompleteSuggestions(query);
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(results);
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching autocomplete suggestions: $e");
        }
      }
    });
  }

  void _onSuggestionTap(Map<String, dynamic> suggestion) {
    _recentlyViewed.insert(0, suggestion);
    navigateToReceipeDetails(suggestion);
    _searchController.clear();
    setState(() {
      _suggestions = [];
    });
  }

  void _searchFood() async {
    final query = _searchController.text;

    if (query.isNotEmpty) {
      try {
        final results = await _apiService.fetchRecipes(query); // Replace with your actual API call
        setState(() {
          _suggestions = [];
        });
        final selectedFood = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              searchQuery: query,
              recipes: results, // Pass the list of foods
              isMealPlan: isMealPlan,
            ),
          ),
        );

        if (selectedFood != null) {
          Navigator.pop(context, selectedFood); // Pass the selected food back to MealPlannerScreen
        }
       
      } catch (e) {
        if (kDebugMode) {
          print("Error: $e");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load foods. Please try again.'),
          ),
        );
      }
    }
  }

  void _navigateToCategoryScreen(String category) async {
    final selectedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          category: category,
          userId: widget.userId,
          isMealPlan: isMealPlan,
        ),
      ),
    );

    if (selectedFood != null) {
      Navigator.pop(context, {'food':selectedFood, 'category':category}); // Pass the selected food back to MealPlannerScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Food',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section Title
            const Text(
              'Search your food',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (query) => _onSearchChanged(query),
              decoration: InputDecoration(
                labelText: 'Search Food...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: isDarkMode? Colors.white : customPurple),
                  onPressed: _searchFood,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Suggestions List
            if (_suggestions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      leading: Icon(
                        Icons.local_dining, // Use any icon you prefer
                        color: customPurple, // Customize the color of the icon
                      ),
                      title: Text(
                        suggestion['title'] ?? 'No Title', // Access the title instead of id
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _onSuggestionTap(suggestion),
                    );
                  },
                ),
              ),
            if (_suggestions.isEmpty && _searchController.text.isNotEmpty)
              const Center(
                child: Text(
                  'No results found',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            const SizedBox(height: 16),

            // Search by Meal Section
            const Text(
              'Search by Meal Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildMealCard('Breakfast', 'images/breakfast.jpg'),
                  _buildMealCard('Lunch', 'images/lunch.jpg'),
                  _buildMealCard('Dinner', 'images/dinner.jpg'),
                  _buildMealCard('Salad', 'images/salad.jpg'),
                  _buildMealCard('Soup', 'images/soup.jpg'),
                  _buildMealCard('Dessert', 'images/dessert.jpg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Method to Build Meal Cards
  Widget _buildMealCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        _navigateToCategoryScreen(title);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
