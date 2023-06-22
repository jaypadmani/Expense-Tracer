import 'package:expense_tracer/controllers/db_helper.dart';
import 'home_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracer/screens/signin_screen.dart';
import 'package:expense_tracer/resusable_widgets/confirm_dialog.dart';
class SettingScreen extends StatefulWidget {

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  DbHelper dbHelper = DbHelper();

  String name = "";

  bool darkModeEnabled = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF3F51B5),
        actions: [

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  child: Image.asset(
                    "assets/images/logo1.png",
                    width: 64.0,
                    height: 64.0,
                  ),
                ),
                const Divider(
                  thickness: 2,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  "Rename Your Name",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Your Name",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                    maxLength: 12,
                    onChanged: (val) {
                      name = val;
                    },
                  ),
                ),
                //
                const SizedBox(
                  height: 20.0,
                ),
                //
                SizedBox(
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (name.isEmpty) {
                        _showToast(context, 'Please Enter a Name');
                      } else {
                        DbHelper dbHelper = DbHelper();
                        await dbHelper.addName(name);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>  HomeScreen(),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF3F51B5)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ),
                        ),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Icon(
                          Icons.arrow_right_alt,
                          size: 24.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            const Divider(
              thickness: 2,
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                height: 45,
                child: TextButton(
                  onPressed: () async{
                    bool? answer = await showConfirmDialog(
                        context, 'WARNING', 'All stored data will be deleted if you log out of your account. Do you want to continue?'
                    );
                    if (answer != null && answer) {
                      dbHelper.cleanData();
                      FirebaseAuth.instance.signOut().then((value) {
                        print("Signed Out");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  SignInScreen()));
                      });
                    }
                    Navigator.pop(context);

                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
