import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_proj/screens/SearchResults.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:latlong/latlong.dart';
import '../vendorDetails/vendor_details.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:test_proj/screens/SearchResults.dart';

enum SingingCharacter {
  RatingHighToLow,
  RatingLowToHigh,
  DistanceClosest,
  DateAddedLatest,
  DateAddedEarliest,
  Relevance,
  DistanceFarthest,
}

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  void initState() {
    super.initState();
    LocationService locSer = new LocationService();

    locSer.getLocation().then((value) {
      setState(() {
        userLocFut = LatLng(value.latitude, value.longitude);
        print("ye rha mai " + userLocFut.toSexagesimal());
      });
    });
  }

  LatLng userLocFut;
  List<Marker> buildMarkers(List<dynamic> searchResults) {
    List<Marker> toShowOnMap = [];
    for (Vendor vendor in searchResults) {
      toShowOnMap.add(new Marker(
        //anchorPos: AnchorPos.align(AnchorAlign.center),
        width: 45.0,
        height: 45.0,
        point: vendor.coordinates,
        builder: (context) => IconButton(
          //alignment: Alignment.bottomRight,
          icon: Icon(Icons.circle),
          iconSize: 40.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorDetails(
                  vendor: vendor,
                ),
              ),
            );
          },
        ),
      ));
    }
    return toShowOnMap;
  }

  Widget buildSuggestions() {
    //print('enter');
    //var selectedIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Flexible(
          fit: FlexFit.loose,
          child: this.searchResults.length != 0
              ? new ListView.builder(
                  shrinkWrap: true,
                  itemCount: this.searchResults.length,
                  itemBuilder: (context, index) {
                    //entered = 'true';
                    Vendor resultList = this.searchResults[index];
                    //print(entered);
                    return ListTile(
                      onTap: () async {
                        //selectedIndex = index;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorDetails(
                              vendor: resultList,
                            ),
                          ),
                        );
                        //Navigator.pop(context);
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
                                .map((x) => Text(x,
                                    style: TextStyle(color: Colors.grey)))
                                .toList(),
                          ),
                          Divider()
                        ],
                      ),
                    );
                  },
                )
              : Text('Enter tags/name'),
        )
      ],
    );
  }

  //String query;
  bool sort = false;
  SingingCharacter sortBy = SingingCharacter.Relevance;
  String selectedSortBy = "";
  List<dynamic> searchResults = [];
  List<String> selectedFilters = [];
  ListView suggestions;
  List<String> tags = ['1', '2,', '3', '4'];
  TextEditingController query = new TextEditingController();
  String dropdownValue = "no limit: default";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: TextField(
            controller: query,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white),
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.white),
            ),
            onChanged: (value) async {
              List<dynamic> sR = [];
              if (value.length != 0) {
                print(value +
                    " " +
                    dropdownValue +
                    " " +
                    userLocFut.latitude.toString() +
                    " " +
                    userLocFut.longitude.toString());
                sR = await VendorDBService.getVendorsFromSearch(
                    value, dropdownValue, userLocFut);
              }
              setState(() {
                this.searchResults = sR;
                sortBy = SingingCharacter.Relevance;
              });
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  query.text = '';
                  searchResults = [];
                });
              },
            )
          ],
        ),
        body: Column(
          children: [
            ButtonBar(
              mainAxisSize: MainAxisSize.max,
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  hint: Text(
                    "Search Radius",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  isExpanded: false,
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: <String>['no limit: default', '10km', '15km', '5km']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                FlatButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          children: [
                            ListTile(
                              title: const Text("Relevance"),
                              leading: Radio(
                                value: SingingCharacter.Relevance,
                                groupValue: sortBy,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    sortBy = value;
                                    print(sortBy);
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Distance: Closest"),
                              leading: Radio(
                                value: SingingCharacter.DistanceClosest,
                                groupValue: sortBy,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    sortBy = value;
                                    this.searchResults.sort((a, b) {
                                      Distance distance = new Distance();

                                      double aDistance =
                                          distance(a.coordinates, userLocFut);
                                      print(aDistance);
                                      double bDistance =
                                          distance(b.coordinates, userLocFut);
                                      print(bDistance);
                                      aDistance.compareTo(bDistance);
                                      return aDistance.compareTo(bDistance);
                                    });
                                    print(sortBy);
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Distance: Farthest"),
                              leading: Radio(
                                value: SingingCharacter.DistanceFarthest,
                                groupValue: sortBy,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    sortBy = value;
                                    this.searchResults.sort((a, b) {
                                      Distance distance = new Distance();

                                      double aDistance =
                                          distance(a.coordinates, userLocFut);
                                      print(aDistance);
                                      double bDistance =
                                          distance(b.coordinates, userLocFut);
                                      print(bDistance);
                                      aDistance.compareTo(bDistance);
                                      return -1 *
                                          aDistance.compareTo(bDistance);
                                    });
                                    print(sortBy);
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Rating: Low to High"),
                              leading: Radio(
                                value: SingingCharacter.RatingLowToHigh,
                                groupValue: sortBy,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    sortBy = value;
                                    print(sortBy);
                                    Navigator.pop(context);
                                    //print(searchResults[2].stars);
                                    this.searchResults.sort(
                                        (a, b) => a.stars.compareTo(b.stars));
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Rating: High To Low"),
                              leading: Radio(
                                value: SingingCharacter.RatingHighToLow,
                                groupValue: sortBy,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    sortBy = value;
                                    print(sortBy);
                                    Navigator.pop(context);
                                    //print(searchResults[2].stars);
                                    this.searchResults.sort((a, b) =>
                                        -1 * a.stars.compareTo(b.stars));
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Date: earliest added first"),
                              leading: Radio(
                                value: SingingCharacter.DateAddedEarliest,
                                groupValue: sortBy,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    sortBy = value;
                                    this.searchResults.sort((a, b) {
                                      DateTime aDate = a.createdOn;
                                      DateTime bDate = b.createdOn;
                                      return aDate.compareTo(bDate);
                                    });
                                    print(sortBy);
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Date: latest added first"),
                              leading: Radio(
                                value: SingingCharacter.DateAddedLatest,
                                groupValue: sortBy,
                                onChanged: (SingingCharacter value) {
                                  setState(() {
                                    sortBy = value;
                                    this.searchResults.sort((a, b) {
                                      DateTime aDate = a.createdOn;
                                      DateTime bDate = b.createdOn;
                                      return -1 * aDate.compareTo(bDate);
                                    });
                                    print(sortBy);
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.sort),
                      Text(
                        "Sort",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: null,
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt),
                      Text("Filter",
                          style: TextStyle(
                            fontSize: 15,
                          )),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    if (this.searchResults.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Search Results are empty",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => new SearchResults(
                            markers: buildMarkers(this.searchResults),
                            mapCenter: this.userLocFut,
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.location_pin),
                      Text("Show On Map",
                          style: TextStyle(
                            fontSize: 15,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            buildSuggestions(),
          ],
        )
        /* Center(
          child: this
              .suggestions /* (searchResults.length != 0)
            ? buildSuggestions()
            : Text('Enter tags/name'), */
          ), */
        );
  }
}
