import 'package:eClassify/data/model/item/item_model.dart';

import '../../app/routes.dart';
import '../../data/Repositories/Item/item_repository.dart';
import '../../data/model/data_output.dart';
import '../../utils/helper_utils.dart';
import '../constant.dart';
import 'blueprint.dart';

class NativeDeepLinkManager extends NativeDeepLinkUtility {
  @override
  void handle(Uri uri, ProcessResult? result) {
    if (uri.toString().startsWith("http") ||
        uri.toString().startsWith("https")) {
      if (result?.result is ItemModel) {
        Future.delayed(
          Duration.zero,
          () {
            HelperUtils.goToNextPage(Routes.adDetailsScreen,
                Constant.navigatorKey.currentContext!, false,
                args: {
                  "model": result?.result as ItemModel,
                });
          },
        );
        /* Navigator.pushNamed(Constant.navigatorKey.currentContext!, Routes.adDetailsScreen, arguments: {
          "from": "home",
          "model": result?.result as ItemModel,
        });*/
      }
    }
  }

  @override
  Future<ProcessResult?> process(Uri uri) async {
    if (uri.pathSegments.contains("items-details")) {
      int itemId = int.parse(uri.pathSegments[1]);
      DataOutput<ItemModel> dataOutput =
          await ItemRepository().fetchItemFromItemId(itemId);

      return ProcessResult<ItemModel>(dataOutput.modelList.first);
    }

    return null;
  }
}

/*
class NativeLinkWidget extends StatefulWidget {
  final RouteSettings settings;

  const NativeLinkWidget({super.key, required this.settings});

  static BlurredRouter render(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return Scaffold(
          body: NativeLinkWidget(
            settings: settings,
          ),
        );
      },
    );
  }

  @override
  State<NativeLinkWidget> createState() => _NativeLinkWidgetState();
}

class _NativeLinkWidgetState extends State<NativeLinkWidget> {
  @override
  void initState() {
    super.initState();

    print("widget.settings.name***${widget.settings.name}");

    NativeDeepLinkManager().handleLink(widget.settings.name ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.territoryColor,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text("Please Wait...")
          ],
        ),
      ),
    );
  }
}
*/
