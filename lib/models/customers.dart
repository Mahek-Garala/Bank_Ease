import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  String? address;
  String? dob;
  String? name;
  int? mobileNo;
  String? panNo;
  int? aadharCardNo;
  String? customerID;
  String? mPin;
  String? email;
  String? url;
  Customer.nothing();
  Customer({
    required this.address,
    required this.dob,
    required this.name,
    required this.mobileNo,
    required this.panNo,
    required this.aadharCardNo,
    required this.customerID,
    required this.mPin,
    required this.email,
    required this.url
  });

  static Customer fromMap(DocumentSnapshot snap) {
    Map<String, dynamic> map = snap.data() as Map<String, dynamic>;
    return Customer(
      address: map['address'],
      dob: map['dob'],
      name: map['name'],
      mobileNo: map['mobileNo'],
      panNo: map['panNO'],
      aadharCardNo: map['aadharCardNo'],
      customerID: map['customerID'],
      mPin: map['mPIN'],
      email: map['email'],
      url : map['url'],
    );
  }
  @override
  String toString() {
    return 'Customer(address: $address, dob: $dob, name: $name, mobileNo: $mobileNo, panNo: $panNo, aadharCardNo: $aadharCardNo, customerID: $customerID, mPin: $mPin, email: $email, url: $url)';
  }
}


