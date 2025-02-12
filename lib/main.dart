import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:train_ticket_booking_system/auth/signinPage.dart';
import 'package:train_ticket_booking_system/pages/coachInfo.dart';
import 'package:train_ticket_booking_system/pages/confirmBook.dart';
import 'package:train_ticket_booking_system/pages/home.dart';
import 'package:train_ticket_booking_system/pages/trainInfo.dart';
import 'package:train_ticket_booking_system/widget/popupSummary.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
   await Firebase.initializeApp(options: FirebaseOptions(
       apiKey: "AIzaSyBGadPh7yxps88ttI278eWdnOUsMI1ya7c",
        authDomain: "train-ticket-booking-sys-ad99e.firebaseapp.com",
        projectId: "train-ticket-booking-sys-ad99e",
       storageBucket: "train-ticket-booking-sys-ad99e.appspot.com",
        messagingSenderId: "8251142919",
        appId: "1:8251142919:web:613c453ed65b9506770ba2"));
  } else {
   await Firebase.initializeApp();
  }
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
