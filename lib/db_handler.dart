// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                            FIREBASE DATABASE HANDLER FUNCTIONS                            * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * This provides all necesary functions to interface with the Firebase database.             * //
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

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// ********************************************************************************************* //
// *                                     DATABASE CLASS                                        * //
// * ----------------------------------------------------------------------------------------- * //
class DatabaseHelper {
  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* --------------------------------------------- VARIABLES
  final DatabaseReference _databaseExpenses = FirebaseDatabase.instance.ref('expenses');
  final DatabaseReference _databaseIncomes = FirebaseDatabase.instance.ref('incomes');
  final DatabaseReference _databaseSources = FirebaseDatabase.instance.ref('sources');
  final DatabaseReference _databaseTransfers = FirebaseDatabase.instance.ref('transfers');
  final DatabaseReference _databaseCategories = FirebaseDatabase.instance.ref('categories');
  final DatabaseReference _databaseBudgets = FirebaseDatabase.instance.ref('budgets');

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------- CLASS METHODS
  Future<void> initialize() async {
    _databaseExpenses.keepSynced(true);
    _databaseIncomes.keepSynced(true);
    _databaseSources.keepSynced(true);
    _databaseTransfers.keepSynced(true);
    _databaseCategories.keepSynced(true);
    _databaseBudgets.keepSynced(true);
  }

  Future<void> insertExpnese(Map<String, dynamic> entry) async {
    try {
      await _databaseExpenses.push().set(entry);
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting expense entry: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteExpense(String entryId) async {
    try {
      await _databaseExpenses.child(entryId).remove();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting expense entry: $e');
      }
      rethrow;
    }
  }

  Future<void> recordTransaction(Map<String, dynamic> entry) async {
    try {
      await _databaseTransfers.push().set(entry);
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting transfer entry: $e');
      }
      rethrow;
    }
  }

