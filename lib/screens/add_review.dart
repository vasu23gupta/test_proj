import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/Review.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddReview extends StatefulWidget {
  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  Review review = Review();
  TextEditingController mycontroller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    review.byUser = user.uid;
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {},
          )
        ],
        title: Text("add a review"),
      ),
      body: Column(
        children: [
          //https://pub.dev/packages/flutter_rating_bar
          RatingBar.builder(
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() => review.stars = rating);
            },
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: mycontroller,
            decoration: textInputDecoration.copyWith(
              hintText: "review",
            ),
            onChanged: (val) {
              setState(() => review.review = val);
            },
          ),
        ],
      ),
    );
  }
}
