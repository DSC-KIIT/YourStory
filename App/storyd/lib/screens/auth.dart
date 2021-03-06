import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storyd/global_values.dart';
import 'package:storyd/screens/home.dart';
import 'package:storyd/screens/landing.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _handleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount account = await googleSignIn.signIn();

    if (account == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await account.authentication;

    // get the credentials to (access / id token)
    // to sign in via Firebase Authentication
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    DocumentSnapshot userDataSnapshot = await (Firestore.instance
        .collection("user-data")
        .document(user.uid)
        .get());

    if (!userDataSnapshot.exists) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => LandingPage(),
        ),
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(isLoggedInPrefKey, true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => MyHomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: "storyd-splash",
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Material(
                    child: Text(
                      "Storyd",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 35,
                        fontFamily: "CircularStd",
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.13,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Image.asset("assets/storyd-splash.png"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Welcome back",
                  style: TextStyle(
                    fontFamily: "CircularStd",
                    fontSize: 45,
                    color: Colors.orangeAccent,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "to ",
                      style: TextStyle(
                        fontFamily: "CircularStd",
                        fontSize: 45,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    Text(
                      "Storyd",
                      style: TextStyle(
                        fontFamily: "CircularStd",
                        fontSize: 45,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                )
              ],
            ),
            Expanded(
              child: Center(
                child: ButtonTheme(
                  height: 50,
                  minWidth: 220,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  buttonColor: Colors.black12,
                  child: RaisedButton(
                    elevation: 0,
                    highlightElevation: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset("assets/googleLogo.png"),
                        ),
                        SizedBox(width: 7),
                        Text(
                          "Connect with Google",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "CircularStd",
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    onPressed: _handleSignIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
