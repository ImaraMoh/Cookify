import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_services.dart';
import 'package:mobile_app/screens/recipe_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
 final bool isMealPlan;
  final String userId;
  const CategoryScreen({super.key, required this.category,required this.userId, required this.isMealPlan});
 
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<dynamic> _categoryRecipes = [];
  bool _isLoading = false;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  // Filter variables
  String? _selectedCuisine;
  String? _selectedTime;
  List<String> cuisines = [
    'Asian',
    'Chinese',
    'Indian',
    'Italian',
    'Japanese',
    'Mexican',
    
  ];

  List<String> times = [
    'Max 15 minutes',
    'Max 30 minutes',
    'Max 60 minutes',
    'More than 60 minutes',
  ];

  @override
  void initState() {
    super.initState();
    fetchRecentlyViewed(); // Fetch recently viewed recipes
    fetchAllRecipes(); // Fetch all recipes by default
    fetchAllRecipes(); // Fetch all recipes by default
  }

// Firestore instance
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// `recentlyViewed` state variable
List<dynamic> _recentlyViewed = [];

// Fetch `recentlyViewed` from Firestore for the specific user
void fetchRecentlyViewed() async {
  try {
    final snapshot = await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('recently_viewed')
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _recentlyViewed = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error fetching recently viewed: $error');
    }
  }
}

// Update `recentlyViewed` in Firestore (under subcollection `recently_viewed`)
void updateRecentlyViewed(Map<String, dynamic> recipe) async {
  try {
    // Check if ID exists and is valid
    if (recipe['id'] == null) {
      throw Exception("Recipe ID is null!");
    }

    // Convert ID to String for Firestore
    String recipeId = recipe['id'].toString();

    final docRef = _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('recently_viewed')
        .doc(recipeId);

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set(recipe);

      setState(() {
        _recentlyViewed.insert(0, recipe);
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error updating recently viewed: $error');
    }
  }
}




  String selectedCategory(String category){
    if(category =='Breakfast') {
      return 'breakfast';
    } else if(category =='Lunch') {
      return 'main course';
    } else if(category =='Dinner') {
      return 'main course';
    }else if(category =='Dessert') {
      return 'dessert';
    } else if(category =='Salad') {
      return 'salad';
    }else if(category =='Soup') {
      return 'soup';
    }else {
      return 'main course';
    }
    
  }
  // Fetch all recipes for the category using AllCategory API
  void fetchAllRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if(selectedCategory(widget.category)=='breakfast')
      {
        final recipes = await ApiService().allcategory(selectedCategory(widget.category), 10);
        final recipes1 = await ApiService().allcategory('bread', 5);
        final recipes2 = await ApiService().allcategory('appetizer', 5);
        List combinedRecipes = [...recipes, ...recipes1, ...recipes2]; // Combine both lists
        combinedRecipes.shuffle(); // Shuffle the list
        setState(() {
          _categoryRecipes = combinedRecipes;
          _isLoading = false;
        });
      }
      else {
        final recipes = await ApiService().allcategory(selectedCategory(widget.category), 20);
        
        setState(() {
          _categoryRecipes = recipes;
          _isLoading = false;
        });
      }
      
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching all recipes for category ${widget.category}: $error');
      }
    }
  }

void fetchFilteredRecipesByCuisine() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Use selected cuisine or fallback to category
    final cuisine = _selectedCuisine == 'Any' || _selectedCuisine == null
        ? widget.category
        : _selectedCuisine!;
    if(selectedCategory(widget.category)=='breakfast'){
        final recipes = await ApiService().cuisinecategory(cuisine, selectedCategory(widget.category), 10);
        final recipes1 = await ApiService().cuisinecategory(cuisine, 'bread', 5);
        final recipes2= await ApiService().cuisinecategory(cuisine, 'appetizer', 5);
        List combinedRecipes = [...recipes, ...recipes1, ...recipes2]; // Combine both lists
        combinedRecipes.shuffle(); // Shuffle the list
        setState(() {
          _categoryRecipes = combinedRecipes;
          _isLoading = false;
        });
    }
    else if(selectedCategory(widget.category)=='dessert'){
        final recipes = await ApiService().cuisinecategory(cuisine, selectedCategory(widget.category), 10);
        final recipes1 = await ApiService().cuisinecategory(cuisine, 'snack', 10);
        
        List combinedRecipes = [...recipes, ...recipes1]; // Combine both lists
        combinedRecipes.shuffle(); // Shuffle the list
        setState(() {
          _categoryRecipes = combinedRecipes;
          _isLoading = false;
        });
    }
    else if(selectedCategory(widget.category)=='main course'){
        final recipes = await ApiService().cuisinecategory(cuisine, selectedCategory(widget.category), 10);
        final recipes1 = await ApiService().cuisinecategory(cuisine, 'side dish', 10);
        
        List combinedRecipes = [...recipes, ...recipes1]; // Combine both lists
        combinedRecipes.shuffle(); // Shuffle the list
        setState(() {
          _categoryRecipes = combinedRecipes;
          _isLoading = false;
        });
    }
    else {
        final recipes = await ApiService().cuisinecategory(cuisine, selectedCategory(widget.category), 20);
        
        setState(() {
          _categoryRecipes = recipes;
          _isLoading = false;
        });
    }
    
  } catch (error) {
    setState(() {
      _isLoading = false;
    });
    if (kDebugMode) {
      print('Error fetching cuisine-based recipes for category ${widget.category}: $error');
    }
  }
}

