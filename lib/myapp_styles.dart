// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                    COLOR TEXT AND STYLES                                  * //
// *.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.*.* //
// *                                                                                           * //
// * This provides all the colors and font types that make the app consistent.                 * //
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

//|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*|*
//|* --------------------------------------------- VARIABLES
const myBackgroundColor = Color.fromARGB(255, 51, 51, 51);
const myOutlineColor = Color.fromARGB(255, 220, 220, 220);
const Color myIvoryColor = Color.fromRGBO(255, 255, 240, 1);
const Color myDarkColor = Color.fromARGB(255, 50, 50, 50);

MaterialColor myIvoryMaterialColor = MaterialColor(
  0x323232, // Primary value (RGB color value)
  <int, Color>{
    50: myIvoryColor.withOpacity(0.1),
    100: myIvoryColor.withOpacity(0.2),
    200: myIvoryColor.withOpacity(0.3),
    300: myIvoryColor.withOpacity(0.4),
    400: myIvoryColor.withOpacity(0.5),
    500: myIvoryColor.withOpacity(0.6), // Primary color
    600: myIvoryColor.withOpacity(0.7),
    700: myIvoryColor.withOpacity(0.8),
    800: myIvoryColor.withOpacity(0.9),
    900: myIvoryColor.withOpacity(1.0),
  },
);

const TextStyle myTextStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
  fontFamily: 'monospace',
  color: myIvoryColor,
);

const TextStyle myTextStylePl = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.normal,
  fontFamily: 'monospace',
  color: myIvoryColor,
);

const TextStyle myTextStylePlsm = TextStyle(
  fontSize: 12.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
  fontFamily: 'monospace',
  color: myIvoryColor,
);

const TextStyle myButtonTextStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
  fontFamily: 'monospace',
  color: myIvoryColor,
);

const TextStyle myMenuStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.w600,
  fontStyle: FontStyle.normal,
  fontFamily: 'monospace',
  color: myIvoryColor,
);

const TextStyle myTableStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.bold,
  fontStyle: FontStyle.normal,
  fontFamily: 'monospace',
  color: myIvoryColor,
);

const TextStyle myTableStylePl = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.normal,
  fontFamily: 'monospace',
  color: myIvoryColor,
);

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: myIvoryColor,
  backgroundColor: myDarkColor,
  elevation: 5,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(7)),
  ),
);

final toggleButtonStyle = ToggleButtonsThemeData(
  selectedColor: myIvoryColor,
  fillColor: myDarkColor,
  textStyle: myButtonTextStyle,
  selectedBorderColor: myIvoryColor,
  borderRadius: BorderRadius.circular(8.0),
  borderWidth: 2.0,
  highlightColor: Colors.teal[800],
);

//EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF EOF//