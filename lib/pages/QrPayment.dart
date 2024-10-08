// // QR Code is scanned, and data (customer ID) is passed to this screen.
// // Firestore queries fetch the recipient and current user details using the scanned data.
// // User enters payment details like the amount and remarks.
// // Amount is verified to ensure it's valid (less than the sender's balance).
// // If valid, the user proceeds to the payment PIN screen to finalize the transaction.
//
// import 'dart:ffi';
// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:bank_ease/models/customers.dart';
// import 'package:bank_ease/models/account.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:bank_ease/pages/scanqr.dart';
//
// late final String code;
//
// class QRPayment extends StatefulWidget {
//   QRPayment({super.key});
//   @override
//   State<QRPayment> createState() => _QRPaymentState();
// }
//
// class _QRPaymentState extends State<QRPayment> {
//   final TextEditingController _amount = TextEditingController();
//   final TextEditingController _remark = TextEditingController();
//
//   Map<dynamic,dynamic> Data = {};
//   String name1="";
//   String CustId = "";
//   String account_holder = "";
//   String account_no = "";
//   String card_no = "";
//   String Amount = "";
//   Customer customer_info = Customer.nothing();
//   Customer current_customer_info = Customer.nothing();
//   Account account_info = Account.nothing();
//   Account current_account_info = Account.nothing();
//   String QrData = "";
//   String Remark = "";
//   bool isAmountValid = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     // Move the logic that depends on inherited widgets here
//     setvariables().then((_) {
//       setState(() {}); // Trigger a rebuild after setting variables
//     });
//   }
//
//   Future<void> setvariables() async {
//     Data =  ModalRoute.of(context)?.settings.arguments as Map; //{'qrCodeData':"111111"};
//     print(Data);
//     QrData = Data['qrCodeData'];
//
//     final pref = await SharedPreferences.getInstance();
//     name1 = pref.getString('name') ?? '';
//     CustId = pref.getString('id') ?? '';
//
//   //qrcode jeno hoi tenu name "account_holder" ma
//     CollectionReference customer = FirebaseFirestore.instance.collection('customers');
//     QuerySnapshot customerQuery = await customer
//         .where('customerID', isEqualTo: QrData)
//         .get();
//     final document = customerQuery.docs[0].data() as Map<String,dynamic>;
//     account_holder = (document)['name'];
//     print(account_holder);
//     customer_info = Customer.fromMap(document);
//     print(document);
//
//     //qrcode jeno hoi tena account ni info "account_info" ma
//     CollectionReference account = FirebaseFirestore.instance.collection('accounts');
//     QuerySnapshot accountQuery = await account
//         .where('customer_ID', isEqualTo: QrData)
//         .get();
//     final document1 = accountQuery.docs[0].data() as Map<dynamic,dynamic>;
//     account_info = Account.fromMap(document1);
//     print(document1);
//
//     //jene scan karyo hase (current user) teni details "current_customer_info" ma
//     CollectionReference current_customer = FirebaseFirestore.instance.collection('customers');
//     QuerySnapshot current_customerQuery = await current_customer
//         .where('customerID', isEqualTo: CustId)
//         .get();
//     final document2 = current_customerQuery.docs[0].data() as Map<String,dynamic>;
//     current_customer_info = Customer.fromMap(document2);
//     print(document2);
//
//     //jene scan karyo hase (current user) teni account details "current_account_info" ma
//     CollectionReference current_account = FirebaseFirestore.instance.collection('accounts');
//     QuerySnapshot current_accountQuery = await current_account
//         .where('customer_ID', isEqualTo: CustId)
//         .get();
//     print(current_accountQuery.docs);
//     final document3 = current_accountQuery.docs[0].data() as Map<dynamic,dynamic>;
//     current_account_info = Account.fromMap(document3);
//     print(document3);
//   }
//
//   void VerifyAmount() async
//   {
//     int am = int.parse(_amount.text) ;
//     print(am);
//     int? curr_am = current_account_info.balance;
//     print("amount");
//     print(_amount.text);
//     print("balance : ");
//     print(current_account_info.balance);
//
//     if( am >= curr_am! )
//     {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(
//         content: Text("Enter valid amount."),
//       ));
//     }
//     else{
//       isAmountValid = true;
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     super.initState();
//
//   }
//
//   //String data = qrData;
//   @override
//   Widget build(BuildContext context) {
//
//     return  Scaffold(
//       appBar: AppBar(
//         title: Text('Scan Qr Code & Pay'),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           alignment: Alignment.topCenter,
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               //mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 //show qr here
//                 SizedBox(height: 120,),
//                 Text('Bharat National Bank',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 SizedBox(height: 75,),
//                 Text('Pay to $account_holder',
//                   style: TextStyle(
//                     color: Colors.black87,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 SizedBox(height: 10,),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Remark : ',
//                       style: TextStyle(
//                         color: Colors.black87,
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                     SizedBox(width: 8,),
//                     Container(
//                       width: 200, // Adjust the width as needed
//                       child: TextFormField(
//                         style: TextStyle(
//                           color: Colors.black87,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1,
//                         ),
//                         controller: _remark,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 10,),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Amount',
//                       style: TextStyle(
//                         color: Colors.black87,
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                     SizedBox(width: 10,),
//                     Text(': ₹ ',
//                       style: TextStyle(
//                         color: Colors.black87,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                     SizedBox(width: 8,),
//                     Container(
//                       width: 150, // Adjust the width as needed
//                       child: TextFormField(
//                         style: TextStyle(
//                           color: Colors.black87,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1,
//                         ),
//                         controller: _amount,
//                         keyboardType: TextInputType.number,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 50,),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 45,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                     ),
//                     onPressed: () async{
//                       print(_amount.text);
//
//                       VerifyAmount();
//
//                       if(isAmountValid)
//                       {
//                         Navigator.pushNamed(context, '/qr_pay',arguments: {'amount' : _amount.text,'remark' : _remark.text,'reciver_Cust' : QrData });
//                       }
//                     },
//                     child: const Text(
//                       'Enter Pin',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 16.0,
//                       ),
//                     ),
//                   ),
//                 ),
//
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:bank_ease/models/customers.dart';
import 'package:bank_ease/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final String code;

