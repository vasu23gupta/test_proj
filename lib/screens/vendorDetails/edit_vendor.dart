import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/vendorDetails/vendor_details.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:test_proj/services/utils.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/hindi_profanity.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';

class EditVendor extends StatefulWidget {
  final Vendor vendor;
  EditVendor({this.vendor});
  @override
  _EditVendorState createState() => _EditVendorState();
}

class _EditVendorState extends State<EditVendor> {
  MapController _mapController = MapController();
  bool _loading = true;
  Marker _marker = Marker();
  String _error = '';
  LatLng _userLoc;
  List<String> _imageIdsToBeRemoved = [];
  Vendor _vendor;
  List<String> _suggestions = [];
  List<String> _allTags = [];
  Widget _tagsSuggestionsOverlay;
  Container _emptyContainer = Container();
  final _filter = ProfanityFilter.filterAdditionally(hindiProfanity);
  LocationService _locSer = LocationService();
  String _loadingText = "";
  LatLngBounds _mapBounds;
  User _user;
  Size _size;
  TextEditingController _addTagController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  //vendor
  String _name;
  String _description;
  List<String> _tags;
  List<String> _imageIds;
  List<Asset> _assetImages;
  List<NetworkImage> _networkImages;
  LatLng _vendorLatLng;

  Future<void> _loadAssets() async {
    List<Asset> _resultList = [];
    try {
      _resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: _assetImages,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#ff73DCE2",
          actionBarTitle: "Select Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      _error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() => _assetImages = _resultList);
  }

  @override
  void initState() {
    super.initState();
    _allTags.addAll(FILTERS.keys);
    _tagsSuggestionsOverlay = _emptyContainer;
    for (List<String> list in FILTERS.values) _allTags.addAll(list);
    _user = Provider.of<User>(context, listen: false);
    _vendor = widget.vendor;
    //
    _name = _vendor.name.toString();
    _description = _vendor.description.toString();
    _addressController.text = _vendor.address.toString();
    _tags = List.from(_vendor.tags);
    _imageIds = List.from(_vendor.imageIds);
    _assetImages = List.from(_vendor.assetImages);
    _networkImages = List.from(_vendor.networkImages);
    _vendorLatLng =
        LatLng(_vendor.coordinates.latitude, _vendor.coordinates.longitude);
    //
    _putMarkerOnMap(_vendorLatLng);
    List<Future> _futures = [];
    _futures.add(_getLocation());
    _futures.add(_getUser());
    Future.wait(_futures).then((value) =>
        (value[0] && value[1]) ? setState(() => _loading = false) : null);
  }

  void _censorVendor() {
    for (var tag in _tags) if (_filter.hasProfanity(tag)) _tags.remove(tag);

    _name = _filter.censor(_name);
    _description = _filter.censor(_description);
    _addressController.text = _filter.censor(_addressController.text);
  }

  void _validateAndEditVendor() {
    if (_name == null || _name.isEmpty) {
      setState(() => _error = "Please add vendor's name.");
      return;
    }
    if (_description == null || _description.isEmpty) {
      setState(() => _error = "Please add vendor's description.");
      return;
    }
    if (_vendorLatLng == null) {
      setState(() => _error = "Please add vendor's location.");
      return;
    }
    if (_addressController.text == null || _addressController.text.isEmpty) {
      setState(() => _error = "Please add vendor's address.");
      return;
    }
    if (_tags == null || _tags.isEmpty) {
      setState(() => _error = "Please add atleast one tag.");
      return;
    }
    if (_assetImages.length + _imageIds.length < 1) {
      setState(() => _error = "Please add atleast one image.");
      return;
    }
    _editVendor();
  }

  Future<void> _editVendor() async {
    Response result;

    try {
      setState(() => _loading = true);
      _censorVendor();
      result = await VendorDBService.updateVendor(
        await _user.getIdToken(),
        widget.vendor.id,
        _name,
        _vendorLatLng,
        _tags,
        _imageIds,
        _imageIdsToBeRemoved,
        _assetImages,
        _description,
        _addressController.text,
      );
    } catch (err) {
      setState(() {
        _loading = false;
        print(err);
        _error = 'Could not edit vendor, please try again later. Error: $err';
      });
      return;
    }

    setState(() => _loading = false);

    if (result.statusCode != 200)
      setState(() {
        print(result.statusCode);
        _error =
            'Could not edit vendor, please try again later. Error: ${result.body}';
      });
    else {
      Map<String, dynamic> object = jsonDecode(result.body);
      if (object.containsKey("limitExceeded"))
        setState(() => _error = object['limitExceeded']);
      else {
        Vendor vendor = Vendor.fromJson(jsonDecode(result.body));
        int _count = 0;
        Navigator.popUntil(context, (route) => _count++ == 2);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => VendorDetails(vendor: vendor)));
      }
    }
  }

  Future<bool> _getLocation() async {
    var ld = await _locSer.getLocation();
    _userLoc = LatLng(ld.latitude, ld.longitude);
    if (_userLoc == null) {
      setState(() =>
          _loadingText += "You need to enable your location to add a vendor.");
      return false;
    } else {
      _mapBounds = HardcoreMath.toBounds(_userLoc);
      if (_vendorLatLng.longitude < _mapBounds.east &&
          _vendorLatLng.longitude > _mapBounds.west &&
          _vendorLatLng.latitude < _mapBounds.north &&
          _vendorLatLng.latitude > _mapBounds.south)
        return true;
      else {
        setState(() =>
            _loadingText += "You must be close to the vendor to edit it.");
        return false;
      }
    }
  }

  Future<bool> _getUser() async {
    Response response =
        await UserDBService(jwt: await _user.getIdToken()).getUserByJWT();
    var json = jsonDecode(response.body);
    if (json['addsRemaining'] > 0) {
      return true;
    } else {
      setState(
          () => _loadingText += "You cannot edit more vendors this month. ");
      return false;
    }
  }

  Future<void> _putMarkerOnMap(LatLng point) async {
    setState(
      () {
        _vendorLatLng = point;
        _marker = Marker(
          width: 45.0,
          height: 45.0,
          point: point,
          builder: (context) => Icon(Icons.location_on, size: 40),
        );
      },
    );
    String address =
        await VendorDBService.getAddress(point.latitude, point.longitude);
    setState(() => _addressController.text = address);
  }

  Widget _previewImages() => (_networkImages.length == 0 &&
          _assetImages.length == 0)
      ? Container()
      : SizedBox(
          height: 150,
          child: ListView.builder(
            itemCount: _networkImages.length + _assetImages.length,
            itemBuilder: (context, index) => Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: index < _networkImages.length
                      ? Image(
                          image: widget.vendor.getImageFomId(_imageIds[index]))
                      : AssetThumb(
                          asset: _assetImages[index - _networkImages.length],
                          width: 150,
                          height: 150,
                        ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  height: 30,
                  width: 30,
                  child: InkResponse(
                    onTap: () => setState(() {
                      if (index < _imageIds.length) {
                        _imageIdsToBeRemoved.add(_imageIds[index]);
                        _imageIds.removeAt(index);
                        _networkImages.removeAt(index);
                      } else if (index < _assetImages.length + _imageIds.length)
                        _assetImages.removeAt(_imageIds.length - index);
                    }),
                    child: CircleAvatar(
                        child: Icon(Icons.close), backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
            scrollDirection: Axis.horizontal,
          ),
        );

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _suggestions
            .map((e) => ListTile(
                  title: Center(child: Text(e)),
                  onTap: () {
                    if (!_tags.contains(e) && _tags.length < 20) _tags.add(e);
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

//https://api.flutter.dev/flutter/material/Chip/onDeleted.html
//https://www.youtube.com/watch?time_continue=413&v=TF-TBsgIErY&feature=emb_logo
  Iterable<Widget> get _tagWidgets sync* {
    for (final String tag in _tags) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: InputChip(
          label: Text(tag),
          onDeleted: () =>
              setState(() => _tags.removeWhere((String entry) => entry == tag)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return _loading
        ? Loading(data: _loadingText)
        : Scaffold(
            appBar: AppBar(
                title: Text('Add Vendor'), backgroundColor: BACKGROUND_COLOR),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  //name:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                        maxLength: 50,
                        initialValue: _name,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Vendor Name'),
                        onChanged: (val) => setState(() => _name = val)),
                  ),
                  //map:
                  SizedBox(
                    height: _size.height * 0.37,
                    width: _size.width * 0.90,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        nePanBoundary: _mapBounds.northEast,
                        swPanBoundary: _mapBounds.southWest,
                        zoom: 18.45,
                        center: _vendorLatLng,
                        maxZoom: 18.45,
                        minZoom: 18.45,
                        onTap: _putMarkerOnMap,
                      ),
                      layers: [
                        TileLayerOptions(
                            urlTemplate:
                                "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                            additionalOptions: {'subscriptionKey': mapApiKey}),
                        MarkerLayerOptions(markers: [_marker]),
                      ],
                    ),
                  ),
                  //address
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _addressController,
                      maxLength: 500,
                      decoration:
                          textInputDecoration.copyWith(hintText: 'Address'),
                    ),
                  ),
                  //add images
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      style: BS(_size.width * 0.4, _size.height * 0.065),
                      child: Text('Upload Images'),
                      onPressed: _loadAssets,
                    ),
                  ),
                  _previewImages(),
                  //description
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                        maxLength: 1000,
                        initialValue: _description,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Vendor description'),
                        onChanged: (val) => setState(() => _description = val)),
                  ),
                  //tags:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                        maxLength: 40,
                        controller: _addTagController,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Enter tags'),
                        onChanged: (val) async {
                          if (_tags.length < 20)
                            _tagsSuggestionsOverlay =
                                await _tagsSuggestions(val);
                          else
                            _tagsSuggestionsOverlay = Text(
                              "Cannot add more than 20 tags",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: _size.width * 0.042),
                            );
                          setState(() {});
                        }),
                  ),
                  _tagsSuggestionsOverlay,
                  //add tag button:
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: BS(_size.width * 0.4, _size.height * 0.065),
                      child: Text('Add tag'),
                      onPressed: () {
                        String tag = _addTagController.text;
                        if (tag.isNotEmpty &&
                            !_tags.contains(tag) &&
                            _tags.length < 20) {
                          tag = capitaliseFirstLetter(_addTagController.text);
                          _tags.add(tag);
                        }
                        setState(() => _addTagController.clear());
                      },
                    ),
                  ),
                  //show tags
                  Wrap(children: _tagWidgets.toList()),
                  //submit button:
                  ElevatedButton(
                    style: BS(_size.width * 0.4, _size.height * 0.065),
                    child: Text('Submit'),
                    onPressed: _validateAndEditVendor,
                  ),
                  //error text:
                  Text(_error, style: ERROR_TEXT_STYLE(_size.width))
                ],
              ),
            ),
          );
  }
}
