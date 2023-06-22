import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracer/resusable_widgets/resusable_widget.dart';
import 'package:expense_tracer/screens/addName_screen.dart';
import 'package:expense_tracer/screens/home_screen.dart';
import 'package:expense_tracer/screens/reset_password.dart';
import 'package:expense_tracer/screens/signup_screen.dart';
import 'package:expense_tracer/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracer/screens/progressIndicator_screen.dart';
import 'package:expense_tracer/controllers/db_helper.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  DbHelper dbHelper = DbHelper();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

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

  Future<void> _validatePassword() async {
    String email = _emailTextController.text;
    String password = _passwordTextController.text;

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _showToast(context, 'Login successful');
      // Perform further actions for successful login
      // For example, navigate to a new screen
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _showToast(context, 'Incorrect email or password');
      } else {
        _showToast(context, 'Error: ${e.message}');
      }
    } catch (e) {
      _showToast(context, 'Error: ${e.toString()}');
    }

    if (password.isNotEmpty && email.isNotEmpty) {
      dbHelper.clearUserNameFromPreferences();
      FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailTextController.text,
              password: _passwordTextController.text)
          .then((value) {
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
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  logoWidget("assets/images/logo.png"),
                  const SizedBox(
                    height: 30,
                  ),
                  reusableTextField("Enter UserName", Icons.person_outline, false,
                      _emailTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reusableTextField("Enter Password", Icons.lock_outline, true,
                      _passwordTextController),
                  const SizedBox(
                    height: 5,
                  ),
                  forgetPassword(context),
                  firebaseUIButton(context, "Sign In", () {
                    if (_emailTextController.text.isEmpty ||
                        _passwordTextController.text.isEmpty) {
                      _showToast(context, 'Please fill in the details');
                    } else if (!_emailTextController.text.isEmpty ||
                        !_passwordTextController.text.isEmpty) {
                      _validatePassword();
                    } else {}
                  }),
                  signUpOption()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPassword())),
      ),
    );
  }
}
