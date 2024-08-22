import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

class PaymentMethod extends StatelessWidget {
  // final String adName;
  // final String adDays;
  // final String adPrice;
  final String totalPayment;

  const PaymentMethod({
    super.key,
    // required this.adName,
    // required this.adDays,
    // required this.adPrice,
    required this.totalPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Boost Ad Name',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Days',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Price',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 1,
                color: context.color.territoryColor,
                margin: EdgeInsets.all(12),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('adName'),
                      Text('adDays'),
                      Text('adPrice'),
                    ],
                  ),
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
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        totalPayment,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
