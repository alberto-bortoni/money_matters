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
// *                                                                                           * //
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
import 'package:universal_html/html.dart' as html;
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
  String _selectedBudgetFileName = 'budgets.csv';
  String _selectedCategoriesFileName = 'categories.csv';
  String _displayText = '';
  String _downloadDir = '';
  String _appDocDir = '';

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

  Future<void> _getApplicationDir() async {
    if (!kIsWeb) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      _appDocDir = appDocDir.path;
    }
  }

  void _browseBudgetFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv'], allowMultiple: false);

    if (result != null) {
      File selectedFile;

      if (!kIsWeb) {
        selectedFile = File(result.files.single.path!);

        // Delete existing budgets.csv file if it exists
        File existingFile = File('$_appDocDir/budgets.csv');
        if (await existingFile.exists()) {
          await existingFile.delete();
        }

        // Copy the selected file to app's local storage
        await selectedFile.copy('$_appDocDir/budgets.csv');
      } else {
        String budgetString = utf8.decode(result.files.single.bytes!);
        html.window.localStorage['budgets'] = budgetString;
      }

      setState(() {
        _selectedBudgetFileName = result.files.single.name; // Update selected budget file name
      });
    }
  }

  void _browseCategoriesFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['csv'], allowMultiple: false);

    if (result != null) {
      File selectedFile;
      if (!kIsWeb) {
        selectedFile = File(result.files.single.path!);

        // Delete existing categories.csv file if it exists
        File existingFile = File('$_appDocDir/categories.csv');
        if (await existingFile.exists()) {
          await existingFile.delete();
        }

        // Copy the selected file to app's local storage
        await selectedFile.copy('$_appDocDir/categories.csv');
      } else {
        String budgetString = utf8.decode(result.files.single.bytes!);
        html.window.localStorage['categories'] = budgetString;
      }

      setState(() {
        _selectedCategoriesFileName = result.files.single.name;
      });
    }
  }

  void _getBudgetsFile() async {
    File existingFile = File('$_appDocDir/budgets.csv');

    String today = DateFormat('yyyyMMdd').format(DateTime.now());
    await existingFile.copy('$_downloadDir/budgets-$today.csv');
  }

  void _getCategoriesFile() async {
    File existingFile = File('$_appDocDir/categories.csv');

    String today = DateFormat('yyyyMMdd').format(DateTime.now());
    await existingFile.copy('$_downloadDir/categories-$today.csv');
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

  void _changeText() {
    setState(() {
      _displayText = 'Donzo exporting!';
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
    _getApplicationDir();
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
            const Text(
              'CONFIG FILES',
              style: myTextStyle,
            ),
            const SizedBox(height: 1.0),
            const Text(
              'Names will be re-written after app closes.',
              style: myTextStylePlsm,
            ),
            const SizedBox(height: 25.0),
            Text(
              'Budget file: $_selectedBudgetFileName',
              style: myTextStylePl,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _browseBudgetFile,
              child: const Text('Browse Budgets'),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Categories file: $_selectedCategoriesFileName',
              style: myTextStylePl,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _browseCategoriesFile,
              child: const Text('Browse Categories'),
            ),
            const SizedBox(height: 60.0),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'EXPORTS',
                    style: myTextStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Text(
                    _displayText,
                    style: myTextStylePl,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getBudgetsFile();
                      _changeText();
                    },
              child: const Text('File: Budgets'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getCategoriesFile();
                      _changeText();
                    },
              child: const Text('File: Categories'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getExpenseThisMonth();
                      _changeText();
                    },
              child: const Text('Expense: This month'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getExpenseLastMonth();
                      _changeText();
                    },
              child: const Text('Expense: Last month'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getExpenseAll();
                      _changeText();
                    },
              child: const Text('Expense: All entries'),
            ),
            const SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: kIsWeb
                  ? null
                  : () {
                      _getTransferAll();
                      _changeText();
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