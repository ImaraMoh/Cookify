import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Set base URL and API key directly here
  final String _baseUrl = 'https://api.spoonacular.com';

<<<<<<< HEAD
  final String _apiKey = '9ecee3af427949d4b5e9831e0b458576'; // Replace with your actual API key
=======
  final String _apiKey =
      '9ecee3af427949d4b5e9831e0b458576'; // Replace with your actual API key
>>>>>>> d240b15987309f0b54b528b7e6d03fbd1bdc1d6b

//         9ecee3af427949d4b5e9831e0b458576
// a2e8aeca685d4b33975aa0fec27c5fb3
// 171dca80728e4b5bb342e075d07b22c0

  // 1. General Recipe Search
  Future<List<dynamic>> fetchRecipes(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('recipes: $data');
      return data['results'] ?? [];
    } else {
      if (kDebugMode) {
        print('Failed to load recipes: ${response.body}');
      }
      throw Exception('Failed to fetch recipes');
    }
  }

  Future<List<dynamic>> cuisinecategory(
      String cuisine, String type, int number) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/recipes/complexSearch?cuisine=$cuisine&type=$type&number=$number&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('OneCategory: $data');
      return data['results'] ?? [];
    } else {
      if (kDebugMode) {
        print('Failed to load OneCategory: ${response.body}');
      }
      throw Exception('Failed to fetch OneCategory');
    }
  }

<<<<<<< HEAD
  Future<List<dynamic>> timecategory( String type, int maxReadyTime, int number) async {
=======
  Future<List<dynamic>> timecategory(
      String type, int maxReadyTime, int number) async {
>>>>>>> 59df5c70f1ab6f2e5629a40f7e8716ebff70d460
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/recipes/complexSearch?type=$type&maxReadyTime=$maxReadyTime&number=$number&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('OneCategory: $data');
      return data['results'] ?? [];
    } else {
      if (kDebugMode) {
        print('Failed to load OneCategory: ${response.body}');
      }
      throw Exception('Failed to fetch OneCategory');
    }
  }

  Future<List<dynamic>> allcategory(String type, int number) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/recipes/complexSearch?type=$type&number=$number&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results = data['results'] ?? [];
      // Shuffle the results
      results.shuffle(Random());

      print('AllCategory (Shuffled): $results');
      return results;
    } else {
      if (kDebugMode) {
        print('Failed to load AllCategory: ${response.body}');
      }
      throw Exception('Failed to fetch AllCategory');
    }
  }

  // 3. Fetch Recipe Details
  Future<Map<String, dynamic>> fetchRecipeDetails(int id) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/recipes/$id/information?apiKey=$_apiKey&includeNutrition=true'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch recipe details');
    }
  }

  // 4. Fetch Random Recipes
  Future<List<dynamic>> fetchRandomRecipes({int number = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recipes/random?number=$number&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          print('Fetched random recipes: $data');
        }

        if (data['recipes'] != null) {
          return data['recipes'];
        } else {
          if (kDebugMode) {
            print('No recipes found in the response.');
          }
          return [];
        }
      } else {
        throw Exception(
            'Failed to fetch random recipes. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred while fetching random recipes: $e');
      }
      return [];
    }
  }

  // 5. Fetch Related Recipes
  Future<List<dynamic>> fetchRelatedRecipes(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/$id/similar?apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch related recipes');
    }
  }

<<<<<<< HEAD
  Future<Map<String, dynamic>> connectUser(String username, String email) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/users/connect?apiKey=$_apiKey'), // Use your API key here
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'username': username,
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    // If the connection is successful, the response will contain the username, password, and hash.
    return json.decode(response.body);
  } else {
    throw Exception('Failed to connect user to Spoonacular');
=======
  Future<Map<String, dynamic>> connectUser(
      String username, String email) async {
    final response = await http.post(
      Uri.parse(
          '$_baseUrl/users/connect?apiKey=$_apiKey'), // Use your API key here
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      // If the connection is successful, the response will contain the username, password, and hash.
      return json.decode(response.body);
    } else {
      throw Exception('Failed to connect user to Spoonacular');
    }
>>>>>>> 59df5c70f1ab6f2e5629a40f7e8716ebff70d460
  }

  // 8. Autocomplete Suggestions
  Future<List<Map<String, dynamic>>> fetchAutocompleteSuggestions(
      String query) async {
    if (query.isEmpty) {
      return [];
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API response: $data'); // Debug print
      // Cast the response to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('Failed to fetch autocomplete suggestions');
    }
  }

<<<<<<< HEAD
=======
  Future<List<String>> autocompleteingredients(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse(
          '$_baseUrl/food/ingredients/autocomplete?query=$query&number=5&apiKey=$_apiKey'),
    );

    print('Response Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data =
            json.decode(response.body); // The response is already a list

        print('API Response Data: $data'); // Debug the full response

        // Directly map the list to extract the 'name' field
        return List<String>.from(data.map((item) => item['name'].toString()));
      } catch (e) {
        print('Error while parsing response: $e');
        rethrow;
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Exception('Failed to fetch autocomplete suggestions');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecipesByIngredients(
      List<String> ingredients) async {
    if (ingredients.isEmpty) return [];

    String ingredientQuery = ingredients.join(',');
    final url =
        '$_baseUrl/recipes/findByIngredients?ingredients=$ingredientQuery&number=10&apiKey=$_apiKey';

    final response = await http.get(Uri.parse(url));

    // Print the status code and response body for better debugging
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('Response: $data');
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch recipes');
    }
  }

// Add this method to fetch analyzed instructions with images
  Future<List<Map<String, dynamic>>> fetchRecipeInstructions(int id) async {
    // Fetch recipe details first to get the image URL
    final recipeDetails = await fetchRecipeDetails(id);

    // Extract the image URL
    final imageUrl = recipeDetails['image'] ?? '';

    // Fetch analyzed instructions
    final response = await http.get(
      Uri.parse('$_baseUrl/recipes/$id/analyzedInstructions?apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List && data.isNotEmpty) {
        // Append image to each instruction step
        List<Map<String, dynamic>> stepsWithImages = [];
        for (var instruction in data[0]['steps']) {
          stepsWithImages.add({
            'step': instruction['step'],
            'number': instruction['number'],
            'image': imageUrl, // Add the image URL
          });
        }
        return stepsWithImages;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch recipe instructions');
    }
  }

>>>>>>> 59df5c70f1ab6f2e5629a40f7e8716ebff70d460
  // 9. Favorites (Storing locally)
  List<int> favorites = [];

  void addToFavorites(int recipeId) {
    if (!favorites.contains(recipeId)) {
      favorites.add(recipeId);
    }
  }

  void removeFromFavorites(int recipeId) {
    favorites.remove(recipeId);
  }

  bool isFavorite(int recipeId) {
    return favorites.contains(recipeId);
  }
}
