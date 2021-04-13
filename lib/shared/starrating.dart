import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  StarRating({this.rating = .0, this.size});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating && rating >= 4)
      icon = Icon(Icons.star_border, color: Colors.green, size: size);
    else if (index >= rating && rating > 2 && rating < 4)
      icon = Icon(Icons.star_border, color: Colors.amberAccent, size: size);
    else if (index >= rating && rating <= 2)
      icon = Icon(Icons.star_border, color: Colors.red, size: size);
    else if (index > rating - 1 && index < rating && rating >= 4)
      icon = Icon(Icons.star_half, color: Colors.green, size: size);
    else if (index > rating - 1 && index < rating && rating > 2 && rating < 4)
      icon = Icon(Icons.star_half, color: Colors.amberAccent, size: size);
    else if (index > rating - 1 && index < rating && rating <= 2)
      icon = Icon(Icons.star_half, color: Colors.red, size: size);
    else if (index < rating && rating >= 4)
      icon = Icon(Icons.star, color: Colors.green, size: size);
    else if (index < rating && rating > 2 && rating < 4)
      icon = Icon(Icons.star, color: Colors.amberAccent, size: size);
    else
      icon = Icon(Icons.star, color: Colors.red);

    return InkResponse(child: icon);
  }

  @override
  Widget build(BuildContext context) =>
      Row(children: List.generate(5, (index) => buildStar(context, index)));
}
