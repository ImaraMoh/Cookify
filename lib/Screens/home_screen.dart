import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/allrecipe_screen.dart';
import 'package:mobile_app/Screens/category_screen.dart';
import 'package:mobile_app/Screens/chatscreen.dart';
import 'package:mobile_app/Screens/ingredient_based_screen.dart';
import 'package:mobile_app/Screens/meal_planner_screen.dart';
import 'package:mobile_app/Screens/signUpReminderScreen.dart';
import 'package:mobile_app/Screens/signupremainderScreen1.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:mobile_app/screens/saved_food_screen.dart';
import 'package:mobile_app/screens/shopping_list_screen.dart';
import 'package:mobile_app/screens/profile_screen.dart'; 
import 'package:mobile_app/services/api_services.dart';
import 'package:mobile_app/screens/recipe_details_screen.dart';
import 'package:mobile_app/screens/search_results_screen.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:mobile_app/Screens/recently_viewed_widget.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
  with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;
  String userName = 'User Name';
  String hash = 'null';
  String userid ='null';
  String userEmail = 'email@example.com';
  List<dynamic> _recipes = [];
  List<dynamic> _randomRecipes = [];
  List<dynamic> _recentlyViewed = [];
  late List<int> likeCounts;
  late List<bool> isLiked;
  bool _isIconPressed = false;  
  bool _isLoading = false;
  int _selectedIndex = 0;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  bool isMealPlan =false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRandomRecipes(); // Load random recipes on init
    _loadRecentlyViewedRecipes();
    _connectAndStoreUser();
    final random = Random();
    likeCounts = List.generate(10,(_) => random.nextInt(20) + 1); // Random like count between 1 and 100
    isLiked = List.generate(10, (_) => false); // Initial liked state
  }

  @override
  void dispose() {
    _tabController.dispose();
     _searchController.dispose();
  _suggestions.clear();
    super.dispose();
  }

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecentlyViewedRecipes();
  }
 
Future<void> _connectAndStoreUser() async {
 
  try {
    // Replace with the actual user's details (e.g., from Firebase)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final response = await ApiService().connectUser(user.displayName ?? 'User Name',  user.email ?? 'email@example.com');
      // Save the username and hash in your app's database or storage
      String apiUsername = response['username'];
      String apiHash = response['hash'];
      
      userNameAssign(apiUsername);
      hashAssign(apiHash);
      // Now, save these values locally or send them to your app's database
      if (kDebugMode) {
        print('Connected User: $apiUsername, Hash: $apiHash , $userName,$hash');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error connecting user: $e');
    }
  }
}

void userNameAssign(String apiUsername){
  userName=apiUsername;
}
void hashAssign(String apiHash){
  hash=apiHash;
}

  void toggleLike(int index) {
    setState(() {
      isLiked[index] = !isLiked[index];
      likeCounts[index] += isLiked[index] ? 1 : -1;
    });
  }

   // Fetch recently viewed recipes from Firestore
  Future<void> _loadRecentlyViewedRecipes() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final userId = user.uid;
    userid = userId;

    try {
      final recentlyViewedRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId) 
          .collection('recently_viewed')
          .orderBy('viewedAt', descending: true)
          .limit(10);

      final querySnapshot = await recentlyViewedRef.get();

      setState(() {
        _recentlyViewed = querySnapshot.docs
            .map((doc) {
              // Safely handle missing or null fields from Firestore
              final recipeId = doc['recipeId'] ?? '';
              final title = doc['title'] ?? 'No Title';
              final image = doc['image'] ?? '';  // Use a default empty string if 'image' is null

              return {
                'recipeId': recipeId,
                'title': title,
                'image': image,
              };
            })
            .toList();
      });

     
      
    } catch (e) {
      // Handle any errors that might occur during the Firebase call
      print("Error loading recently viewed recipes: $e");
    }
  }
}





Future<List<Map<String, dynamic>>> fetchRecentlyViewedRecipes(String userId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users') // Assuming each user has a recently viewed list
        .doc(userId)
        .collection('recentlyViewed')
        .orderBy('timestamp', descending: true) // Order by most recently viewed
        .limit(10) // Limit the number of items fetched
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print("Error fetching recently viewed recipes: $e");
    return [];
  }
}

  void _loadRandomRecipes() async {
  setState(() {
    _isLoading = true; // Show loading indicator
  });

  try {
    final randomRecipes = await ApiService().fetchRandomRecipes(number: 10);
    final recipesWithImages = randomRecipes
        .where((recipe) => recipe['image'] != null && recipe['image'].isNotEmpty)
        .toList();

    // Add the recipes to Firestore
    // await _addRecipesToFirestore(recipesWithImages);

    setState(() {
      _randomRecipes = recipesWithImages;
      _isLoading = false; // Stop loading once data is fetched
    });
  } catch (error) {
    setState(() {
      _isLoading = false; // Stop loading in case of error
    });
    if (kDebugMode) {
      print('Error fetching random recipes: $error');
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Failed to load random recipes. Please try again later.')),
    );
  }
}

