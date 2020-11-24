import 'package:flutter/material.dart';
import 'package:test_proj/models/vendor.dart';

class HomeSearchBar extends StatefulWidget with PreferredSizeWidget {
  final List<Vendor> vendors;
  HomeSearchBar({this.vendors});
  @override
  _HomeSearchBarState createState() => _HomeSearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  List<Vendor> vendors = HomeSearchBar().vendors;
  Icon appBarIcon = Icon(Icons.search);
  dynamic appBarTitle = Text('Map');
  String stringToSearch;
  List<Text> searchResults;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: appBarTitle,
      backgroundColor: Colors.brown[400],
      elevation: 0.0,
      actions: <Widget>[
        IconButton(
          icon: appBarIcon,
          onPressed: () {
            setState(
              () {
                if (this.appBarIcon.icon == Icons.search) {
                  this.appBarIcon = Icon(Icons.close);
                  this.appBarTitle = TextField(
                    onChanged: (value) {
                      setState(() {
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
                  this.appBarIcon = Icon(Icons.search);
                  this.appBarTitle = Text("Map");
                }
              },
            );
          },
        ),
      ],
    );
  }

  void getSearchResults() {
    searchResults = [];
    vendors.forEach((vendor) {
      if (vendor.contains(stringToSearch)) {
        searchResults.add(Text(vendor.name));
      }
    });
  }
}

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String stringToSearch;
  showOverlay(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry searchBox = OverlayEntry(
      builder: (context) => Positioned(
        top: 100.0,
        child: TextField(
          onChanged: (value) {
            setState(() {
              stringToSearch = value;
            });
          },
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white),
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
    overlayState.insert(searchBox);
  }

  @override
  Widget build(BuildContext context) {
    showOverlay(context);
    return Container();
  }
}
