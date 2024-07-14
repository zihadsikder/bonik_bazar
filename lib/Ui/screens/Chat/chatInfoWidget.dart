import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import '../../../Utils/helper_utils.dart';
import '../../../Utils/ui_utils.dart';
import '../../../app/routes.dart';
import '../../../data/Repositories/Item/item_repository.dart';
import '../../../data/helper/widgets.dart';
import '../../../data/model/data_output.dart';
import '../../../data/model/item/item_model.dart';

class ChatInfoWidget extends StatelessWidget {
  final String itemTitleImage;
  final String itemTitle;
  final String itemId;

  const ChatInfoWidget(
      {super.key,
      required this.itemTitleImage,
      required this.itemTitle,
      required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.color.territoryColor),
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: context.screenHeight * 0.46,
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              width: context.screenWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector(
                      onTap: () {
                        UiUtils.showFullScreenImage(context,
                            provider:
                                CachedNetworkImageProvider(itemTitleImage));
                      },
                      child: CachedNetworkImage(
                        memCacheHeight: 500,
                        memCacheWidth: 500,
                        imageUrl: itemTitleImage,
                        width: context.screenWidth,
                        fit: BoxFit.cover,
                        height: context.screenHeight * 0.3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(itemTitle)
                          .setMaxLines(
                            lines: 2,
                          )
                          .size(
                            context.font.larger.rf(
                              context,
                            ),
                          ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: UiUtils.buildButton(context, onPressed: () async {
                        try {
                          Widgets.showLoader(context);
                          ItemRepository fetch = ItemRepository();
                          DataOutput<ItemModel> dataOutput = await fetch
                              .fetchItemFromItemId(int.parse(itemId));
                          Future.delayed(
                            Duration.zero,
                            () {
                              Widgets.hideLoder(context);

                              HelperUtils.goToNextPage(
                                  Routes.adDetailsScreen, context, false,
                                  args: {
                                    'model': dataOutput.modelList[0],
                                  });
                            },
                          );
                        } catch (e) {
                          Widgets.hideLoder(context);
                        }
                      },
                          buttonTitle: "viewItem".translate(context),
                          width: context.screenWidth * 0.5,
                          fontSize: context.font.normal,
                          height: 40),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
