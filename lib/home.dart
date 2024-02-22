// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:energy_tariff/bulb.dart';
import 'package:energy_tariff/datapage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_seria_changed/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_settings/open_settings.dart';

final List<BluetoothDiscoveryResult> _devicesList = [];
BluetoothConnection? bluetoothConnection;
bool switchValue = false;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String isconnected = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (switchValue == false || bluetoothConnection == null) {
        isconnected = "Connect";
      } else {
        isconnected = "Disconnect";
      }
    });
  }

  void _disconnect() {
    if (bluetoothConnection != null) {
      bluetoothConnection!.dispose();
      bluetoothConnection = null;
      print('Disconnected');
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    print("Connect to device");
    try {
      _disconnect();
      final BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      print('Connected to ${device.name}');
      print(device.name);
      bluetoothConnection = connection;
      Navigator.of(context).pop();
      setState(() {
        switchValue = true;
        print(switchValue);
        if (switchValue == false || bluetoothConnection == null) {
          isconnected = "Connect";
          print(switchValue);
        } else {
          isconnected = "Disconnect";
        }
      });
      connection.input!.listen((Uint8List data) {
        print("listening:");
        print(data);
      }).onDone(() {
        setState(() {
          switchValue = false;
          if (switchValue == false || bluetoothConnection == null) {
            isconnected = "Connect";
          } else {
            isconnected = "Disconnect";
          }
        });
        print('Device Disconnected.');
        bluetoothConnection = null;
      });
    } catch (error) {
      print('Error connecting to ${device.name}: $error');
      Navigator.of(context).pop();
    }
  }

  Future<void> _askUserToEnableBluetooth(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth is turned off'),
          content:
              const Text('Please turn on Bluetooth and try again to continue.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                OpenSettings.openBluetoothSetting();
                setState(() {});
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _startDiscovery(BuildContext context) async {
    print("Started");
    setState(() {
      _isLoading = true;
      _devicesList.clear();
      print("Cleared");
    });
    await FlutterBluetoothSerial.instance.cancelDiscovery();

    FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
      setState(() {
        print("Added");
        _devicesList.add(device);
      });
    }).onDone(() {
      print("Scanning completed");
      setState(() {
        _isLoading = false;
      });
      _showCustomDialog(context);
    });
  }

  Future<void> _checkBluetoothStatus(BuildContext context) async {
    print('Check2');
    bool isEnabled = (await FlutterBluetoothSerial.instance.isEnabled) ?? false;
    if (!isEnabled) {
      print("Blutooth OFF");
      _askUserToEnableBluetooth(context);
    } else {
      print("Blutooth ON");
      _startDiscovery(context);
    }
  }

  Future<void> requestBluetoothScanPermission(BuildContext context) async {
    print("Check1");
    var status = await Permission.bluetoothScan.status;
    if (status.isDenied) {
      PermissionStatus result = await Permission.bluetoothScan.request();
      if (result.isGranted) {
        print('Granted, Bluetooth check');
        _checkBluetoothStatus(context);
      } else {
        print("Not granted");
      }
    } else if (status.isPermanentlyDenied) {
      print('Request settings');
      openAppSettings();
    } else {
      print('All ready Granted, Bluetooth check');
      _checkBluetoothStatus(context);
    }
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discovered Devices:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _devicesList.isEmpty
                        ? const Center(
                            child: Text(
                            'No devices !',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                            ),
                          ))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _devicesList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_devicesList[index].device.name ??
                                    'Unknown'),
                                subtitle:
                                    Text(_devicesList[index].device.address),
                                trailing: _devicesList[index].device.isBonded
                                    ? const Icon(Icons.bluetooth_connected,
                                        color: Colors.green)
                                    : const Icon(Icons.bluetooth,
                                        color: Colors.grey),
                                onTap: () {
                                  _connectToDevice(_devicesList[index].device);
                                },
                              );
                            },
                          ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 150.0, top: 35.0),
              child: Transform.scale(
                scale: 0.80,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.8,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Switch(
                    value: switchValue,
                    onChanged: (value) {
                      setState(() {});
                    },
                    activeColor: Colors.green,
                    inactiveTrackColor: Colors.grey,
                    activeTrackColor: Colors.lightGreenAccent,
                    inactiveThumbColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: 40.0,
              ),
              child:Text(
                "ENERGY TARIFF",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 40.0,
                left: 15.0,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      top: 12.0, right: 23.0, left: 23.0, bottom: 12.0),
                  backgroundColor: Colors.black12, // Set background color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30.0), // Set border radius
                    side: const BorderSide(
                      color: Colors.grey,
                      width: 3.0,
                    ),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const inSightsPage(), // Ensure the correct capitalization and naming convention
                    ),
                  );
                },
                child: const Text(
                  "Insights",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 40.0,
                right: 15.0,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      top: 12.0, right: 23.0, left: 23.0, bottom: 12.0),
                  backgroundColor: Colors.black12, // Set background color
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30.0), // Set border radius
                    side: const BorderSide(
                      color: Colors.grey,
                      width: 3.0,
                    ), // Set border color
                  ),
                  elevation: 4, // Add elevation
                ),
                onPressed: () async {
                  if(isconnected == "Connect"){
                    await requestBluetoothScanPermission(context);
                    print("Connected");
                  }else{
                    _disconnect();
                  }
                },
                child: _isLoading
              ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Text(
                  isconnected,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BulbWidget(value: "1", name: "LED 1",switchValue: switchValue,),
              BulbWidget(value: "2", name: "LED 2",switchValue: switchValue,),
              BulbWidget(value: "3", name: "LED 3",switchValue: switchValue,),
              BulbWidget(value: "4", name: "LED 4",switchValue: switchValue,),
            ],
          ),
        ],
      ),
    );
  }
}

