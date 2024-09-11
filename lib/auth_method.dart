
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bank_ease/pages/signup.dart';


class AuthMethod{
  final FirebaseFirestore _firestore  = FirebaseFirestore.instance;
  Future <Map<String, dynamic>?> getCustomer(String customerid) async {
    try{
      var doc = await _firestore.collection("customers").get();
      var customers = doc.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      Map<String, dynamic>? specificCustomer = customers.firstWhere(
            (customer) => customer['customerID'] == customerid,
      );
      return specificCustomer;
    }
    catch(e) {
      print(e.toString());
    }
    return null;
  }
  Future<Map<dynamic,dynamic>?> savepin(String customerId,String setpin) async {
    try{
      final QuerySnapshot<Object?> querySnapshot = await _firestore.collection('customers').where('customerID', isEqualTo: customerId).get();
      if (querySnapshot.docs.isNotEmpty) {
        final DocumentReference documentRef = querySnapshot.docs[0].reference;
        final customer = querySnapshot.docs[0].data();
        final customerName = (customer as Map)['name'];
        await documentRef.update({
          'mPIN': setpin,
        });
        return customer;
      } else {
        return null;
      }
    }
    catch(error){
      print(error.toString());
    }
    return null;

  }

}

