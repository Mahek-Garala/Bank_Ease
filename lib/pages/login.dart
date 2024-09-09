import 'dart:ui';
import 'package:bank_ease/auth_method.dart';
import 'package:bank_ease/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
// import 'package:bank_ease/pages/authentication.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool islogin = false;
  //database
  String ID = "";
  String name = "";
  String storedPin = "";
  static final _auth =
  LocalAuthentication(); // interact with the device's biometric authentication system.

  static Future<bool> canAuthenticate() async =>
      await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  static Future<bool> authentication() async {
    final List<BiometricType> availableBiometrics =
    await _auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
    }

    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.face)) {
      // Specific types of biometrics are available.
      // Use checks like this with caution!
    }
    print(availableBiometrics);

    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');
      if (!await canAuthenticate()) return false;
      return await _auth.authenticate(
        localizedReason:
        "get into the app", //explaining why authentication is needed.
        options: const AuthenticationOptions(
          //Shows error dialog for system-related issues
          useErrorDialogs: true,
          //If true, auth dialog is show when app open from background
          stickyAuth: true,
          //Prevent non-biometric auth like such as pin, passcode.
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('error $e');
      return false;
    }
  }

  Future<bool> verifyCustomer(String pin) async {
    try {
      //fetch from database thru ID
      var customer = await AuthMethod().getCustomer(ID);

      if (customer != null) {
        print(customer['mPIN']);
        if (pin == customer['mPIN']) {

          islogin = true;
          return true; // PIN is correct
        } else {
          showSnackBar(context, "Invalid PIN");
        }
        return false;
      } else {
        showSnackBar(context, "Customer not found");
      }
      return false;
    } catch (e) {
      print('Error verifying customer: $e');
      return false; // Return false if there is an error
    }
  }

  void loadData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = pref.getString('name')!;
    });
    ID = pref.getString('id')!;
    storedPin = pref.getString('pin')!;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Map<dynamic, dynamic> data = {}; //fill from argument passing

  @override
  Widget build(BuildContext context) {
    data =
    data.isEmpty ? ModalRoute.of(context)?.settings.arguments as Map : data;
    print(data);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/blue2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 50.0, sigmaX: 50.0),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.black,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                shadowColor: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: _formkey,
                    child: OverflowBar(
                      overflowSpacing: 20,
                      children: [
                        Text(
                          "Welcome $name", //name from database
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25.0,
                          ),
                        ),
                        Text(
                          "Enter your pin to login", //name from database
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 21.0,
                          ),
                        ),
                        TextFormField(
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 22.0,
                          ),
                          controller: _password,
                          keyboardType: TextInputType.number,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'pin is empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(hintText: "Pin"),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                //authentication thru fingerprint
                                bool auth = await authentication(); //hardcoded
                                print("can authenticate: $auth");
                                if (auth) {
                                  Navigator.pushReplacementNamed(
                                      context, '/home',
                                      arguments: {'name': data['name']});
                                }
                              },
                              icon: Icon(Icons.fingerprint),
                              label: Text(
                                "Authenticate",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.0,
                                ),
                              )),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              if (_formkey.currentState!.validate()) {
                                await verifyCustomer(_password.text);
                              }
                              if (islogin) {
                                Navigator.pushReplacementNamed(context, '/home',
                                    arguments: {'name': data['name']});
                              }
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
