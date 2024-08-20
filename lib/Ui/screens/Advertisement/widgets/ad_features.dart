import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

class AdFeatures extends StatefulWidget {
  final String adHeading;

  AdFeatures({
    super.key,
    required this.adHeading,
  });

  @override
  State<AdFeatures> createState() => _AdFeaturesState();
}

class _AdFeaturesState extends State<AdFeatures> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.adHeading, // Access adHeading via widget.adHeading
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          height: 1,
          color: Colors.amber,
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.color.territoryColor),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.electric_bolt_outlined),
                        Text('this is super fast'),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Container(
                          height: 100,
                          width: 2,
                          color: context.color.territoryColor,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Colors.grey,
                              checkColor: Colors.white,
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            SizedBox(width: 4.0),
                            Text("7 Days - "),
                            Text("TK 900"),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Colors.grey,
                              checkColor: Colors.white,
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            SizedBox(width: 4.0),
                            Text("7 Days - "),
                            Text("TK 900"),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Colors.grey,
                              checkColor: Colors.white,
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            SizedBox(width: 4.0),
                            Text("15 Days - "),
                            Text("TK 900"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
