import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth_handler/auth_handler.dart';

class Signup extends StatefulWidget{
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

  final _formGlobalKey = GlobalKey<FormState>();
// loginCustomer method
  void savepin() async{
    try{
      final customerId = customerIdController.text.trim();
      final pin = setpinController.text.trim();
      final customerName = "Mahek"; // from database maybe
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('name', customerName);
      pref.setString('id', customerId);

      String name = pref.getString('name')!;
      String ID = pref.getString('id')!;

      print(name);
      print(ID);
      //send name also from database
      Navigator.pushReplacementNamed(context,'/login_page',arguments: {'id': customerId , 'name':customerName});


    }catch(error){
      print('Error : ${error.toString()}');
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
        title: Center(
          child:Text('Sign Up')
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child:Form( //for validate and manage
            key: _formGlobalKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Email is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0) ,
                TextFormField(
                  controller: customerIdController,
                  decoration: InputDecoration(labelText: 'Customer ID'),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Customer ID is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                    onPressed: () {
                      if(_formGlobalKey.currentState!.validate()){
                        print('email :');
                        final mail = emailController.text.trim();
                        //customer id check krvu , its like acc no.
                        if(mail == 'mahekgarala808@gmail.com'){
                          print("allow pin to show");
                          setState(() {
                            verifyOtpField = true ;
                          });
                        }else{
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Enter Correct details."),
                          ));
                        }
                      }
                    },
                    child: const Text('Set PIN'),
                ),
                SizedBox(height: 16.0),
                if(verifyOtpField)
                  TextFormField(
                    controller: setpinController,
                    decoration: InputDecoration(labelText: 'Set PIN'),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return 'Set PIN is required';
                      }
                      //Add pin validation if needed
                      return null;
                    },
                  ),
                SizedBox(height: 16.0),
                if(verifyOtpField)
                  TextFormField(
                    controller: confirmsetpinController,
                    decoration: InputDecoration(labelText: 'Confirm PIN'),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return 'Confirm PIN is required';
                      }
                      if(value != setpinController.text){
                        return "PINs do not match";
                      }
                      return null;
                    },
                  ),
                if(verifyOtpField)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: (){
                      if(_formGlobalKey.currentState!.validate()){
                        if(setpinController.text == confirmsetpinController.text){
                          //save in database
                          savepin();
                        }
                        else{
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Invalid Pin"),
                          ));
                        }
                      }
                    },
                    child: Text('Sign Up'),
                  ),
              ],
            ),
          )
        ),
      ),
    );
  }
  
}



