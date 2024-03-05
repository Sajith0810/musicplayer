import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music"),
      ),
      drawer: Container(
        margin: EdgeInsets.only(left: 5,top: 5,bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: const Column(
          children: [DrawerHeader(child: Text("Header"))],
        ),
      ),
    );
  }
}
