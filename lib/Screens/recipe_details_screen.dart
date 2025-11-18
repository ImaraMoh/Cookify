// lib/screens/recipe_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart'; 
import 'package:mobile_app/auth.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:mobile_app/Services/api_services.dart';
import 'package:mobile_app/providers/saved_food_provider.dart';
import 'package:mobile_app/providers/shopping_list_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final int recipeId;
  final bool isMealPlan;
  final bool isSearch;
  RecipeDetailScreen({super.key, required this.recipeId,required this.isMealPlan,required this.isSearch});
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  Future<String?> _showCategorySelectionDialog(BuildContext context) async {
    String? selectedCategory;

    return await showDialog<String>(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select a Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Breakfast Category
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.fastfood, color: Colors.orange), // Icon for Breakfast
                        SizedBox(width: 10),
                        Text('Breakfast'),
                      ],
                    ),
                    tileColor: selectedCategory == 'Breakfast' ? Colors.orange.withOpacity(0.1) : null, // Highlight the selected category
                    trailing: Checkbox(
                      value: selectedCategory == 'Breakfast',
                      onChanged: (bool? value) {
                        setState(() {
                          selectedCategory = value! ? 'Breakfast' : null; // Toggle selection
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Breakfast'; // Select this category
                      });
                    },
                  ),
                  // Lunch Category
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.lunch_dining, color: Colors.green), // Icon for Lunch
                        SizedBox(width: 10),
                        Text('Lunch'),
                      ],
                    ),
                    tileColor: selectedCategory == 'Lunch' ? Colors.green.withOpacity(0.1) : null, // Highlight the selected category
                    trailing: Checkbox(
                      value: selectedCategory == 'Lunch',
                      onChanged: (bool? value) {
                        setState(() {
                          selectedCategory = value! ? 'Lunch' : null; // Toggle selection
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Lunch'; // Select this category
                      });
                    },
                  ),
                  // Dinner Category
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.dinner_dining, color: Colors.purple), // Icon for Dinner
                        SizedBox(width: 10),
                        Text('Dinner'),
                      ],
                    ),
                    tileColor: selectedCategory == 'Dinner' ? Colors.purple.withOpacity(0.1) : null, // Highlight the selected category
                    trailing: Checkbox(
                      value: selectedCategory == 'Dinner',
                      onChanged: (bool? value) {
                        setState(() {
                          selectedCategory = value! ? 'Dinner' : null; // Toggle selection
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Dinner'; // Select this category
                      });
                    },
                  ),
                  // Salad Category
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.restaurant, color: Colors.greenAccent), // Icon for Salad
                        SizedBox(width: 10),
                        Text('Salad'),
                      ],
                    ),
                    tileColor: selectedCategory == 'Salad' ? Colors.greenAccent.withOpacity(0.1) : null, // Highlight the selected category
                    trailing: Checkbox(
                      value: selectedCategory == 'Salad',
                      onChanged: (bool? value) {
                        setState(() {
                          selectedCategory = value! ? 'Salad' : null; // Toggle selection
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Salad'; // Select this category
                      });
                    },
                  ),
                  // Dessert Category
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.cake, color: Colors.pink), // Icon for Dessert
                        SizedBox(width: 10),
                        Text('Dessert'),
                      ],
                    ),
                    tileColor: selectedCategory == 'Dessert' ? Colors.pink.withOpacity(0.1) : null, // Highlight the selected category
                    trailing: Checkbox(
                      value: selectedCategory == 'Dessert',
                      onChanged: (bool? value) {
                        setState(() {
                          selectedCategory = value! ? 'Dessert' : null; // Toggle selection
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Dessert'; // Select this category
                      });
                    },
                  ),
                  // Soup Category
                  ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.soup_kitchen, color: Colors.red), // Icon for Soup
                        SizedBox(width: 10),
                        Text('Soup'),
                      ],
                    ),
                    tileColor: selectedCategory == 'Soup' ? Colors.red.withOpacity(0.1) : null, // Highlight the selected category
                    trailing: Checkbox(
                      value: selectedCategory == 'Soup',
                      onChanged: (bool? value) {
                        setState(() {
                          selectedCategory = value! ? 'Soup' : null; // Toggle selection
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        selectedCategory = 'Soup'; // Select this category
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, selectedCategory); // Return the selected category
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override 
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Details',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the text bold
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        
        future: ApiService().fetchRecipeDetails(recipeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final recipe = snapshot.data!;
            final savedFoodProvider = Provider.of<SavedFoodProvider>(context);
            final shoppingListProvider = Provider.of<ShoppingListProvider>(context);

            // Save the recently viewed recipe
            Auth().saveRecentlyViewedRecipe(
              recipe['id'].toString(),
              recipe['title'],
              recipe['image']
            );

            // Check if the recipe is already saved
            bool isSaved = savedFoodProvider.savedRecipes
                .any((savedRecipe) => savedRecipe['id'] == recipeId);

            // Extract instructions from the recipe data
            final instructions = recipe['analyzedInstructions'] ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (recipe['image'] != null)
                  Image.network(recipe['image'], height: 200, fit: BoxFit.cover),
                const SizedBox(height: 16),
                Text(recipe['title'], style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cooking Time: ${recipe['readyInMinutes']} minutes',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if(isMealPlan)
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
                      if (isMealPlan && isSearch) 
                        IconButton(
                          icon: Icon(Icons.add, color: customPurple),
                          onPressed: () async {
                                // Show dialog to select a category
                                final selectedCategory = await _showCategorySelectionDialog(context);

                                if (selectedCategory != null) {
                                  // If a category is selected, pop the recipe and category to the MealPlannerScreen
                                  Navigator.pop(context, {'recipe': recipe, 'category': selectedCategory});
                                }
                              },
                        )
                      else if (isMealPlan)
                        IconButton(
                          icon: Icon(Icons.add, color: customPurple),
                          onPressed: ()  {
                                 Navigator.pop(context, recipe);
                              },
                        )
                    ],
                  ),

                ],
              ),

                const SizedBox(height: 16),
                // Buttons for saving the recipe and adding ingredients to the shopping list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {

                        final user = Auth().currentUser; // Check logged-in user
                        if (user == null) {
                          // Navigate to SignUpReminder screen if guest user
                          Navigator.pushNamed(context, '/signupReminder');
                          return;
                        }
                        // Toggle saved state
                        if (isSaved) {
                          savedFoodProvider.removeRecipe(recipe);
                        } else {
                          savedFoodProvider.addRecipe(recipe);
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {

                        final user = Auth().currentUser; // Check logged-in user
                        if (user == null) {
                          // Navigate to SignUpReminder screen if guest user
                          Navigator.pushNamed(context, '/signupReminder');
                          return;
                        }
                        
                        final recipeTitle = recipe['title'] ?? 'Unnamed Recipe'; // Use the recipe title or a fallback
                        final ingredients = recipe['extendedIngredients']
                                ?.map<String>((i) => i['original'].toString())
                                .toList() ??
                            [];

                        if (ingredients.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No ingredients found to add to the shopping list.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        try {
                          // Add ingredients to the shoppingListProvider (local state management and Firestore)
                          await shoppingListProvider.addRecipeIngredients(recipeTitle, ingredients);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$recipeTitle ingredients added to the shopping list.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          // Handle errors
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add $recipeTitle ingredients: $e'),
                              duration: const Duration(seconds: 3),
                            ),
                          );

                          if (kDebugMode) {
                            print('Error adding ingredients: $e');
                          }
                        }
                      },
                      child: const Text('Add to Shopping List'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Ingredient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Measurement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                    // Set the heading row height and data row height
                    headingRowHeight: 40, // Adjust height for the heading
                    dataRowHeight: 62, // Adjust height for each row
                    rows: List.generate(recipe['extendedIngredients']?.length ?? 0, (index) {
                      final ingredient = recipe['extendedIngredients'][index];
                      final nameWithMeasurement = ingredient['original'] ?? '';
                      final name = _extractIngredientName(nameWithMeasurement);
                      final measurement = _extractMeasurement(ingredient);
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(name)),
                          DataCell(Text(measurement)),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Directly use _buildInstructionSections with the fetched instructions data
                ..._buildInstructionSections(instructions),
              ],
            );
          }
        },
      ),
    );
  }

  // Function to extract only the ingredient name (without the measurement)
  String _extractIngredientName(String ingredient) {
    // Regular expression to match and remove measurement part (like "1/2 cup", "1 cup", etc.)
    final regExp = RegExp(r'^[0-9\/\.\-\+\*\s]*');
    return ingredient.replaceFirst(regExp, '').trim();
  }

  // Function to extract the full measurement as a string (preserving the fraction, like "1/2 cup")
  String _extractMeasurement(Map<String, dynamic> ingredient) {
    final amount = ingredient['amount']?.toString() ?? '';
    final unit = ingredient['unit'] ?? '';

    // Handle fractions as strings (e.g., "1/2 cup" instead of "0.5 cup")
    final originalMeasurement = ingredient['originalString'] ?? '';
    if (originalMeasurement.isNotEmpty) {
      return originalMeasurement; // Use the original string directly
    }

    // If originalString is not available, use the amount and unit
    return '$amount $unit';
  }
  
  // Function to handle displaying instructions
  List<Widget> _buildInstructionSections(List<dynamic> instructionData) {
    if (instructionData == null || instructionData.isEmpty) {
      return [const Text('No instructions available.', style: TextStyle(fontStyle: FontStyle.italic))];
    }

    return instructionData.map<Widget>((instruction) {
      final steps = (instruction['steps'] as List<dynamic>?) ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (instruction['name'] != null && instruction['name'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                instruction['name'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          if (steps.isEmpty)
            const Text('No steps available.', style: TextStyle(fontStyle: FontStyle.italic)),
          // The entire instruction section in a rounded black container with white text
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: customPurple,
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...steps.map<Widget>((step) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display step number and step description in white text
                        Text(
                          '${step['number']}. ${step['step']}',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        // White divider line after each step
                        const Divider(
                          color: Colors.white, // White divider
                          thickness: 1,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}
