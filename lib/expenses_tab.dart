// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                  ALL EXPENSES TABLE TAB                                   * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * This tab shows all the expenses in a table format. User can delete entries here.          * //
// *                                                                                           * //
// * -- Revision --                                                                            * //
// *   2024-03-16 -- version 1.0.0, the first usable                                           * //
// *                                                                                           * //
// * -- Author --                                                                              * //
// *   Alberto Bortoni                                                                         * //
// *                                                                                           * //
// * -- TODOS --                                                                               * //
// *   Error handling is ass                                                                   * //
// *                                                                                           * //
// ~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~.~`~ //

import 'package:flutter/material.dart';
import 'db_handler.dart';
import 'myapp_styles.dart';

// ********************************************************************************************* //
// *                                     EXPENSES TAB CLASS                                    * //
// * ----------------------------------------------------------------------------------------- * //
class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExpensesTabState createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* --------------------------------------------- VARIABLES
  bool _thisMonthSelected = true;
  late Map<dynamic, dynamic>? _allEntries = {};
  late List<bool> _isSelected = [];

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------- CLASS METHODS
  Future<void> _initializeData() async {
    await _updateExpensesAndSummary();
    setState(() {
      // Initialize isSelected list with false values for each entry
      _isSelected = List<bool>.generate(_allEntries?.length ?? 0, (index) => false);
    });
  }

  Future<void> _updateExpensesAndSummary() async {
    if (_thisMonthSelected) {
      _allEntries = await DatabaseHelper().getEntriesThisMonth();
    } else {
      _allEntries = await DatabaseHelper().getEntriesLastMonth();
    }
  }

  Future<void> _deleteButtonPressed() async {
    for (int i = 0; i < _isSelected.length; i++) {
      if (_isSelected[i]) {
        // Get the entry id from the corresponding index in _allEntries
        String? entryId = _allEntries?.entries.elementAt(i).key.toString();
        String? source = _allEntries?.entries.elementAt(i).value['source'].toString();
        double? amount =   _allEntries?.entries.elementAt(i).value['amount'].toDouble();
        

        // Call the deleteEntry function with the entryId
        if (entryId != null) {
          await DatabaseHelper().deleteExpense(entryId);
        }

        // remunerate the money deleted to the source
        if (source != null && amount != null ) {
          amount = amount * -1; 
          await DatabaseHelper().updateAccountSources(source, amount);
        }
        
        

        // Remove the entry from _allEntries and _isSelected
        setState(() {
          _allEntries?.remove(entryId);
          _isSelected.removeAt(i);
        });
      }
    }
  }

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ------------------------------------ OVERRIDDEN METHODS
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------------- WIDGETS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 10.0),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleButtons(
                  isSelected: [_thisMonthSelected, !_thisMonthSelected],
                  onPressed: (index) async {
                    setState(() {
                      _thisMonthSelected = index == 0 ? true : false;
                    });
                    await _updateExpensesAndSummary();
                    setState(() {
                      _isSelected = List<bool>.filled(_allEntries?.length ?? 0, false);
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                      child: Text('This month', style: myButtonTextStyle),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                      child: Text('Last month', style: myButtonTextStyle),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: _deleteButtonPressed,
                ),
              ],
            ),
          ),

          // Expenses section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _allEntries != null
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 10.0,
                      columns: const [
                        DataColumn(label: Text('Date', style: myTableStyle)),
                        DataColumn(label: Text('Time', style: myTableStyle)),
                        DataColumn(label: Text('Description', style: myTableStyle)),
                        DataColumn(label: Text('Amount', style: myTableStyle)),
                        DataColumn(label: Text('Category', style: myTableStyle)),
                        DataColumn(label: Text('Category Type', style: myTableStyle)),
                        DataColumn(label: Text('Budget', style: myTableStyle)),
                        DataColumn(label: Text('Source', style: myTableStyle)),
                        DataColumn(label: Text('Id', style: myTableStyle)),
                      ],
                      rows: List<DataRow>.generate(_allEntries?.length ?? 0, (index) {
                        final entry = _allEntries?.entries.elementAt(index);
                        return DataRow(
                          selected: _isSelected[index],
                          onSelectChanged: (selected) {
                            setState(() {
                              _isSelected[index] = selected!;
                            });
                          },
                          cells: [
                            DataCell(_buildCell(entry?.value['date'].toString() ?? '', 110)),
                            DataCell(_buildCell(entry?.value['time'].toString() ?? '', 70)),
                            DataCell(_buildCell(entry?.value['description'].toString() ?? '', 200)),
                            DataCell(Container(
                              alignment: Alignment.centerRight,
                              child: _buildCell(entry?.value['amount'].toString() ?? '', 90),
                            )),
                            DataCell(_buildCell(entry?.value['category'].toString() ?? '', 150)),
                            DataCell(
                                _buildCell(entry?.value['categoryType'].toString() ?? '', 150)),
                            DataCell(_buildCell(entry?.value['budget'].toString() ?? '', 150)),
                            DataCell(_buildCell(entry?.value['source'].toString() ?? '', 150)),
                            DataCell(_buildCell(entry?.key.toString() ?? '', 200)),
                          ],
                        );
                      }),
                    ),
                  )
                : const Center(
                    child: Text('No entries found', style: myTextStylePl),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: myTableStylePl,
      ),
    );
  }
}

//EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF//