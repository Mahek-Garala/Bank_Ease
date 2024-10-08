import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading>{

  void redirectToLoginpage() async {

    print("hi");
    SharedPreferences pref = await SharedPreferences.getInstance();
    //Navigator.pushNamed(context,'/login_page');
    print(pref);

    String name1 = pref.getString('name') ?? '';
    print(name1);
    if (name1 == '') {
      Navigator.pushReplacementNamed(context, '/sign_up');
      //When we submit for account then pref.serString from database
    } else {
      //For everyother time loggin
      print("else");
      String ID = pref.getString('id')!;
      print(ID);
      Navigator.pushReplacementNamed(context, '/login_page',
          arguments: {'name': name1});
    }
  }

  @override
  void initState(){
    super.initState();
    print("init");
    redirectToLoginpage();
  }
  @override
  Widget build(BuildContext context){
    return const Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: SpinKitFadingCube(
          color: Colors.white,
          size:80.0,
        ),
      ),
    );
  }
}