class QRPayment extends StatefulWidget {
  QRPayment({super.key});
  @override
  State<QRPayment> createState() => _QRPaymentState();
}

class _QRPaymentState extends State<QRPayment> {
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _remark = TextEditingController();

  Map<dynamic, dynamic> Data = {};
  String name1 = "";
  String CustId = "";
  String account_holder = "";
  String account_no = "";
  String card_no = "";
  String Amount = "";
  Customer customer_info = Customer.nothing();
  Customer current_customer_info = Customer.nothing();
  Account account_info = Account.nothing();
  Account current_account_info = Account.nothing();
  String QrData = "";
  String Remark = "";
  bool isAmountValid = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Move the logic that depends on inherited widgets here
    setvariables().then((_) {
      setState(() {}); // Trigger a rebuild after setting variables
    });
  }

  Future<void> setvariables() async {
    Data = ModalRoute.of(context)?.settings.arguments as Map; //{'qrCodeData':"111111"};
    print(Data);
    QrData = Data['qrCodeData'];
    final pref = await SharedPreferences.getInstance();
    name1 = pref.getString('name') ?? '';
    CustId = pref.getString('id') ?? '';

    // QR code details
    CollectionReference customer = FirebaseFirestore.instance.collection('customers');
    QuerySnapshot customerQuery = await customer
        .where('customerID', isEqualTo: QrData)
        .get();
    final document = customerQuery.docs[0].data() as Map<String, dynamic>;
    account_holder = (document)['name'];
    print(account_holder);
    customer_info = Customer.fromMap(document);
    print(document);

    // Account details of QR code holder
    CollectionReference account = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot accountQuery = await account
        .where('customer_ID', isEqualTo: QrData)
        .get();
    final document1 = accountQuery.docs[0].data() as Map<dynamic, dynamic>;
    account_info = Account.fromMap(document1);
    print(document1);

    // Current user details
    CollectionReference current_customer = FirebaseFirestore.instance.collection('customers');
    QuerySnapshot current_customerQuery = await current_customer
        .where('customerID', isEqualTo: CustId)
        .get();
    final document2 = current_customerQuery.docs[0].data() as Map<String, dynamic>;
    current_customer_info = Customer.fromMap(document2);
    print(document2);

    // Current user account details
    CollectionReference current_account = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot current_accountQuery = await current_account
        .where('customer_ID', isEqualTo: CustId)
        .get();
    print(current_accountQuery.docs);
    final document3 = current_accountQuery.docs[0].data() as Map<dynamic, dynamic>;
    current_account_info = Account.fromMap(document3);
    print(document3);
  }

  void VerifyAmount() async {
    int am = int.parse(_amount.text);
    print(am);
    int? curr_am = current_account_info.balance;
    print("amount");
    print(_amount.text);
    print("balance : ");
    print(current_account_info.balance);

    if (am >= curr_am!) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter valid amount."),
      ));
    } else {
      isAmountValid = true;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code & Pay'),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SizedBox(height: 120),
                Text(
                  'Bharat National Bank',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 75),
                Text(
                  'Pay to $account_holder',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blueAccent, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Remark : ',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          controller: _remark,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blueAccent, width: 1.5),
                    borderRadius: BorderRadius.circular(8),

                  ),
                  child: Row(
                    children: [
                      Text(
                        'Amount : ₹ ',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          controller: _amount,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                SizedBox(
                  width: 220,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.blueAccent, width: 2.5),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4), // Remove border radius
                      ),
                    ),
                    onPressed: () async {
                      print(_amount.text);
                      VerifyAmount();
                      if (isAmountValid) {
                        Navigator.pushReplacementNamed(context, '/qr_pay', arguments: {'amount': _amount.text, 'remark': _remark.text, 'reciver_Cust': QrData});
                      }
                    },
                    child: const Text(
                      'Enter Pin',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
