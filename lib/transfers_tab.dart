// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                  RECORD TRANSFERS TAB                                     * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * This tab is where the user registers transfers, or moving money that is not an expense.   * //
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
import 'myapp_styles.dart';

// ********************************************************************************************* //
// *                                     TRANSFERS TAB CLASS                                   * //
// * ----------------------------------------------------------------------------------------- * //
class TransfersTab extends StatefulWidget {
  const TransfersTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransfersState createState() => _TransfersState();
}

class _TransfersState extends State<TransfersTab> {
  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* --------------------------------------------- VARIABLES
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  List<String> _incomesOptions = ['NaN'];
  List<String> _sourcesOptions = ['NaN'];
  List<String> _fromOptions = ['NaN'];
  List<String> _fromDisplay = ['NaN'];
  List<String> _toOptions = ['NaN'];
  List<String> _toDisplay = ['NaN'];

  String _selectedTo = 'NaN';
  String _selectedFrom = 'NaN';

  final String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String _currentTime = DateFormat('HH:mm').format(DateTime.now());

  String _displayText = '';

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------- CLASS METHODS
  void _initializeIncomesAndSourcesOptions() async {
    // Parse the "budgets.csv" file and update _budgetOptions
    List<String> incomes = await DatabaseHelper().getIcomesTypes();
    List<String> sources = await DatabaseHelper().getSourcesTypes();

    setState(() {
      _sourcesOptions = sources;
      _incomesOptions = incomes;

      _toOptions = ['NaN'] + _sourcesOptions;
      _fromOptions = _toOptions + _incomesOptions;

      _toDisplay = ['NaN'] + _sourcesOptions.map((source) => 'Source - $source').toList();
      _fromDisplay = _toDisplay + _incomesOptions.map((source) => 'Income - $source').toList();
    });
  }

  void _recordTransaction() async {
    String transferType;
    double amount;

    if (_descriptionController.text.trim() == '') {
      _changeText('Fill description');
      return;
    }

    try {
      amount = double.parse(_amountController.text.trim());
      amount = amount.toDouble().abs();
    } catch (e) {
      _changeText('Fill amount with number');
      return;
    }

    if (_selectedFrom == 'NaN' || _selectedTo == 'NaN') {
      _changeText('Options cannot be NaN');
      return;
    }

    if (_sourcesOptions.contains(_selectedFrom)) {
      DatabaseHelper().updateAccountSources(_selectedFrom, -amount.toDouble().abs());
    }
    DatabaseHelper().updateAccountSources(_selectedTo, amount.toDouble().abs());

    if (_incomesOptions.contains(_selectedFrom)) {
      transferType = 'income';
    } else {
      transferType = 'transfer';
    }

    final entry = {
      'date': _currentDate,
      'time': _currentTime,
      'description': _descriptionController.text.trim(),
      'amount': amount,
      'from': _selectedFrom,
      'to': _selectedTo,
      'type': transferType,
      'timestamp': _getTimestamp(_currentDate, _currentTime)
    };

    await DatabaseHelper().recordTransaction(entry);

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
      _selectedFrom = 'NaN';
      _selectedTo = 'NaN';
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
    _initializeIncomesAndSourcesOptions();
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
                labelText: 'Transfer Description',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
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
            const SizedBox(height: 20.0),
            DropdownButtonFormField(
              value: _selectedFrom,
              decoration: const InputDecoration(
                labelText: 'From',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              items: _fromDisplay.map((String value) {
                return DropdownMenuItem<String>(
                  value: _fromOptions[_fromDisplay.indexOf(value)],
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFrom = newValue!;
                });
              },
            ),
            const SizedBox(height: 20.0),
            DropdownButtonFormField(
              value: _selectedTo,
              decoration: const InputDecoration(
                labelText: 'To',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: myOutlineColor, width: 1.5),
                  borderRadius: BorderRadius.zero,
                ),
              ),
              items: _toDisplay.map((String value) {
                return DropdownMenuItem<String>(
                  value: _toOptions[_toDisplay.indexOf(value)],
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTo = newValue!;
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
                    _recordTransaction();
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