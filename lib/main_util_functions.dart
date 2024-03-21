// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                  MAIN UTILITY FUNCTIONS                                   * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * Helping functions for main app.                                                           * //
// *                                                                                           * //
// * -- Revision --                                                                            * //
// *   2024-03-16 -- version 1.0.0, the first usable                                           * //
// *                                                                                           * //
// * -- Author --                                                                              * //
// *   Alberto Bortoni                                                                         * //
// *                                                                                           * //
// * -- TODOS --                                                                               * //
// *                                                                                           * //
// *                                                                                           * //
// ~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~ //

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

//|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
//|* ----------------------------------------------- METHODS
Future<void> useValidUserCredentials() async {
  String jsonString = await rootBundle.loadString('assets/valid_users.json');
  Map<String, dynamic> data = jsonDecode(jsonString);

  List<dynamic> users = data['users'];

  String email = users[0]['email'];
  String password = users[0]['password'];

  await initializeUserSignIn(email, password);
}

Future<void> initializeUserSignIn(String emailAddress, String password) async {
  try {
    //await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailAddress, password: password);
    if (kDebugMode) {
      print('User signed in successfully!');
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      if (kDebugMode) {
        print('Error signing in: ${e.message}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error signing in: $e');
    }
  }
}

Future<void> copyDefaultFiles() async {
  if (!kIsWeb) {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    File budgetFile = File('$appDocPath/budgets.csv');

    // Copy the default budgets file if it doesn't exist
    if (!await budgetFile.exists()) {
      ByteData budgetData = await rootBundle.load('assets/budgets.csv');
      List<int> budgetBytes = budgetData.buffer.asUint8List();
      await budgetFile.writeAsBytes(budgetBytes);
    }

    // Copy the default categories file if it doesn't exist
    File categoriesFile = File('$appDocPath/categories.csv');
    if (!await categoriesFile.exists()) {
      ByteData categoriesData = await rootBundle.load('assets/categories.csv');
      List<int> categoriesBytes = categoriesData.buffer.asUint8List();
      await categoriesFile.writeAsBytes(categoriesBytes);
    }
  }
}

Future<List<String>> parseBudgetsCSV() async {
  List<String> budgets = [];
  try {
    String contents = '';

    if (!kIsWeb) {
      String appDocPath = (await getApplicationDocumentsDirectory()).path;
      File file = File('$appDocPath/budgets.csv');
      contents = await file.readAsString();
    } else {
      contents = await rootBundle.loadString('assets/budgets.csv');
    }

    // Split the contents by line and add each entry to the list
    budgets = contents.split('\n').map((e) => e.trim()).toList();

    // Add an empty string at the beginning of the list
    budgets.insert(0, 'NaN');
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing budgets.csv: $e');
    }
  }
  return budgets;
}

Future<Map<String, List<String>>> parseCategoriesCSV() async {
  Map<String, List<String>> categoryMap = {};
  try {
    List<String> lines = [];

    if (!kIsWeb) {
      String appDocPath = (await getApplicationDocumentsDirectory()).path;
      File file = File('$appDocPath/categories.csv');
      lines = await file.readAsLines();
    } else {
      lines = await readLinesFromAsset('assets/categories.csv');
    }

    // Add NaN key with an empty list
    categoryMap['NaN'] = [];

    // Iterate over each line in the file
    for (String line in lines) {
      // Split the line by comma to separate categoryType and category
      List<String> parts = line.split(',').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        String categoryType = parts[0];
        String category = parts[1];

        // Add categoryType to allCategoryTypes list under each category
        if (!categoryMap.containsKey(category)) {
          categoryMap[category] = [];
        }
        if (!categoryMap[category]!.contains(categoryType)) {
          categoryMap[category]!.add(categoryType);
        }
      }
    }

    // Append an empty string at the start of each list except for the "NaN" key
    categoryMap.forEach((key, value) {
      if (key != 'NaN') {
        value.insert(0, '');
      }
    });
  } catch (e) {
    // Handle errors, such as file not found
    if (kDebugMode) {
      print('Error parsing categories.csv: $e');
    }
  }
  return categoryMap;
}

Future<List<String>> readLinesFromAsset(String assetPath) async {
  String contents = await rootBundle.loadString(assetPath);
  return contents.split('\n');
}

//EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF//