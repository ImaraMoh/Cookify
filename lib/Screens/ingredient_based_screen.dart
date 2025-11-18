import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/Screens/pantryscreen.dart';
import 'package:mobile_app/Services/api_services.dart';
import 'package:mobile_app/screens/recipe_list_screen.dart'; // Import RecipeListScreen

class IngredientSearchScreen extends StatefulWidget {
  const IngredientSearchScreen({super.key});

  @override
  _IngredientSearchScreenState createState() => _IngredientSearchScreenState();
}

class _IngredientSearchScreenState extends State<IngredientSearchScreen> {
  final TextEditingController _ingredientController = TextEditingController();
   List<String> _selectedIngredients = []; // For selected ingredients
  List<dynamic> _recipes = [];
  bool _isLoading = false;
  List<String> _suggestions = [];
  Timer? _debounce;
  // Custom colors
  final Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  final Color selectedPurple = const Color.fromARGB(255, 182, 148, 224);

  // Ingredient sets
  // Ingredient sets
final List<String> pantryIngredients = [
  'Butter',
  'Egg',
  'Garlic',
  'Milk',
  'Onion',
  'Sugar',
  'Flour',
  'Olive Oil',
  'Garlic Powder',
  'White Rice',
  'Vinegar',
  'Salt',
  'Honey',
  'Cinnamon',
  'Nutmeg',
  'Baking Powder',
  'Soy Sauce',
  'Tomato Paste',
  'Peanut Butter',
  'Mayonnaise',
  'Mustard',
  'Almonds',
  'Coconut Oil',
  'Maple Syrup',
  'Rice Vinegar',
];
final List<String> nonVegItems = [
  'Chicken',
  'Beef',
  'Pork',
  'Lamb',
  'Turkey',
  'Duck',
  'Goat',
  'Rabbit',
  'Quail',
  'Venison',
  'Salmon',
  'Tuna',
  'Shrimp',
  'Lobster',
  'Crab',
  'Oysters',
  'Mussels',
  'Clams',
  'Squid',
  'Octopus',
  'Anchovies',
  'Sardines',
  'Mackerel',
  'Ham',
  'Bacon',
];

final List<String> vegetables = [
  'Tomato',
  'Cheese',
  'Lemon',
  'Pepper',
  'Spinach',
  'Carrot',
  'Broccoli',
  'Cabbage',
  'Zucchini',
  'Cauliflower',
  'Potato',
  'Cucumber',
  'Radish',
  'Peas',
  'Kale',
  'Asparagus',
  'Eggplant',
  'Mushrooms',
  'Bell Pepper',
  'Lettuce',
  'Sweet Potato',
  'Green Beans',
  'Squash',
  'Artichoke',
];

final List<String> fruits = [
  'Apple',
  'Banana',
  'Orange',
  'Strawberry',
  'Blueberry',
  'Pineapple',
  'Grapes',
  'Watermelon',
  'Mango',
  'Peach',
  'Cherry',
  'Pear',
  'Kiwi',
  'Lime',
  'Plum',
  'Apricot',
  'Papaya',
  'Pomegranate',
  'Raspberry',
  'Blackberry',
  'Nectarine',
  'Tangerine',
  'Dragonfruit',
  'Lychee',
  'Guava',
];

final List<String> dairyProducts = [
  'Milk',
  'Cheese',
  'Yogurt',
  'Butter',
  'Cream',
  'Paneer',
  'Ghee',
  'Curd',
  'Whipped Cream',
  'Buttermilk',
  'Kefir',
  'Sour Cream',
  'Condensed Milk',
  'Goat Cheese',
  'Mozzarella',
  'Ricotta',
  'Cottage Cheese',
  'Feta',
  'Brie',
  'Cream Cheese',
  'Mascarpone',
  'Parmesan',
  'Blue Cheese',
  'Gruyère',
  'Havarti',
];

final List<String> grains = [
  'Rice',
  'Wheat',
  'Oats',
  'Barley',
  'Corn',
  'Quinoa',
  'Buckwheat',
  'Millet',
  'Rye',
  'Sorghum',
  'Bulgur',
  'Couscous',
  'Wild Rice',
  'Teff',
  'Amaranth',
  'Spelt',
  'Farro',
  'Polenta',
  'Brown Rice',
  'White Rice',
  'Freekeh',
  'Couscous',
  'Triticale',
  'Cornmeal',
  'Semolina',
];

final List<String> spicesHerbs = [
  'Basil',
  'Coriander',
  'Cumin',
  'Turmeric',
  'Black Pepper',
  'Paprika',
  'Parsley',
  'Thyme',
  'Rosemary',
  'Oregano',
  'Saffron',
  'Ginger',
  'Nutmeg',
  'Cloves',
  'Dill',
  'Bay Leaves',
  'Allspice',
  'Cinnamon',
  'Cardamom',
  'Chilli Powder',
  'Mint',
  'Lavender',
  'Tarragon',
  'Marjoram',
  'Sage',
];

  final Map<String, bool> isExpanded = {
    'Pantry Ingredients': false,
    'Non Veg':false,
    'Vegetables & Greens': false,
    'Fruits': false,
    'Dairy Products': false,
    'Grains': false,
    'Spices & Herbs': false,
  };

// Callback function to update selectedIngredients
  void _updateIngredients(List<String> updatedIngredients) {
    setState(() {
      _selectedIngredients = updatedIngredients;
    });
  }
  void _toggleIngredient(String ingredient) {
  setState(() {
   
    if (_selectedIngredients.contains(ingredient)) {
      _selectedIngredients.remove(ingredient);
    } else {
      _selectedIngredients.add(ingredient);
    }
  });
}

void _toggle(String ingredient) {
  setState(() {
    String normalizedIngredient = ingredient.toLowerCase(); // Normalize to lowercase
    if (_selectedIngredients.contains(normalizedIngredient)) {
      
    } else {
      _selectedIngredients.add(normalizedIngredient);
    }
  });
}


