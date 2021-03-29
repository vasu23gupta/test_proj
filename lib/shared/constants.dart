import 'dart:collection';
import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  //fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      //color: Colors.white,
      width: 2.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      //color: Colors.pink,
      width: 2.0,
    ),
  ),
);

const AUTH_MAIN_COLOR = Color(0xff2470c7);

// ignore: non_constant_identifier_names
HashMap<String, List<String>> FILTERS = HashMap.from({
  "Food": [
    "Tea Stall",
    "Paan",
    "Fast Food",
    "North Indian",
    "South Indian",
    "Chinese",
    "Other"
  ],
  "Repair": ["Tailor", "Cobbler", "Car", "Bike", "Cycle", "Other"],
  "Shops": ["Toys", "Crafts", "Clothing", "Grocery", "Other"],
});
HashMap<String, List<bool>> areSelected = HashMap.from({
  "Food": [false, false, false, false, false, false, false],
  "Repair": [false, false, false, false, false, false],
  "Shops": [false, false, false, false, false],
});
HashMap<String, bool> isSelected = HashMap.from({
  "Food": false,
  "Repair": false,
  "Shops": false,
});
