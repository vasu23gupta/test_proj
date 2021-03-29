import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final Color color;

  StarRating({this.starCount = 5, this.rating = .0, this.color});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating && rating >= 4)
      icon = Icon(Icons.star_border, color: Colors.green);
    else if (index >= rating && rating > 2 && rating < 4)
      icon = Icon(Icons.star_border, color: Colors.amberAccent);
    else if (index >= rating && rating <= 2)
      icon = Icon(Icons.star_border, color: Colors.red);
    else if (index > rating - 1 && index < rating && rating >= 4)
      icon = Icon(Icons.star_half, color: Colors.green);
    else if (index > rating - 1 && index < rating && rating > 2 && rating < 4)
      icon = Icon(Icons.star_half, color: Colors.amberAccent);
    else if (index > rating - 1 && index < rating && rating <= 2)
      icon = Icon(Icons.star_half, color: Colors.red);
    else if (index < rating && rating >= 4)
      icon = Icon(Icons.star, color: Colors.green);
    else if (index < rating && rating > 2 && rating < 4)
      icon = Icon(Icons.star, color: Colors.amberAccent);
    else
      icon = Icon(Icons.star, color: Colors.red);

    return InkResponse(child: icon);
  }

  @override
  Widget build(BuildContext context) => Row(
      children: List.generate(starCount, (index) => buildStar(context, index)));
}
