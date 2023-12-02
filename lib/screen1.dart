import 'package:flutter/material.dart';
import 'database.dart';
import 'screen2.dart';

class Screen1 extends StatefulWidget {
  const Screen1({Key? key}) : super(key: key);

  @override
  Screen1State createState() => Screen1State();
}

class FoodSearch extends SearchDelegate<String> {
  final List<Plan> plans;
  final Function(String) onQueryChanged;

  FoodSearch(this.plans, this.onQueryChanged);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryChanged(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = plans
        .where((plan) => plan.date.toLowerCase().contains(query.toLowerCase()));

    return ListView(
      children: results
          .map<Widget>((plan) => ListTile(
                title: Text(plan.date),
                onTap: () {
                  close(context, plan.date);
                },
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = plans.where(
        (plan) => plan.date.toLowerCase().startsWith(query.toLowerCase()));

    return ListView(
      children: suggestions
          .map<Widget>((plan) => ListTile(
                title: Text(plan.date),
                onTap: () {
                  query = plan.date;
                  onQueryChanged(query);
                },
              ))
          .toList(),
    );
  }
}

class Screen1State extends State<Screen1> {
  List<Plan> _plans = [];
  List<Plan> _filteredPlans = [];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    _plans = await DatabaseHelper().getAllPlans();
    _filteredPlans = List.from(_plans);
  }

  void _filterFoods(String query) {
    final results = _plans
        .where((plan) => plan.date.toLowerCase().contains(query.toLowerCase()));
    setState(() {
      _filteredPlans = results.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Food>>(
      // get notes from database
      future: DatabaseHelper().getFoods(),

      // build screen
      builder: (context, snapshot) {
        // waiting to connect to database
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        // error occurred
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        // create screen
        else {
          // get list of notes
          final foods = snapshot.data ?? [];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Calorie Counter'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: FoodSearch(_plans, _filterFoods),
                    );
                  },
                ),
              ],
            ),
            body: foods.isEmpty
                ? const Center(
                    child: Text('No Notes Here.'),
                  )
                : GridView.builder(
                    itemCount: _filteredPlans.length,
                    padding: const EdgeInsets.all(10.0),

                    // set up grid view
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // number of items in each row
                      crossAxisSpacing:
                          10.0, // horizontal distance between cards
                      mainAxisSpacing: 10.0, // vertical distance between cards
                      childAspectRatio:
                          12 / 20, // adjust ratio width and height
                    ),

                    // for each note
                    itemBuilder: (context, index) {
                      // get note
                      final plan = _filteredPlans[index];

                      // use alternating colours
                      Color bgColor = Colors.white;
                      if (index % 4 == 0) {
                        bgColor = const Color.fromRGBO(187, 229, 242, 1.0);
                      } else if (index % 4 == 1) {
                        bgColor = const Color.fromRGBO(255, 229, 158, 1.0);
                      } else if (index % 4 == 2) {
                        bgColor = const Color.fromRGBO(255, 192, 203, 1.0);
                      } else if (index % 4 == 3) {
                        bgColor = const Color.fromRGBO(198, 242, 187, 1.0);
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Screen2(plan: plan),
                            ),
                          );
                        },
                        child: Card(
                          color: bgColor,
                          child: SingleChildScrollView(
                            child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                ListTile(
                                  title: const Text(
                                    'Date',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  subtitle: Text(plan.date),
                                ),
                                ListTile(
                                  title: const Text(
                                    'Target Calories',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  subtitle: Text(plan.target),
                                ),
                                ListTile(
                                  title: const Text(
                                    'Food',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  subtitle: Text(plan.food),
                                ),
                                ListTile(
                                  title: const Text(
                                    'Calories',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  subtitle: Text(plan.calories),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: FloatingActionButton(
                tooltip: 'Go to Note Page',
                shape: const CircleBorder(),
                backgroundColor: const Color.fromRGBO(77, 77, 77, 1.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Screen2()),
                  );
                },
                child: const Icon(
                  Icons.add,
                  color: Color.fromRGBO(255, 161, 79, 1.0),
                  size: 25.0,
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        }
      },
    );
  }
}
