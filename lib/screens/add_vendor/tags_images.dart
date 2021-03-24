import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendorDetails/vendor_details.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/hindi_profanity.dart';
import 'package:test_proj/shared/loading.dart';

class AddVendorTagsImages extends StatefulWidget {
  final Vendor vendor;
  AddVendorTagsImages({this.vendor});
  @override
  _AddVendorTagsImagesState createState() => _AddVendorTagsImagesState();
}

class _AddVendorTagsImagesState extends State<AddVendorTagsImages> {
  TextEditingController addTagController = TextEditingController();
  Vendor vendor;
  String errorText = '';
  List<String> tags = [];
  List<Asset> images = [];
  bool loading = false;
  final filter = ProfanityFilter.filterAdditionally(hindiProfanity);
  User user;
  List<String> suggestions = [];
  List<String> allTags = [];
  Widget tagsSuggestionsOverlay;
  Container emptyContainer = Container();

  String capitaliseFirstLetter(String string) {
    return string
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> addVendor() async {
    setState(() => loading = true);
    for (var tag in tags) {
      if (filter.hasProfanity(tag)) tags.remove(tag);
    }
    vendor.name = filter.censor(vendor.name);
    vendor.description = filter.censor(vendor.description);
    vendor.address = filter.censor(vendor.address);
    Response result;

    result = await VendorDBService.addVendor(
      vendor.name,
      vendor.coordinates,
      vendor.tags,
      vendor.assetImages,
      vendor.description,
      await user.getIdToken(),
      vendor.address,
    );

    setState(() => loading = false);

    if (result.statusCode != 200)
      setState(() {
        print(result.statusCode);
        errorText = 'Could not add vendor, please try again later.';
      });
    else {
      Vendor vendor = Vendor.fromJson(jsonDecode(result.body));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VendorDetails(vendor: vendor)),
      );
    }
  }

  Widget previewImages() {
    if (images.length > 0)
      return SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AssetThumb(
                    asset: images[index],
                    width: 150,
                    height: 150,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  height: 25,
                  width: 25,
                  child: InkResponse(
                    onTap: () {
                      setState(() {
                        images.removeAt(index);
                      });
                    },
                    child: CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
          scrollDirection: Axis.horizontal,
        ),
      );
    else
      return emptyContainer;
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = [];
    //String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          //actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      errorText = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() => images = resultList);
  }

  Iterable<Widget> get tagWidgets sync* {
    for (final String tag in tags) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: InputChip(
          label: Text(tag),
          onDeleted: () {
            setState(() {
              tags.removeWhere((String entry) {
                return entry == tag;
              });
            });
          },
        ),
      );
    }
  }

  Future<Container> tagsSuggestions(String query) async {
    suggestions.clear();
    if (query.isNotEmpty) {
      query = query.toLowerCase();
      for (var item in allTags) {
        if (item.toLowerCase().contains(query)) suggestions.add(item);
      }
    }

    return Container(
      color: Theme.of(context).cardColor,
      // height: 200,
      // width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: suggestions
            .map((e) => ListTile(
                  title: Center(child: Text(e)),
                  onTap: () {
                    if (!tags.contains(e)) tags.add(e);
                    setState(() {
                      addTagController.clear();
                      suggestions.clear();
                      tagsSuggestionsOverlay = emptyContainer;
                    });
                  },
                ))
            .toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor;
    allTags.addAll(FILTERS.keys);
    tagsSuggestionsOverlay = emptyContainer;
    for (List<String> list in FILTERS.values) {
      allTags.addAll(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context);
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Upload Images',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: loadAssets,
                  ),
                  previewImages(),
                  //add tags
                  TextField(
                    controller: addTagController,
                    decoration:
                        textInputDecoration.copyWith(hintText: 'Enter tags'),
                    onChanged: (val) async {
                      tagsSuggestionsOverlay = await tagsSuggestions(val);
                      setState(() {});
                    },
                  ),
                  tagsSuggestionsOverlay,
                  //add tag button:
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Add tag',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      String tag = capitaliseFirstLetter(addTagController.text);
                      if (tag.isNotEmpty && !tags.contains(tag)) tags.add(tag);

                      setState(() => addTagController.clear());
                    },
                  ),
                  //show tags
                  Wrap(
                    children: tagWidgets.toList(),
                  ),
                  //error text
                  Text(
                    errorText,
                    style: TextStyle(color: Colors.red),
                  ),
                  //submit button
                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (images.length > 0 && tags.length > 0) {
                        errorText = '';
                        vendor.tags = tags;
                        vendor.assetImages = images;
                        await addVendor();
                      } else
                        setState(() => errorText =
                            "Please select atleast one tag and image");
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
