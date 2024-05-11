// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                               APP SETTINGS AND EXPORTS TAB                                * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * This tab is where the user can upload the budgets and categories to be considered.        * //
// * It also provides export buttons to get the transacions and expenses in CSV format.        * //
// *                                                                                           * //
// * -- Revision --                                                                            * //
// *   2024-03-16 -- version 1.0.0, the first usable                                           * //
// *                                                                                           * //
// * -- Author --                                                                              * //
// *   Alberto Bortoni                                                                         * //
// *                                                                                           * //
// * -- TODOS --                                                                               * //
// *   - Bad error handling                                                                    * //
// *   - To move files                                                                         * //
// *        adb push .\junk\mods.csv /storage/emulated/0/Download/                             * //
// *   - when updating expenses, the amount will not update the sources, dont use now          * //
// *                                                                                           * //
// ~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~ //

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'myapp_styles.dart';
import 'package:intl/intl.dart';
import 'db_handler.dart';
import 'dart:convert';

// ********************************************************************************************* //
// *                                     SETTINGS TAB CLASS                                    * //
// * ----------------------------------------------------------------------------------------- * //
class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* --------------------------------------------- VARIABLES
  String _displayText = '';
  String _downloadDir = '';

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------- CLASS METHODS
  Future<void> _getDownloadDir() async {
    if (!kIsWeb) {
      if (Platform.isIOS) {
        _downloadDir = (await getDownloadsDirectory())?.path ?? '';
      } else {
        _downloadDir = "/storage/emulated/0/Download/";

        bool dirDownloadExists = false;
        dirDownloadExists = await Directory(_downloadDir).exists();
        if (dirDownloadExists) {
          _downloadDir = "/storage/emulated/0/Download/";
        } else {
          _downloadDir = "/storage/emulated/0/Downloads/";
        }
      }
    }
  }

  Future<String> _browseExpenseChanges() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv'], allowMultiple: false);

    if (result != null) {
      Map<String, dynamic> changedExpenses = {};

      if (!kIsWeb) {
        File selectedFile = File(result.files.single.path!);

        try {
          List<String> lines = await selectedFile.readAsLines();

          // Skip the header row
          if (lines.isNotEmpty) lines.removeAt(0);

          for (String line in lines) {
            List<String> values = line.split(',');

            // Extract ID and create entry
            String id = values[9]; // Assuming 'id' is the last column
            Map<String, dynamic> entry = {
              'date': values[0],
              'time': values[1],
              'description': values[2],
              'amount': int.parse(values[3]),
              'category': values[4],
              'categoryType': values[5],
              'budget': values[6],
              'source': values[7],
              'timestamp': int.parse(values[8]),
            };

            // Add entry to changedExpenses map
            changedExpenses[id] = entry;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error reading CSV file: $e');
          }
          return 'There was an error parsing the file';
        }

        // Call updateTransactions
        DatabaseHelper().updateTransactions(changedExpenses);
        return 'Import successful';
      }
      return 'No importing from web';
    } else {
      return 'Cant open that file';
    }
  }

  Future<void> _getBudgetsFile() async {
    // Get the list of budgets keys
    List<String> budgets = await DatabaseHelper().getBudgetsTypes();
    budgets.remove('NaN');

    // Create a map with keys from the list and null values
    Map<String, dynamic> budgetsMap =
        Map.fromIterable(budgets, key: (key) => key, value: (_) => null);

    // Convert budgetsMap to JSON string
    String budgetsJson = json.encode(budgetsMap);

    // Get directory to save the file
    String filePath = '$_downloadDir/budgets.json';

    // Save JSON string to file
    try {
      File file = File(filePath);
      await file.writeAsString(budgetsJson);
      if (kDebugMode) {
        print('Budgets file saved at: $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving budgets file: $e');
      }
    }
  }

  Future<void> _getCategoriesFile() async {
    Map<String, List<String>> categoriesMap = await DatabaseHelper().getCategoriesTypes();

    // Remove the 'NaN' key if it exists
    categoriesMap.removeWhere((key, value) => key == 'NaN');

    // Convert categoriesMap to JSON string
    String categoriesJson = json.encode(categoriesMap);

    // Get directory to save the file
    String today = DateFormat('yyyyMMdd').format(DateTime.now());
    String filePath = '$_downloadDir/categories-$today.json';

    // Save JSON string to file
    try {
      File file = File(filePath);
      await file.writeAsString(categoriesJson);
      if (kDebugMode) {
        print('Categories file saved at: $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving categories file: $e');
      }
    }
  }

  void _getExpenseThisMonth() async {
    Map<dynamic, dynamic>? allEntries = await DatabaseHelper().getEntriesThisMonth();
    if (allEntries == null) {
      return;
    }

    // Open a file for writing
    String thisMonth = DateFormat('yyyyMM').format(DateTime.now());
    File csvFile = File('$_downloadDir/expenses-$thisMonth.csv');
    IOSink sink = csvFile.openWrite();

    try {
      // Define the header row
      sink.writeln('date,time,description,amount,category,categoryType,budget,source,timestamp,id');

      // Write each entry to the CSV file
      allEntries.forEach((key, entry) {
        sink.writeln(
            '${entry['date']},${entry['time']},${entry['description']},${entry['amount']},${entry['category']},${entry['categoryType']},${entry['budget']},${entry['source']},${entry['timestamp']},${key.toString()}');
      });

      // Close the file
      await sink.close();
      if (kDebugMode) {
        print('CSV file exported successfully.');
      }
    } catch (e) {
      sink.close();
      if (kDebugMode) {
        print('Error exporting CSV file: $e');
      }
    }
  }

  void _getExpenseLastMonth() async {
    Map<dynamic, dynamic>? allEntries = await DatabaseHelper().getEntriesLastMonth();
    if (allEntries == null) {
      return;
    }

    // Open a file for writing
    DateTime now = DateTime.now();
    DateTime lastM = DateTime(now.year, now.month - 1);
    String lastMonth = DateFormat('yyyyMM').format(lastM);

    File csvFile = File('$_downloadDir/expenses-$lastMonth.csv');
    IOSink sink = csvFile.openWrite();

    try {
      // Define the header row
      sink.writeln('date,time,description,amount,category,categoryType,budget,source,timestamp,id');

      // Write each entry to the CSV file
      allEntries.forEach((key, entry) {
        sink.writeln(
            '${entry['date']},${entry['time']},${entry['description']},${entry['amount']},${entry['category']},${entry['categoryType']},${entry['budget']},${entry['source']},${entry['timestamp']},${key.toString()}');
      });

      // Close the file
      await sink.close();
      if (kDebugMode) {
        print('CSV file exported successfully.');
      }
    } catch (e) {
      sink.close();
      if (kDebugMode) {
        print('Error exporting CSV file: $e');
      }
    }
  }

  void _getExpenseAll() async {
    Map<dynamic, dynamic>? allEntries = await DatabaseHelper().getAllEntries();
    if (allEntries == null) {
      return;
    }

    // Open a file for writing

    String tdate = DateFormat('yyyyMMdd').format(DateTime.now());
    File csvFile = File('$_downloadDir/expensesAll-$tdate.csv');
    IOSink sink = csvFile.openWrite();

    try {
      // Define the header row
      sink.writeln('date,time,description,amount,category,categoryType,budget,source,timestamp,id');

      // Write each entry to the CSV file
      allEntries.forEach((key, entry) {
        sink.writeln(
            '${entry['date']},${entry['time']},${entry['description']},${entry['amount']},${entry['category']},${entry['categoryType']},${entry['budget']},${entry['source']},${entry['timestamp']},${key.toString()}');
      });

      // Close the file
      await sink.close();
      if (kDebugMode) {
        print('CSV file exported successfully.');
      }
    } catch (e) {
      sink.close();
      if (kDebugMode) {
        print('Error exporting CSV file: $e');
      }
    }
  }

  void _getTransferAll() async {
    Map<dynamic, dynamic>? allEntries = await DatabaseHelper().getAllTransfers();
    if (allEntries == null) {
      return;
    }

    // Open a file for writing
    String tdate = DateFormat('yyyyMMdd').format(DateTime.now());
    File csvFile = File('$_downloadDir/transferAll-$tdate.csv');
    IOSink sink = csvFile.openWrite();

    try {
      // Define the header row
      sink.writeln('date,time,description,amount,from,to,type,timestamp,id');

      // Write each entry to the CSV file
      allEntries.forEach((key, entry) {
        sink.writeln(
            '${entry['date']},${entry['time']},${entry['description']},${entry['amount']},${entry['from']},${entry['to']},${entry['type']},${entry['timestamp']},${key.toString()}');
      });

      // Close the file
      await sink.close();
      if (kDebugMode) {
        print('CSV file exported successfully.');
      }
    } catch (e) {
      sink.close();
      if (kDebugMode) {
        print('Error exporting CSV file: $e');
      }
    }
  }

  void _changeText(String text) {
    setState(() {
      _displayText = text;
    });

    // Reset text to default after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _displayText = '';
      });
    });
  }

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ------------------------------------ OVERRIDDEN METHODS
  @override
  void initState() {
    super.initState();
    _getDownloadDir();
  }

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ------------------------------------ OVERRIDDEN METHODS
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10.0),
            Text(
              _displayText,
              style: myTextStylePl,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10.0),
            const Text(
              'IMPORTS',
              style: myTextStyle,
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () async {
                      await _browseExpenseChanges();
                      _changeText('Import successful');
                    },
              child: const Text('Browse Expense Change'),
            ),
            const SizedBox(height: 50.0),
            const Text(
              'EXPORTS',
              style: myTextStyle,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getBudgetsFile();
                      _changeText('Donzo exporting!');
                    },
              child: const Text('File: Budgets'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getCategoriesFile();
                      _changeText('Donzo exporting!');
                    },
              child: const Text('File: Categories'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getExpenseThisMonth();
                      _changeText('Donzo exporting!');
                    },
              child: const Text('Expense: This month'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getExpenseLastMonth();
                      _changeText('Donzo exporting!');
                    },
              child: const Text('Expense: Last month'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getExpenseAll();
                      _changeText('Donzo exporting!');
                    },
              child: const Text('Expense: All entries'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getTransferAll();
                      _changeText('Donzo exporting!');
                    },
              child: const Text('Transactions: All entries'),
            ),
          ],
        ),
      ),
    );
  }
}

//EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF//