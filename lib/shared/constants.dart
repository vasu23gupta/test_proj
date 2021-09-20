import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const textInputDecoration = InputDecoration(
  counterText: "",
  filled: true,
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0)),
  focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 1.0)),
);

// ignore: non_constant_identifier_names
ButtonStyle BS(double w, double h) => ButtonStyle(
    minimumSize: MaterialStateProperty.all<Size>(Size(w, h)),
    backgroundColor: MaterialStateProperty.all<Color>(TEXT_COLOR),
    shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))));

const BACKGROUND_COLOR = Color(0xff73DCE2);
const TEXT_COLOR = Color(0xff5C73FF);
String mapApiKey = '';

SvgPicture foodMarker = SvgPicture.asset('assets/food.svg');
SvgPicture repairMarker = SvgPicture.asset('assets/repair.svg');
SvgPicture shopMarker = SvgPicture.asset('assets/shop.svg');
SvgPicture pinMarker = SvgPicture.asset('assets/pin.svg');

// ignore: non_constant_identifier_names
TextStyle ERROR_TEXT_STYLE(double _w) =>
    TextStyle(color: Colors.red, fontSize: _w * 0.042);

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
            hintStyle: TextStyle(color: ThemeData.light().hintColor)),
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
    "Chinese"
  ],
  "Repair": ["Tailor", "Cobbler", "Car", "Bike", "Cycle"],
  "Shop": ["Toys", "Crafts", "Clothing", "Grocery"],
});
HashMap<String, List<bool>> areSelected = HashMap.from({
  "Food": [false, false, false, false, false, false],
  "Repair": [false, false, false, false, false],
  "Shop": [false, false, false, false],
});
HashMap<String, bool> isSelected = HashMap.from({
  "Food": false,
  "Repair": false,
  "Shop": false,
});
