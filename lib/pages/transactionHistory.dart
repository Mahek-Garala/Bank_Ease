
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bank_ease/models/account.dart';
import 'package:bank_ease/models/transactions.dart';
import 'package:bank_ease/models/customers.dart';
import 'package:intl/intl.dart';

Account account_info = Account.nothing();
String sender_name = "";
String receiver_name = "";

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({Key? key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  String selectedMonth = 'All';  // Default to "All" for showing all transactions
  String selectedYear = '2024';   // Default to the current year

  List<String> months = [
    'All', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // You can set the years based on your requirements. This is just an example.
  List<String> years = List.generate(10, (index) => (2024 - index).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Month selection
                DropdownButton<String>(
                  value: selectedMonth,
                  items: months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
                // Year selection
                DropdownButton<String>(
                  value: selectedYear,
                  items: years.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Transactions>>(
              future: fetchFilteredTransactions(), // Use the filtered transaction fetching function
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No transactions available.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Transactions transaction = snapshot.data![index];
                      bool isSent = transaction.sender_account_no == account_info.account_no;

                      DateTime transactionDate = transaction.date!.toDate();
                      String formattedDate = DateFormat.yMMMd().format(transactionDate);
                      Color transactionColor = isSent ? Colors.red : Colors.green;

                      return FutureBuilder<Map<String, String>>(
                        future: fetchNames(transaction.sender_account_no, transaction.receiver_account_no),
                        builder: (context, nameSnapshot) {
                          if (nameSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (nameSnapshot.hasError) {
                            return Text('Error fetching names');
                          } else if (!nameSnapshot.hasData) {
                            return Text('Loading names...');
                          }

                          final senderName = nameSnapshot.data!['sender']!;
                          final receiverName = nameSnapshot.data!['receiver']!;

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.blueAccent),
                            ),
                            child: ListTile(
                              title: Text(
                                'Transaction ID: ${transaction.hashCode}',
                                style: TextStyle(color: transactionColor),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sender: $senderName'),
                                  Text('Receiver: $receiverName'),
                                  Text('Amount: \₹${transaction.amount}'),
                                  Text('Remark: ${transaction.remarks}'),
                                  Text('Date: $formattedDate'),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Modified to include month and year filtering logic
  Future<List<Transactions>> fetchFilteredTransactions() async {
    final pref = await SharedPreferences.getInstance();
    final CustId = pref.getString('id') ?? '';

    CollectionReference account = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot accountQuery = await account.where('customer_ID', isEqualTo: CustId).get();
    final document1 = accountQuery.docs[0].data() as Map<dynamic, dynamic>;
    account_info = Account.fromMap(document1);

    CollectionReference transaction = FirebaseFirestore.instance.collection('transaction');

    // Fetch all transactions related to the current account
    QuerySnapshot sentTransactionsQuery = await transaction
        .where('sender_account_no', isEqualTo: account_info.account_no)
        .get();
    QuerySnapshot receivedTransactionsQuery = await transaction
        .where('receiver_account_no', isEqualTo: account_info.account_no)
        .get();

    List<Transactions> transactions = [];

    // Combine sent and received transactions
    for (var document in sentTransactionsQuery.docs) {
      final doc1 = document.data() as Map<dynamic, dynamic>;
      final transactionInfo = Transactions.fromMap(doc1);
      transactions.add(transactionInfo);
    }

    for (var document in receivedTransactionsQuery.docs) {
      final doc1 = document.data() as Map<dynamic, dynamic>;
      final transactionInfo = Transactions.fromMap(doc1);
      transactions.add(transactionInfo);
    }

    // Filter the transactions locally in the app based on the selected month and year
    if (selectedMonth != 'All' || selectedYear != '2024') {
      transactions = filterTransactionsByMonthAndYear(transactions);
    }

    // Sort by date (latest first)
    transactions.sort((a, b) => a.date!.toDate().compareTo(b.date!.toDate()));
    transactions = transactions.reversed.toList();
    return transactions;
  }

  // Helper function to filter transactions by selected month and year
  List<Transactions> filterTransactionsByMonthAndYear(List<Transactions> transactions) {
    int selectedMonthIndex = months.indexOf(selectedMonth); // Get index of the selected month
    int selectedYearInt = int.parse(selectedYear); // Convert selected year to integer

    return transactions.where((transaction) {
      DateTime transactionDate = transaction.date!.toDate();
      return (selectedMonthIndex == 0 || transactionDate.month == selectedMonthIndex) &&
          transactionDate.year == selectedYearInt;
    }).toList();
  }

  // Fetch the sender and receiver names (remains unchanged)
  Future<Map<String, String>> fetchNames(String? sender_account_no, String? receiver_account_no) async {
    CollectionReference account = FirebaseFirestore.instance.collection('accounts');
    CollectionReference customer = FirebaseFirestore.instance.collection('customers');

    Map<String, String> names = {};

    // Fetch sender's name
    QuerySnapshot accountQuery = await account.where('account_no', isEqualTo: sender_account_no).get();
    final document1 = accountQuery.docs[0].data() as Map<dynamic, dynamic>;
    final account_info1 = Account.fromMap(document1);

    QuerySnapshot customerQuery = await customer.where('customerID', isEqualTo: account_info1.customer_ID).get();
    final document2 = customerQuery.docs[0].data() as Map<String, dynamic>;
    final customer_info1 = Customer.fromMap(document2);
    names['sender'] = customer_info1.name!;

    // Fetch receiver's name
    accountQuery = await account.where('account_no', isEqualTo: receiver_account_no).get();
    final document3 = accountQuery.docs[0].data() as Map<dynamic, dynamic>;
    final account_info2 = Account.fromMap(document3);

    customerQuery = await customer.where('customerID', isEqualTo: account_info2.customer_ID).get();
    final document4 = customerQuery.docs[0].data() as Map<String, dynamic>;
    final customer_info2 = Customer.fromMap(document4);
    names['receiver'] = customer_info2.name!;

    return names;
  }
}