  Future<void> updateAccountSources(String source, double amount) async {
    try {
      final snapshot = await _databaseSources.child('$source/balance').get();

      double currentVal;
      if (snapshot.value is int) {
        currentVal = (snapshot.value as int).toDouble();
      } else {
        currentVal = snapshot.value as double;
      }

      double newVal = currentVal + amount;

      await _databaseSources.update({'$source/balance': newVal});
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting transfer entry: $e');
      }
      rethrow;
    }
  }

  Future<void> updateTransactions(Map<String, dynamic> transactions) async {
    try {
      await _databaseExpenses.update(transactions);
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting transfer entry: $e');
      }
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>?> getEntriesThisMonth() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    int firstDayOfMonthInt = int.parse('${DateFormat('yyyyMMdd').format(firstDayOfMonth)}0000');
    int lastDayOfMonthInt = int.parse('${DateFormat('yyyyMMdd').format(lastDayOfMonth)}2359');

    try {
      final snapshot = await _databaseExpenses
          .orderByChild('timestamp')
          .startAt(firstDayOfMonthInt)
          .endAt(lastDayOfMonthInt)
          .get();

      Map<dynamic, dynamic>? entries = snapshot.value as dynamic;

      List<MapEntry<dynamic, dynamic>> sortedEntries = (entries?.entries.toList() ?? []);
      sortedEntries.sort((a, b) => b.value['timestamp'] - a.value['timestamp']);

      Map<dynamic, dynamic> sortedEntriesMap = Map.fromEntries(sortedEntries);

      return sortedEntriesMap;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting entries for this month: $e');
      }
      return null;
    }
  }

  Future<Map<dynamic, dynamic>?> getEntriesLastMonth() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
    DateTime lastDayOfLastMonth = DateTime(now.year, now.month, 0);

    int firstDayOfLastMonthInt =
        int.parse('${DateFormat('yyyyMMdd').format(firstDayOfLastMonth)}0000');

    int lastDayOfLastMonthInt =
        int.parse('${DateFormat('yyyyMMdd').format(lastDayOfLastMonth)}2359');

    try {
      final snapshot = await _databaseExpenses
          .orderByChild('timestamp')
          .startAt(firstDayOfLastMonthInt)
          .endAt(lastDayOfLastMonthInt)
          .get();

      Map<dynamic, dynamic>? entries = snapshot.value as dynamic;

      List<MapEntry<dynamic, dynamic>> sortedEntries = (entries?.entries.toList() ?? []);
      sortedEntries.sort((a, b) => b.value['timestamp'] - a.value['timestamp']);

      Map<dynamic, dynamic> sortedEntriesMap = Map.fromEntries(sortedEntries);

      return sortedEntriesMap;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting entries for this month: $e');
      }
      return null;
    }
  }

  Future<Map<dynamic, dynamic>?> getAllEntries() async {
    try {
      final snapshot = await _databaseExpenses.orderByChild('timestamp').get();
      Map<dynamic, dynamic>? entries = snapshot.value as dynamic;

      List<MapEntry<dynamic, dynamic>> sortedEntries = (entries?.entries.toList() ?? []);
      sortedEntries.sort((a, b) => b.value['timestamp'] - a.value['timestamp']);

      Map<dynamic, dynamic> sortedEntriesMap = Map.fromEntries(sortedEntries);

      return sortedEntriesMap;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting entries for this month: $e');
      }
      return null;
    }
  }

  Future<List<String>> getIcomesTypes() async {
    List<String> incomesList = [''];

    try {
      final snapshot = await _databaseIncomes.get();
      Map<dynamic, dynamic>? incomes = snapshot.value as dynamic;

      if (incomes != null) {
        incomesList = incomes.keys.cast<String>().toList()..sort();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting incomes types: $e');
      }
    }

    return incomesList;
  }

  Future<Map<String, List<String>>> getCategoriesTypes() async {
    Map<String, List<String>> categoriesMap = {};
    categoriesMap['NaN'] = [];

    try {
      final snapshot = await _databaseCategories.get();
      Map<dynamic, dynamic>? categories = snapshot.value as dynamic;

      if (categories != null) {
        List<String> categoriesList = categories.keys.cast<String>().toList()..sort();

        for (String key in categoriesList) {
          categoriesMap[key] = List<String>.from(categories[key])..sort();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting category types: $e');
      }
    }

    // Append an empty string at the start of each list except for the "NaN" key
    categoriesMap.forEach((key, value) {
      if (key != 'NaN') {
        value.insert(0, '');
      }
    });

    return categoriesMap;
  }

  Future<List<String>> getBudgetsTypes() async {
    List<String> budgetsList = [];

    try {
      final snapshot = await _databaseBudgets.get();
      Map<dynamic, dynamic>? budgets = snapshot.value as dynamic;

      if (budgets != null) {
        budgetsList = budgets.keys.cast<String>().toList()..sort();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting budget types: $e');
      }
    }

    // Add an empty string at the beginning of the list
    budgetsList.insert(0, 'NaN');

    return budgetsList;
  }

  Future<List<String>> getSourcesTypes(bool isexpense) async {
    List<String> sourcesList = [];

    try {
      final snapshot = await _databaseSources.get();
      Map<dynamic, dynamic>? sources = snapshot.value as Map<dynamic, dynamic>?;

      if (sources != null) {
        sources.forEach((key, value) {
          if (isexpense) {
            // If 'isexpense' is true, include sources with 'expense' set to true
            if (value['expense'] == true) {
              sourcesList.add(key.toString());
            }
          } else {
            // If 'isexpense' is false, include all sources
            sourcesList.add(key.toString());
          }
        });

        // Sort the list of sources alphabetically
        sourcesList.sort();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting incomes types: $e');
      }
    }

    return sourcesList;
  }

  Future<Map<String, double>> getSourcesAmounts() async {
    late Map<String, double> sourcesAmounts = {};

    try {
      final snapshot = await _databaseSources.get();
      Map<dynamic, dynamic>? sources = snapshot.value as dynamic;

      if (sources != null) {
        List<String> sourcesList = sources.keys.cast<String>().toList()..sort();

        for (String key in sourcesList) {
            double balance = (sources[key]!['balance'] as num?)?.toDouble() ?? 0.0;
            sourcesAmounts[key] = balance;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting incomes types: $e');
      }
    }

    return sourcesAmounts;
  }

  Future<Map<dynamic, dynamic>?> getAllTransfers() async {
    try {
      final snapshot = await _databaseTransfers.orderByChild('timestamp').get();
      Map<dynamic, dynamic>? entries = snapshot.value as dynamic;

      List<MapEntry<dynamic, dynamic>> sortedEntries = (entries?.entries.toList() ?? []);
      sortedEntries.sort((a, b) => b.value['timestamp'] - a.value['timestamp']);

      Map<dynamic, dynamic> sortedEntriesMap = Map.fromEntries(sortedEntries);

      return sortedEntriesMap;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting entries for this month: $e');
      }
      return null;
    }
  }
}

//EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF//