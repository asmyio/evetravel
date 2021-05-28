import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    User? result = FirebaseAuth.instance.currentUser;
    return Scaffold(
        backgroundColor: Constants.kPrimaryColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: Constants.statusBarColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset("assets/images/main-img.png"),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text: Constants.textIntro,
                          style: TextStyle(
                            color: Constants.kBlackColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 30.0,
                          )),
                      TextSpan(
                          text: Constants.textIntroDesc1,
                          style: TextStyle(
                              color: Constants.kDarkBlueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0)),
                      TextSpan(
                          text: Constants.textIntroDesc2,
                          style: TextStyle(
                              color: Constants.kBlackColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0)),
                    ])),
                SizedBox(height: size.height * 0.01),
                SizedBox(height: size.height * 0.1),
                SizedBox(
                  width: size.width * 0.8,
                  child: OutlinedButton(
                    onPressed: () {
                      result == null
                          ? Navigator.pushNamed(
                              context, Constants.signInNavigate)
                          : Navigator.pushReplacementNamed(
                              context, Constants.homeNavigate);
                    },
                    child: Text(Constants.textStart),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Constants.kPrimaryColor),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.kBlackColor),
                        side: MaterialStateProperty.all<BorderSide>(
                            BorderSide.none)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
