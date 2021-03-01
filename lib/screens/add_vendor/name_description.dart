import 'package:flutter/material.dart';
import 'package:test_proj/shared/constants.dart';

class AddVendorNameDescription extends StatefulWidget {
  @override
  _AddVendorNameDescriptionState createState() =>
      _AddVendorNameDescriptionState();
}

class _AddVendorNameDescriptionState extends State<AddVendorNameDescription> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

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
          RaisedButton(
            color: Colors.pink[400],
            child: Text(
              'Next >',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
