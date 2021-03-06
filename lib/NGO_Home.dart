import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ngo_donor_connect/SignIn.dart';
import 'package:ngo_donor_connect/StatementNGO.dart';
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NGO_Setup.dart';

class MyNGOh extends StatefulWidget {
  MyNGOh({Key key}) : super(key: key);

  @override
  _MyNGOh createState() => new _MyNGOh();
}

class _MyNGOh extends State<MyNGOh> {
  var _name;
  var _chip = 0;
  var user;

  void abc() {
    FirebaseDatabase.instance
        .reference()
        .child("NGO")
        .child(user.uid)
        .once()
        .then((value) async {
      _name = value.value["name"];
      List<dynamic> myKeys = value.value.keys.toList();
      if (myKeys.contains("amount")) {
        _chip = value.value["amount"];
      }
      setState(() {});
      var mypos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      FirebaseDatabase.instance
          .reference()
          .child("NGO")
          .child(user.uid)
          .update({"lat": mypos.latitude, "long": mypos.longitude});
    }).catchError((err) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MySignIn()),
      );
    });
  }

  Future<void> setData() async {
    user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user == null && prefs.getStringList("Data") == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MySignIn()),
      );
    } else if (user == null) {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: prefs.getStringList("Data")[0],
              password: prefs.getStringList("Data")[1])
          .then((value) {
        user = value.user;
        abc();
      }).catchError((err) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MySignIn()),
        );
      });
    } else {
      abc();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setData();
    });
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(
              "Hello,\n" + ReCase(_name.toString()).titleCase,
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),
            Padding(padding: EdgeInsets.only(top: 70.0)),
            new Text(
              "Donation Received :\nRs. " + _chip.toString(),
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),
          ]),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              disabledColor: Colors.green,
              onPressed: null,
            ),
            IconButton(
              icon: Icon(Icons.request_page_sharp),
              disabledColor: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyNGOStatement()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              disabledColor: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyNGO_Set()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                FirebaseAuth.instance.signOut().then((value) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MySignIn()),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
