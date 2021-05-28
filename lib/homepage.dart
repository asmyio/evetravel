import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference rider =
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
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user!.photoURL!),
                              radius: 35,
                            ),
                            title: new Text(
                              user!.displayName!,
                              //textAlign: TextAlign.center,
                            ),
                            subtitle: Text(
                              user!.email!,
                              // textAlign: TextAlign.center,
                            ),
                          ),
                          Divider(),
                          ListTile(
                            title: Text("Badges Earned",
                                textAlign: TextAlign.center),
                          )
                        ],
                      );
                    },
                  )),
                )),
            Flexible(
              flex: 3,
              child: StreamBuilder<QuerySnapshot>(
                stream: rider.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  return new Container(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(columns: [
                            DataColumn(
                                label: Text(
                              'Badges',
                              textAlign: TextAlign.center,
                            )),
                            DataColumn(
                                label: Text(
                              'View',
                              textAlign: TextAlign.center,
                            ))
                          ], rows: _createRows(snapshot.data!)),
                        ),
                      ));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // le Rows For The Profile
  List<DataRow> _createRows(QuerySnapshot snapshot) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      //  GeoPoint geoPoint = document.data()!['junction'];
      //    double lat = geoPoint.latitude;
      //   double lng = geoPoint.longitude;

      return new DataRow(cells: [
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
                    //     _pushPage(context, SCHomePage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.travel_explore),
                  title: Text("Travel Plan"),
                  onTap: () {
                    //     _pushPage(context, SCHomePage());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.approval),
                  title: Text("Quests"),
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, Constants.questNavigate, (route) => false);
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
