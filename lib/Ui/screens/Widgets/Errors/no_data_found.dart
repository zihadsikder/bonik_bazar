import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:flutter/material.dart';

import '../../../../utils/AppIcon.dart';

class NoDataFound extends StatelessWidget {
  final double? height;
  final String? mainMessage;
  final String? subMessage;
  final VoidCallback? onTap;

  const NoDataFound(
      {super.key, this.onTap, this.height, this.mainMessage, this.subMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            // height: height ?? 200,
            child: UiUtils.getSvg(
              AppIcons.no_data_found,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(mainMessage == null
                  ? "nodatafound".translate(context)
                  : mainMessage!)
              .size(context.font.extraLarge)
              .color(context.color.territoryColor)
              .bold(weight: FontWeight.w600),
          const SizedBox(
            height: 14,
          ),
          Text(subMessage == null
                  ? "sorryLookingFor".translate(context)
                  : subMessage!)
              .size(context.font.larger)
              .centerAlign(),
          // Text(UiUtils.getTranslatedLabel(context, "nodatafound")),
          // TextButton(
          //     onPressed: onTap,
          //     style: ButtonStyle(
          //         overlayColor: MaterialStateItem.all(
          //             context.color.teritoryColor.withOpacity(0.2))),
          //     child: const Text("Retry").color(context.color.teritoryColor))
        ],
      ),
    );
  }
}
