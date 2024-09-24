
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:email_otp/email_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bank_ease/pages/Loading.dart';
import 'package:auth_handler/auth_handler.dart';
import 'package:bank_ease/auth_method.dart';
import 'package:bank_ease/utils/util.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool showOtpField = false;
  bool verifyOtpField = false;
  TextEditingController otpController = TextEditingController();
  TextEditingController otpverifyController = TextEditingController();
  TextEditingController setpinController = TextEditingController();
  TextEditingController confirmsetpinController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController customerIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Future <String?> loginCustomer(String customerId) async {
    try{
      var res = await AuthMethod().getCustomer(customerId);
      if(res != null){
        return res['email'];
      }else{
        print("user not found");
      }
    }
    catch(e){
      print(e.toString());
    }
  }
  Future<void> setPin()async{

    try{
      Map<dynamic,dynamic>? customer =  await AuthMethod().savepin(customerIdController.text,setpinController.text);
      if(customer != null){
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('name', customer['name']);
        pref.setString('id', customer['customerID']);
        showSnackBar(context, "Customer Updated Succssefully..");
        await AuthMethod().SetTransactionPin(customer['customerID'],setpinController.text);
        Navigator.pushReplacementNamed(context,'/login_page',arguments: {'id': customer['name'] , 'name':customer['customerID']});
      }else{
        showSnackBar(context, "Customer not Found..");
      }
    }catch(e){
      print(e.toString());
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    otpverifyController.dispose();
    setpinController.dispose();
    confirmsetpinController.dispose();
    emailController.dispose();
    customerIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize the package

    /*authHandler.config(
      senderEmail: "bharatnationalbank@gmail.com",
      senderName: "BHARAT NATIONAL BANK",
      otpLength: 4,
    );*/

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Sign Up')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Set the GlobalKey<FormState> for form validation
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {return 'Email is required';
                    }
                    // Add more complex email validation logic here if needed
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: customerIdController,
                  decoration: InputDecoration(labelText: 'Customer ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Customer ID is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed:() async {
                    if (_formKey.currentState!.validate()) {
                      final email = await loginCustomer(customerIdController.text);
                      if (email == emailController.text.trim()) {
                        setState(() {
                          verifyOtpField = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Enter correct details."),
                        ));
                        // Implement OTP verification and signup logic here
                        // You can compare otpController.text with the expected OTP
                      }
                    }
                  },
                  child: Text("Set PIN",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),),
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 16.0),
                if (verifyOtpField)
                  TextFormField(
                    controller: setpinController,
                    decoration: InputDecoration(labelText: 'Set PIN'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Set PIN is required';
                      }
                      // Add PIN format validation here if needed
                      return null;
                    },
                  ),
                SizedBox(height: 16.0),
                if (verifyOtpField)
                  TextFormField(
                    controller: confirmsetpinController,
                    decoration: InputDecoration(labelText: 'Confirm PIN'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm PIN is required';
                      }
                      if (value != setpinController.text) {
                        return 'PINs do not match';
                      }
                      return null;
                    },
                  ),
                SizedBox(
                  height: 16,
                ),
                if (verifyOtpField)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Form is valid, proceed with signup
                        // Implement signup logic here
                        if(setpinController.text == confirmsetpinController.text)
                        {
                          setPin();

                        }
                        else
                        {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Invalid PIN"),
                          ));
                        }
                      }
                    },
                    child: Text("Sign Up",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

