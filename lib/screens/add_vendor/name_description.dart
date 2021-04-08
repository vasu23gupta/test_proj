import 'package:flutter/material.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/shared/constants.dart';

class AddVendorNameDescription extends StatefulWidget {
  final Vendor vendor;
  AddVendorNameDescription({this.vendor});
  @override
  _AddVendorNameDescriptionState createState() =>
      _AddVendorNameDescriptionState();
}

class _AddVendorNameDescriptionState extends State<AddVendorNameDescription> {
  Vendor _vendor;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _vendor = widget.vendor;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Name & Description",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2661FA),
                    fontSize: size.width * 0.09),
              ),
            ),
            SizedBox(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                  maxLength: 50,
                  onChanged: (value) => setState(() => _vendor.name = value),
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Let\'s give a name to the vendor'),
                ),
              ),
            ),
            SizedBox(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: TextField(
                    maxLength: 1000,
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    onChanged: (value) =>
                        setState(() => _vendor.description = value),
                    decoration: textInputDecoration.copyWith(
                        hintText:
                            'Add some description for the vendor. Try to include the product and services available, prices, timings and contact details.')),
              ),
            ),
            SizedBox(
                child: Text(_errorText, style: TextStyle(color: Colors.red))),
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
      ),
    );
  }
}
