import 'package:eClassify/Ui/screens/Advertisement/widgets/ad_features.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AdFeatures(adHeading: 'URGENT AD',),
            SizedBox(
                height: 16
            ),
            AdFeatures(adHeading: 'PIN AD',),
            SizedBox(
                height: 16
            ),
            AdFeatures(adHeading: 'FEATURES ADD',),
          ],
        ),
      ),
    );
  }
}
