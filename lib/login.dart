import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseFirestore firebaseConnection = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;
  bool loginState = false;
  var signIn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //checking is currently user is loged in or not
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
        Navigator.pushNamedAndRemoveUntil(
            context, '/userhome', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chit Chat"),
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ModalProgressHUD(
          inAsyncCall: loginState,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Login Here.',
                      style: TextStyle(fontSize: 20),
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
                        onPressed: () async {
                          if (mounted) {
                            setState(() {
                              loginState = true;
                            });
                          }
                          try {
                            signIn = await auth.signInWithEmailAndPassword(
                                email: email, password: password);
                            if (signIn != null) {
                              if (mounted) {
                                setState(() {
                                  loginState = false;
                                });
                              }

                              Toast.show('Login Successfully.', context,
                                  gravity: Toast.CENTER);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, "/userhome", (route) => false);
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              Toast.show('No user with this email', context,
                                  gravity: Toast.CENTER);
                              if (mounted) {
                                setState(() {
                                  loginState = false;
                                });
                              }
                            } else if (e.code == 'wrong-password') {
                              Toast.show(
                                'Wrong Password',
                                context,
                                backgroundColor: Colors.indigo,
                                gravity: Toast.CENTER,
                              );
                              if (mounted) {
                                setState(() {
                                  loginState = false;
                                });
                              }
                            }
                          }
                        },
                        child: Text(
                          "Login",
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
                        Text('Do not have an account?'),
                        FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/register");
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(color: Colors.blue),
                            )),
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
