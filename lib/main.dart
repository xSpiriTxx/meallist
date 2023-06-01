import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal App',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: MealScreen(),
    );
  }
}

class MealListScreen extends StatelessWidget {
  final Category category;

  const MealListScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: FutureBuilder<List<Meal>>(
        future: fetchMealsByCategory(category.name),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final meals = snapshot.data;
            return ListView.builder(
              itemCount: meals?.length,
              itemBuilder: (context, index) {
                final meal = meals?[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(meal!.thumbnailUrl),
                  ),
                  title: Text(
                    meal.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailScreen(mealId: meal.id),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class MealScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meals'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: MealSearchDelegate());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final categories = snapshot.data;
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: categories?.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final category = categories?[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MealListScreen(category: category!),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        categories![index].name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

// SearchScreen widget
class SearchScreen extends StatelessWidget {
  final String searchQuery;

  const SearchScreen({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Meal>>(
        future: fetchMealsByQuery(searchQuery),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final meals = snapshot.data;
            return ListView.builder(
              itemCount: meals?.length,
              itemBuilder: (context, index) {
                final meal = meals?[index];
                return ListTile(
                  title: Text(meal!.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailScreen(mealId: meal.id),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

// MealSearchDelegate class
class MealSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search Meals';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SearchScreen(searchQuery: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // No suggestions implemented in this example
  }
}

class MealDetailScreen extends StatelessWidget {
  final String mealId;

  const MealDetailScreen({required this.mealId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMealDetail(mealId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final mealDetail = snapshot.data;
            final mealName = mealDetail?['strMeal'];
            final mealThumbnailUrl = mealDetail?['strMealThumb'];
            final mealInstructions = mealDetail?['strInstructions'];

            // Extract ingredient and measurement values from the mealDetail
            List<String> ingredients = [];
            List<String> measurements = [];
            for (int i = 1; i <= 20; i++) {
              String ingredient = mealDetail?['strIngredient$i'];
              String measurement = mealDetail?['strMeasure$i'];
              if (ingredient != null && ingredient.trim().isNotEmpty) {
                ingredients.add(ingredient);
                measurements.add(measurement ?? '');
              }
            }

            return ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealName,
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      CachedNetworkImage(
                        imageUrl: mealThumbnailUrl,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Ingredients:',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          ingredients.length,
                          (index) => Text(
                            '${measurements[index]} ${ingredients[index]}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Instructions:',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        mealInstructions,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class Meal {
  final String id;
  final String name;
  final String thumbnailUrl;

  Meal({required this.id, required this.name, required this.thumbnailUrl});
}

Future<List<Category>> fetchCategories() async {
  final url =
      Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?c=list');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedResponse = json.decode(response.body);
    final categoryList = decodedResponse['meals'] as List<dynamic>;

    final categories = categoryList.map((category) {
      final id = category['strCategory'];
      final name = category['strCategory'];
      return Category(id: id, name: name);
    }).toList();

    return categories;
  } else {
    throw Exception('Failed to fetch categories');
  }
}

Future<List<Meal>> fetchMealsByCategory(String category) async {
  final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedResponse = json.decode(response.body);
    final mealList = decodedResponse['meals'] as List<dynamic>;

    final meals = mealList.map((meal) {
      final id = meal['idMeal'];
      final name = meal['strMeal'];
      final thumbnailUrl = meal['strMealThumb'];
      return Meal(id: id, name: name, thumbnailUrl: thumbnailUrl);
    }).toList();

    return meals;
  } else {
    throw Exception('Failed to fetch meals');
  }
}

Future<List<Meal>> fetchMealsByQuery(String query) async {
  final url =
      Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedResponse = json.decode(response.body);
    final mealList = decodedResponse['meals'] as List<dynamic>;

    final meals = mealList.map((meal) {
      final id = meal['idMeal'];
      final name = meal['strMeal'];
      final thumbnailUrl = meal['strMealThumb'];
      return Meal(id: id, name: name, thumbnailUrl: thumbnailUrl);
    }).toList();

    return meals;
  } else {
    throw Exception('Failed to fetch meals');
  }
}

Future<Map<String, dynamic>> fetchMealDetail(String mealId) async {
  final url =
      Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedResponse = json.decode(response.body);
    final mealDetail = decodedResponse['meals'][0] as Map<String, dynamic>;
    return mealDetail;
  } else {
    throw Exception('Failed to fetch meal detail');
  }
}