  List<Widget> buildIngredientWidgets(List<String> ingredients) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return ingredients.map((ingredient) {
      final isSelected = _selectedIngredients.contains(ingredient);
      return GestureDetector(
        onTap: () => _toggleIngredient(ingredient),
        child: Chip(
          label: Text(
            ingredient,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black,
            ),
          ),
          backgroundColor: isSelected ? selectedPurple :  Color.fromARGB(255, 234, 231, 231),
          side: const BorderSide(color: Colors.white),
        ),
      );
    }).toList();
  }

  Widget buildCollapsibleContainer(String title, List<String> ingredients, String imageAsset) {
  final bool expanded = isExpanded[title] ?? false;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add some gap above the heading
            const SizedBox(height: 12), // Adjust the height as needed

            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded[title] = !expanded;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Dynamically add the image with a border and shadow
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2), // Border around the image
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                          offset: Offset(2, 4), // Position of the shadow
                          blurRadius: 6, // Blur effect
                          spreadRadius: 1, // Spread effect
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Match border radius
                      child: Image.asset(
                        imageAsset, // Use a specific image for each section
                        width: 40,
                        height: 30,
                        fit: BoxFit.cover, // Ensure the image fits properly
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // Space between the image and the title
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
            const SizedBox(height: 8), // Adds space between title and ingredients
            const Divider(thickness: 1, color: Colors.grey), // Adds a line under the heading
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Wrap(
                spacing: 4.0,
                children: buildIngredientWidgets(
                    ingredients.take(4).toList()), // Show only 4 chips
              ),
              secondChild: Wrap(
                spacing: 4.0,
                children:
                    buildIngredientWidgets(ingredients), // Show all chips
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  
void goToPantryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantryScreen(selectedIngredients: _selectedIngredients.toList(),
        onIngredientsChanged: _updateIngredients,),
      ),
    );
  }
  
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      ApiService apiService = ApiService();
      
      try {
        final results = await apiService.autocompleteingredients(query);
        print('API Results: $results');  // Debug print

        // Update the suggestions state with the list of names
        setState(() {
          _suggestions = results;  // Assign the list of names directly
        });

        print('Suggestions: $_suggestions');
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching autocomplete suggestions: $e");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _ingredientController,
                      onChanged: (query) {
                        _onSearchChanged(query);
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter ingredients (comma-separated)',
                        labelStyle: TextStyle(color: isDarkMode? Colors.white : customPurple),
                        border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    ),
                        prefixIcon: Icon(Icons.search, color: isDarkMode? Colors.white : customPurple),
                      ),
                    ),
                  ),
                  Container(  // ✅ Wrap Stack inside a Container with a height
                      height: _suggestions.isNotEmpty ? 200 : 0,  // Adjust height dynamically
                      child: Stack(
                        children: [
                          if (_suggestions.isNotEmpty)
                            Positioned(
                              top: -20,  // ✅ Change to 0 to position correctly
                              left: 16,
                              right: 16,
                              child: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  height: 198,
                                  child: ListView.builder(
                                    itemCount: _suggestions.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        leading: IconButton(
                                          icon: const Icon(Icons.add),  // ✅ Correct usage of IconButton
                                          color: customPurple,
                                          onPressed: () => _toggle(_suggestions[index]), // ✅ Now this only triggers when clicking the icon
                                        ),
                                        title: Text(
                                          _suggestions[index],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onTap: () => _toggle(_suggestions[index]), // ✅ Triggers when the list tile itself is tapped
                                      );

                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  
                  buildCollapsibleContainer('Pantry Ingredients', pantryIngredients,'images/pantry.jpg.webp'),
                  buildCollapsibleContainer('Non Veg', nonVegItems,'images/nonveg.jpg'),
                  buildCollapsibleContainer('Vegetables & Greens', vegetables,'images/veg.jpg'),
                  buildCollapsibleContainer('Fruits', fruits,'images/fruit.jpeg'),
                  buildCollapsibleContainer('Dairy Products', dairyProducts,'images/dairy.webp'),
                  buildCollapsibleContainer('Grains', grains,'images/grains.png'),
                  buildCollapsibleContainer('Spices & Herbs', spicesHerbs,'images/spices.jpg'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: isDarkMode? Colors.black12 : Colors.white12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 130, // Adjust width as needed
                child: ElevatedButton(
                  onPressed: () {
                    // Implement logic for My Pantry button
                    goToPantryScreen();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 234, 231, 231), // Corrected parameter
                  ),
                   child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black, // Set default text color to black for the text before the number
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Pantry ('), // Text before the number
                        TextSpan(
                          text: '${_selectedIngredients.length}', // The number (ingredient count)
                          style: TextStyle(
                            color: customPurple, // Set a different color for the number
                          ),
                        ),
                        TextSpan(text: ')'), // Text after the number
                      ],
                    ),
                  ),

                ),
              ),
              SizedBox(
                width: 130, // Adjust width as needed
                child: ElevatedButton(
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeListScreen(selectedIngredients: _selectedIngredients)),
                      );
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPurple, // Corrected parameter
                  ),
                  child: const Text('See Recipe',
                  style: TextStyle(
                    color: Colors.black, // Set text color to black
                    fontWeight: FontWeight.bold, // Make the text bold
                    inherit: false, // Prevent inheritance from parent TextStyle
                  ),),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}




