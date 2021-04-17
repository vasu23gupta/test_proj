import 'package:flutter/material.dart';
import 'package:test_proj/screens/Search/Filter.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:latlong/latlong.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/starrating.dart';
import '../vendorDetails/vendor_details.dart';
import 'package:flutter_map/flutter_map.dart';

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
  final List<dynamic> searchRes;
  final LatLng userLoc;
  Search({this.searchRes, this.userLoc});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<dynamic> searchResults = [];
  SingingCharacter _sortBy = SingingCharacter.Relevance;
  ListView suggestions;
  TextEditingController query = TextEditingController();
  String _dropdownValue = "no limit: default";
  List<String> _searchRadii = ['no limit: default', '10km', '15km', '5km'];
  LatLng _userLoc;
  Size _size;

  @override
  void initState() {
    super.initState();
    searchResults = widget.searchRes == null ? [] : widget.searchRes;
    _userLoc = widget.userLoc;
  }

  Future<void> _performSearch(value) async {
    List<dynamic> sR = [];
    if (value.length > 1)
      sR = await VendorDBService.getVendorsFromSearch(
          value, _dropdownValue, _userLoc);
    setState(() => searchResults = sR);
  }

  List<Marker> _buildMarkers(List<dynamic> searchResults) {
    List<Marker> toShowOnMap = [];
    for (Vendor vendor in searchResults) {
      toShowOnMap.add(Marker(
        width: 45.0,
        height: 45.0,
        point: vendor.coordinates,
        builder: (context) => IconButton(
          icon: Icon(Icons.circle),
          iconSize: 40.0,
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VendorDetails(vendor: vendor),
          )),
        ),
      ));
    }
    return toShowOnMap;
  }

  Widget _buildSuggestions() =>
      searchResults != null && searchResults.length != 0
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) =>
                  _buildVendorTile(searchResults[index]),
            )
          : Text('Enter tags/name');

  Container _buildVendorTile(Vendor result) => Container(
        padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 2,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          tileColor: Theme.of(context).cardColor,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => VendorDetails(vendor: result))),
          title: Row(
            children: [
              Column(children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image(
                    image: VendorDBService.getVendorImage(result.imageIds[0]),
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                  ),
                ),
                Text('X Kms away')
              ]),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(result.name, style: TextStyle(fontSize: 20)),
                  SizedBox(
                    width: 200,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: result.tags
                            .map((x) => Chip(label: Text(x)))
                            .toList(),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        result.stars.toString(),
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      StarRating(rating: result.stars)
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            ButtonBar(
              mainAxisSize: MainAxisSize.max,
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  hint: Text("Search Radius"),
                  isExpanded: false,
                  value: _dropdownValue,
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline:
                      Container(height: 2, color: Colors.deepPurpleAccent),
                  onChanged: (String newValue) =>
                      setState(() => _dropdownValue = newValue),
                  items: _searchRadii
                      .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                      .toList(),
                ),
                TextButton(
                  onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                            children: [
                              ListTile(
                                title: const Text("Relevance"),
                                leading: Radio(
                                  value: SingingCharacter.Relevance,
                                  groupValue: _sortBy,
                                  onChanged: (SingingCharacter value) {
                                    setState(() {
                                      _sortBy = value;
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text("Distance: Closest"),
                                leading: Radio(
                                  value: SingingCharacter.DistanceClosest,
                                  groupValue: _sortBy,
                                  onChanged: (SingingCharacter value) {
                                    setState(() {
                                      _sortBy = value;
                                      searchResults.sort((a, b) {
                                        Distance distance = Distance();
                                        double aDistance =
                                            distance(a.coordinates, _userLoc);
                                        double bDistance =
                                            distance(b.coordinates, _userLoc);
                                        return aDistance.compareTo(bDistance);
                                      });
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: const Text("Distance: Farthest"),
                                leading: Radio(
                                  value: SingingCharacter.DistanceFarthest,
                                  groupValue: _sortBy,
                                  onChanged: (SingingCharacter value) =>
                                      setState(() {
                                    _sortBy = value;
                                    searchResults.sort((a, b) {
                                      Distance distance = Distance();
                                      double aDistance =
                                          distance(a.coordinates, _userLoc);
                                      double bDistance =
                                          distance(b.coordinates, _userLoc);
                                      aDistance.compareTo(bDistance);
                                      return -1 *
                                          aDistance.compareTo(bDistance);
                                    });
                                    Navigator.pop(context);
                                  }),
                                ),
                              ),
                              ListTile(
                                title: const Text("Rating: Low to High"),
                                leading: Radio(
                                  value: SingingCharacter.RatingLowToHigh,
                                  groupValue: _sortBy,
                                  onChanged: (SingingCharacter value) =>
                                      setState(() {
                                    _sortBy = value;
                                    print(_sortBy);
                                    Navigator.pop(context);
                                    searchResults.sort(
                                        (a, b) => a.stars.compareTo(b.stars));
                                  }),
                                ),
                              ),
                              ListTile(
                                title: const Text("Rating: High To Low"),
                                leading: Radio(
                                  value: SingingCharacter.RatingHighToLow,
                                  groupValue: _sortBy,
                                  onChanged: (SingingCharacter value) =>
                                      setState(() {
                                    _sortBy = value;
                                    Navigator.pop(context);
                                    searchResults.sort((a, b) =>
                                        -1 * a.stars.compareTo(b.stars));
                                  }),
                                ),
                              ),
                              ListTile(
                                title: const Text("Date: earliest added first"),
                                leading: Radio(
                                  value: SingingCharacter.DateAddedEarliest,
                                  groupValue: _sortBy,
                                  onChanged: (SingingCharacter value) =>
                                      setState(() {
                                    _sortBy = value;
                                    searchResults.sort((a, b) =>
                                        a.createdOn.compareTo(b.createdOn));
                                    Navigator.pop(context);
                                  }),
                                ),
                              ),
                              ListTile(
                                title: const Text("Date: latest added first"),
                                leading: Radio(
                                  value: SingingCharacter.DateAddedLatest,
                                  groupValue: _sortBy,
                                  onChanged: (SingingCharacter value) =>
                                      setState(() {
                                    _sortBy = value;
                                    searchResults.sort((a, b) =>
                                        -1 *
                                        a.createdOn.compareTo(b.createdOn));
                                    Navigator.pop(context);
                                  }),
                                ),
                              ),
                            ],
                          )),
                  child: Row(
                    children: [
                      Icon(Icons.sort),
                      Text("Sort", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (searchResults != null && searchResults.isNotEmpty)
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              Filter(searchResults: searchResults)));
                    else
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Search Results are empty")));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt),
                      Text("Filter", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                )
              ],
            ),
            _buildSuggestions(),
          ],
        ));
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: BACKGROUND_COLOR,
        elevation: 5,
        title: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.withOpacity(0.25)),
          child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search)),
              onChanged: _performSearch),
        ),
      );
}
