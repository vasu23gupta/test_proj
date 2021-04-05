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

const BACKGROUND_COLOR = Color(0xff73DCE2);
const TEXT_COLOR = Color(0xff5C73FF);

Padding buildEmailRow(_emailController) => Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email,
            color: TEXT_COLOR,
          ),
          hintText: 'E-mail',
        ),
        validator: (val) => val.isEmpty ? 'Enter an email' : null,
      ),
    );

Padding buildLogo(double _h) => Padding(
      padding: EdgeInsets.symmetric(vertical: _h * 0.085),
      child: Text(
        'LOCALPEDIA',
        style: TextStyle(
          fontSize: _h * 0.05,
          fontWeight: FontWeight.bold,
          color: TEXT_COLOR,
        ),
      ),
    );

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
