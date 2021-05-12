import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/Search/Search.dart';
import 'package:test_proj/screens/Search/filters.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:latlong/latlong.dart';

class Filter extends StatefulWidget {
  final List<dynamic> searchResults;
  final LatLng userLoc;
  Filter({this.searchResults = const [],this.userLoc});
  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  List<dynamic> _finalList;
  String _selectedFilter = "rating";
  var filters;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

  Widget myWidget(String filter) {
    Widget mywidget = Container();
    if (filter == 'rating') {
      mywidget = Column(children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, index) => RadioListTile(
              groupValue: filters.sRating,
              title: Text('>= $index.0'),
              value: index,
              onChanged: (val) => setState(() => filters.setSrating(index)),
            ),
          ),
        ),
      ]);
    }
    if (filter == 'tags') {
      mywidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filters.tags.length,
              itemBuilder: (context, index) => CheckboxListTile(
                title: Text(filters.tags[index]),
                value: filters.sTags[index],
                onChanged: (bool val) => setState(() {
                  filters.sTags[index] = val;
                  if (val)
                    filters.selectedTags.add(filters.tags[index]);
                  else if (filters.selectedTags.contains(filters.tags[index]))
                    filters.selectedTags.remove(filters.tags[index]);
                }),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: mywidget),
        ListTile(
          tileColor: Colors.orange[400],
          title: TextButton(
            onPressed: () {
              List<Vendor> filtered = [];
              for (Vendor v in widget.searchResults) {
                if (filters.selectedTags.isNotEmpty) {
                  for (String tag in filters.selectedTags)
                    if (v.tags.contains(tag) && v.stars >= filters.selectedRating)
                      filtered.add(v);
                } else if (v.stars >= filters.sRating) filtered.add(v);
              }
              setState(() {
                _finalList = filtered;
                filters.setFinalList(_finalList);
                Navigator.pop(context);
                // Navigator.pop(context);
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => Search(userLoc: widget.userLoc,)));
              });
            },
            child: Text("Apply"),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    
    filters=Provider.of<Filters>(context);
    
    return Scaffold(
        appBar: AppBar(
          backgroundColor: BACKGROUND_COLOR,
          title: Text("Filter",
              style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Container(
                      color: _selectedFilter == 'rating'
                          ? Colors.white
                          : Colors.grey,
                      height: 50,
                      width: 200,
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _selectedFilter = "rating"),
                        child: Text("Rating"),
                      ),
                    ),
                    Container(
                      color: _selectedFilter == 'tags'
                          ? Colors.white
                          : Colors.grey,
                      height: 50,
                      width: 200,
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _selectedFilter = 'tags'),
                        child: Text("Tags"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 6, child: Container(child: myWidget(_selectedFilter))),
          ],
        ));
  }
}
