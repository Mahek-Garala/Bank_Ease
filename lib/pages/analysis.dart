
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_ease/models/account.dart';
import 'package:bank_ease/models/transactions.dart';

class TransactionAnalytics extends StatefulWidget {
  const TransactionAnalytics({Key? key}) : super(key: key);

  @override
  _TransactionAnalyticsState createState() => _TransactionAnalyticsState();
}

class _TransactionAnalyticsState extends State<TransactionAnalytics> {
  List<Transactions> transactions = [];
  Account account_info = Account.nothing();
  int selectedYear = DateTime.now().year; // Default to current year

  @override
  void initState() {
    super.initState();
    fetchFilteredTransactions();
  }

  Future<void> fetchFilteredTransactions() async {
    final pref = await SharedPreferences.getInstance();
    final custId = pref.getString('id') ?? '';

    CollectionReference account = FirebaseFirestore.instance.collection('accounts');
    QuerySnapshot accountQuery = await account.where('customer_ID', isEqualTo: custId).get();
    if (accountQuery.docs.isEmpty) return;

    final document1 = accountQuery.docs[0].data() as Map<String, dynamic>;
    account_info = Account.fromMap(document1);

    CollectionReference transaction = FirebaseFirestore.instance.collection('transaction');

    QuerySnapshot sentTransactionsQuery = await transaction
        .where('sender_account_no', isEqualTo: account_info.account_no)
        .get();
    QuerySnapshot receivedTransactionsQuery = await transaction
        .where('receiver_account_no', isEqualTo: account_info.account_no)
        .get();

    transactions = [];
    transactions.addAll(sentTransactionsQuery.docs.map((doc) {
      final docData = doc.data() as Map<String, dynamic>;
      return Transactions.fromMap(docData);
    }));
    transactions.addAll(receivedTransactionsQuery.docs.map((doc) {
      final docData = doc.data() as Map<String, dynamic>;
      return Transactions.fromMap(docData);
    }));

    print("Fetched Transactions: $transactions");

    transactions.sort((a, b) => a.date!.toDate().compareTo(b.date!.toDate()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Analytics'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Monthly Transaction Volume',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Year Selector
          DropdownButton<int>(
            value: selectedYear,
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedYear = newValue;
                });
              }
            },
            items: List.generate(5, (index) => DateTime.now().year - index)
                .map<DropdownMenuItem<int>>((year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 350,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BarChart(
                BarChartData(
                  barGroups: getMonthlyTransactionBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final months = getDisplayMonths();
                          if (value.toInt() < 0 || value.toInt() >= months.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(months[value.toInt()]);
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, x, y, data) {
                        String month = getDisplayMonths()[group.x.toInt()];
                        return BarTooltipItem(
                          '$month\nTotal: ₹${y.toY.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> getDisplayMonths() {
    return ['Jn', 'Fb', 'Mr', 'Ap', 'My', 'Jn', 'Jl', 'Ag', 'Sp', 'Oc', 'Nv', 'Dc'];
  }

  List<String> getActualMonths() {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  }

  Map<String, Map<String, double>> getMonthlyTransactionVolume() {
    Map<String, Map<String, double>> monthlyData = {};

    for (var transaction in transactions) {
      if (transaction.amount != null && transaction.date != null) {
        DateTime date = (transaction.date as Timestamp).toDate();

        // Only include transactions from the selected year
        if (date.year == selectedYear) {
          String month = DateFormat('MMM').format(date);

          monthlyData.putIfAbsent(month, () => {'sent': 0.0, 'received': 0.0});

          if (transaction.sender_account_no == account_info.account_no) {
            monthlyData[month]!['sent'] = (monthlyData[month]!['sent'] ?? 0) + transaction.amount!.toDouble();
          } else if (transaction.receiver_account_no == account_info.account_no) {
            monthlyData[month]!['received'] = (monthlyData[month]!['received'] ?? 0) + transaction.amount!.toDouble();
          }
        }
      }
    }

    print("Monthly Data: $monthlyData");
    return monthlyData;
  }

  List<BarChartGroupData> getMonthlyTransactionBarGroups() {
    List<BarChartGroupData> barGroups = [];
    List<String> actualMonths = getActualMonths();

    // Fetch monthly transaction volumes for the selected year
    Map<String, Map<String, double>> monthlyData = getMonthlyTransactionVolume();

    for (int i = 0; i < actualMonths.length; i++) {
      final actualMonth = actualMonths[i];

      // Retrieve sent and received amounts for the current month
      final sentAmount = monthlyData[actualMonth]?['sent'] ?? 0.0;
      final receivedAmount = monthlyData[actualMonth]?['received'] ?? 0.0;

      const scaleFactor = 1;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: receivedAmount * scaleFactor,
              width: 10,
              color: Colors.green,
            ),
            BarChartRodData(
              toY: sentAmount * scaleFactor,
              width: 10,
              color: Colors.red,
            ),
          ],
          barsSpace: 1,
        ),
      );
    }

    return barGroups;
  }
}

// Main Entry Point
void main() {
  runApp(const MaterialApp(
    home: TransactionAnalytics(),
  ));
}