Future<void> _addRecipesToFirestore(List<dynamic> recipes) async {
  final CollectionReference recipesCollection = FirebaseFirestore.instance.collection('random_recipes');

  for (var recipe in recipes) {
    try {
      // Add each recipe to Firestore
      await recipesCollection.add({
        'id': recipe['id'] ?? '',
        'dishTypes': recipe['dishTypes']??'',
        'title': recipe['title'] ?? 'No Title',
        'image': recipe['image'] ?? '',
        'readyInMinutes': recipe['readyInMinutes'] ?? 'N/A',
        'ingredients': recipe['ingredients'] ?? [],
        'instructions': recipe['instructions'] ?? '',
        'dateAdded': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) {
        print('Recipe added successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error adding recipe to Firestore: $error');
      }
    }
  }
}

  void _searchRecipe() async {
    final query = _searchController.text;

    if (query.isNotEmpty) {
      try {
        final apiService = ApiService();
        final recipes = await apiService.fetchRecipes(query);

        setState(() {
          _recipes = recipes;
          _suggestions = [];
        });
        _searchController.clear();
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => SearchResultsScreen(
              searchQuery: query,
              recipes: _recipes,
              isMealPlan: isMealPlan,
            ),
          ),
        );
       
        
      } catch (error) {
        if (kDebugMode) {
          print('Error: $error');
        }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load recipes. Please try again.'),
        ),
      );
    }
  }
}

  void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () async {
    ApiService apiService = ApiService();
    
    try {
      final results = await apiService.fetchAutocompleteSuggestions(query);
      print('API Results: $results');  // Debug print
      setState(() {
        _suggestions = List<Map<String, dynamic>>.from(results);
      });
      print('Suggestions: $_suggestions');
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching autocomplete suggestions: $e");
      }
    }
  });
}


  void _onSuggestionTap(Map<String, dynamic> suggestion) {
    _recentlyViewed.insert(0, suggestion);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(recipeId: suggestion['id'],isMealPlan:isMealPlan,isSearch:false)),
    );
    _searchController.clear();
    setState(() {
      _suggestions = [];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  
  PreferredSizeWidget _buildAppBar() {
    if (_selectedIndex == 0) {
      return AppBar(
        title: const Row(
          children: [
            Text(
              'Cookify', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ],
        ),
        backgroundColor: customPurple,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isIconPressed = !_isIconPressed;
              });

              if (kDebugMode) {
                print(userName + hash);
              }

              // Check if userId is guest
              if (userid == 'null') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //builder: (context) => MealPlannerScreen(userId: userid),
                    builder: (context) => SignUpReminderPage(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealPlannerScreen(userId: userid),
                    
                  ),
                );
              }

              // Reset icon state when coming back
              Navigator.popUntil(context, (route) {
                if (route.isFirst) {
                  setState(() {
                    _isIconPressed = false;
                  });
                }
                return true;
              });
            },
          ),
        ],
      );
    } else {
      return PreferredSize(preferredSize: const Size(0, 0), child: Container());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: _buildAppBar(), 
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          
             Column(
              children: [
                // Tab Navigation for Explore Recipe and What's in Your Kitchen
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Explore Recipe'),
                    Tab(text: "What's in Your Kitchen"),
                  ],
                  labelColor: isDarkMode ? Colors.white : customPurple, 
                  unselectedLabelColor: isDarkMode ? Colors.white : Colors.black, 
                  indicatorColor: customPurple,
                ),

                Expanded(
                  
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                      child:Column(
                        children: [
                          
                          //search recipe
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 20.0),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (query) {
                                _onSearchChanged(query);
                              },
                              decoration: InputDecoration(
                                labelText: 'Search Recipe...',
                                labelStyle: TextStyle(color: isDarkMode? Colors.white : customPurple),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    ),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.search,
                                  color: isDarkMode? Colors.white : customPurple
                                  ), 
                                  onPressed: _searchRecipe,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: _suggestions.isNotEmpty ? 200 : 0,
                            child: Stack(
                              children: [
                                if (_suggestions.isNotEmpty)
                                Positioned(
                                  top: 0,
                                  left: 16,
                                  right: 16,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        itemCount: _suggestions.length,
                                        itemBuilder: (context, index) {
                                          // Access 'title' from the map at index
                                          var suggestion = _suggestions[index];  // Access the whole suggestion map

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
                                            onTap: () => _onSuggestionTap(_suggestions[index]),  // Pass the whole map to _onSuggestionTap
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),


                          // Latest Recipes Section 
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Our Latest Recipes',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  // Add the "See All" button
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return AllRecipesScreen(
                                              recipes: _randomRecipes,
                                              initialLikeCounts: likeCounts,
                                              isLiked: isLiked,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'See All',
                                      style: TextStyle(color: isDarkMode? Colors.white : customPurple), // Set the text color to customPurple
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: SizedBox(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _isLoading ? 5 : _randomRecipes.length, // Show placeholders while loading
                                itemBuilder: (context, index) {
                                  if (_isLoading) {
                                    // Placeholder Card while loading
                                    return SizedBox(
                                      width: 250,
                                      child: Card(
                                        margin: const EdgeInsets.only(right: 16, bottom: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 200,
                                              width: 250,
                                              color: Colors.grey.shade300, // Light grey background
                                              child: const Icon(
                                                Icons.fastfood, // Placeholder icon
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 16,
                                                width: 150,
                                                color: Colors.grey.shade300, // Simulate a loading bar for title
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Actual Recipe Card when data is loaded
                                    final recipe = _randomRecipes[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (!_recentlyViewed.any((item) => item['id'] == recipe['id'])) {
                                            _recentlyViewed.insert(0, recipe);
                                          }
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RecipeDetailScreen(recipeId: recipe['id'],isMealPlan:isMealPlan,isSearch:false),
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        width: 250,
                                        child: Card(
                                          margin: const EdgeInsets.only(right: 16, bottom: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(10),
                                                      topRight: Radius.circular(10),
                                                    ),
                                                    child: recipe['image'] != null
                                                        ? Image.network(
                                                            recipe['image'],
                                                            height: 200,
                                                            width: 250,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return Container(
                                                                height: 200,
                                                                width: 250,
                                                                color: Colors.grey,
                                                                child: const Icon(Icons.broken_image,
                                                                    size: 60, color: Colors.white),
                                                              );
                                                            },
                                                          )
                                                        : Container(
                                                            height: 200,
                                                            width: 250,
                                                            color: Colors.grey,
                                                            child: const Icon(Icons.fastfood,
                                                                size: 60, color: Colors.white),
                                                          ),
                                                  ),
                                                  // Time overlay in the top-left corner
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: const Color.fromARGB(255, 0, 0, 0)
                                                            .withOpacity(0.6),
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.timer,
                                                              size: 14, color: Colors.white),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            recipe['preparationMinutes'] != null &&
                                                                recipe['preparationMinutes'] > 0
                                                            ? '${recipe['preparationMinutes']} mins'
                                                            : recipe['readyInMinutes'] != null
                                                                ? '${recipe['readyInMinutes']} mins'
                                                                : 'N/A',
                                                            style: const TextStyle(
                                                                fontSize: 12, color: Colors.white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // Like Button
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: GestureDetector(
                                                      onTap: () => toggleLike(index),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.6),
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            // Icon(
                                                            //   Icons.thumb_up,
                                                            //   size: 14,
                                                            //   color: isLiked[index]
                                                            //       ? const Color.fromARGB(255, 93, 167, 199)
                                                            //       : Colors.white,
                                                            // ),
                                                            // const SizedBox(width: 4),
                                                            // Text(
                                                            //   '${likeCounts[index]}',
                                                            //   style: const TextStyle(
                                                            //       fontSize: 12, color: Colors.white),
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Recipe Title
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  recipe['title'] ?? 'No Title', // Fallback for missing title
                                                  style: const TextStyle(
                                                      fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),

                          // Inside the Column in the body of your HomeScreen
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Today\'s Recipe',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20), // Add space between the title and recipe
                                _randomRecipes.isEmpty // Check if recipes are still loading or unavailable
                                    ? Container(
                                        height: 300, // Placeholder height
                                        width: 400, // Placeholder width
                                        color: Colors.grey.shade300, // Background color for the placeholder
                                        child: const Center(
                                          child: Icon(
                                            Icons.fastfood, // Placeholder icon
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          // Add the clicked recipe to recentlyViewed, avoiding duplicates
                                          setState(() {
                                            if (!_recentlyViewed.any((item) => item['id'] == _randomRecipes[9]['id'])) {
                                              _recentlyViewed.insert(0, _randomRecipes[9]); // Add to the start
                                            }
                                          });
                                          // Navigate to the recipe details screen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RecipeDetailScreen(recipeId: _randomRecipes[9]['id'],isMealPlan:isMealPlan,isSearch:false),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 300, // Adjust height as needed
                                          width: 400,
                                          child: Card(
                                            margin: const EdgeInsets.only(top: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(10),
                                                        topRight: Radius.circular(10),
                                                      ),
                                                      child: _randomRecipes[9]['image'] != null
                                                          ? Image.network(
                                                              _randomRecipes[9]['image'],
                                                              height: 200,
                                                              width: 400,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                  height: 200,
                                                                  width: 400,
                                                                  color: Colors.grey,
                                                                  child: const Icon(Icons.broken_image, size: 60, color: Colors.white),
                                                                );
                                                              },
                                                            )
                                                          : Container(
                                                              height: 200,
                                                              width: 400,
                                                              color: Colors.grey,
                                                              child: const Icon(Icons.fastfood, size: 60, color: Colors.white),
                                                            ),
                                                    ),
                                                    // Time overlay
                                                    Positioned(
                                                      top: 8,
                                                      left: 8,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(Icons.timer, size: 14, color: Colors.white),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                                  _randomRecipes[0]['preparationMinutes'] != null &&
                                                                      _randomRecipes[0]['preparationMinutes'] > 0
                                                                  ? '${_randomRecipes[0]['preparationMinutes']} mins'
                                                                  : _randomRecipes[0]['readyInMinutes'] != null
                                                                      ? '${_randomRecipes[0]['readyInMinutes']} mins'
                                                                      : 'N/A',
                                                              style: const TextStyle(fontSize: 12, color: Colors.white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // Favorite Icon (Like Button)
                                                    Positioned(
                                                      bottom: 8,
                                                      right: 8,
                                                      child: GestureDetector(
                                                        onTap: () => toggleLike(9),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black.withOpacity(0.6),
                                                            borderRadius: BorderRadius.circular(5),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              // Icon(
                                                              //   Icons.thumb_up,
                                                              //   size: 14,
                                                              //   color: isLiked[9]
                                                              //       ? const Color.fromARGB(255, 93, 167, 199)
                                                              //       : Colors.white,
                                                              // ),
                                                              // const SizedBox(width: 4),
                                                              // Text(
                                                              //   '${likeCounts[9]}',
                                                              //   style: const TextStyle(fontSize: 12, color: Colors.white),
                                                              // ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Recipe Title
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    _randomRecipes[9]['title'] ?? 'No Title',
                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),


                          // Quick Links For You Section
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Title
                                const Text(
                                  'Quick Links For You',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                    height: 20), // Space between title and tabs

                                // Horizontal Tabs for Meal Categories
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildClickableImage(
                                          'Breakfast', 'images/breakfast.jpg',userid),
                                      _buildClickableImage(
                                          'Lunch', 'images/lunch.jpg',userid),
                                      _buildClickableImage(
                                          'Dinner', 'images/dinner.jpg',userid),
                                      _buildClickableImage(
                                          'Dessert', 'images/dessert.jpg',userid),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          
                        
                        RecentlyViewedWidget(recentlyViewed: _recentlyViewed),
                        ],
                      ),
                      ),
                      const IngredientSearchScreen(),
                    ],
                  ),
                ),
              ],
            ),
          
           
          const SavedFoodScreen(),
          userid == 'null' ? SignUpReminderPage1() : CommunityChatScreen(),

          //userid == 'null' ? CommunityChatScreen() : CommunityChatScreen(),

          const ShoppingListScreen(),
          // ProfileScreen
          userid == 'null' ? SignUpReminderPage1() : ProfileScreen(),
          
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: 
        // Hide bottom navigation bar for Profile or when user is not logged in
       BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Ensures fixed positions for icons
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'ShoppingList',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: customPurple, // Color for selected item
          selectedFontSize: 12, // Size of selected item's text
          unselectedFontSize: 10, // Size of unselected items' text
          iconSize: 28, // Uniform icon size
          showUnselectedLabels: true, // Keeps labels for unselected items
        ),
    );
  }

  Widget _buildClickableImage(String category, String imagePath, String userId) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () {
       
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(category: category, userId:userId,isMealPlan:isMealPlan),
          ),
        );
      },
      child: Container(
        width: 250, // Set width for the image container
        height: 300, // Set height for the image container
        margin: const EdgeInsets.only(right: 16), // Add spacing between items
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4), // Subtle shadow for depth
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16), // Match container corners
          child: Stack(
            children: [
              // Background Image
              Image.asset(
                imagePath,
                width: 250,
                height: 300,
                fit: BoxFit.cover,
              ),
              // Overlay Text
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    category,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
