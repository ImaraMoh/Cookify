import 'package:flutter/material.dart';
import 'package:mobile_app/providers/shopping_list_provider.dart';
import 'package:provider/provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();

    // Load shopping list if it's empty
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
    if (shoppingListProvider.shoppingList.isEmpty) {
      shoppingListProvider.loadShoppingList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    final customPurple = const Color.fromARGB(255, 96, 26, 182);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: customPurple,
        automaticallyImplyLeading: false,
      ),
      body: shoppingListProvider.shoppingList.isEmpty
          ? _buildEmptyState() // Empty state when there are no items
          : _buildShoppingList(shoppingListProvider), // Build shopping list if data is available
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'images/start3.png', // Path to your image
            height: 150, // Adjust the height of the image
            width: 150,  // Adjust the width of the image
          ),
          const SizedBox(height: 20), // Space between the image and the text
          const Text(
            'No items in your shopping list!',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingList(ShoppingListProvider shoppingListProvider) {
    return FutureBuilder<Map<String, List<String>>>(
      future: shoppingListProvider.getRecipesWithIngredients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final recipesWithIngredients = snapshot.data!;

        return ListView.builder(
          itemCount: recipesWithIngredients.keys.length,
          itemBuilder: (context, index) {
            final recipeTitle = recipesWithIngredients.keys.elementAt(index);
            final ingredients = recipesWithIngredients[recipeTitle]!;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ExpansionTile(
                title: Text(
                  recipeTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  ...ingredients.map((ingredient) => ListTile(
                        title: Text(ingredient),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Removing ingredient
                            await shoppingListProvider.removeItem(
                              recipeTitle,
                              item: ingredient,
                              deleteRecipe: false,
                            );

                            // Show a confirmation SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Removed $ingredient from $recipeTitle.'),
                              ),
                            );
                          },
                        ),
                      )),
                  ListTile(
                    title: const Text(
                      'Delete Entire Recipe',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () async {
                        // Removing entire recipe
                        await shoppingListProvider.removeItem(
                          recipeTitle,
                          item: recipeTitle,
                          deleteRecipe: true,
                        );

                        // Show a confirmation SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Removed $recipeTitle and its ingredients from shopping list.'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
