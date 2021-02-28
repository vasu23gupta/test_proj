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

// ignore: non_constant_identifier_names
HashMap<String, List<String>> FILTERS = HashMap.from({
  "Food": ["North Indian", "Chinese", "South Indian"],
  "Repair": ["Car", "Bike", "Cycle"],
  "yvyvu": ["yrvr", "45y95"],
  "251125v": ["wyye4y"],
  "vb845yb": [null],
});
HashMap<String, List<bool>> areSelected = HashMap.from({
  "Food": [false, false, false],
  "Repair": [false, false, false],
  "yvyvu": [false, false],
  "251125v": [false],
  "vb845yb": [false],
});
HashMap<String, bool> isSelected = HashMap.from({
  "Food": false,
  "Repair": false,
  "yvyvu": false,
  "251125v": false,
  "vb845yb": false,
});
