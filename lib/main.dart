import 'package:flutter/material.dart';
import 'package:iiitk_events/pages/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginPage(),);
  }
}

void main(){
  runApp(App());
}