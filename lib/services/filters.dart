import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_proj/shared/constants.dart';

class Filters extends ChangeNotifier {
  List<dynamic> _finalList = [];
  List<String> _tags = [];
  List<bool> _stags;
  HashSet<String> _selTags = HashSet.from({});
  int _srating = 0;
  bool filtersApplied = false;
  Filters() {
    _tags.addAll(FILTERS.keys);
    for (List<String> item in FILTERS.values) _tags.addAll(item);
    _stags = List<bool>.filled(_tags.length, false);
  }
  void setFinalList(List<dynamic> filtered) {
    _finalList = filtered;
    if (_srating > 0 || _selTags.isNotEmpty)
      filtersApplied = true;
    else
      filtersApplied = false;
    notifyListeners();
  }

  get finalList => _finalList;

  void setSrating(int val) {
    _srating = val;
    notifyListeners();
  }

  get sRating => _srating;

  void setTags(int val) {
    _stags = List<bool>.filled(_tags.length, false);
    notifyListeners();
  }

  get tags => _tags;
  get sTags => _stags;
  void setSelectedTags(int val) {
    _selTags = HashSet.from({});
    notifyListeners();
  }

  get selectedTags => _selTags;

  get selectedRating => _srating;
}
