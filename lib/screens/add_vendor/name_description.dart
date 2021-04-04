import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/add_vendor/location_address.dart';
import 'package:test_proj/services/location_service.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loading.dart';
import 'package:latlong/latlong.dart';

class AddVendorNameDescription extends StatefulWidget {
  final Vendor vendor;
  AddVendorNameDescription({this.vendor});
  @override
  _AddVendorNameDescriptionState createState() =>
      _AddVendorNameDescriptionState();
}

class _AddVendorNameDescriptionState extends State<AddVendorNameDescription> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  Vendor vendor;
  String errorText = '';
  bool loading = true;
  LocationData userLoc;
  LocationService locSer = LocationService();
  String loadingText;

  Future getLocation() async {
    userLoc = await locSer.getLocation();
    if (userLoc == null)
      setState(() =>
          loadingText = "You need to enable your location to add a vendor.");
    else
      setState(() {
        vendor.coordinates = LatLng(userLoc.latitude, userLoc.longitude);
        loading = false;
      });
  }

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor;
    if (vendor.coordinates == null)
      getLocation();
    else
      loading = false;
  }

  @override
  Widget build(BuildContext context) {
     Size size = MediaQuery.of(context).size;
    return loading
        ? Loading(data: loadingText)
        : Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Name & Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2661FA),
                  fontSize: 36
                ),
                textAlign: TextAlign.left,
              ),
            ),
               SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child:   TextField(
            controller: _nameController,
            decoration: textInputDecoration.copyWith(hintText: 'Vendor Name'),
          ),
                      ),
                    ),
                     SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child:    TextField(
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    controller: _descriptionController,
                    decoration: textInputDecoration.copyWith(
                        hintText: 'Vendor description')),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    SizedBox(
                      child:  Text(errorText, style: TextStyle(color: Colors.red)),
                    ),
                      Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: RaisedButton(
                onPressed: () {
              if (_nameController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty) {
                      errorText = '';
                      vendor.name = _nameController.text;
                      vendor.description = _descriptionController.text;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              AddVendorLocationAddress(vendor: vendor)));
                    } else
                      setState(() =>
                          errorText = "Name and description cannot be empty");
            },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                textColor: Colors.white,
                padding: const EdgeInsets.all(0),
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  width: size.width * 0.5,
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(80.0),
                    gradient: new LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 136, 34),
                        Color.fromARGB(255, 255, 177, 41)
                      ]
                    )
                  ),
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    "Next",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
               /* TextField(
                    controller: _nameController,
                    decoration:
                        textInputDecoration.copyWith(hintText: 'Vendor Name')),
                TextField(
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    controller: _descriptionController,
                    decoration: textInputDecoration.copyWith(
                        hintText: 'Vendor description')),
                Text(errorText, style: TextStyle(color: Colors.red)),
                RaisedButton(
                  color: Colors.pink[400],
                  child: Text('Next >', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty) {
                      errorText = '';
                      vendor.name = _nameController.text;
                      vendor.description = _descriptionController.text;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              AddVendorLocationAddress(vendor: vendor)));
                    } else
                      setState(() =>
                          errorText = "Name and description cannot be empty");
                  },
                ),*/
              ],
            ),
          );
  }
}
