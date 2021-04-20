import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Chat extends StatefulWidget {
  var friend;

  Chat({Key key, @required this.friend}) : super(key: key);

  @override
  _ChatState createState() => _ChatState(friend);
}

class _ChatState extends State<Chat> {
  var friend;
  var controller = TextEditingController();
  var scroll_controller = ScrollController();
  var message;
  var firebaseConnection = FirebaseFirestore.instance;
  var auth = FirebaseAuth.instance;
  var events;
  var location;

  String getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  void sendMessage(String message) {
    FocusScope.of(context).unfocus();
    var id = getChatRoomId(
        auth.currentUser.email.toString(), friend.get("email").toString());
    firebaseConnection.collection("chats").doc(id).collection("messages").add({
      'message': message,
      'createdAt': DateTime.now(),
      'sender': auth.currentUser.email.toString(),
    });

    controller.clear();
  }

  _ChatState(this.friend);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          leading: Container(
            margin: EdgeInsets.only(left: 5),
            padding: EdgeInsets.all(2),
            child: friend.get('profilePic').toString().isEmpty
                ? CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: ClipOval(
                      child: Image.asset('images/images.png'),
                    ))
                : CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: ClipOval(
                      child: Image.network(friend.get('profilePic')),
                    ),
                    radius: 50,
                  ),
          ),
          title: Text(friend.get("Name")),
          actions: [
            IconButton(
                onPressed: () {
                  Toast.show(friend.get('location'), context,
                      duration: 5, gravity: Toast.CENTER);
                },
                icon: Icon(Icons.my_location_rounded)),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                  child: StreamBuilder<QuerySnapshot>(
                builder: (context, snapshot) {
                  try {
                    if (snapshot.data == null)
                      return Center(child: Text("Say Hello.."));
                    else {
                      events = snapshot.data.docs;
                    }
                  } catch (e) {
                    print(e);
                  }

                  return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      reverse: true,
                      itemCount: (events.length != null) ? events.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          padding: EdgeInsets.only(
                              left: 14, right: 14, top: 10, bottom: 10),
                          width: 500,
                          child: Align(
                              alignment:
                                  events[index].get("sender").toString() ==
                                          auth.currentUser.email.toString()
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                              child: Card(
                                borderOnForeground: true,
                                margin: EdgeInsets.all(0),
                                elevation: 1,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  color:
                                      events[index].get("sender").toString() ==
                                              auth.currentUser.email.toString()
                                          ? Colors.grey.shade200
                                          : Colors.blue[200],
                                  child: Text(
                                    events[index].get("message"),
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              )),
                        );
                      });
                },
                stream: firebaseConnection
                    .collection('chats')
                    .doc(getChatRoomId(auth.currentUser.email.toString(),
                        friend.get("email").toString()))
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
              )),
            ),
            Row(
              verticalDirection: VerticalDirection.down,
              children: [
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.all(2),
                    child: TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey,
                        labelText: "Type your massage",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 0),
                          gapPadding: 10,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onChanged: (value) {
                        message = value;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                  width: 60,
                  height: 50,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black),
                  //color: Colors.blue,
                  child: IconButton(
                      onPressed: () {
                        if (message != null) {
                          sendMessage(message);
                        }
                      },
                      icon: Icon(Icons.send),
                      color: Colors.white),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
