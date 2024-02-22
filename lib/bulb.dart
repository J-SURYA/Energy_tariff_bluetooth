// ignore_for_file: deprecated_member_use, avoid_print, unnecessary_null_comparison
import 'package:energy_tariff/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class BulbWidget extends StatefulWidget {
  final String value;
  final String name;
  final bool switchValue;

  const BulbWidget({Key? key, required this.value, required this.name,required this.switchValue,}) : super(key: key);

  @override
  State<BulbWidget> createState() => _BulbWidgetState();
}

class _BulbWidgetState extends State<BulbWidget> {
  bool isSwitched = false;
  late double curValue = 0.0;

  @override
  void initState() {
    super.initState();
    final DatabaseReference valueReference = FirebaseDatabase.instance.reference().child(widget.name);
    valueReference.onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          curValue = (event.snapshot.value as double);
        });
        print(event.snapshot.value as double);
      }else{
        print("No data");
      }
    });
  }


  String get bulbImage {
    if (isSwitched) {
      return 'assets/on.png';
    } else {
      return 'assets/off.png';
    }
  }

  void _sendData(String data) {
    print("Sending Data : $data");
    try {
      if (bluetoothConnection != null) {
        bluetoothConnection!.output.add(Uint8List.fromList(data.codeUnits));
        bluetoothConnection!.output.allSent.then((_) {
          print('Data sent: $data');
        });
      } else {
        print("Not connected");
        setState(() {
          switchValue = false;
        });
      }
    } catch (error) {
      if (error is StateError) {
        print("Not paired");
      } else {
        print('Error sending data: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Image.asset(
          bulbImage,
          width: 160,
          height: 120,
        ),
        const SizedBox(height: 10),
        Text(
          widget.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          curValue.toStringAsFixed(3),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Switch(
          value: isSwitched,
          onChanged: widget.switchValue ?
          (value) {
            if (value) {
              _sendData("${widget.name}On");
            } else {
              _sendData("${widget.name}Off");
            }
            setState(() {
              isSwitched = value;
            });
          } : null,
        ),
      ],
    );
  }
}