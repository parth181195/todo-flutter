import 'package:flutter/material.dart';
// import './pages/home_page.dart';
import './pages/home.dart';

void main() {
  runApp(new MaterialApp(
    home: new Home(),
    theme: new  ThemeData.dark().copyWith(
          primaryColor: Colors.grey[800],
          accentColor: Colors.cyan[300],
          buttonColor: Colors.grey[800],
          textSelectionColor: Colors.cyan[100],
          backgroundColor: Colors.grey[800],
    )
  ));
}