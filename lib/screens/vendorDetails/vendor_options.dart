import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_proj/models/vendor.dart';
import 'package:test_proj/screens/add_vendor/add_vendor.dart';
import 'package:test_proj/services/database.dart';
import 'package:test_proj/shared/constants.dart';
import 'package:test_proj/shared/loginPopup.dart';
import 'edit_vendor.dart';

class VendorOptions extends StatelessWidget {
  final Vendor vendor;
  VendorOptions({this.vendor});

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    //https://stackoverflow.com/questions/58144948/easiest-way-to-add-3-dot-pop-up-menu-appbar-in-flutter
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'Edit':
            if (_user.isAnonymous)
              showDialog<void>(
                  context: context,
                  builder: (_) => LoginPopup(to: "edit a vendor"));
            //DONT DELETE
            else if (!_user.emailVerified) {
              await _user.reload();
              if (!_user.emailVerified)
                showDialog<void>(
                    context: context,
                    builder: (_) => VerifyEmailPopup(to: "edit a vendor"));
              else
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddVendor(vendor: vendor)));
            } else
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EditVendor(vendor: vendor)));
            break;
          case 'Report':
            if (_user.isAnonymous)
              showDialog<void>(
                  context: context,
                  builder: (_) => LoginPopup(to: "report a vendor"));
            //DONT DELETE
            else if (!_user.emailVerified) {
              await _user.reload();
              if (!_user.emailVerified)
                showDialog<void>(
                    context: context,
                    builder: (_) => VerifyEmailPopup(to: "report a vendor"));
              else
                vendor.reported
                    ? print('reported')
                    : showDialog<void>(
                        context: context,
                        builder: (_) => Report(vendor: vendor));
            } else
              vendor.reported
                  ? print('reported')
                  : showDialog<void>(
                      context: context, builder: (_) => Report(vendor: vendor));
            //https://stackoverflow.com/questions/54480641/flutter-how-to-create-forms-in-popup
            break;
        }
      },
      itemBuilder: (_) {
        return {'Edit', if (!vendor.reported) 'Report'}
            .map((String choice) =>
                PopupMenuItem<String>(value: choice, child: Text(choice)))
            .toList();
      },
    );
  }
}

class Report extends StatefulWidget {
  final Vendor vendor;
  Report({this.vendor});
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  String _selectedReport = '';
  List<String> _reasons = [
    'This vendor is duplicate.',
    'This vendor is spam and does not exist',
    'This vendor is not available anymore.',
    'Other'
  ];
  TextEditingController _otherReportController = TextEditingController();
  String _alertText = '';
  double _h;
  double _w;
  Widget _bottomWidget = Container();
  User _user;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<User>(context, listen: false);
  }

  Text _alertTextWidget() => Text(_alertText, style: ERROR_TEXT_STYLE(_w));

  void _updateReport(String report) => setState(() => _selectedReport = report);

  void _reportVendor() async {
    if (_selectedReport == _reasons[3])
      _selectedReport += " " + _otherReportController.text.trim();
    if (_selectedReport.isNotEmpty) {
      setState(() => _bottomWidget = CircularProgressIndicator());
      final response = await VendorDBService.reportVendor(
          _selectedReport, widget.vendor, await _user.getIdToken());
      if (response.statusCode == 200) {
        setState(() => widget.vendor.reported = true);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Reported successfully!')));
      } else
        setState(() {
          _alertText = "Could not report vendor";
          _bottomWidget = _alertTextWidget();
        });
    } else
      setState(() {
        _alertText = "Please select a reason.";
        _bottomWidget = _alertTextWidget();
      });
  }

  @override
  Widget build(BuildContext context) {
    _h = MediaQuery.of(context).size.height;
    _w = MediaQuery.of(context).size.width;
    return AlertDialog(
      content: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          //close button
          Positioned(
            right: -40.0,
            top: -40.0,
            child: InkResponse(
              onTap: () => Navigator.of(context).pop(),
              child: CircleAvatar(
                  child: Icon(Icons.close), backgroundColor: Colors.red),
            ),
          ),
          _buildReportsColumn(),
        ],
      ),
    );
  }

  Column _buildReportsColumn() => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //1
          RadioListTile(
            value: _reasons[0],
            groupValue: _selectedReport,
            title: Text(_reasons[0]),
            onChanged: _updateReport,
            selected: true,
          ),
          //2
          RadioListTile(
            value: _reasons[1],
            groupValue: _selectedReport,
            title: Text(_reasons[1]),
            onChanged: _updateReport,
            selected: true,
          ),
          //3
          RadioListTile(
            value: _reasons[2],
            groupValue: _selectedReport,
            title: Text(_reasons[2]),
            onChanged: _updateReport,
            selected: true,
          ),
          //other
          RadioListTile(
            value: _reasons[3],
            groupValue: _selectedReport,
            title: Text(_reasons[3]),
            onChanged: _updateReport,
            selected: true,
          ),
          if (_selectedReport == _reasons[3])
            TextFormField(
                maxLength: 500,
                controller: _otherReportController,
                decoration: textInputDecoration.copyWith(
                    hintText: "Please enter your issue here")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: BS(_w * 0.1, _h * 0.05),
              child: Text('Submit'),
              onPressed: _reportVendor,
            ),
          ),
          _bottomWidget,
        ],
      );
}
