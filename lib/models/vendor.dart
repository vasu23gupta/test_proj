import 'package:latlong/latlong.dart';
import 'package:flutter/material.dart';
import 'package:test_proj/services/database.dart';
import 'Review.dart';

class Vendor {
  String id;
  String name;
  LatLng coordinates;
  List<String> tags;
  List<NetworkImage> images;
  List<String> imageIds;
  String description;
  List<String> reviewIds = [];
  List<Review> reviews;
  double stars;
  String address;

  Vendor({
    this.id,
    this.coordinates,
    this.name,
    this.tags,
    this.description,
    this.imageIds,
    this.reviewIds,
    this.stars,
    this.address,
  }) {
    this.images = new List(imageIds.length);
  }

  Vendor.fromJsonCoords(Map<String, dynamic> json) {
    this.id = json['_id'];
    this.coordinates = new LatLng(json['location']['coordinates'][1].toDouble(),
        json['location']['coordinates'][0].toDouble());
  }

  Vendor.fromJsonSearch(Map<String, dynamic> json) {
    List<String> temp = new List<String>();
    for (var item in json['tags']) {
      temp.add(item.toString());
    }
    this.id = json['_id'];
    this.name = json['name'];
    this.tags = temp;
  }

  factory Vendor.fromJson(Map<String, dynamic> json) {
    List<String> temp = new List<String>();
    List<String> temp2 = new List<String>();
    List<String> temp3 = new List<String>();
    for (var item in json['tags']) {
      temp.add(item.toString());
    }
    for (var item in json['images']) {
      temp2.add(item.toString());
    }
    for (var item in json['reviews']) {
      temp3.add(item);
    }
    return Vendor(
      id: json['_id'],
      name: json['name'],
      coordinates: new LatLng(json['location']['coordinates'][1].toDouble(),
          json['location']['coordinates'][0].toDouble()),
      description: json['description'],
      tags: temp,
      imageIds: temp2,
      reviewIds: temp3,
      stars: json['rating'].toDouble(),
      address: json['address'],
    );
  }

  NetworkImage getImage(int index) {
    if (images[index] == null) {
      images[index] = VendorDBService.getVendorImage(imageIds[index]);
    }
    return images[index];
  }

  // bool operator ==(other) {
  //   return (other is Vendor &&
  //           other.id == id &&
  //           other.name == name &&
  //           other.coordinates == coordinates &&
  //           listEquals(other.tags, tags)
  //       //other.dataId == dataId,
  //       );
  // }

  // bool contains(String string) {
  //   if (tags.contains(string) || name.startsWith(string)) return true;
  //   return false;
  // }

  // @override
  // int get hashCode => hashValues(
  //     name.hashCode, id.hashCode, coordinates.hashCode, tags.hashCode);
}
