import 'package:flutter/material.dart';

class Review {
  String id;
  String byUser;
  String review = '';
  double stars = 0;
  Review({this.byUser, this.review, this.stars, this.id});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      byUser: json['by'],
      review: json['review'],
      stars: json['stars'].toDouble(),
    );
  }

  Container get widget {
    return Container();
  }
}
