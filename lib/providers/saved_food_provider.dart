import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/auth.dart';

class SavedFoodProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _savedRecipes = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> get savedRecipes => List.unmodifiable(_savedRecipes);

  // Fetch saved recipes from Firestore
  Future<void> fetchSavedRecipes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_recipes') // Ensure consistent collection name
          .get();

      // Clear the current saved recipes and load new ones
      _savedRecipes
        ..clear()
        ..addAll(snapshot.docs.map((doc) => doc.data()));

      notifyListeners(); // Notify listeners after data is fetched
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching saved recipes: $e");
      }
      throw Exception("Error fetching saved recipes");
    }
  }

  // Add a recipe to saved list and Firestore
  Future<void> addRecipe(Map<String, dynamic> recipe) async {
    try {
      _savedRecipes.add(recipe);
      notifyListeners();

      // Add to Firestore
      final userId = Auth().getCurrentUserId(); // Replace with your method to get the user ID
      if (userId != null) {
        final userRef = _firestore.collection('users').doc(userId);
        await userRef
            .collection('saved_recipes') // Ensure consistent collection name
            .doc(recipe['id'].toString())
            .set(recipe);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding recipe: $e");
      }
      throw Exception("Error adding recipe");
    }
  }

  // Remove a recipe from saved list and Firestore
  Future<void> removeRecipe(Map<String, dynamic> recipe) async {
    try {
      _savedRecipes.removeWhere((savedRecipe) => savedRecipe['id'] == recipe['id']);
      notifyListeners();

      // Remove from Firestore
      final userId = Auth().getCurrentUserId(); // Replace with your method to get the user ID
      if (userId != null) {
        final userRef = _firestore.collection('users').doc(userId);
        await userRef
            .collection('saved_recipes') // Ensure consistent collection name
            .doc(recipe['id'].toString())
            .delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error removing recipe: $e");
      }
      throw Exception("Error removing recipe");
    }
  }
}
