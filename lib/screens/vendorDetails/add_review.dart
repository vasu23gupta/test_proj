import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/Review.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendorDetails/vendor_details.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:test_proj/shared/hindi_profanity.dart';

class AddReview extends StatefulWidget {
  final Vendor vendor;
  AddReview({this.vendor});
  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  String alertText = "";
  Review review = Review();
  final filter = ProfanityFilter.filterAdditionally(hindiProfanity);
  TextEditingController _reviewController = TextEditingController();
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
                if (_reviewController.text.isNotEmpty)
                  review.review = filter.censor(_reviewController.text);
                final response = await VendorDBService.addVendorReview(
                    review, widget.vendor, await user.getIdToken());
                if (response.statusCode == 200) {
                  setState(() => widget.vendor.reviewed = true);
                  int count = 0;
                  Navigator.popUntil(context, (route) => count++ == 2);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              VendorDetails(vendor: widget.vendor)));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Review added successfully!'),
                    duration: Duration(seconds: 3),
                  ));
                } else
                  setState(() => alertText = "Could not add review");
              } else
                setState(() =>
                    alertText = "Please make sure that rating is selected");
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
            onRatingUpdate: (rating) => setState(() => review.stars = rating),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _reviewController,
            decoration: textInputDecoration.copyWith(hintText: "review"),
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
