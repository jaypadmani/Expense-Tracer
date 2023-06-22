import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracer/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracer/screens/addTransaction_screen.dart';
import 'package:expense_tracer/model/transaction_model.dart';
import 'package:expense_tracer/resusable_widgets/confirm_dialog.dart';
import 'package:expense_tracer/controllers/db_helper.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setting_screen.dart';


class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box box;
  late SharedPreferences preferences;
  DbHelper dbHelper = DbHelper();
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpense = 0;


  late final List<TransactionModel> transactionList;

  DateTime today = DateTime.now();
  DateTime now = DateTime.now();

  final FirebaseAuth auth = FirebaseAuth.instance;
  String? name;

  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  @override
  void initState() {
    super.initState();
    getPreference();
    box = Hive.box('money');
    fetch();
    loadName();
  }

  Future<void> loadName() async {
    String? storedName = await dbHelper.getName();
    setState(() {
      name = storedName;
    });
  }

  getPreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  getTotalBalance(List<TransactionModel> entiredata) {
    totalExpense = 0;
    totalIncome = 0;
    totalBalance = 0;

    for (TransactionModel data in entiredata) {
      if (data.date.month == today.month) {
        if (data.type == "Income") {
          totalBalance += data.amount;
          totalIncome += data.amount;
        } else {
          totalBalance -= data.amount;
          totalExpense += data.amount;
        }
      }
    }
  }

  Future<List<TransactionModel>> fetch() async {
    if (box.values.isEmpty) {
      return Future.value([]);
    } else {
      List<TransactionModel> items = [];
      box.toMap().values.forEach((element) {
        // print(element);
        items.add(
          TransactionModel(
            element['amount'] as int,
            element['note'],
            element['date'] as DateTime,
            element['type'],
          ),
        );
      });
      return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    String? email = user?.email;
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEEF1F2),
        appBar: AppBar(
          title: const Text('Home Page'),
          backgroundColor: const Color(0xFF3F51B5),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => const AddTransaction(),
                  ),
                )
                    .whenComplete(() {
                  setState(() {});
                });
              },
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ],
        ),
        drawer: SafeArea(
          child: Drawer(
            backgroundColor: const Color(0xFF3F51B5),
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3.8,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF3F51B5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/logo.png'),
                          radius: 50,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Welcome, $name",
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          email ?? 'No email found',
                          style:
                              const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 1.45,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.home,
                          weight: 8,
                          color: Colors.black,
                        ),
                        title: const Text(
                          'Home',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.add,
                          weight: 8,
                          color: Colors.black,
                        ),
                        title: const Text(
                          'Add Expense',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AddTransaction(),
                          ));
                        },
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.settings,
                          weight: 8,
                          color: Colors.black,
                        ),
                        title: const Text(
                          'Settings',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>  SettingScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2.5,
                          height: 45,
                          child: TextButton(
                            onPressed: () async {
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
                                          builder: (context) =>
                                           SignInScreen()));
                                });
                              }
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
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
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF3F51B5),
          onPressed: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => const AddTransaction(),
              ),
            )
                .whenComplete(() {
              setState(() {});
            });
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: const Icon(
            Icons.add,
            size: 32.0,
          ),
        ),
        body: FutureBuilder<List<TransactionModel>>(
          future: fetch(),
          builder: (BuildContext context,
              AsyncSnapshot<List<TransactionModel>> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error'),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Please add Your transactions!'),
                );
              }
              getTotalBalance(snapshot.data!);
              return ListView(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color(0xFF202021),
                          borderRadius: BorderRadius.all(Radius.circular(24.0))),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 8.0),
                      child: Column(
                        children: [
                          const Text(
                            "Total Balance",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22.0, color: Colors.white),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            "$totalBalance ₹ ",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26.0, color: Colors.white),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                cardIncome(totalIncome.toString()),
                                cardExpense(totalExpense.toString())
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(
                      12.0,
                    ),
                    child: Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 26.0,
                        //color: Colors.black87,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length + 1,
                      itemBuilder: (context, index) {
                        TransactionModel dataAtIndex;
                        try {
                          // dataAtIndex = snapshot.data![index];
                          dataAtIndex = snapshot.data![index];
                        } catch (e) {
                          // deleteAt deletes that key and value,
                          // hence makign it null here., as we still build on the length.
                          return Container();
                        }

                        if (dataAtIndex.type == "Income") {
                          return IncomeTile(dataAtIndex.amount, dataAtIndex.note,
                              dataAtIndex.date, index);
                        } else {
                          return expenseTile(dataAtIndex.amount, dataAtIndex.note,
                              dataAtIndex.date, index);
                        }
                      }),
                ],
              );
            } else {
              return const Center(
                child: Text("Error!"),
              );
            }
          },
        ),
      ),
    );
  }

  Widget cardIncome(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: const EdgeInsets.all(6.0),
          margin: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.arrow_upward,
            size: 28.0,
            color: Colors.green[700],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Income",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            Text(
              "$value ₹ ",
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget cardExpense(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: const EdgeInsets.all(6.0),
          margin: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.arrow_downward,
            size: 28.0,
            color: Colors.red[700],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Expense",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white70,
              ),
            ),
            Text(
              "$value ₹",
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget expenseTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
          context,
          "WARNING",
          "This will delete this expense record. Do you want to continue ?",
        );
        if (answer != null && answer) {
          await dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
            color: const Color(0xfffac5c5),
            borderRadius: BorderRadius.circular(8.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_down_outlined,
                      size: 28.0,
                      color: Colors.red[700],
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    const Text(
                      "Expense",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "${date.day} ${months[date.month - 1]} ${date.year}",
                    style: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: 24.0,
                      // fontWeight: FontWeight.w700
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  " - $value ₹",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(color: Colors.grey[800]
                      // fontSize: 24.0,
                      // fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget IncomeTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
          context,
          "WARNING",
          "This will delete this expense record. Do you want to continue ?",
        );
        if (answer != null && answer) {
          await dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
            color: const Color(0xffd8fac5),
            // Color(0xffced4eb),
            borderRadius: BorderRadius.circular(8.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_up_outlined,
                      size: 28.0,
                      color: Colors.green[700],
                    ),
                    const SizedBox(
                      width: 4.0,
                    ),
                    const Text(
                      "Income",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "${date.day} ${months[date.month - 1]} ${date.year}",
                    style: const TextStyle(),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  " + $value ₹",
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.w700),
                ),
                Text(
                  note,
                  style: const TextStyle(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
