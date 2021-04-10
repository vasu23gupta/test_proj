import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/Search/Search.dart';

class Filter extends StatefulWidget {
  final List<dynamic> searchResults;
  Filter({this.searchResults = const []});
  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  List<dynamic> finalList;
  Color ratingButton = Colors.white;
  Color tagsButton;
  String selectedFilter = "rating";
  List<String> tags = List.from({
    "food",
    "north indian",
    "chinese",
    "south indian",
    "services",
    "tea",
    "fast food",
  });
  List<bool> stags = [false, false, false, false, false, false, false, false];
  HashSet<String> selTags = HashSet.from({});
  int selectedVal = 0;
  bool val4 = false;
  bool val3 = false;
  bool val2 = false;
  bool val1 = false;
  bool val0 = true;
  bool food = false;
  bool none = true;
  bool tea = false;
  bool fastFood = false;
  bool services = false;
  Widget myWidget(String filter) {
    Widget mywidget = Container();
    if (filter == 'rating') {
      mywidget = Column(children: [
        CheckboxListTile(
          title: const Text('>= 4.0'),
          value: val4,
          onChanged: (bool value) {
            setState(() {
              selectedVal = 4;
              val4 = value;
              val3 = false;
              val2 = false;
              val1 = false;
              val0 = false;
              print(value);
            });
            print(val4);
          },
        ),
        CheckboxListTile(
          title: const Text('>= 3.0'),
          value: val3,
          onChanged: (bool value) {
            setState(() {
              selectedVal = 3;
              val3 = value;
              val4 = false;
              val2 = false;
              val1 = false;
              val0 = false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('>= 2.0'),
          value: val2,
          onChanged: (bool value) {
            setState(() {
              selectedVal = 2;
              val2 = value;
              val3 = false;
              val4 = false;
              val1 = false;
              val0 = false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('>= 1.0'),
          value: val1,
          onChanged: (bool value) {
            setState(() {
              selectedVal = 1;
              val1 = value;
              val3 = false;
              val2 = false;
              val4 = false;
              val0 = false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('>= 0'),
          value: val0,
          onChanged: (bool value) {
            setState(() {
              selectedVal = 0;
              val0 = value;
              val3 = false;
              val2 = false;
              val1 = false;
              val4 = false;
            });
          },
        ),
      ]);
    }
    if (filter == 'tags') {
      mywidget = Column(
        children: [
          ListTile(
            title: Text('tags'),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: tags.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(tags[index]),
                value: stags[index],
                onChanged: (bool value) {
                  setState(() {
                    stags[index] = value;
                    if (value) {
                      selTags.add(tags[index]);
                    } else {
                      if (selTags.contains(tags[index])) {
                        selTags.remove(tags[index]);
                      }
                    }
                  });
                },
              );
            },
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        mywidget,
        BottomAppBar(
          child: FlatButton(
            onPressed: () {
              List<Vendor> filtered = [];
              for (Vendor v in widget.searchResults) {
                if (selTags.isNotEmpty) {
                  for (String tag in selTags) {
                    if (v.tags.contains(tag) && v.stars >= selectedVal) {
                      filtered.add(v);
                    }
                  }
                } else {
                  if (v.stars >= selectedVal) {
                    filtered.add(v);
                  }
                }
              }
              setState(
                () {
                  finalList = filtered;
                  print(finalList);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Search(
                                searchRes: finalList,
                              )));
                },
              );
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
          actions: [],
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Filters",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        body: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    FlatButton(
                      minWidth: double.infinity,
                      onPressed: () {
                        setState(() {
                          ratingButton = Colors.white;
                          selectedFilter = "rating";
                          tagsButton = null;
                        });
                      },
                      child: Text("Rating"),
                      color: ratingButton,
                    ),
                    FlatButton(
                      minWidth: double.infinity,
                      onPressed: () {
                        setState(() {
                          tagsButton = Colors.white;
                          selectedFilter = 'tags';
                          ratingButton = null;
                        });
                      },
                      child: Text("Tags"),
                      color: tagsButton,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                child: myWidget(selectedFilter),
              ),
            ),
          ],
        ));
  }
}
