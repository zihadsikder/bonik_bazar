
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import '../../../../../../Utils/ui_utils.dart';
import '../../../../../../Utils/validator.dart';
import '../../../../Widgets/DynamicField/dynamic_field.dart';
import '../custom_field.dart';

class CustomRadioField extends CustomField {
  @override
  String type = "radio";
  String? selectedRadioValue;
  bool calledUpdate = false;
  FormFieldState<String>? validation;
  List? values;

  @override
  void init() {
    dynamic selectedCustomFieldValue = (parameters['values']);
    values = selectedCustomFieldValue;
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null) {
        if ((parameters['value'] as List).isNotEmpty) {
          selectedRadioValue = parameters['value'][0];
        } /*else {
          selectedRadioValue = (selectedCustomFieldValue[0]);
        }*/
      } /*else {
        selectedRadioValue = (selectedCustomFieldValue[0]);
      }*/
    } /*else {
      selectedRadioValue = (selectedCustomFieldValue[0]);
      AbstractField.fieldsData.addAll({
        parameters['id'].toString(): [selectedRadioValue]
      });
    }*/

    validation?.didChange((selectedCustomFieldValue[0]));

    update(() {});

    // selectedRadio.value = widget.radioValues?[index];

    super.init();
  }

  @override
  Widget render() {
    return CustomValidator<String>(
      initialValue: values![0],
      builder: (FormFieldState<String> state) {
        if (validation == null) {
          validation = state;
          Future.delayed(Duration.zero, () {
            update(() {});
          });
        }

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
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          color: context.color.textDefaultColor),
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
                    children: List.generate(values!.length ?? 0, (index) {
                      var element = values![index];

                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: index == 0 ? 0 : 4,
                          end: 4,
                          bottom: 4,
                          top: 4,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            selectedRadioValue = element;
                            update(() {});
                            state.didChange(selectedRadioValue);

                            // selectedRadio.value = widget.radioValues?[index];
                            AbstractField.fieldsData.addAll({
                              parameters['id'].toString(): [selectedRadioValue]
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: context.color.borderColor,
                                    width: 1.5),
                                color: selectedRadioValue == element
                                    ? context.color.territoryColor
                                        .withOpacity(0.1)
                                    : context.color.secondaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Text(values![index]).color(
                                    (selectedRadioValue == element
                                        ? context.color.territoryColor
                                        : context.color.textLightColor))),
                          ),
                        ),
                      );
                    })),
                if (state.hasError)
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                    child: Text(state.errorText ?? "")
                        .size(context.font.small)
                        .color(context.color.error),
                  )
              ],
            )
          ],
        );
      },
      validator: (String? value) {
        ///This will check only when the filed is required so we should validate
        if (parameters['required'] != 1) {
          return null;
        }
        if (value != null) return null;

        return "Selecting this is required";
      },
    );
  }
}
