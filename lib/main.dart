import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bank_ease/pages/signup.dart';
import 'package:bank_ease/pages/Loading.dart';
import 'package:bank_ease/pages/login.dart';
import 'package:bank_ease/pages/home.dart';
import 'package:bank_ease/pages/QrPay.dart';
import 'package:bank_ease/pages/QrPayment.dart';
import 'package:bank_ease/pages/transaction.dart';
import 'package:bank_ease/pages/profile.dart';
import 'package:bank_ease/pages/UpdateProfile.dart';
import 'package:bank_ease/pages/QrScannerOverlay.dart';
import 'package:bank_ease/pages/generateqrcode.dart';
import 'package:bank_ease/pages/scanqr.dart';
import 'package:bank_ease/pages/analysis.dart';
import 'package:bank_ease/pages/transactionHistory.dart';
import 'package:bank_ease/pages/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("firebase initialized succ.....");
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes:{
        '/' : (context) => const Loading(),
        '/login_page': (context) => const LoginPage(),
        '/sign_up': (context) => const Signup(),
        '/home': (context) => const Home(),
        '/genrate_qr': (context) => GenerateQRCode(),
        '/profile': (context) => Profile(),
        '/transaction': (context) => TransactionPage(),
        '/scan_qr': (context) => const Scanqr(),
        '/transactionHistory' : (context) => const TransactionHistory(),
        '/updateProfile' : (context) => UpdateProfilePage(),
        '/qr_payment' : (context) => QRPayment(),
        '/qr_pay' : (context) => QrPay(),
        '/analysis' : (context)=> TransactionAnalytics(),
      }
  ));
}

