import 'package:flutter/material.dart';
import 'dart:io';
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    // Hardcoded user data
    final String fullName = "Mahek Garala";
    final String mobileNo = "8799188894";
    final String dob = "07/08/2005";
    final String address = "123 Main Street, Junagadh";
    final String email = "mahekgarala808@gmail.com";
    final String imageUrl = "blue1.jpg"; // Your image file in assets/images/

    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      body: SafeArea(
        minimum: const EdgeInsets.only(top: 100),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/$imageUrl'),
            ),
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 40.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Pacifico",
              ),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
              ),
            ),
            InfoCard(
              text: mobileNo,
              icon: Icons.phone,
              onPressed: () {},
            ),

            InfoCard(
              text: dob,
              icon: Icons.cake,
              onPressed: () {},
            ),

            InfoCard(
              text: address,
              icon: Icons.location_city,
              onPressed: () {},
            ),

            InfoCard(
              text: email,
              icon: Icons.email,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
// class InfoCard extends StatelessWidget {
//   final String text;
//   final IconData icon;
//   final VoidCallback onPressed;
//
//   InfoCard({required this.text, required this.icon, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.teal,
//         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       onPressed: onPressed,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: Colors.teal,
//         ),
//         title: Text(
//           text,
//           style: const TextStyle(
//             color: Colors.teal,
//             fontSize: 20,
//             fontFamily: "Source Sans Pro",
//           ),
//         ),
//       ),
//
//     );
//   }
// }

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onPressed;

  InfoCard({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.teal,
          ),
          title: Text(
            text,
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 20,
              fontFamily: "Source Sans Pro",
            ),
          ),
        ),
      ),
    );
  }
}

// void main() {
//   runApp(Profile());
// }
