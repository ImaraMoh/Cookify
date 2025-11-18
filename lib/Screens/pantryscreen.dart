import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/ingredient_based_screen.dart';
import 'package:mobile_app/Screens/recipe_list_screen.dart';

class PantryScreen extends StatefulWidget {
  final List<String> selectedIngredients;
final Function(List<String>) onIngredientsChanged;
  PantryScreen({required this.selectedIngredients,required this.onIngredientsChanged});

  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  List<String> ingredients = [];
  final Color selectedPurple = const Color.fromARGB(255, 182, 148, 224);

  @override
  void initState() {
    super.initState();
    // Convert all ingredients to lowercase to ensure case-insensitive comparison
    ingredients = widget.selectedIngredients
        .map((ingredient) => ingredient.toLowerCase())
        .toSet() // Use a Set to remove duplicates
        .toList();
  }

  void _deleteIngredient(String ingredient) {
    setState(() {
      ingredients.remove(ingredient);
    });
// Call the callback to update the parent screen
    widget.onIngredientsChanged(ingredients);
    
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Pantry",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ingredients.isEmpty
                ? Center(
                    child: Text(
                      "No ingredients added!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      return Card(
                        elevation: 4, // Adds shadow effect
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                          title: Text(
                            ingredient,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteIngredient(ingredient),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150, // Adjust width as needed
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecipeListScreen(selectedIngredients: widget.selectedIngredients)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPurple, // Corrected parameter
                  ),
                  child: const Text(
                    'See Recipe',
                    style: TextStyle(
                      color: Colors.black, // Set text color to black
                      fontWeight: FontWeight.bold, // Make the text bold
                      inherit: false, // Prevent inheritance from parent TextStyle
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
