import 'package:evetravel/quests.dart';
import 'homepage.dart';
import 'sign_in.dart';
import 'welcome_page.dart';
import 'quests.dart';
import 'package:flutter/material.dart';

class Navigate {
  static Map<String, Widget Function(BuildContext)> routes = {
    '/': (context) => WelcomePage(),
    '/sign-in': (context) => SignInPage(),
    '/home': (context) => HomePage(),
    '/quest': (context) => QuestPage(),
  };
}
