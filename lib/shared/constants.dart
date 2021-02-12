import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'dart:math';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 2.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.pink,
      width: 2.0,
    ),
  ),
);

Icon appBarIcon = Icon(Icons.search);
dynamic appBarTitle = Text('Map');
String stringToSearch;

AppBar homeAppBar(
    Icon appBarIcon, dynamic appBarTitle, String stringToSearch, State state) {
  return AppBar(
    title: appBarTitle,
    backgroundColor: Colors.brown[400],
    elevation: 0.0,
    actions: <Widget>[
      IconButton(
        icon: appBarIcon,
        onPressed: () {
          state.setState(
            () {
              if (appBarIcon.icon == Icons.search) {
                appBarIcon = Icon(Icons.close);
                appBarTitle = TextField(
                  onChanged: (value) {
                    state.setState(() {
                      stringToSearch = value;
                    });
                  },
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.white)),
                );
              } else {
                appBarIcon = Icon(Icons.search);
                appBarTitle = Text("AppBar Title");
              }
            },
          );
        },
      ),
    ],
  );
}

class VendorFilter extends StatefulWidget {
  final List<String> selectedFilters;
  final String text;
  final Color color;
  VendorFilter({this.text, this.selectedFilters, this.color});
  @override
  _VendorFilterState createState() => _VendorFilterState();
}

class _VendorFilterState extends State<VendorFilter> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      labelPadding: EdgeInsets.all(5),
      label: Text(widget.text),
      backgroundColor: widget.color,
      padding: EdgeInsets.all(5),
      selected: _isSelected,
      selectedColor: Colors.blue,
      onSelected: (val) {
        setState(() {
          _isSelected = val;
          if (val) {
            widget.selectedFilters.add(widget.text);
          } else {
            widget.selectedFilters.removeWhere((String name) {
              return name == widget.text;
            });
          }
          // String filters = '';
          // for (var item in widget.selectedFilters) {
          //   filters += item;
          // }
          // print(filters);
        });
      },
    );
  }
}