void fetchFilteredRecipesByTime() async {
  setState(() {
    _isLoading = true;
  }); 

  try {
    // Determine max ready time based on selected time filter
    int maxReadyTime = 0; // Default: no limit
    if (_selectedTime == 'Max 15 minutes') {
      maxReadyTime = 15;
    } else if (_selectedTime == 'Max 30 minutes') {
      maxReadyTime = 30;
    } else if (_selectedTime == 'Max 60 minutes') {
      maxReadyTime = 60;
    } else if (_selectedTime == 'More than 60 minutes') {
      maxReadyTime = 500; // Arbitrary high limit for "More than 60 minutes"
    }

    final recipes = await ApiService().timecategory( selectedCategory(widget.category), maxReadyTime, 5);
    setState(() {
      _categoryRecipes = recipes;
      _isLoading = false;
    });
  } catch (error) {
    setState(() {
      _isLoading = false;
    });
    if (kDebugMode) {
      print('Error fetching time-based recipes for category ${widget.category}: $error');
    }
  }
}

// Apply filters separately
void _applyFilters() {
   if (_selectedCuisine != null && _selectedCuisine != 'Any') {
    fetchFilteredRecipesByCuisine(); // Apply only cuisine filter
  } else if (_selectedTime != null && _selectedTime != 'Any') {
    fetchFilteredRecipesByTime(); // Apply only time filter
  } else {
    fetchAllRecipes(); // No filters selected, fetch all recipes
  }
}


  void addToMealPlanner(Map<String, dynamic> recipe)  {
    Navigator.pop(context, recipe);
}

void _navigateToReceipeDetails(Map<String, dynamic> recipe) async {
    final selectedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailScreen(recipeId: recipe['id'],isMealPlan:widget.isMealPlan,isSearch:false),
      ),
    );

    if (selectedFood != null) {
      Navigator.pop(context, selectedFood); // Pass the selected food back to MealPlannerScreen
    }
  }

  void _showCuisineFilter(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Cuisine',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select Cuisine'),
                  value: _selectedCuisine,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCuisine = newValue;
                    });
                  },
                  items: ['Any', ...cuisines].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context); // Close modal
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showTimeFilter(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select Time'),
                  value: _selectedTime,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTime = newValue;
                    });
                  },
                  items: times.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context); // Close modal
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
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
        title: Text(
          widget.category,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
        backgroundColor: customPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white), // Changed to three-dot vertical icon
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.restaurant),
                              title: const Text('Filter by Cuisine'),
                              onTap: () {
                                Navigator.pop(context); // Close current modal
                                _showCuisineFilter(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.access_time),
                              title: const Text('Filter by Time'),
                              onTap: () {
                                Navigator.pop(context); // Close current modal
                                _showTimeFilter(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),

        ],
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _categoryRecipes.isEmpty
        ? Center(child: Text('No recipes available for ${widget.category}.'))
        : ListView.builder(
            itemCount: _categoryRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _categoryRecipes[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: recipe['image'] != null
                    ? Image.network(
                        recipe['image'],
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            width: 50,
                            color: Colors.grey,
                            child: const Icon(Icons.broken_image,
                                size: 30, color: Colors.white),
                          );
                        },
                      )
                    : Container(
                        height: 50,
                        width: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.fastfood,
                            size: 30, color: Colors.white),
                      ),
                title: Text(
                  recipe['title'] ?? 'No Title',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: widget.isMealPlan
                    ? IconButton( 
                        icon: const Icon(Icons.add, color: Color.fromARGB(255, 96, 26, 182)),
                        onPressed: () {
                          // Add recipe to meal planner
                          addToMealPlanner(recipe); // Implement this function to handle meal planner logic
                        },
                      )
                    : null,
                onTap: () {
                  if (kDebugMode) {
                    print("Recipe data: $recipe");
                  }

                  updateRecentlyViewed(recipe); // Update Firestore with the viewed recipe
                  
                  _navigateToReceipeDetails(recipe);
                },
              );
            },
          ),

    
    
    );
  }
}
