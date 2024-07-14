import 'package:eClassify/Ui/screens/widgets/blurred_dialoge_box.dart';

import 'package:eClassify/data/cubits/Report/item_report_cubit.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../Utils/ui_utils.dart';
import '../../../../utils/AppIcon.dart';

import '../../Report/report_item_screen.dart';

class ReportItemButton extends StatefulWidget {
  final int itemId;
  final Function() onSuccess;

  const ReportItemButton(
      {super.key, required this.itemId, required this.onSuccess});

  @override
  State<ReportItemButton> createState() => _ReportItemButtonState();
}

class _ReportItemButtonState extends State<ReportItemButton> {
  bool shouldReport = true;

  void _onTapYes(int itemId) {
    _bottomSheet(itemId);
  }

  _onTapNo() {
    shouldReport = false;
    setState(() {});
  }

  void _bottomSheet(int itemId) {
    ItemReportCubit cubit = BlocProvider.of<ItemReportCubit>(context);
    UiUtils.showBlurredDialoge(context,
        dialoge: EmptyDialogBox(
            child: AlertDialog(
          backgroundColor: context.color.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: BlocProvider.value(
            value: cubit,
            child: ReportItemScreen(itemId: itemId),
          ),
        ))).then((value) {
      widget.onSuccess.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (shouldReport == false) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 135,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isDark
                  ? widgetsBorderColorLight.withOpacity(0.1)
                  : widgetsBorderColorLight,
              width: 1.5)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("didYoufindProblem".translate(context))
                      .setMaxLines(lines: 2)
                      .bold(weight: FontWeight.w100)
                      .size(context.font.larger),
                  const Spacer(),
                  Row(
                    children: [
                      MaterialButton(
                          onPressed: () {
                            UiUtils.checkUser(
                                onNotGuest: () {
                                  _onTapYes.call(widget.itemId);
                                },
                                context: context);
                          },
                          textColor: context.color.territoryColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDark
                                      ? widgetsBorderColorLight.withOpacity(0.1)
                                      : widgetsBorderColorLight),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text("yes".translate(context))),
                      const SizedBox(
                        width: 10,
                      ),
                      MaterialButton(
                          onPressed: _onTapNo,
                          textColor: context.color.territoryColor,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: isDark
                                      ? widgetsBorderColorLight.withOpacity(0.1)
                                      : widgetsBorderColorLight),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text("notReally".translate(context)))
                    ],
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? AppIcons.reportDark
                  : AppIcons.report,
            )
          ],
        ),
      ),
    );
  }
}
