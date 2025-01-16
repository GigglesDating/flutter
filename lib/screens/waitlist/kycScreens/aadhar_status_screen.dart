import 'package:flutter/material.dart';
import '../profileCreationScreens/profile_creation1.dart';

class AadharStatusScreen extends StatefulWidget {
  const AadharStatusScreen({super.key});

  @override
  State<AadharStatusScreen> createState() => _AadharStatusScreenState();
}

class _AadharStatusScreenState extends State<AadharStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ProfileCreation1()));
          },
          child: const Text('Launch HyperVerge SDK'),
        ),
      ),
    );
  }
}
