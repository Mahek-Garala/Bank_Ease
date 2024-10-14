// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:bank_ease/auth_method.dart';
//
// import '../models/customers.dart';
//
// class UpdateProfilePage extends StatefulWidget {
//   @override
//   _UpdateProfilePageState createState() => _UpdateProfilePageState();
// }
//
// class _UpdateProfilePageState extends State<UpdateProfilePage> {
//
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _mobileController = TextEditingController();
//   TextEditingController _addressController = TextEditingController();
//
//
//   String customerId = "";
//   void loadData() async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     setState(() {
//       customerId = pref.getString('id')!;
//     });
//     await setController();
//   }
//   Future<void> setController() async{
//     CollectionReference customer = FirebaseFirestore.instance.collection('customers');
//     QuerySnapshot customerQuery = await customer.where('customerID', isEqualTo: customerId).get();
//     final document = customerQuery.docs[0].data() as Map<String, dynamic>;
//     final data = Customer.fromMap(document);
//     setState(() {
//       _emailController.text = data.email??"";
//       _addressController.text = data.address??"";
//       _mobileController.text = data.mobileNo.toString()??"";
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update Profile'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _mobileController,
//               decoration: InputDecoration(labelText: 'Mobile Number'),
//               keyboardType: TextInputType.phone,
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _addressController,
//               decoration: InputDecoration(labelText: 'Address'),
//             ),
//             SizedBox(height: 32.0),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//               ),
//               onPressed: () {
//                 String updatedEmail = _emailController.text;
//                 String updatedMobile = _mobileController.text;
//                 String updatedAddress = _addressController.text;
//
//                 int Updatedmobile = int.parse(updatedMobile);
//
//                 if (updatedEmail.isNotEmpty || updatedMobile.isNotEmpty || updatedAddress.isNotEmpty) {
//                   AuthMethod().setData(customerId, updatedEmail,Updatedmobile, updatedAddress);
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text('Profile Updated'),
//                         content: Text('Your profile has been updated successfully.'),
//                         actions: <Widget>[
//                           TextButton(
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                               Navigator.pushReplacementNamed(context, '/home');
//                             },
//                             child: Text('OK'),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 } else {
//                   // Show a dialog indicating that all fields are empty
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text('Enter Valid Data'),
//                         content: Text('All Fields are Empty'),
//                         actions: <Widget>[
//                           TextButton(
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                             child: Text('OK'),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 }
//               },
//               child: Text('Update Profile'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _mobileController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }
// }
//
// void main() => runApp(MaterialApp(home: UpdateProfilePage()));


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_ease/auth_method.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String verificationId = "";
  bool otpSent = false;

  void loadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      customerId = pref.getString('id')!;
    });
    await setController();
  }

  Future<void> setController() async {
    CollectionReference customer =
    FirebaseFirestore.instance.collection('customers');
    QuerySnapshot customerQuery =
    await customer.where('customerID', isEqualTo: customerId).get();
    final document = customerQuery.docs[0].data() as Map<String, dynamic>;
    final data = Customer.fromMap(document);
    setState(() {
      _emailController.text = data.email ?? "";
      _addressController.text = data.address ?? "";
      _mobileController.text = data.mobileNo.toString() ?? "";
    });
  }

  // Send OTP function
  void sendOTP(String mobileNumber) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    await _auth.verifyPhoneNumber(
      phoneNumber: mobileNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval scenario
        await _auth.signInWithCredential(credential);
        print("OTP auto-retrieved and verified");
        proceedWithProfileUpdate(); // Call this function after OTP is auto-verified
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: $e');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          this.verificationId = verificationId;
          otpSent = true;
        });
        print('OTP sent');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          this.verificationId = verificationId;
        });
      },
    );
  }

  // Verify OTP function
 void verifyOTP(String smsCode) async {
    try {
      // Create PhoneAuthCredential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with credential
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        print('OTP verified successfully: ${userCredential.user?.uid}');
        proceedWithProfileUpdate(); // Call your function
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      // Handle different types of errors if needed
    }
  }

  // Function to handle profile update
  void proceedWithProfileUpdate() {
    String updatedEmail = _emailController.text;
    String updatedMobile = _mobileController.text;
    String updatedAddress = _addressController.text;

    int Updatedmobile = int.parse(updatedMobile);

    AuthMethod().setData(customerId, updatedEmail, Updatedmobile, updatedAddress);
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
  }

  // Show dialog to prompt OTP
  void showOtpDialog(String mobileNumber) {
    TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the OTP sent to $mobileNumber'),
              TextField(
                controller: otpController,
                decoration: InputDecoration(labelText: 'OTP'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                verifyOTP(otpController.text); // Verify the entered OTP
                Navigator.of(context).pop();
              },
              child: Text('Verify'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Error dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

                if (updatedEmail.isNotEmpty || updatedMobile.isNotEmpty || updatedAddress.isNotEmpty) {
                  String mobileNumberToSendOTP =
                  updatedMobile.isNotEmpty ? updatedMobile : _mobileController.text.toString();

                  // Send OTP to the updated or previous mobile number
                 sendOTP(mobileNumberToSendOTP);
                  //sendOTP("+91$mobileNumberToSendOTP"); // Example: adding a country code

                  // Show OTP dialog for verification
                  showOtpDialog(mobileNumberToSendOTP);
                } else {
                  showErrorDialog('All fields are empty. Please enter valid data.');
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
