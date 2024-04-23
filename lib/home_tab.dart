// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                 HOME/RECORD EXPENSE TAB                                   * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * This tab is where the user enters an expense and categorizses it propperly.               * //
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_handler.dart';
import 'main_util_functions.dart';
import 'myapp_styles.dart';
import 'dart:async';

// ********************************************************************************************* //
// *                                      HOME TAB CLASS                                       * //
// * ----------------------------------------------------------------------------------------- * //
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* --------------------------------------------- VARIABLES
  late String _currentDate;
  late String _currentTime;
  late Timer _timer;

  final _descriptionController = TextEditingController();

  final _amountController = TextEditingController();
  bool _makePositiveCb = false;

  late String _categoryValue = 'NaN';
  List<String> _categoryOptions = ['NaN'];
  late Map<String, List<String>> _categoryMap = {
    'NaN': ['']
  };

  String _typeValue = '';

  late String _budgetValue = 'NaN';
  List<String> _budgetOptions = ['NaN'];

  List<String> _sourcesOptions = ['NaN'];
  String _selectedSource = 'NaN';

  String _displayText = '';

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------- CLASS METHODS
  void _updateDateTime() {
    setState(() {
      _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _currentTime = DateFormat('HH:mm').format(DateTime.now());
    });
  }

  void _initializeCategoryOptions() async {
    // Parse the "categories.csv" file and update _categoriesOptions
    _categoryMap = await parseCategoriesCSV();
    List<String> uniqueCategories = _categoryMap.keys.toList();

    setState(() {
      _categoryOptions = uniqueCategories;
      _categoryValue = _categoryOptions.first; // Set default value for budget to empty string
    });
  }

  void _initializeBudgetOptions() async {
    // Parse the "budgets.csv" file and update _budgetOptions
    List<String> budgets = await parseBudgetsCSV();
    setState(() {
      _budgetOptions = budgets;
      _budgetValue = _budgetOptions.first; // Set default value for budget to empty string
    });
  }

  void _initializeSourcesOptions() async {
    List<String> sources = await DatabaseHelper().getSourcesTypes();
    setState(() {
      _sourcesOptions = ['NaN'] + sources;
      _selectedSource = _sourcesOptions.first;
    });
  }

  void _saveEntryToDatabase() async {
    if (_descriptionController.text.trim() == '') {
      _changeText('Fill description');
      return;
    }

    double amount;
    try {
      amount = double.parse(_amountController.text.trim());
      amount = amount.toDouble().abs();
      if (!_makePositiveCb) {
        amount = -amount;
      }
    } catch (e) {
      _changeText('Fill amount with number');
      return;
    }

    if (_categoryValue == 'NaN' ||
        _typeValue == '' ||
        _budgetValue == 'NaN' ||
        _selectedSource == 'NaN') {
      _changeText('Options cannot be NaN');
      return;
    }

    final entry = {
      'date': _currentDate,
      'time': _currentTime,
      'description': _descriptionController.text.trim(),
      'amount': amount,
      'category': _categoryValue,
      'categoryType': _typeValue,
      'budget': _budgetValue,
      'source': _selectedSource,
      'timestamp': _getTimestamp(_currentDate, _currentTime)
    };

    await DatabaseHelper().insertExpnese(entry);
    await DatabaseHelper().updateAccountSources(_selectedSource, amount);

    _clearForm();
  }

  int _getTimestamp(String date, String time) {
    // Convert date string to DateTime object
    DateTime dateTime = DateTime.parse('$date $time');

    // Format DateTime object into 'yyyyMMddHHmm' format
    String formattedDateTime = DateFormat('yyyyMMddHHmm').format(dateTime);

    // Parse formattedDateTime into an integer
    return int.parse(formattedDateTime);
  }

  void _clearForm() {
    _descriptionController.clear();
    _amountController.clear();
    setState(() {
      _categoryValue = 'NaN';
      _typeValue = '';
      _budgetValue = 'NaN';
      _selectedSource = 'NaN';
      _makePositiveCb = false;
    });
  }

  void _changeText(String text) {
    setState(() {
      _displayText = text; // Change text after button press
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
    _updateDateTime();
    _initializeBudgetOptions();
    _initializeCategoryOptions();
    _initializeSourcesOptions();

    // Start a timer to update the date and time every minute
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _updateDateTime();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------------- WIDGETS
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'Date:  ', style: myTextStyle),
                  TextSpan(text: _currentDate, style: myTextStylePl),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'Time:  ', style: myTextStyle),
                  TextSpan(text: _currentTime, style: myTextStylePl),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Expense Description',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                Checkbox(
                  value: _makePositiveCb,
                  onChanged: (newValue) {
                    setState(() {
                      _makePositiveCb = newValue ?? false;
                    });
                  },
                ),
                const Text('+', style: myButtonTextStyle),
              ],
            ),
            const SizedBox(height: 20.0),
            DropdownButtonFormField(
              value: _categoryValue,
              decoration: const InputDecoration(
                labelText: 'Category',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              items: _categoryOptions.map((category) {
                return DropdownMenuItem(value: category, child: Text(category, style: myMenuStyle));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _categoryValue = value.toString();
                  if (_categoryValue == "NaN") {
                    _typeValue = '';
                  } else {
                    _typeValue = _categoryMap[value.toString()]!.first;
                  }
                });
              },
            ),
            const SizedBox(height: 20.0),
            DropdownButtonFormField(
              value: _typeValue,
              decoration: const InputDecoration(
                labelText: 'Type',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              items: _categoryMap[_categoryValue]!.map((categoryType) {
                return DropdownMenuItem(
                    value: categoryType, child: Text(categoryType, style: myMenuStyle));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _typeValue = value.toString();
                });
              },
            ),
            const SizedBox(height: 20.0),
            DropdownButtonFormField(
              value: _budgetValue,
              decoration: const InputDecoration(
                labelText: 'Budget',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              items: _budgetOptions.map((budget) {
                return DropdownMenuItem(value: budget, child: Text(budget, style: myMenuStyle));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _budgetValue = value.toString();
                });
              },
            ),
            const SizedBox(height: 20.0),
            DropdownButtonFormField(
              value: _selectedSource,
              decoration: const InputDecoration(
                labelText: 'Source',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              items: _sourcesOptions.map((budget) {
                return DropdownMenuItem(value: budget, child: Text(budget, style: myMenuStyle));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSource = value.toString();
                });
              },
            ),
            const SizedBox(height: 30.0),
            Text(_displayText, style: myTextStylePl, textAlign: TextAlign.center),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _saveEntryToDatabase();
                  },
                  style: raisedButtonStyle,
                  child: const Text('Push', style: myButtonTextStyle),
                ),
                const SizedBox(width: 20.0),
                OutlinedButton(
                  onPressed: () {
                    _clearForm();
                  },
                  style: raisedButtonStyle,
                  child: const Text('Clear', style: myButtonTextStyle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF//