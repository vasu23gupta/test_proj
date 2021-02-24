import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/Review.dart';
import 'package:test_proj/models/customUser.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendorDetails/vendor_details.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddReview extends StatefulWidget {
  //final VendorData vendorData;
  final Vendor vendor;
  AddReview({this.vendor});
  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  String alertText = "";
  Review review = Review();
  TextEditingController mycontroller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              if (review.stars != 0) {
                final response = await VendorDBService.addVendorReview(
                    review, widget.vendor, await user.getIdToken());
                if (response.statusCode == 200) {
                  mycontroller.clear();
                  setState(() {
                    alertText = "Successfully added";
                    widget.vendor.reviewed = true;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorDetails(
                        vendor: widget.vendor,
                      ),
                    ),
                  );
                } else {
                  setState(() {
                    alertText = "Could not add review";
                  });
                }
                //print(response.body.toString());
              } else {
                setState(() {
                  alertText = "Please make sure that rating is selected";
                });
              }
            },
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
          Text(
            alertText,
            style: TextStyle(color: Colors.red, fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
