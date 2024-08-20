import 'package:flutter/material.dart';

class BoostDetailsScreen extends StatefulWidget {
  const BoostDetailsScreen({super.key});

  @override
  State<BoostDetailsScreen> createState() => _BoostDetailsScreenState();
}

class _BoostDetailsScreenState extends State<BoostDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boost'),
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      ),
    );
  }
}
