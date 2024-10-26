import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud/features/app/splash_screen/splash_screen.dart';
import 'package:flutter_crud/features/user_auth/presentation/pages/login_page.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: "AIzaSyCJRet5WFAlHp3qIvnBW2DmozyZAP-l2nM",
        appId: "1:161986859695:web:c830f05649c2f4a8093a5a",
        messagingSenderId: "161986859695",
        projectId: "crud2-1af82",),
    );
  }

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase',
      home: SplashScreen(
        child: LoginPage(),
      )
    );
  }
}
