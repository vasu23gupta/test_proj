import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/shared/constants.dart';

class Filters extends ChangeNotifier
{
  List<dynamic> _finalList =[];
  //String _selectedFilter = "rating";
  List<String> _tags = [];
  List<bool> _stags;
  HashSet<String> _selTags = HashSet.from({});
  int _srating = 0;
  Widget ratings;
  Widget tag;
  Filters() {
    _tags.addAll(FILTERS.keys);
    for (List<String> item in FILTERS.values) _tags.addAll(item);
    _stags = List<bool>.filled(_tags.length, false);
    ratings = Column(children: [
      Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 5,
          itemBuilder: (context, index) => RadioListTile(
            groupValue: _srating,
            title: Text('>= $index.0'),
            value: index,
            onChanged: (val) { 
              print("rating changes");
              print(val);
              _srating = val;
              print(_srating);
              notifyListeners();
            }
          ),
        ),
      ),
    ]);
    tag=Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _tags.length,
            itemBuilder: (context, index) => CheckboxListTile(
              title: Text(_tags[index]),
              value: _stags[index],
              onChanged: (bool val)  {
                _stags[index] = val;
                
                if (val)
                  _selTags.add(_tags[index]);
                else if (_selTags.contains(_tags[index]))
                  _selTags.remove(_tags[index]);
                notifyListeners();  
              }),
            ),
        ),
      ],
    );
  }
  void setFinalList(List<dynamic> filtered){
    _finalList=filtered;
    print(_finalList);
    notifyListeners();
  }
  get finalList => _finalList;

  void setSrating(int val){
    _srating=val;
    notifyListeners();
  }

  get sRating => _srating;
  get rats => ratings;
  
  void setTags(int val){
    _stags = List<bool>.filled(_tags.length, false);
    notifyListeners();
  }
  get tags => _tags;
  get sTags => _stags;
  void setSelectedTags(int val)
  {
    _selTags = HashSet.from({});
    notifyListeners();
  }
  get selectedTags => _selTags;

  get selectedRating => _srating;
}