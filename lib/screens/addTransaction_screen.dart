import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracer/controllers/db_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  int? amonunt;
  String?  note;
  String? types;
  DateTime sdate = DateTime.now();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: sdate,
        firstDate: DateTime(1990, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != sdate) {
      setState(() {
        sdate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          const SizedBox(
            height: 20.0,
          ),
          const Text(
            "Add Transaction",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w700,
                color: Colors.black),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.black),
                padding: const EdgeInsets.all(12.0),
                child: const Icon(
                  Icons.attach_money,
                  size: 24.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 12.0,
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "₹",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 24.0,
                  ),
                  onChanged: (val) {
                    try {
                      amonunt = int.parse(val);
                    } catch (e) {}
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16.0)),
                padding: const EdgeInsets.all(12.0),
                child: const Icon(
                  Icons.description,
                  size: 24.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 12.0,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    maxLength: 12,
                    decoration: InputDecoration(
                      hintText: "Note of Transaction",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 24.0,
                    ),
                    onChanged: (val) {
                      note = val;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16.0)),
                padding: const EdgeInsets.all(12.0),
                child: const Icon(
                  Icons.moving_sharp,
                  size: 24.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 12.0,
              ),
              ChoiceChip(
                label: Text(
                  "Income",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: types == "Income" ? Colors.white : Colors.black,
                  ),
                ),
                selectedColor: Colors.green,
                selected: types == "Income" ? true : false,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      types = "Income";
                      if (note!.isEmpty || note == "Expense") {
                        note = 'Income';
                      }
                    });
                  }
                },
              ),
              const SizedBox(
                width: 12.0,
              ),
              ChoiceChip(
                label: Text(
                  "Expense",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: types == "Expense" ? Colors.white : Colors.black,
                  ),
                ),
                selectedColor: Colors.red,
                selected: types == "Expense" ? true : false,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      types = "Expense";
                      if (note!.isEmpty || note == "Expense") {
                        note = 'Expense';
                      }
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          SizedBox(
            height: 50.0,
            child: TextButton(
              onPressed: () {
                _selectDate(context);
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero)),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(
                        16.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(
                      12.0,
                    ),
                    child: const Icon(
                      Icons.date_range,
                      size: 24.0,
                      // color: Colors.grey[700],
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 12.0,
                  ),
                  Text(
                    "${sdate.day} ${months[sdate.month - 1]}",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          SizedBox(
            height: 50.0,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF3F51B5)),
              ),
              onPressed: () {
                if (amonunt != null && note != null && types!= null) {
                  DbHelper dbHelper = DbHelper();
                  dbHelper.addData(amonunt!, sdate, types!, note!);

                  Navigator.of(context).pop();
                } else {
                  _showToast(context, 'Please Enter the Details');
                }
              },
              child: const Text(
                "Add",
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
