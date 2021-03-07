import 'package:flutter/material.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/add_vendor/location_address.dart';
import 'package:test_proj/shared/constants.dart';

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

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: textInputDecoration.copyWith(hintText: 'Vendor Name'),
          ),
          TextField(
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            controller: _descriptionController,
            decoration:
                textInputDecoration.copyWith(hintText: 'Vendor description'),
          ),
          Text(
            errorText,
            style: TextStyle(color: Colors.red),
          ),
          RaisedButton(
            color: Colors.pink[400],
            child: Text(
              'Next >',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (_nameController.text.isNotEmpty &&
                  _descriptionController.text.isNotEmpty) {
                errorText = '';
                vendor.name = _nameController.text;
                vendor.description = _descriptionController.text;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddVendorLocationAddress(
                      vendor: vendor,
                    ),
                  ),
                );
              } else {
                setState(() {
                  errorText = "Name and description cannot be empty";
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
