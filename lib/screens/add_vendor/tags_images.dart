import 'dart:convert';
import 'dart:math';
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
  TextEditingController _addTagController = TextEditingController();
  Vendor _vendor;
  String _errorText = '';
  bool _loading = false;
  final _filter = ProfanityFilter.filterAdditionally(hindiProfanity);
  User _user;
  List<String> _suggestions = [];
  List<String> _allTags = [];
  Widget _tagsSuggestionsOverlay;
  Container _emptyContainer = Container();

  TextStyle btnTextStyle(Size size) =>
      TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.045);

  String _capitaliseFirstLetter(String string) => string
      .toLowerCase()
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');

  void validateAndAddVendor() {
    if (_vendor.name == null || _vendor.name.isEmpty) {
      setState(() => _errorText = "Please add vendor's name.");
      return;
    }
    if (_vendor.description == null || _vendor.description.isEmpty) {
      setState(() => _errorText = "Please add vendor's description.");
      return;
    }
    if (_vendor.coordinates == null) {
      setState(() => _errorText = "Please add vendor's location.");
      return;
    }
    if (_vendor.address == null || _vendor.address.isEmpty) {
      setState(() => _errorText = "Please add vendor's address.");
      return;
    }
    if (_vendor.tags == null || _vendor.tags.isEmpty) {
      setState(() => _errorText = "Please add atleast one tag.");
      return;
    }
    if (_vendor.assetImages == null || _vendor.assetImages.isEmpty) {
      setState(() => _errorText = "Please add atleast one image.");
      return;
    }
    _addVendor();
  }

  void censorVendor() {
    for (var tag in _vendor.tags)
      if (_filter.hasProfanity(tag)) _vendor.tags.remove(tag);

    _vendor.name = _filter.censor(_vendor.name);
    _vendor.description = _filter.censor(_vendor.description);
    _vendor.address = _filter.censor(_vendor.address);
  }

  Future<void> _addVendor() async {
    Response result;
    try {
      setState(() => _loading = true);
      censorVendor();
      result = await VendorDBService.addVendor(
        _vendor.name,
        _vendor.coordinates,
        _vendor.tags,
        _vendor.assetImages,
        _vendor.description,
        await _user.getIdToken(),
        _vendor.address,
      );
    } catch (err) {
      setState(() {
        _loading = false;
        print(err);
        _errorText = 'Could not add vendor, please try again later.';
      });
      return;
    }
    if (result.statusCode != 200)
      setState(() {
        _loading = false;
        _errorText = 'Could not add vendor, please try again later.';
      });
    else {
      Map<String, dynamic> object = jsonDecode(result.body);
      if (object.containsKey("limitExceeded")) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(object['limitExceeded'])));
      } else {
        setState(() => _loading = false);
        Vendor vendor = Vendor.fromJson(jsonDecode(result.body));
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => VendorDetails(vendor: vendor)));
      }
    }
  }

  Widget _previewImages() {
    if (_vendor.assetImages.length > 0)
      return SizedBox(
        height: 150,
        child: ListView.builder(
          itemCount: _vendor.assetImages.length,
          itemBuilder: (context, index) {
            return Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AssetThumb(
                    asset: _vendor.assetImages[index],
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
                    onTap: () =>
                        setState(() => _vendor.assetImages.removeAt(index)),
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
      return _emptyContainer;
  }

  Future<void> _loadAssets() async {
    List<Asset> resultList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: _vendor.assetImages,
        materialOptions: MaterialOptions(
          actionBarColor: "#ff73DCE2",
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() => _vendor.assetImages = resultList);
  }

  Iterable<Widget> get _tagWidgets sync* {
    for (final String tag in _vendor.tags)
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: InputChip(
          label: Text(tag),
          onDeleted: () => setState(
              () => _vendor.tags.removeWhere((String entry) => entry == tag)),
        ),
      );
  }

  Future<Container> _tagsSuggestions(String query) async {
    _suggestions.clear();
    if (query.isNotEmpty) {
      query = query.toLowerCase();
      for (int i = 0; i < _allTags.length && _suggestions.length < 3; i++) {
        var item = _allTags[i];
        if (item.toLowerCase().contains(query)) _suggestions.add(item);
      }
    }

    return Container(
      color: Theme.of(context).cardColor,
      // height: 200,
      // width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _suggestions
            .map((e) => ListTile(
                  title: Center(child: Text(e)),
                  onTap: () {
                    if (!_vendor.tags.contains(e) && _vendor.tags.length < 20)
                      _vendor.tags.add(e);
                    setState(() {
                      _addTagController.clear();
                      _suggestions.clear();
                      _tagsSuggestionsOverlay = _emptyContainer;
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
    _vendor = widget.vendor;
    _vendor.assetImages = [];
    _vendor.tags = [];
    _allTags.addAll(FILTERS.keys);
    _tagsSuggestionsOverlay = _emptyContainer;
    for (List<String> list in FILTERS.values) _allTags.addAll(list);
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    _user = Provider.of<User>(context);
    return _loading
        ? Loading()
        : Scaffold(
            body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Tags & Images",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2661FA),
                        fontSize: 36),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _previewImages(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _loadAssets,
                      style: BS(_size.width * 0.4, _size.height * 0.065),
                      child: Text('Upload Images', style: btnTextStyle(_size)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      maxLength: 40,
                      controller: _addTagController,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Enter tags'),
                      onChanged: (val) async {
                        if (_vendor.tags.length < 20)
                          _tagsSuggestionsOverlay = await _tagsSuggestions(val);
                        else
                          _tagsSuggestionsOverlay = Text(
                            "Cannot add more than 20 tags",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: _size.width * 0.042),
                          );
                        setState(() {});
                      },
                    ),
                  ),
                  _tagsSuggestionsOverlay,
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        String tag = _addTagController.text;
                        if (tag.isNotEmpty &&
                            !_vendor.tags.contains(tag) &&
                            _vendor.tags.length < 20) {
                          tag = _capitaliseFirstLetter(_addTagController.text);
                          _vendor.tags.add(tag);
                        }
                        setState(() => _addTagController.clear());
                      },
                      style: BS(_size.width * 0.4, _size.height * 0.065),
                      child: Text('Add Tag', style: btnTextStyle(_size)),
                    ),
                  ),
                  Wrap(children: _tagWidgets.toList()),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: validateAndAddVendor,
                      style: BS(_size.width * 0.4, _size.height * 0.065),
                      child: Text('Submit', style: btnTextStyle(_size)),
                    ),
                  ),
                  Text(_errorText, style: ERROR_TEXT_STYLE(_size.width))
                ],
              ),
            ),
          ));
  }
}
