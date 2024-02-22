import 'package:energy_tariff/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (p0, p1, p2) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: FutureBuilder(
                future: Firebase.initializeApp(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasError) {
                    if (kDebugMode) {
                      print("You have an error: ${snapshot.error.toString()}");
                    }
                    return const Text("Something went wrong!");
                  } else {
                    return const MyHomePage();
                  }
                },
              ),
        );
      }
    );
  }
}
