import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';

class QuestPage extends StatefulWidget {
  QuestPage({Key? key}) : super(key: key);

  @override
  _QuestPageState createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference badge =
        FirebaseFirestore.instance.collection("travel_badges");
    return Scaffold(
      drawer: LeDrawer(),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              FirebaseService service = new FirebaseService();
              await service.signOutFromGoogle();
              Navigator.pushReplacementNamed(context, Constants.signInNavigate);
            },
          )
        ],
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.blue),
        title: Text("Home"),
      ),
      body: Center(
        /*  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(user!.email!),
              Text(user!.displayName!),
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoURL!),
                radius: 20,
              )
            ],
          ), */
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
                flex: 1,
                child: Card(
                  child: Center(
                      child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('travel_badges')
                        .doc()
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print(snapshot.error.toString());
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading");
                      }

                      return new ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            title: Text("Available Badges",
                                textAlign: TextAlign.center),
                          )
                        ],
                      );
                    },
                  )),
                )),
            Flexible(
              flex: 3,
              child: Center(
                  child: StreamBuilder<QuerySnapshot>(
                stream: badge.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  return new ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return new Card(
                          child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: NetworkImage(
                                document.data()!['badge_icon'],
                              ),
                              radius: 30,
                            ),
                            title: new Text(
                              document.data()!['badge_name'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: new Text(
                              document.data()!['badge_desc'],
                              textAlign: TextAlign.justify,
                            ),
                            isThreeLine: true,
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                          title: Text(
                                            "Requirements",
                                          ),
                                          content: Column(
                                            children: [
                                              Text(
                                                document.data()!['badge_req'],
                                              )
                                            ],
                                          ));
                                    });
                              },
                              child: Text(
                                "Requirements",
                              ))
                        ],
                      ));
                    }).toList(),
                  );
                },
              )),
            )
          ],
        ),
      ),
      /* floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) =>
                    AlertDialog(scrollable: true, content: _AddBadgeForm()));
          },
          label: Text("Add Badges")), */
    );
  }

  // le Rows For The Profile
  List<DataRow> _createRows(QuerySnapshot snapshot) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      //  GeoPoint geoPoint = document.data()!['junction'];
      //    double lat = geoPoint.latitude;
      //   double lng = geoPoint.longitude;

      return new DataRow(cells: [
        DataCell(
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage:
                NetworkImage(document.data()!['badge_icon'].toString()),
            radius: 20,
          ),
          //   "$lat,$lng",
        ),
        DataCell(Text(
          document.data()!['badge_name'].toString(),
          textAlign: TextAlign.center,
        )),
        DataCell(ElevatedButton(
          onPressed: () async {
            return showDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                      title: Text(document.data()!['badge_name']),
                      content: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                                document.data()!['badge_icon'].toString()),
                            radius: 60,
                          ),
                          Text(
                            "Awarded for:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(document.data()!['badge_desc']),
                          Text(
                            "\nRequirement:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            document.data()!['badge_req'],
                          )
                        ],
                      ));
                });
          },
          child: Text(
            "View",
          ),
        )),
      ]);
    }).toList();

    return newList;
  }
}

// Add Badges Form

class _AddBadgeForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddBadgeFormState();
}

class _AddBadgeFormState extends State<_AddBadgeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _badgename = TextEditingController();
  final TextEditingController _badgedetails = TextEditingController();
  final TextEditingController _badgeicon = TextEditingController();
  final TextEditingController _badgerequirements = TextEditingController();

  // Navigates to a new page
  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context) /*!*/ .push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _badgename,
                  decoration: const InputDecoration(labelText: 'Badge Name'),
                  validator: (String? value) {
                    if (value!.isEmpty) return 'Please enter some text';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _badgedetails,
                  decoration:
                      const InputDecoration(labelText: 'Badge Description'),
                  validator: (String? value) {
                    if (value!.isEmpty) return 'Please enter some text';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _badgerequirements,
                  decoration:
                      const InputDecoration(labelText: 'Badge Requirements'),
                  validator: (String? value) {
                    if (value!.isEmpty) return 'Please enter some text';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _badgeicon,
                  decoration: const InputDecoration(labelText: 'Badge Link'),
                  validator: (String? value) {
                    if (value!.isEmpty) return 'Please enter some text';
                    return null;
                  },
                ),
                Container(
                    padding: const EdgeInsets.only(top: 16),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: Text("Add Badge"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.cyan,
                        onPrimary: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 5,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          addBadge();
                          _pushPage(context, QuestPage());
                          //  print(_chosenValue);
                        }
                      },
                    )),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _badgename.dispose();
    _badgeicon.dispose();
    _badgedetails.dispose();
    _badgerequirements.dispose();
    super.dispose();
  }

  Future<void> addBadge() async {
    CollectionReference clubs =
        FirebaseFirestore.instance.collection('travel_badges');
    // Call the user's CollectionReference to add a new club
    return clubs
        .doc()
        .set({
          'badge_name': _badgename.text,
          'badge_desc': _badgedetails.text,
          'badge_req': _badgerequirements.text,
          'badge_icon': _badgeicon.text,
        })
        .then((value) => print("Club Added"))
        .catchError((error) => print("Failed to add user in db: $error"));
  }
}

// Drawer Class

class LeDrawer extends StatelessWidget {
  // navigates to a new page
  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context) /*!*/ .push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Text("Eve Travel"),
                Text("QR Code Right Here"),
              ],
            ),
            decoration: BoxDecoration(
              color: HexColor('#F7F7F7'),
            ),
          ),
          Container(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Profile"),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, Constants.homeNavigate, (route) => false);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text("News"),
                  onTap: () {
                    //     _pushPage(context, SCQuestPage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.travel_explore),
                  title: Text("Travel Plan"),
                  onTap: () {
                    //     _pushPage(context, SCQuestPage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.approval),
                  title: Text("Quests"),
                  onTap: () {
                    //    _pushPage(context, FeedbackPage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.how_to_vote_outlined),
                  title: Text("History"),
                  onTap: () {
                    //     _pushPage(context, VotePage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.supervised_user_circle_rounded),
                  title: Text("Help"),
                  onTap: () {
                    //   _pushPage(context, SCUserManagement());
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
