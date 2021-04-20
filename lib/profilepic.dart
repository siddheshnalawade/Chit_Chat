import 'package:flutter/material.dart';

class ProfilePicture extends StatefulWidget {
  var friend;
  ProfilePicture({Key key, @required this.friend}) : super(key: key);

  @override
  _ProfilePictureState createState() => _ProfilePictureState(friend);
}

class _ProfilePictureState extends State<ProfilePicture> {
  var friend;
  _ProfilePictureState(this.friend);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text(friend.get('Name')),
          backgroundColor: Colors.black,
        ),
        body: Container(
          color: Colors.black,
          child: Hero(
            tag: friend.get('email').toString(),
            child: Center(
              child: Container(
                child: friend.get('profilePic').toString().isNotEmpty
                    ? Container(
                        child:
                            Image.network(friend.get('profilePic').toString()),
                      )
                    : Container(
                        child: Image.asset('images/images.png'),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
