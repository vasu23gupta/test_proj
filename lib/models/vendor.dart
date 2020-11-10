import 'dart:collection';

class Vendor {
  String id;
  String name;
  String coordinates;
  HashSet<String> tags;

  Vendor({this.id, this.coordinates, this.name, this.tags});
}
