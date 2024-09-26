
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_ease/models/customers.dart';
import 'package:bank_ease/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name1 = "";
  String CustId = "";
  String account_holder = "";
  String account_no = "";
  String card_no = "";
  Customer customer_info = Customer.nothing();
  Account account_info = Account.nothing();

  Future<void> setvariables() async {
    super.initState();
    final pref = await SharedPreferences.getInstance();
    name1 = pref.getString('name') ?? '';
    CustId = pref.getString('id') ?? '';
    CollectionReference customer = FirebaseFirestore.instance.collection('customers');
    QuerySnapshot customerQuery = await customer.where('customerID', isEqualTo: CustId).get();
    final document = customerQuery.docs[0].data() as Map<String, dynamic>;
    account_holder = (document)['name'];
    customer_info = Customer.fromMap(document);
    //String documentId1 = customerQuery.docs[0].id;

    CollectionReference account = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot accountQuery = await account.where('customer_ID', isEqualTo: CustId).get();
    //String documentId = accountQuery.docs[0].id;
    final document1 = accountQuery.docs[0].data() as Map<dynamic,dynamic>;
    account_info = Account.fromMap(document1);
  }

  @override
  void initState() {
    setvariables();
  }
  @override
  void didChangeDependencies() async{
    super.didChangeDependencies();
    // setVariables().then((_) {
    //   setState(() {}); // Trigger a rebuild after setting variables
    // });
    await setvariables(); // Fetch latest account details, including balance
  }
  bool isAccountDetailsExpanded = false;

  Future<Customer> fetchuserdata() async {
    CollectionReference customer = FirebaseFirestore.instance.collection('customers');
    QuerySnapshot customerQuery = await customer.where('customerID', isEqualTo: CustId).get();
    final document = customerQuery.docs[0].data() as Map<String, dynamic>;
    final data = Customer.fromMap(document);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BankEase'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () async {
              Customer customer = await fetchuserdata();
              Navigator.pushNamed(context, '/profile', arguments: customer);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/updateProfile');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: Text(
                  'Bharat Nation Bank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Account Details'),
                onTap: () {
                  Navigator.of(context).pop(); // This will close the drawer
                  setState(() {
                    isAccountDetailsExpanded = !isAccountDetailsExpanded;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Transaction History'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/transactionHistory');
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 5,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text(
                        'Account Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: isAccountDetailsExpanded
                            ? const Icon(
                          Icons.keyboard_arrow_up,
                          key: Key('up'),
                        )
                            : const Icon(
                          Icons.keyboard_arrow_down,
                          key: Key('down'),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isAccountDetailsExpanded = !isAccountDetailsExpanded;
                        });
                      },
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isAccountDetailsExpanded ? 300 : 0,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.account_circle),
                              title: const Text('Account Holder'),
                              subtitle: Text(customer_info.name.toString()),
                            ),
                            ListTile(
                              leading: const Icon(Icons.account_balance),
                              title: const Text('Account Number'),
                              subtitle: Text(account_info.account_no.toString()),
                            ),
                            ListTile(
                              leading: const Icon(Icons.credit_card),
                              title: const Text('Card Number'),
                              subtitle: Text(account_info.debit_card_no.toString()),
                            ),
                            ListTile(
                              leading: const Icon(Icons.currency_rupee_rounded),
                              title: const Text('Balance'),
                              subtitle: Text(account_info.balance.toString()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/genrate_qr');
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(220.0, 65.0),  // Same size for all buttons
                      side: BorderSide(color: Colors.blueAccent, width: 3),  // Thick blue border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),  // Slight rounding
                      ),
                      elevation: 5,  // Lower shadow
                      shadowColor: Colors.grey.withOpacity(0.5),  // Slight shadow
                    ),
                    icon: Icon(Icons.qr_code, color: Colors.black),  // Icon color black
                    label: Text(
                      'QR Code',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,  // Larger font size
                          fontWeight: FontWeight.bold,
                      ),  // Set font color to black
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/scan_qr');
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(220.0, 65.0),  // Same size
                      side: BorderSide(color: Colors.blueAccent, width: 3),  // Thick blue border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),  // Slight rounding
                      ),
                      elevation: 5,  // Lower shadow
                      shadowColor: Colors.grey.withOpacity(0.5),  // Slight shadow
                    ),
                    icon: Icon(Icons.qr_code_scanner, color: Colors.black),  // Icon color black
                    label: Text(
                      'Scan & Pay',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,  // Larger font size
                          fontWeight: FontWeight.bold,
                      ),  // Set font color to black
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/transaction');
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(220.0, 65.0),  // Same size
                      side: BorderSide(color: Colors.blueAccent, width: 3),  // Thick blue border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),  // Slight rounding
                      ),
                      elevation: 5,  // Lower shadow
                      shadowColor: Colors.grey.withOpacity(0.5),  // Slight shadow
                    ),
                    icon: Icon(Icons.send, color: Colors.black),  // Icon color black
                    label: Text(
                      'Transfer Money',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,  // Larger font size
                          fontWeight: FontWeight.bold,
                      ),  // Set font color to black
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/transactionHistory');
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(220.0, 65.0),  // Same size
                      side: BorderSide(color: Colors.blueAccent, width: 3),  // Thick blue border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),  // Slight rounding
                      ),
                      elevation: 5,  // Lower shadow
                      shadowColor: Colors.grey.withOpacity(0.5),  // Slight shadow
                    ),
                    icon: Icon(Icons.history, color: Colors.black),  // Icon color black
                    label: Text(
                      'Transaction History',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,  // Larger font size
                          fontWeight: FontWeight.bold,
                      ),  // Set font color to black
                    ),
                  ),
                ),
              ],
            )



          ],
        ),
      ),
    );
  }
}
