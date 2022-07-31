import 'package:flutter/material.dart';
import 'package:starr/screens/home.dart';
import 'package:starr/services/globals.dart';

class IndexScreen extends StatefulWidget {
  @override
  IndexScreenState createState() => IndexScreenState();
}

class IndexScreenState extends State<IndexScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializeApp(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                body: Center(
                    child: Image.asset("assets/images/logo.png", width: 96)));
          } else {
            return HomeScreen();
          }
        });
  }
}
