import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/auth.dart'; // Assuming you have Auth class to get the current user

class ShoppingListProvider with ChangeNotifier {
  List<String> _shoppingList = [];

  List<String> get shoppingList => _shoppingList;

  // Load shopping list from Firestore
  Future<void> loadShoppingList() async {
    try {
      final shoppingList = await Auth().getShoppingList();
      _shoppingList = shoppingList;
      notifyListeners(); // Notify listeners to update the UI
      if (kDebugMode) {
        print("Shopping list loaded successfully: $_shoppingList");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading shopping list: $e");
      }
    }
  }

  // Add recipe ingredients to Firestore and local state
  Future<void> addRecipeIngredients(String recipeTitle, List<String> ingredients) async {
    final userId = Auth().getCurrentUserId(); // Get the current user's ID
    if (userId == null) return;

    try {
      final shoppingListRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shopping_list');

      // Store the ingredients in a document with the recipe title as the ID
      await shoppingListRef.doc(recipeTitle).set({
        'ingredients': FieldValue.arrayUnion(ingredients), // Merge ingredients
      });

      // Update the local shopping list
      _shoppingList.addAll(ingredients);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding ingredients to Firestore: $e');
      }
      rethrow; // Re-throw for error handling in the UI
    }
  }

  // Remove an item (ingredient or recipe) from the shopping list
  Future<void> removeItem(String recipeTitle, {required String item, bool deleteRecipe = false}) async {
    final userId = Auth().getCurrentUserId(); // Get the current user's ID

    if (deleteRecipe) {
      // Delete the entire recipe
      try {
        final shoppingListRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('shopping_list');

        // Find the document for the recipe (recipe name matches item)
        final querySnapshot = await shoppingListRef.where(FieldPath.documentId, isEqualTo: item).get();

        if (querySnapshot.docs.isNotEmpty) {
          // Delete the document (entire recipe)
          await shoppingListRef.doc(item).delete();

          // Remove the recipe locally
          _shoppingList.removeWhere((recipe) => recipe == item);
          notifyListeners(); // Notify listeners for immediate UI update

          if (kDebugMode) {
            print("Recipe '$item' removed from Firestore and local state.");
          }
        } else {
          if (kDebugMode) {
            print("Recipe '$item' not found in Firestore.");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error removing recipe from Firestore: $e");
        }
      }
    } else {
      // Delete a specific ingredient
      try {
        final shoppingListRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('shopping_list');

        // Find the document containing the ingredient
        final querySnapshot = await shoppingListRef.get();
        for (var doc in querySnapshot.docs) {
          if (doc['ingredients'].contains(item)) {
            // Remove the ingredient from the 'ingredients' list
            List ingredients = List.from(doc['ingredients']);
            ingredients.remove(item);

            // Update Firestore or delete the document if no ingredients remain
            if (ingredients.isEmpty) {
              await shoppingListRef.doc(doc.id).delete();
              _shoppingList.remove(doc.id); // Remove the recipe from local state
            } else {
              await shoppingListRef.doc(doc.id).update({'ingredients': ingredients});
            }

            break; // Exit once we find and update/delete the document
          }
        }

        // Remove the ingredient locally
        _shoppingList.remove(item);
        notifyListeners(); // Notify listeners for immediate UI update

        if (kDebugMode) {
          print("Ingredient '$item' removed from Firestore and local state.");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error removing ingredient from Firestore: $e");
        }
      }
    }
  }
  Future<Map<String, List<String>>> getRecipesWithIngredients() async {
    final userId = Auth().getCurrentUserId();
    if (userId == null) return {};

    try {
      final shoppingListRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('shopping_list');

      final querySnapshot = await shoppingListRef.get();

      // Convert Firestore data to a map of recipe titles and their ingredients
      final recipesWithIngredients = {
        for (var doc in querySnapshot.docs)
          doc.id: List<String>.from(doc['ingredients'] ?? [])
      };

      return recipesWithIngredients;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipes with ingredients: $e');
      }
      return {};
    }
  }


}
