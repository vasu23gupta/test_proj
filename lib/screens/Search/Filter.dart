import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/Search/Search.dart';
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
  List<String> _tags = [];
  List<bool> _stags;
  HashSet<String> _selTags = HashSet.from({});
  int _srating = 0;

  @override
  void initState() {
    super.initState();
    _tags.addAll(FILTERS.keys);
    for (List<String> item in FILTERS.values) _tags.addAll(item);
    _stags = List<bool>.filled(_tags.length, false);
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
              groupValue: _srating,
              title: Text('>= $index.0'),
              value: index,
              onChanged: (val) => setState(() => _srating = index),
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
              itemCount: _tags.length,
              itemBuilder: (context, index) => CheckboxListTile(
                title: Text(_tags[index]),
                value: _stags[index],
                onChanged: (bool val) => setState(() {
                  _stags[index] = val;
                  if (val)
                    _selTags.add(_tags[index]);
                  else if (_selTags.contains(_tags[index]))
                    _selTags.remove(_tags[index]);
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
                if (_selTags.isNotEmpty) {
                  for (String tag in _selTags)
                    if (v.tags.contains(tag) && v.stars >= _srating)
                      filtered.add(v);
                } else if (v.stars >= _srating) filtered.add(v);
              }
              setState(() {
                _finalList = filtered;
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Search(searchRes: _finalList,userLoc: widget.userLoc,)));
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
