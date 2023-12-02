import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  // avoid errors from flutter upgrade
  WidgetsFlutterBinding.ensureInitialized();

  // manually create
  // var food1 = const Food(food: 'Pizza', calories: '285');
  // var plan1 = const Plan(date: '2023-12-07', target: '300', food: 'Pizza', calories: '285');

  // get database
  var db = DatabaseHelper();

  // add to database
  // await db.insertFood(food1);
  // await db.insertPlan(plan1);

  // print food items
  db.getFoods().then((foods) {
    foods.forEach((food) {
      print(food.toString());
    });
  });

  // print plans
  db.getAllPlans().then((plans) {
    plans.forEach((plan) {
      print(plan.toString());
    });
  });
}

// database operations
class DatabaseHelper {
  // initialize database
  Future<Database> database() async {
    return openDatabase(
      // find database
      join(await getDatabasesPath(), 'calorie_calculator_database.db'),

      // create database
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE foods(id INTEGER PRIMARY KEY AUTOINCREMENT, food TEXT, calories TEXT)',
        );
        db.execute(
          'CREATE TABLE plans(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, target TEXT, food TEXT, calories TEXT)',
        );
      },
      version: 1,
    );
  }

  // insert food
  Future<void> insertFood(Food food) async {
    // get database
    final db = await database();

    // insert food
    // conflict algorithm replaces previous data is inserted twice
    await db.insert(
      'foods',
      food.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPlan(Plan plan) async {
    final db = await database();

    await db.insert(
      'plans',
      plan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // get all foods
  Future<List<Food>> getFoods() async {
    // get database
    final db = await database();

    // query for all foods
    final List<Map<String, dynamic>> maps = await db.query('foods');

    // convert the List<Map<String, dynamic> into a List<Food>.
    return List.generate(maps.length, (i) {
      return Food(
        id: maps[i]['id'] as int,
        food: maps[i]['food'] as String,
        calories: maps[i]['calories'] as String,
      );
    });
  }

  Future<List<Plan>> getAllPlans() async {
    final db = await database();

    // query for all foods
    final List<Map<String, dynamic>> maps = await db.query('plans');

    return List.generate(maps.length, (i) {
      return Plan(
        id: maps[i]['id'] as int,
        date: maps[i]['date'] as String,
        target: maps[i]['target'] as String,
        food: maps[i]['food'] as String,
        calories: maps[i]['calories'] as String,
      );
    });
  }

  Future<void> deletePlan(int id) async {
    final db = await database();

    await db.delete(
      'plans',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

// data definition
class Food {
  final int? id;
  final String food;
  final String calories;

  const Food({
    this.id,
    required this.food,
    required this.calories,
  });

  // convert to map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'food': food,
      'calories': calories,
    };
  }

  // print
  @override
  String toString() {
    return 'Food{id: $id, food: $food, calories: $calories}';
  }
}

// data definition
class Plan {
  final int? id;
  final String date;
  final String target;
  final String food;
  final String calories;

  const Plan({
    this.id,
    required this.date,
    required this.target,
    required this.food,
    required this.calories,
  });

  // convert to map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'target': target,
      'food': food,
      'calories': calories,
    };
  }

  // print
  @override
  String toString() {
    return 'Plan{id: $id, date: $date, target: $target, food: $food, calories: $calories}';
  }
}
