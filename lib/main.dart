import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bank_ease/pages/signup.dart';
import 'package:bank_ease/pages/Loading.dart';
import 'package:bank_ease/pages/login.dart';
import 'package:bank_ease/pages/home.dart';
import 'package:bank_ease/pages/profile.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(MaterialApp(
      initialRoute: '/',
      routes:{
        '/' : (context) => const Loading(),
        '/login_page': (context) => const LoginPage(),
        '/sign_up': (context) => const Signup(),
        '/home': (context) => const Home(),
        // '/genrate_qr': (context) => GenerateQRCode(),
        // '/profile': (context) => Profile(),
        // '/transaction': (context) => TransactionPage(),
        // '/scan_qr': (context) => const Scanqr(),
        // '/transactionHistory' : (context) => const transactionHistory(),
        // '/updateProfile' : (context) => UpdateProfilePage(),
        // '/qr_payment' : (context) => QRPayment(),
        // '/qr_pay' : (context) => QrPay(),
      }
  ));
}