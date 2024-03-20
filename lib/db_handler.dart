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

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------- CLASS METHODS
  Future<void> initialize() async {
    _databaseExpenses.keepSynced(true);
    _databaseIncomes.keepSynced(true);
    _databaseSources.keepSynced(true);
    _databaseTransfers.keepSynced(true);
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
      final snapshot = await _databaseSources.child(source).get();

      double currentVal;
      if (snapshot.value is int) {
        currentVal = (snapshot.value as int).toDouble();
      } else {
        currentVal = snapshot.value as double;
      }

      double newVal = currentVal + amount;

      await _databaseSources.update({source: newVal});
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
        incomesList = incomes.keys.cast<String>().toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting incomes types: $e');
      }
    }

    return incomesList;
  }

  Future<List<String>> getSourcesTypes() async {
    List<String> sourcesList = [''];

    try {
      final snapshot = await _databaseSources.get();
      Map<dynamic, dynamic>? sources = snapshot.value as dynamic;

      if (sources != null) {
        sourcesList = sources.keys.cast<String>().toList();
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
        sources.forEach((key, value) {
          if (key is String && value is num) {
            sourcesAmounts[key] = value.toDouble();
          }
        });
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