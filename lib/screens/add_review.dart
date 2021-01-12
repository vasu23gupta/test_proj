import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_proj/models/Review.dart';
import 'package:test_proj/shared/constants.dart';

class AddReview extends StatefulWidget {
  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  Review review;
  TextEditingController mycontroller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [],
          title: Text("add a review"),
        ),
        body: Column(
          children: [
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
        ));
  }
}
