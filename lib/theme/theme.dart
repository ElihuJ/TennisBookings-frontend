import 'package:flutter/material.dart';

import 'colors.dart';

final ThemeData _theme = ThemeData();

const _fontFamily = 'FredokaOne';

final ThemeData selectedTheme = ThemeData(
  checkboxTheme: CheckboxThemeData(fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    return AppColors.white;
  })),

  primaryIconTheme: const IconThemeData(color: AppColors.primaryGreen), // * Burger menu icon color

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.white,
    titleTextStyle: TextStyle(color: Colors.black, fontFamily: _fontFamily, fontSize: 20),
    centerTitle: true,
    iconTheme: IconThemeData(color: AppColors.primaryGreen),
  ), // * App bar style
  fontFamily: _fontFamily,
  primaryColor: AppColors.white,
  colorScheme: _theme.colorScheme.copyWith(
    primary: AppColors.white,
    secondary: AppColors.primaryGreen,
  ),
  primaryColorDark: AppColors.white,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.white,
    selectedItemColor: AppColors.primaryGreen,
    unselectedItemColor: AppColors.grey,
  ), // Bottom Menu
  iconTheme: _theme.iconTheme.copyWith(
    color: AppColors.primaryGreen, // * Changes icon color as Back button in email login screen
  ),
  cardTheme: const CardTheme(
    color: AppColors.white,
    elevation: 5,
  ),
  searchBarTheme: SearchBarThemeData(
    backgroundColor: WidgetStateProperty.resolveWith((states) => AppColors.white),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryGreen,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primaryGreen,
    disabledColor: AppColors.grey,
    colorScheme: _theme.colorScheme.copyWith(primary: AppColors.primaryGreen),
    textTheme: ButtonTextTheme.primary,
    padding: const EdgeInsets.all(10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(10),
    ),
  ),
  canvasColor: AppColors.almostWhite, // * Background color of the scaffold / Drawer / SearchBox
  scaffoldBackgroundColor: AppColors.almostWhite, // * Background color of the scaffold
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: AppColors.white, // * Background color
      foregroundColor: AppColors.black, // * Text color
      padding: const EdgeInsets.all(0),
      alignment: Alignment.center,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    // * Input fields style for search box
    floatingLabelStyle: TextStyle(color: AppColors.grey, fontSize: 12),
    hintStyle: TextStyle(color: AppColors.grey, fontSize: 20),
    border: InputBorder.none,
    contentPadding: EdgeInsets.only(bottom: 14),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    // * Cursor color
    cursorColor: AppColors.primaryGreen,
    selectionColor: AppColors.brightYellow,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 57),
    displayMedium: TextStyle(fontSize: 45),
    displaySmall: TextStyle(fontSize: 36),
    headlineLarge: TextStyle(fontSize: 32),
    headlineMedium: TextStyle(fontSize: 28),
    headlineSmall: TextStyle(fontSize: 24),
    titleLarge: TextStyle(fontSize: 22),
    titleMedium: TextStyle(fontSize: 16), // * Form fields
    titleSmall: TextStyle(fontSize: 14),
    bodyLarge: TextStyle(fontSize: 14),
    bodyMedium: TextStyle(fontSize: 12),
    bodySmall: TextStyle(fontSize: 11),
  ),
  snackBarTheme: const SnackBarThemeData(
    // * Snackbar style
    backgroundColor: AppColors.almostWhite,
    contentTextStyle: TextStyle(color: AppColors.black),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
  ),
);
