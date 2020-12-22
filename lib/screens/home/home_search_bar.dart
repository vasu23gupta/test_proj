import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/services/database.dart';

class HomeSearchBar extends StatefulWidget with PreferredSizeWidget {
  HomeSearchBar() {}
  @override
  _HomeSearchBarState createState() => _HomeSearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  HomeSearchBar.createVendors(List<Vendor> vendor) {}
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  List<dynamic> vendors = [];
  Icon appBarIcon = Icon(Icons.search);
  dynamic appBarTitle = Text('Map');
  String stringToSearch;
  List<Text> searchResults;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: appBarTitle,
      elevation: 0.0,
      actions: <Widget>[
        IconButton(
          icon: appBarIcon,
          onPressed: () async {
            vendors = await VendorDBService().getVendors();
            //vendors.add(
            //   await VendorDBService().getVendor('5fe0f368e458bc46fc863218'));
            //print(vendors);
            showSearch(context: context, delegate: SearchVendors(vendors));
            //   setState(
            //     () {
            //       if (this.appBarIcon.icon == Icons.search) {
            //         this.appBarIcon = Icon(Icons.close);
            //         this.appBarTitle = TextField(
            //           onChanged: (value) {
            //             setState(() {
            //               stringToSearch = value;
            //             });
            //           },
            //           style: TextStyle(
            //             color: Colors.white,
            //           ),
            //           decoration: InputDecoration(
            //               prefixIcon: Icon(Icons.search, color: Colors.white),
            //               hintText: "Search...",
            //               hintStyle: TextStyle(color: Colors.white)),
            //         );
            //       } else {
            //         this.appBarIcon = Icon(Icons.search);
            //         this.appBarTitle = Text("Map");
            //       }
            //     },
            //   );
          },
        ),
      ],
    );
  }

  /* void getSearchResults() {
    //searchResults = [];
    vendors.forEach((vendor) {
      if (vendor.contains(stringToSearch)) {
        List<Text> searchResults;
        searchResults.add(Text(vendor.name));
      }
    });
  } */
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

class SearchVendors extends SearchDelegate<Vendor> {
  List<dynamic> vendors;
  int selectedIndex;
  var searchRes;
  SearchVendors(this.vendors);
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Center(child: Text(searchRes[selectedIndex].name));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //List<dynamic> searchResults;
    final searchResults = query.isEmpty
        ? vendors
        : vendors.where((p) {
            if (p.name.startsWith(query) || p.tags.contains(query))
              return true;
            else
              return false;
          }).toList();
    searchRes = searchResults;
    // TODO: implement buildSuggestions
    //print(searchResults.length);
    return searchResults.isEmpty
        ? Text(
            'No Results Found ...',
            style: TextStyle(fontSize: 20),
          )
        : ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final Vendor resultList = searchResults[index];
              return ListTile(
                  onTap: () {
                    selectedIndex = index;
                    showResults(context);
                  },
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resultList.name,
                        style: TextStyle(fontSize: 20),
                      ),
                      Row(
                        children: resultList.tags
                            .map((x) =>
                                Text(x, style: TextStyle(color: Colors.grey)))
                            .toList(),
                      ),
                      Divider()
                    ],
                  ));
            },
          );
  }
}
