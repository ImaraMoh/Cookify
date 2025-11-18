import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/recipe_details_screen.dart';
import 'package:mobile_app/providers/saved_food_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedFoodScreen extends StatefulWidget {
  const SavedFoodScreen({super.key});

  @override
  _SavedFoodScreenState createState() => _SavedFoodScreenState();
}

class _SavedFoodScreenState extends State<SavedFoodScreen> {

  bool isMealPlan=false; bool isSearch=false;

  
//  bacb681154d86f10a5e655bdb2dd4dcfda991b9a
  @override
  void initState() {
    super.initState();

    // Fetch the saved recipes when the screen is loaded if the user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final savedFoodProvider = Provider.of<SavedFoodProvider>(context, listen: false);
      savedFoodProvider.fetchSavedRecipes(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedFoodProvider = Provider.of<SavedFoodProvider>(context);
    final savedRecipes = savedFoodProvider.savedRecipes;
    Color customPurple = const Color.fromARGB(255, 96, 26, 182);

    final user = FirebaseAuth.instance.currentUser;
    // If user is null (guest), display the message 'No saved foods yet'
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Saved Recipes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: customPurple,
          automaticallyImplyLeading: false,
        ),
        body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Add your image here
                  Image.asset(
                    'images/likefood.png', // Path to your image
                    height: 150, // Adjust the height of the image
                    width: 150,  // Adjust the width of the image
                  ),
                  SizedBox(height: 20), // Space between the image and the text
                  Text(
                    'No saved recipes yet!',
                    style: TextStyle(fontSize: 16, ),
                  ),
                ],
              ),
            ),
      );
    }

    // If the user is logged in, display saved recipes
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Recipes',
          
        ),
        titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        backgroundColor: customPurple,
        automaticallyImplyLeading: false,
      ),
      body: savedRecipes.isNotEmpty
          ? ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return ListTile(
                  leading: recipe['image'] != null
                      ? Image.network(recipe['image'], width: 50, height: 50)
                      : null,
                  title: Text(recipe['title']),
                  subtitle: Text(recipe['readyInMinutes'] != null
                      ? 'Ready in ${recipe['readyInMinutes']} minutes'
                      : 'No time info'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      // Remove the recipe from saved list
                      savedFoodProvider.removeRecipe(recipe);
                    },
                  ),
                  onTap: () {
                    // Navigate to RecipeDetailScreen when a recipe is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(

                        builder: (_) => RecipeDetailScreen(recipeId: recipe['id'],isMealPlan:isMealPlan,isSearch:isSearch),

                      ),
                    );
                  },
                );
              },
            )
          :  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Add your image here
                  Image.asset(
                    'images/likefood.png', // Path to your image
                    height: 150, // Adjust the height of the image
                    width: 150,  // Adjust the width of the image
                  ),
                  SizedBox(height: 20), // Space between the image and the text
                  Text(
                    'No saved recipes yet!',
                    style: TextStyle(fontSize: 16, ),
                  ),
                ],
              ),
            ),

    );
  }
}
