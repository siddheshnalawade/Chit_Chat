import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  FirebaseFirestore firebaseConnection = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;
  var username;
  bool registerState = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        title: Text("Chit Chat"),
      ),
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: registerState,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Register Here.',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        username = value;
                      },
                      validator: (email) {
                        if (username.isEmpty) {
                          return "please Enter Name";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter First and Last Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (email) {
                        if (email.isEmpty) {
                          return "please Enter Email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      obscureText: true,
                      obscuringCharacter: '*',
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (password) {
                        if (password.isEmpty) {
                          return "please Enter Password";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20)),
                      child: FlatButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              registerState = true;
                            });
                          }
                          try {
                            var user = auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                            if (user != null) {
                              //Adding details of user to firebase
                              print(email);
                              firebaseConnection
                                  .collection('users')
                                  .doc(email)
                                  .set({
                                    'email': email,
                                    'Name': username,
                                    'uid': auth.currentUser.uid,
                                    'profilePic': '',
                                  })
                                  .then((value) => {print("written data")})
                                  .onError((error, stackTrace) => {
                                        print(error),
                                      });
                              Toast.show('Registration Successful', context,
                                  gravity: Toast.CENTER);
                              if (mounted) {
                                setState(() {
                                  registerState = false;
                                });
                              }
                              Navigator.popAndPushNamed(context, "/userhome");
                              Toast.show('Registered Successfully', context,
                                  gravity: Toast.CENTER);
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              Toast.show(
                                  'The password provided is too weak.', context,
                                  gravity: Toast.CENTER);
                              if (mounted) {
                                setState(() {
                                  registerState = false;
                                });
                              }
                            } else if (e.code == 'email-already-in-use') {
                              Toast.show(
                                  'The account already exists for that email.',
                                  context,
                                  gravity: Toast.CENTER);
                              if (mounted) {
                                setState(() {
                                  registerState = false;
                                });
                              }
                            }
                          } catch (e) {
                            Toast.show(e.toString(), context);
                          }
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?'),
                        FlatButton(
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, "/login");
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
