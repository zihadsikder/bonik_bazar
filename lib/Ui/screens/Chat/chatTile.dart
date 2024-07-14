import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Utils/AppIcon.dart';
import '../../../Utils/Notification/notification_service.dart';
import '../../../Utils/ui_utils.dart';
import '../../../data/cubits/chatCubits/delete_message_cubit.dart';
import '../../../data/cubits/chatCubits/load_chat_messages.dart';
import '../Widgets/AnimatedRoutes/blur_page_route.dart';
import '../chat/chat_screen.dart';

class ChatTile extends StatelessWidget {
  final String profilePicture;
  final String userName;
  final String itemPicture;
  final String itemName;
  final String itemId;
  final String pendingMessageCount;
  final String id;
  final String date;
  final int itemOfferId;
  final int itemPrice;
  final int itemAmount;
  final String? status;
  final String? buyerId;


  const ChatTile(
      {super.key,
      required this.profilePicture,
      required this.userName,
      required this.itemPicture,
      required this.itemName,
      required this.pendingMessageCount,
      required this.id,
      required this.date,
      required this.itemId,
      required this.itemOfferId,
      required this.itemPrice,
       this.status,
      required this.itemAmount, this.buyerId,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, BlurredRouter(
          builder: (context) {
            currentlyChatingWith = id;
            currentlyChatItemId = itemId;
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => LoadChatMessagesCubit(),
                ),
                BlocProvider(
                  create: (context) => DeleteMessageCubit(),
                ),
              ],
              child: Builder(builder: (context) {
                return ChatScreen(
                  profilePicture: profilePicture,
                  itemTitle: itemName,
                  userId: id,
                  itemImage: itemPicture,
                  userName: userName,
                  itemId: itemId,
                  date: date,
                  itemOfferId: itemOfferId,
                  itemPrice: itemPrice,
                  itemOfferPrice: itemAmount,
                  status: status,
                  buyerId: buyerId,
                );
              }),
            );
          },
        ));
      },
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.color.borderColor,
              width: 1.5,
            ),
          ),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    const SizedBox(
                      width: 58,
                      height: 58,
                    ),
                    GestureDetector(
                      onTap: () {
                        UiUtils.showFullScreenImage(context,
                            provider: CachedNetworkImageProvider(itemPicture));
                      },
                      child: Container(
                        width: 47,
                        height: 47,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: context.color.textDefaultColor
                                    .withOpacity(0.05))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: UiUtils.getImage(
                            itemPicture,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      end: 8,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          UiUtils.showFullScreenImage(context,
                              provider:
                                  CachedNetworkImageProvider(profilePicture));
                        },
                        child: Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: Colors.white, width: 1)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: profilePicture == ""
                                ? CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        context.color.territoryColor,
                                    child: SvgPicture.asset(AppIcons.profile,
                                        height: 15,
                                        width: 15,
                                        colorFilter: ColorFilter.mode(
                                            context.color.buttonColor,
                                            BlendMode.srcIn)),
                                  )
                                : CircleAvatar(
                                    radius: 15,
                                    backgroundColor:
                                        context.color.territoryColor,
                                    backgroundImage:
                                        NetworkImage(profilePicture),
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ).bold().color(context.color.textColorDark),
                      Text(
                        itemName,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ).color(context.color.textColorDark),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
