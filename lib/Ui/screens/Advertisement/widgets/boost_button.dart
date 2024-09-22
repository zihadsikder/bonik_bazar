import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../boost_details_screen.dart';

class BoostButton extends StatelessWidget {
  const BoostButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
       height: 24, // You can adjust the height as per your needs
       width: 96, // Adjust the width as well
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Set radius here
      ),

      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Also set radius here
          ),
            padding: EdgeInsets.all(2),
          // Ensure no additional padding
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoostDetailsScreen(),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.electric_bolt_outlined,
              size: 12,
            ),
            SizedBox(width: 4), // Add spacing between icon and text
            Text('Boost Ad')
                .size(context.font.small)
                .color(context.color.textColorDark.withOpacity(0.4)).bold(),
          ],
        ),
      ),
    );
  }
}
