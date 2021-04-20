import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String imagelink;
  var image;
  var name = 'user';
  ImagePicker imagePicker = ImagePicker();
  final FirebaseAuth auth = FirebaseAuth.instance;
  var firebaseConnection = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    firebaseConnection
        .collection('users')
        .doc(auth.currentUser.email)
        .snapshots()
        .listen((event) {
      setState(() {
        imagelink = event.get('profilePic');
        name = event.get('Name');
      });
    });
    print(imagelink);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text('Profile'),
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.all(10),
                  child: imagelink == null
                      ? CircleAvatar(
                          child: ClipOval(
                            child: Image.asset('images/images.png'),
                          ),
                          radius: 100,
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.network(imagelink),
                          ),
                          radius: 100,
                        )),
              RaisedButton(
                onPressed: () async {
                  image =
                      (await imagePicker.getImage(source: ImageSource.gallery));

                  var file = File(image.path);
                  firebase_storage.FirebaseStorage storage =
                      firebase_storage.FirebaseStorage.instance;

                  var ref = storage
                      .ref()
                      .child('ProfilePics')
                      .child(auth.currentUser.email);
                  if (file != null) {
                    Toast.show('Uploading', context, duration: 3);
                    ref.putFile(file).whenComplete(() async {
                      var link = await ref.getDownloadURL();

                      setState(() {
                        imagelink = link;
                      });
                      Toast.show(
                        'Profile Picture Uploaded',
                        context,
                        gravity: Toast.BOTTOM,
                        duration: 3,
                      );
                      print('upload');
                      firebaseConnection
                          .collection('users')
                          .doc(auth.currentUser.email)
                          .set({
                        'profilePic': imagelink,
                      }, SetOptions(merge: true));
                    });
                  }
                },
                child: Text('Upload profile pic'),
              ),
              RaisedButton(
                onPressed: () async {
                  var geolocator = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high);
                  print(geolocator.latitude.toString());
                  print(geolocator.longitude.toString());
                  var latitude = geolocator.latitude;
                  var longitude = geolocator.longitude;
                  var cordinates = Coordinates(latitude, longitude);
                  var address = await Geocoder.local
                      .findAddressesFromCoordinates(cordinates);
                  print(address.first.featureName);
                  print(address.first.addressLine);
                  Toast.show(address.first.addressLine, context, duration: 5);
                },
                child: Text('Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
