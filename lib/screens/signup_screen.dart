import 'package:expense_tracer/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracer/resusable_widgets/resusable_widget.dart';
import 'package:expense_tracer/screens/addName_screen.dart';
import 'package:expense_tracer/screens/home_screen.dart';
import 'package:expense_tracer/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracer/screens/progressIndicator_screen.dart';
import 'package:expense_tracer/controllers/db_helper.dart';
import 'package:hive/hive.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  DbHelper dbHelper = DbHelper();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  void _showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  void _validatePassword() async {
    String password = _passwordTextController.text;
    String email = _emailTextController.text;

    if (password.isEmpty) {
      _showToast(context, 'Please fill in the password');
    } else if (password.length < 6 || password.length > 10) {
      _showToast(context, 'Password must be between 6 and 10 characters long');
    } else {
      dbHelper.clearUserNameFromPreferences();
      final UserCredential? userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailTextController.text,
              password: _passwordTextController.text)
          .then((value) {
        print("Created New Account");
        _showToast(context, "Account created successfully!");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ProgressIndicatorScreen()));
      }).onError((error, stackTrace) {
        print("Error ${error.toString()}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
            },
              child: Icon(Icons.arrow_back,
              size: 30,)),
          title: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter UserName", Icons.person_outline, false,
                      _userNameTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter Email Id", Icons.person_outline, false,
                      _emailTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter Password", Icons.lock_outlined, true,
                      _passwordTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  firebaseUIButton(context, "Sign Up", () {
                    if (_userNameTextController.text.isEmpty ||
                        _emailTextController.text.isEmpty ||
                        _passwordTextController.text.isEmpty) {
                      _showToast(context, "Please fill in the details");
                    } else if (!_passwordTextController.text.isEmpty) {
                      _validatePassword();
                    } else {}
                  })
                ],
              ),
            ))),
      ),
    );
  }
}
