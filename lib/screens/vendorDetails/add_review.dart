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
import 'package:test_proj/shared/loading.dart';

class AddReview extends StatefulWidget {
  final Vendor vendor;
  AddReview({this.vendor});
  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  String _errorText = "";
  Review _review = Review();
  final _filter = ProfanityFilter.filterAdditionally(hindiProfanity);
  TextEditingController _reviewController = TextEditingController();
  User _user;
  double _h;
  double _w;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
  }

  Future<void> addReview() async {
    if (_review.stars != 0 && _review.stars != null) {
      if (_reviewController.text.isNotEmpty)
        _review.review = _filter.censor(_reviewController.text);
      setState(() => _loading = true);
      final response = await VendorDBService.addVendorReview(
          _review, widget.vendor, await _user.getIdToken());
      if (response.statusCode == 200) {
        widget.vendor.reviewed = true;
        int count = 0;
        Navigator.popUntil(context, (route) => count++ == 2);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VendorDetails(vendor: widget.vendor)));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Review added successfully!')));
      } else
        setState(() {
          _errorText = "Could not add review";
          _loading = false;
        });
    } else
      setState(() => _errorText = "Please make sure that rating is selected");
  }

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
    _w = MediaQuery.of(context).size.width;
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: BACKGROUND_COLOR,
              actions: <Widget>[
                IconButton(icon: Icon(Icons.check), onPressed: addReview)
              ],
              title: Text("Add review"),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //https://pub.dev/packages/flutter_rating_bar
                RatingBar.builder(
                  minRating: 0.5,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) =>
                      setState(() => _review.stars = rating),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    maxLength: 500,
                    controller: _reviewController,
                    decoration:
                        textInputDecoration.copyWith(hintText: "Review"),
                  ),
                ),
                Text(_errorText, style: ERROR_TEXT_STYLE(_w)),
              ],
            ),
          );
  }
}
