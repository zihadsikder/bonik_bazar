import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../Utils/AppIcon.dart';
import '../../../../../../Utils/ui_utils.dart';
import '../../../../Widgets/DynamicField/dynamic_field.dart';
import '../custom_field.dart';

class CustomFieldDropdown extends CustomField {
  @override
  String type = "dropdown";
  String? selected;

  @override
  void init() {
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null) {
        if ((parameters['value'] as List).isNotEmpty) {
          selected = parameters['value'][0].toString();
        }
      }
    } else {
      /* selected = parameters['values'][0];
      AbstractField.fieldsData.addAll({
        parameters['id'].toString(): [selected],
      });*/

      selected = ""; // Ensure selected is null initially
      // Ensure blank option is included in the values
     /* if (!(parameters['values'] as List).contains("")) {
        (parameters['values'] as List).insert(0, "");
      }*/
    }

    update(() {});
    super.init();
  }

  @override
  Widget render() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32.rw(context),
              height: 32.rh(context),
              decoration: BoxDecoration(
                color: context.color.territoryColor.withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: SizedBox(
                height: 20,
                width: 20,
                child: FittedBox(
                  fit: BoxFit.none,
                  child: UiUtils.imageType(parameters['image'],
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      color: context.color.textDefaultColor),
                ),
              ),
            ),
            SizedBox(
              width: 10.rw(
                context,
              ),
            ),
            Text(
              parameters['name'],
            )
                .size(
                  context.font.large,
                )
                .bold(weight: FontWeight.w500)
                .color(
                  context.color.textColorDark,
                )
          ],
        ),
        SizedBox(
          height: 14.rh(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Container(
            decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(
                  10,
                ),
                border: Border.all(
                  width: 1,
                  color: context.color.borderColor.darken(30),
                )),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: DropdownButton(
                  value: selected?.isEmpty == true ? null : selected,
                  dropdownColor: context.color.secondaryColor,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  icon: SvgPicture.asset(AppIcons.downArrow),
                  isDense: true,
                  borderRadius: BorderRadius.circular(10),
                  style: TextStyle(
                    color: context.color.textLightColor,
                    fontSize: context.font.large,
                  ),
                  underline: const SizedBox.shrink(),
                  items: (parameters['values'] as List<dynamic>)
                      .map<DropdownMenuItem<dynamic>>((dynamic e) {
                    return DropdownMenuItem<dynamic>(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (v) {
                    selected = v.toString();
                    update(() {});
                    print("seleted dropdown****$selected");
                    AbstractField.fieldsData.addAll({
                      parameters['id'].toString(): [selected],
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
