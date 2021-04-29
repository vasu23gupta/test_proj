import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/Search/Search.dart';
import 'package:test_proj/shared/constants.dart';

class Filter extends StatefulWidget {
  final List<dynamic> searchResults;
  Filter({this.searchResults = const []});
  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  List<dynamic> finalList;
  //Color ratingButton = Colors.white;
  //Color tagsButton;
  String selectedFilter = "rating";
  List<String> tags = [];
  List<bool> stags ;
  HashSet<String> selTags = HashSet.from({});
  int selectedVal = 0;
  List<bool> sratings=[false,false,false,false,false];

  @override
  void initState() {
    super.initState();
    tags.addAll(FILTERS.keys);
    for (List<String> item in FILTERS.values) tags.addAll(item);
    stags=List<bool>.filled(tags.length, false); 
  }

  Widget myWidget(String filter) {
    Widget mywidget = Container();
    if (filter == 'rating') {
      mywidget = Column(
        children: [
          ListTile(title: Text('Ratings')),
          Expanded(child:ListView.builder(
            shrinkWrap: true,
            itemCount: sratings.length,
            itemBuilder: (context,index) {
              return CheckboxListTile(
                title: Text('>= ${sratings.length-index-1}.0'),
                value: sratings[sratings.length-index-1],
                onChanged: (bool value) {
                  setState(() {
                    sratings[sratings.length-index-1]=value;
                    selectedVal = sratings.length-index-1;
                    for(int i=0;i<sratings.length;i++)
                    {
                      if(sratings.length-index-1!=i)
                      sratings[i]=false;
                    }
                  });
                },
              );
            },
          ),
        ),
      ]);
    }
    if (filter == 'tags') {
      mywidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text('tags')),
          Expanded(
            child:ListView.builder(
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
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child:mywidget),
        ListTile(
          tileColor: Colors.orange[400],
          title: FlatButton(
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Search(searchRes: finalList)));
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
                    TextButton(
                      onPressed: () =>
                          setState(() => selectedFilter = "rating"),
                      child: Text("Rating"),
                    ),
                    TextButton(
                      onPressed: () => setState(() => selectedFilter = 'tags'),
                      child: Text("Tags"),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 6, child: Container(child: myWidget(selectedFilter))),
          ],
        ));
  }
}
