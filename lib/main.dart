import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'AuthPage.dart';
import 'TicketListPage.dart';


void main() async{
      WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
   await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyBIoLyIcvmlzB0VhiOudFRR0KCJw7TzQAo",
        authDomain: "pfa5-4f42b.firebaseapp.com",
        projectId: "pfa5-4f42b",
        storageBucket: "pfa5-4f42b.firebasestorage.app",
        messagingSenderId: "866621539298",
        appId: "1:866621539298:web:b299b76ebcc7e544b3efbb"));
  }
  else{
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
      title: 'My App',
      home:TicketListPage(),
    );
  }
}
