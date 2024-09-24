import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_ease/auth_method.dart';

import '../models/customers.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _addressController = TextEditingController();


  String customerId = "";
  void loadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      customerId = pref.getString('id')!;
    });
    await setController();
  }
  Future<void> setController() async{
    CollectionReference customer = FirebaseFirestore.instance.collection('customers');
    QuerySnapshot customerQuery = await customer.where('customerID', isEqualTo: customerId).get();
    final document = customerQuery.docs[0].data() as Map<String, dynamic>;
    final data = Customer.fromMap(document);
    setState(() {
      _emailController.text = data.email??"";
      _addressController.text = data.address??"";
      _mobileController.text = data.mobileNo.toString()??"";
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _mobileController,
              decoration: InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                String updatedEmail = _emailController.text;
                String updatedMobile = _mobileController.text;
                String updatedAddress = _addressController.text;

                int Updatedmobile = int.parse(updatedMobile);

                if (updatedEmail.isNotEmpty || updatedMobile.isNotEmpty || updatedAddress.isNotEmpty) {
                  AuthMethod().setData(customerId, updatedEmail,Updatedmobile, updatedAddress);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Profile Updated'),
                        content: Text('Your profile has been updated successfully.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Show a dialog indicating that all fields are empty
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Enter Valid Data'),
                        content: Text('All Fields are Empty'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

void main() => runApp(MaterialApp(home: UpdateProfilePage()));
