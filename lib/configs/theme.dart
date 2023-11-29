import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: "Muli",
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFC88D67),
      ),
      appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black)),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF757575)),
        bodyMedium: TextStyle(color: Color(0xFF757575)),
        bodySmall: TextStyle(color: Color(0xFF757575)),
      ),
      // inputDecorationTheme: const InputDecorationTheme(
      //   floatingLabelBehavior: FloatingLabelBehavior.always,
      //   contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
      //   enabledBorder: outlineInputBorder,
      //   focusedBorder: outlineInputBorder,
      //   border: outlineInputBorder,
      // ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(28)),
  borderSide: BorderSide(color: Color(0xFF757575)),
  gapPadding: 10,
);
