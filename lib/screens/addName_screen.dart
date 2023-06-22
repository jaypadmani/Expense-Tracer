import 'package:expense_tracer/controllers/db_helper.dart';
import 'package:expense_tracer/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddName extends StatefulWidget {

  @override
  _AddNameState createState() => _AddNameState();
}

class _AddNameState extends State<AddName> {

  String name = "";

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
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
           backgroundColor: Color(0xFF3F51B5),
        ),
        body: Padding(
          padding: const EdgeInsets.all(
            12.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                "What should we Call You ?",
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
              const SizedBox(
                height: 20.0,
              ),
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
                    backgroundColor: MaterialStateProperty.all<Color> (Color(0xFF3F51B5)),
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
                        "Let's Start",
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
        ),
      ),
    );
  }
}
