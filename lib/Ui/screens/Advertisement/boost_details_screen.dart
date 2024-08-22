import 'package:eClassify/Ui/screens/Advertisement/widgets/ad_features.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              AdFeatures(
                adHeading: 'URGENT AD',
              ),
              SizedBox(height: 16),
              AdFeatures(
                adHeading: 'PIN AD',
              ),
              SizedBox(height: 16),
              AdFeatures(
                adHeading: 'FEATURES ADD',
              ),
              SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    height: 1,
                    color: Colors.amber,
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: context.color.territoryColor),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        BoostTitle(),
                        Container(
                          height: 1,
                          color: context.color.territoryColor,
                          margin: EdgeInsets.all(12),
                        ),
                        Column(
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                // This is important to avoid infinite height error
                                physics: NeverScrollableScrollPhysics(),
                                // Prevent scrolling in ListView
                                itemCount: 5,
                                // Set the number of items you want to display
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${(index + 1).toString()}. URGENT AD'),
                                      Text('3 Days'),
                                      Text('600'),
                                    ],
                                  );
                                }),
                          ],
                        ),
                        Container(
                          height: 1,
                          color: context.color.territoryColor,
                          margin: EdgeInsets.symmetric(vertical: 12),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '1700.00',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade500),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BoostDetailsScreen()),
                        );
                      },
                      child:
                          Text('Skip') .size(context.font.large)
                              .setMaxLines(lines: 2)
                              .color(context.color.textDefaultColor),
                      ),

                  TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.amber),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BoostDetailsScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Text('Continue') .size(context.font.large)
                              .setMaxLines(lines: 2)
                              .color(context.color.textDefaultColor),
                          Icon(
                            Icons.arrow_circle_right_outlined,
                          ),

                        ],
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BoostTitle extends StatelessWidget {
  const BoostTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Boost Ad Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Days',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Price',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
