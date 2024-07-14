import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/Utils/validator.dart';
import 'package:flutter/material.dart';

import '../../../../../../Utils/ui_utils.dart';

import '../../../../Widgets/DynamicField/dynamic_field.dart';
import '../custom_field.dart';

class CustomCheckboxField extends CustomField {
  @override
  String type = "checkbox";

  List checked = [];

  @override
  void init() {
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null) {
        if ((parameters['value'] as List).isNotEmpty) {
          checked = parameters['value'];
          update(() {});
        }
      }


    }
    super.init();
  }

  @override
  Widget render() {
    return CustomValidator<List>(
      validator: (List? value) {
        if (parameters['required'] != 1) {
          return null;
        }

        if (value?.isNotEmpty == true) {
          return null;
        }

        if (checked.isNotEmpty) {
          return null;
        }

        return "pleaseSelectValue".translate(context);
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.rw(context),
                  height: 48.rh(context),
                  decoration: BoxDecoration(
                    color: context.color.territoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: UiUtils.imageType(parameters['image'],
                          width: 24, height: 24, fit: BoxFit.cover,color: context.color.textDefaultColor),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.rw(context),
                ),
                Text(parameters['name'])
                    .size(context.font.large)
                    .bold(weight: FontWeight.w500)
                    .color(state.hasError
                        ? context.color.error
                        : context.color.textColorDark)
              ],
            ),
            SizedBox(
              height: 14.rh(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: List.generate(
                    parameters['values'].length,
                    (index) {

                      final value = parameters['values'][index].toString();
                      final isChecked = checked.contains(value);
                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: index == 0 ? 0 : 4,
                          bottom: 4,
                          top: 4,
                          end: 4,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            if (isChecked) {
                              checked.remove(value);
                            } else {
                              checked.add(value);
                            }
                            AbstractField.fieldsData.addAll({
                              parameters['id'].toString(): checked,
                            });
                            update(() {});
                            state.didChange(checked);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.color.borderColor,
                                width: 1.5,
                              ),
                              color: isChecked
                                  ? context.color.territoryColor
                                      .withOpacity(0.1)
                                  : context.color.secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isChecked ? Icons.done : Icons.add,
                                    color: isChecked
                                        ? context.color.territoryColor
                                        : context.color.textColorDark,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(value).color(isChecked
                                      ? context.color.territoryColor
                                      : context.color.textLightColor),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                    child: Text(
                      state.errorText ?? "",
                    ).size(context.font.small).color(context.color.error),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
