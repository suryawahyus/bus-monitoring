import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monitoring/widget/animation_widget.dart';
import 'package:monitoring/widget/map_widget.dart';
import 'package:monitoring/widget/schedule_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBcwQI7J3eFqeH-ePkRh0WWKYX0PvLb6U8",
            authDomain: "mybussdrs-8eac9.firebaseapp.com",
            databaseURL:
                "https://mybussdrs-8eac9-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "mybussdrs-8eac9",
            storageBucket: "mybussdrs-8eac9.appspot.com",
            messagingSenderId: "387806559771",
            appId: "1:387806559771:web:5f0991ad9c901a008e42be",
            measurementId: "G-L5HSNDSBVP"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0500FF), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 1910,
                height: 600,
                child: const MapScreen(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 947,
                  height: 340,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF0500FF), width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const AnimationBus(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 922,
                  height: 340,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFF0500FF), width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const ScheduleBus(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
