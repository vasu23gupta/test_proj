import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final Color color;

  StarRating({this.starCount = 5, this.rating = .0, this.color});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating && rating >= 4) {
      icon = new Icon(Icons.star_border,
          color: Colors.green /* Theme.of(context).buttonColor,*/
          );
    } else if (index >= rating && rating > 2 && rating < 4) {
      icon = new Icon(Icons.star_border,
          color: Colors.amberAccent /*Theme.of(context).buttonColor,*/
          );
    } else if (index >= rating && rating <= 2) {
      icon = new Icon(
        Icons.star_border,
        color: Colors.red, /*Theme.of(context).buttonColor,*/
      );
    } else if (index > rating - 1 && index < rating && rating >= 4) {
      icon = new Icon(Icons.star_half,
          color: Colors.green /*color ?? Theme.of(context).primaryColor,*/
          );
    } else if (index > rating - 1 &&
        index < rating &&
        rating > 2 &&
        rating < 4) {
      icon = new Icon(Icons.star_half,
          color: Colors.amberAccent /*color ?? Theme.of(context).primaryColor,*/
          );
    } else if (index > rating - 1 && index < rating && rating <= 2) {
      icon = new Icon(Icons.star_half,
          color: Colors.red /*color ?? Theme.of(context).primaryColor,*/
          );
    } else if (index < rating && rating >= 4) {
      icon = new Icon(
        Icons.star,
        color: Colors.green, /*color ?? Theme.of(context).primaryColor,*/
      );
    } else if (index < rating && rating > 2 && rating < 4) {
      icon = new Icon(
        Icons.star,
        color: Colors.amberAccent, /*color ?? Theme.of(context).primaryColor,*/
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: Colors.red, /*color ?? Theme.of(context).primaryColor,*/
      );
    }
    return new InkResponse(
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        children:
            new List.generate(starCount, (index) => buildStar(context, index)));
  }
}
