import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bank_ease/models/customers.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Customer;
    //database ma add kari de
    final baseurl = "assets/images/";
    final fullurl = data.url;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[800]!, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 30),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/images/$fullurl'),
                ),
                SizedBox(height: 15),
                Text(
                  data.name.toString(),
                  style: TextStyle(
                    fontSize: 36.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Pacifico",
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Customer Profile',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white70,
                    fontFamily: "Source Sans Pro",
                  ),
                ),
                SizedBox(height: 20),
                Divider(
                  color: Colors.white,
                  thickness: 1.5,
                  indent: 30,
                  endIndent: 30,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      InfoCard(text: data.mobileNo.toString(), icon: Icons.phone),
                      InfoCard(text: data.dob.toString(), icon: Icons.cake),
                      InfoCard(text: data.address.toString(), icon: Icons.location_on),
                      InfoCard(text: data.email.toString(), icon: Icons.email),
                    ],
                  ),
                ),
                SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;

  InfoCard({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.blueGrey,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: "Source Sans Pro",
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Profile(),
  ));
}
