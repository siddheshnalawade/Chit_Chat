import 'package:Chat_App/profilepic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';

import 'chat.dart';

class UserHomePage extends StatefulWidget {
  UserHomePage({Key key}) : super(key: key);

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  var events;
  var logitude;
  var latitude;
  var address;
  FirebaseFirestore firebaseConnection = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  /*void getLocation() async {
    var email = auth.currentUser.email.toString();
    var geolocator = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = geolocator.latitude;
      logitude = geolocator.longitude;
    });
    var cordinates = Coordinates(latitude, logitude);
    var add = await Geocoder.local.findAddressesFromCoordinates(cordinates);
    setState(() {
      address = add.first.addressLine;
      firebaseConnection.collection('users').doc(email).set({
        'location': address,
      }, SetOptions(merge: true));
    });
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          title: Text('Chit Chat'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/profile");
              },
              icon: Icon(Icons.account_circle_sharp),
            ),
            IconButton(
              onPressed: () {
                auth.signOut();
                Navigator.popAndPushNamed(context, "/login");
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
            builder: (context, snapshot) {
              try {
                if (snapshot.data == null)
                  return CircularProgressIndicator();
                else {
                  events = snapshot.data.docs;
                }
              } catch (e) {
                print(e);
              }

              return Container(
                child: ListView.builder(
                  itemCount: (events.length != null) ? events.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 0,
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration:
                                    Duration(milliseconds: 1500),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ProfilePicture(friend: events[index]),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return Align(
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          child: Hero(
                            tag: events[index].get('email').toString(),
                            child: Container(
                              child: events[index]
                                      .get('profilePic')
                                      .toString()
                                      .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 30,
                                      child: ClipOval(
                                        child: Image.network(events[index]
                                            .get('profilePic')
                                            .toString()),
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 30,
                                      child: ClipOval(
                                        child: Image.asset('images/images.png'),
                                      )),
                            ),
                          ),
                        ),
                        title: Text(events[index].get("Name")),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  Chat(friend: events[index])));
                        },
                      ),
                    );
                  },
                ),
              );
            },
            stream: firebaseConnection
                .collection("users")
                .where("email", isNotEqualTo: auth.currentUser.email.toString())
                .snapshots(),
          ),
        ),
      ),
    );
  }
}
