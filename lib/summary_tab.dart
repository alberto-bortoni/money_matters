// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                           CATEGORY/BUDGET/ACCOUNTS SUMMARY TAB                            * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * This tab shows the user the summary of all expenses by budget, category, and target       * //
// * account.                                                                                  * //
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
import 'db_handler.dart';
import 'myapp_styles.dart';

// ********************************************************************************************* //
// *                                     SUMMARY TAB CLASS                                     * //
// * ----------------------------------------------------------------------------------------- * //
class SummaryTab extends StatefulWidget {
  const SummaryTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SummaryTabState createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* -------------------------------------------- VARIALBES
  bool _thisMonthSelected = true;
  late List<String> _budgets = [];
  late Map<String, List<String>> _categories = {};
  late Map<String, double> _budgetAmounts = {};
  late Map<String, double> _categoryAmounts = {};
  late Map<String, double> _accountsTally = {};

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------- CLASS METHODS
  Future<void> _initializeData() async {
    _budgets = await DatabaseHelper().getBudgetsTypes();
    _categories = await DatabaseHelper().getCategoriesTypes();
    await _updateBudgetCategoryAccountAmounts();

    setState(() {});
  }

  Future<void> _updateBudgetCategoryAccountAmounts() async {
    _budgetAmounts = {};
    _categoryAmounts = {};
    Map<dynamic, dynamic>? entries;
    if (_thisMonthSelected) {
      entries = await DatabaseHelper().getEntriesThisMonth();
    } else {
      entries = await DatabaseHelper().getEntriesLastMonth();
    }
    if (entries != null) {
      entries.forEach((key, value) {
        String budget = value['budget'];
        String category = value['category'];
        double amount = value['amount'].toDouble();
        if (_budgets.contains(budget)) {
          _budgetAmounts.update(budget, (value) => value + amount, ifAbsent: () => amount);
        } else {
          _budgetAmounts.update('NaN', (value) => value + amount, ifAbsent: () => amount);
        }
        if (_categories.containsKey(category)) {
          _categoryAmounts.update(category, (value) => value + amount, ifAbsent: () => amount);
        } else {
          _categoryAmounts.update('NaN', (value) => value + amount, ifAbsent: () => amount);
        }
      });
    }

    _accountsTally = await DatabaseHelper().getSourcesAmounts();
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
    return ListView(
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
                  await _updateBudgetCategoryAccountAmounts();
                  setState(() {});
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
            ],
          ),
        ),

        // Budgets section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'BUDGETS',
                style: myTextStyle,
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _budgets.length + 1,
                itemBuilder: (context, index) {
                  if (index < _budgets.length) {
                    String budget = _budgets[index];
                    double amount = _budgetAmounts[budget] ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(budget, style: myTextStylePl),
                          ),
                          Text('\$${amount.toStringAsFixed(2)}', style: myTextStylePl),
                        ],
                      ),
                    );
                  } else {
                    // Calculate total amount
                    double totalAmount =
                        _budgetAmounts.values.fold(0, (prev, amount) => prev + (amount));
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('TOTAL', style: myTextStylePl),
                          ),
                          Text('\$${totalAmount.toStringAsFixed(2)}', style: myTextStylePl),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // Categories section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CATEGORIES',
                style: myTextStyle,
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  String category = _categories.keys.elementAt(index);
                  double amount = _categoryAmounts[category] ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(category, style: myTextStylePl),
                        ),
                        Text('\$${amount.toStringAsFixed(2)}', style: myTextStylePl),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ACCOUNTS',
                style: myTextStyle,
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _accountsTally.length,
                itemBuilder: (context, index) {
                  String accounts = _accountsTally.keys.elementAt(index);
                  double amount = _accountsTally[accounts] ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(accounts, style: myTextStylePl),
                        ),
                        Text('\$${amount.toStringAsFixed(2)}', style: myTextStylePl),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF//