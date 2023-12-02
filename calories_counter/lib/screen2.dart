import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'screen1.dart';

class Screen2 extends StatefulWidget {
  const Screen2({Key? key, this.plan}) : super(key: key);
  final Plan? plan;

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  final dateController = TextEditingController();
  final targetController = TextEditingController();
  final calorieController = TextEditingController();
  final foodController = TextEditingController();
  var id;
  Food? selectedFood;

  @override
  void dispose() {
    dateController.dispose();
    targetController.dispose();
    calorieController.dispose();
    foodController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (widget.plan != null) {
      dateController.text = widget.plan!.date;
      targetController.text = widget.plan!.target;
      calorieController.text = widget.plan!.calories;
      foodController.text = widget.plan!.food;
      id = widget.plan!.id;
    }
  }

  // check if a string only contains numbers
  bool isNumeric(String str) {
    final numericRegex = RegExp(r'^-?[0-9]+$');
    return numericRegex.hasMatch(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 120.0),
              height: 270,
              child: Card(
                color: const Color.fromRGBO(255, 229, 158, 1.0),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      // date selector
                      TextField(
                        controller: dateController,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.calendar_today),
                            labelText: "Enter Date"),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2030));

                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);

                            setState(() {
                              dateController.text = formattedDate;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // target calories
                      TextField(
                        controller: targetController,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(122, 122, 122, 1.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2.0,
                            ),
                          ),
                          labelText: 'Target',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // calories and food
                      Row(
                        children: <Widget>[
                          // calorie input
                          SizedBox(
                            width: 112,
                            child: TextField(
                              controller: calorieController,
                              decoration: const InputDecoration(
                                alignLabelWithHint: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(122, 122, 122, 1.0),
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2.0,
                                  ),
                                ),
                                labelText: 'Calories',
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          // food selection
                          FutureBuilder<List<Food>>(
                            future: DatabaseHelper().getFoods(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Food>> snapshot) {
                              if (snapshot.hasData) {
                                return DropdownMenu<Food>(
                                  initialSelection:
                                      selectedFood ?? snapshot.data![0],
                                  controller: foodController,
                                  requestFocusOnTap: true,
                                  label: const Text('Food'),
                                  onSelected: (Food? food) {
                                    setState(() {
                                      selectedFood = food;
                                      calorieController.text = food!.calories;
                                    });
                                  },
                                  dropdownMenuEntries: snapshot.data!
                                      .map<DropdownMenuEntry<Food>>(
                                          (Food food) {
                                    return DropdownMenuEntry<Food>(
                                      value: food,
                                      label: food.food,
                                      enabled: true,
                                      style: MenuItemButton.styleFrom(
                                        foregroundColor: Colors.black,
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                    'An error occurred while fetching food items');
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.plan != null)
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    // add plan to database
                    await DatabaseHelper().deletePlan(id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Plan Deleted',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );

                    // move to home screen
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Screen1()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 0, 0, 0.65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12), // Adjust corner radius here
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          tooltip: 'Go to Note Page',
          shape: const CircleBorder(),
          backgroundColor: const Color.fromRGBO(77, 77, 77, 1.0),
          onPressed: () async {
            String dateText = dateController.text;
            String targetText = targetController.text;
            String calorieText = calorieController.text;
            String foodText = foodController.text;

            // empty text fields
            if (dateText.isEmpty ||
                targetText.isEmpty ||
                calorieText.isEmpty ||
                foodText.isEmpty) {
              // display toast
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Empty Text Fields',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              // if calorie and target calorie is not numerical
              if (!isNumeric(calorieText) || !isNumeric(targetText)) {
                // display toast
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Calorie is not a Numerical Value',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                Plan newPlan;

                if (widget.plan != null) {
                  newPlan = Plan(
                    id: id,
                    date: dateText,
                    target: targetText,
                    food: foodText,
                    calories: calorieText,
                  );
                } else {
                  newPlan = Plan(
                    date: dateText,
                    target: targetText,
                    food: foodText,
                    calories: calorieText,
                  );
                }

                // add plan to database
                await DatabaseHelper().insertPlan(newPlan);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Plan Created',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );

                // move to home screen
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Screen1()),
                  );
                }
              }
            }
          },
          child: const Icon(
            Icons.check,
            color: Color.fromRGBO(255, 161, 79, 1.0),
            size: 25.0,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
