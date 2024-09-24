// The page is responsible for handling a payment operation using the given transaction details.
// It interacts with Firebase Firestore to fetch the necessary data about customers, accounts, and updates the database with the transaction results.
// The page provides user feedback (via dialog boxes) on success or error.

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bank_ease/models/customers.dart';
import 'package:bank_ease/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrPay extends StatefulWidget {
  const QrPay({super.key});

  @override
  State<QrPay> createState() => _QrPayState();
}

class _QrPayState extends State<QrPay> {

  final TextEditingController _pin = TextEditingController();

  Map<dynamic,dynamic> Data = {};

  String amount = "";
  String reciver_Cust = "";
  String Remark = "";
  String name1="";
  String CustId = "";
  String account_holder = "";
  String account_no = "";
  String card_no = "";
  //String Amount = "";
  Customer customer_info = Customer.nothing();
  Customer current_customer_info = Customer.nothing();
  Account account_info = Account.nothing();
  Account current_account_info = Account.nothing();
  String QrData = "";
  bool isAmountValid = false;
  String? pinValidationMessage;

  @override
  void didChangeDependencies() { // typically used when you need to fetch data.
    super.didChangeDependencies();

    // Move the logic that depends on inherited widgets here
    setVariables().then((_) {
      setState(() {}); // Trigger a rebuild after setting variables
    });
  }

  Future<void> setVariables() async
  {
    Data = ModalRoute.of(context)?.settings.arguments as Map;
    print(Data);
    print(Data.isEmpty);

    amount = Data['amount'];
    reciver_Cust = Data['reciver_Cust'];
    Remark = Data['remark'];

    final pref = await SharedPreferences.getInstance();
    name1 = pref.getString('name') ?? '';
    CustId = pref.getString('id') ?? '';

    //jeno qrcode hoi tenu name
    CollectionReference customer = FirebaseFirestore.instance.collection('customers');
    QuerySnapshot customerQuery = await customer
        .where('customerID', isEqualTo: reciver_Cust)
        .get();
    final document = customerQuery.docs[0].data() as Map<String,dynamic>;
    account_holder = (document)['name'];
    print(account_holder);
    customer_info = Customer.fromMap(document);
    print(document);

    //jeno qr code hoi teni account details
    CollectionReference account = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot accountQuery = await account
        .where('customer_ID', isEqualTo: reciver_Cust)
        .get();
    final document1 = accountQuery.docs[0].data() as Map<dynamic,dynamic>;
    account_info = Account.fromMap(document1);
    print(document1);

    //jene scan karyo(current user) teni info
    CollectionReference current_customer = FirebaseFirestore.instance.collection('customers');
    QuerySnapshot current_customerQuery = await current_customer
        .where('customerID', isEqualTo: CustId)
        .get();
    final document2 = current_customerQuery.docs[0].data() as Map<String,dynamic>;
    current_customer_info = Customer.fromMap(document2);
    print(document2);

    //jene scan karyo(current user) tena account ni info
    CollectionReference current_account = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot current_accountQuery = await current_account
        .where('customer_ID', isEqualTo: CustId)
        .get();
    final document3 = current_accountQuery.docs[0].data() as Map<dynamic,dynamic>;
    current_account_info = Account.fromMap(document3);
    print(document3);

  }

  Future<void> handlesubmit(String senderAccount, String receiverAccount,
      String amount, String remark, String transactionPin) async {
    if(senderAccount == receiverAccount){
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Action'),
              content: Text('Both Sender and Receiver cannot be Same.'),
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
      });
      return;
    }
    final parsedAmount = int.parse(amount);
    final parsedpin = int.parse(transactionPin);
    DateTime now = new DateTime.now();


    CollectionReference account = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot sender_account = await account.where('account_no', isEqualTo: senderAccount).get();
    if (sender_account.docs.isNotEmpty) {
      final document = sender_account.docs[0].data();
      final pin = (document as Map)['transaction_pin'];
      if (pin == parsedpin) {
        // "CollectionReference" Refers to multiple documents.
        // Can create new documents, query existing documents, and list all documents.
        // Can reference a document inside it via doc().
        CollectionReference transaction = FirebaseFirestore.instance.collection('transaction');
        await transaction.add({
          'sender_account_no': senderAccount,
          'receiver_account_no': receiverAccount,
          'amount': parsedAmount,
          'remarks': remark,
          'date': now
        }).then((value) => print("Added Data"));

        //sender na acc mathi minus

        // "DocumentReference" Refers to a single document.
        // Can be used to read, update, delete, or set data on that specific document.
        // Can reference its parent collection using parent (if needed).
        final DocumentReference sender_doc = sender_account.docs[0].reference;
        final bal = (document as Map)['balance'];
        final rem_bal = bal - parsedAmount;
        await sender_doc.update({'balance': rem_bal});

        //receiver na acc ma plus
        QuerySnapshot receiver = await account.where('account_no', isEqualTo: receiverAccount).get();
        final DocumentReference receiver_doc = receiver.docs[0].reference;
        final receiver_doc_data = receiver.docs[0].data();
        final receiver_bal = (receiver_doc_data as Map)['balance'];
        final new_bal = receiver_bal + parsedAmount;
        await receiver_doc.update({'balance': new_bal});

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Transaction Successful'),
              content: Text('Amount Transferred Successfully.'),
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
      else {
        setState(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Invalid PIN'),
                content: Text('Please Enter a Valid Pin.'),
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
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(' Pay'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  SizedBox(height: 120,),
                  Text('Bharat National Bank',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 75,),
                  Text('Pay to ' + account_holder,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Amount : ₹ ' + amount + ' /-',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text('Enter 4-digit pin :',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    width: 150, // Adjust the width as needed
                    child: TextFormField(
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                      controller: _pin,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(height: 50,),
                  SizedBox(
                    width: 180,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.blueAccent, width: 2.5),  // Blue accent border
                        elevation: 5,  // Elevation for shadow effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),  // Border radius similar to previous style
                        ),
                      ),
                      onPressed: () async {
                        String senderAccount = current_account_info.account_no.toString();
                        String receiverAccount = account_info.account_no.toString();
                        String transactionPin = _pin.text;

                        // Add your transaction logic here
                        await handlesubmit(senderAccount, receiverAccount, amount, Remark, transactionPin);

                        print("Sender's Account: $senderAccount");
                        print("Receiver's Account: $receiverAccount");
                        print("Amount: $amount");
                        print("Remark: $Remark");
                        print("Transaction PIN: $transactionPin");
                      },
                      child: const Text(
                        'Pay',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 22.0,
                          color: Colors.black,  // White text color for better contrast
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        )
    );
  }
}
