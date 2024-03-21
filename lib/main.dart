// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                             __  __       _   _                            * //
// *                                            |  \/  |     | | | |                           * //
// *            _ __ ___   ___  _ __   ___ _   _| \  / | __ _| |_| |_ ___ _ __ ___             * //
// *           | '_ ` _ \ / _ \| '_ \ / _ \ | | | |\/| |/ _` | __| __/ _ \ '__/ __|            * //
// *           | | | | | | (_) | | | |  __/ |_| | |  | | (_| | |_| ||  __/ |  \__ \            * //
// *           |_| |_| |_|\___/|_| |_|\___|\__, |_|  |_|\__,_|\__|\__\___|_|  |___/            * //
// *                                        __/ |                                              * //
// *                                       |___/                                               * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * This app is designed to manage and record all my expenses and transactions.               * //
// * It uses a Realtime Database in Firebase to push and pull expenses as to provide a could   * //
// * backup, and work across multiple devices. It implements a security key in the device to   * //
// * allow usage, rather than username-passwords.                                              * //
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
import 'home_tab.dart';
import 'summary_tab.dart';
import 'settings_tab.dart';
import 'db_handler.dart';
import 'expenses_tab.dart';
import 'transfers_tab.dart';
import 'main_util_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'myapp_styles.dart';

// ********************************************************************************************* //
// *                                      MAIN APP CLASS                                       * //
// * ----------------------------------------------------------------------------------------- * //
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await copyDefaultFiles();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await useValidUserCredentials();
  await DatabaseHelper().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------------- WIDGETS
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tabs Demo',
      theme: ThemeData(
        primarySwatch: myIvoryMaterialColor,
        colorScheme: const ColorScheme.dark(
          background: myDarkColor,
          onBackground: myDarkColor,
          primary: myIvoryColor,
          onPrimary: myIvoryColor,
          secondary: myIvoryColor,
          onSecondary: myIvoryColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(style: raisedButtonStyle),
        toggleButtonsTheme: toggleButtonStyle,
        textTheme: const TextTheme(
          bodyLarge: myTextStyle,
          labelLarge: myButtonTextStyle,
          displayLarge: myTextStyle,
          displayMedium: myTextStyle,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

// ********************************************************************************************* //
// *                              MAIN BODY AND TAB CONTROL CLASS                              * //
// * ----------------------------------------------------------------------------------------- * //
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* --------------------------------------------- VARIABLES
  late TabController _tabController;
  int _currentIndex = 0;

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------- CLASS METHODS
  void _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ------------------------------------ OVERRIDDEN METHODS
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
  //|* ----------------------------------------------- WIDGETS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(10.0),
        child: AppBar(
          title: const Text(''),
          backgroundColor: myBackgroundColor,
          elevation: 0,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeTab(),
          SummaryTab(),
          ExpensesTab(),
          TransfersTab(),
          SettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme: IconThemeData(color: Colors.teal[800]),
        backgroundColor: myBackgroundColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          _tabController.animateTo(index);
        },
      ),
    );
  }
}

//EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF//