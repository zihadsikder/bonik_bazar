part of "../chat_widget.dart";

class AttachmentMessage extends StatefulWidget {
  final String url;
  const AttachmentMessage({super.key, required this.url});

  @override
  State<AttachmentMessage> createState() => _AttachmentMessageState();
}

class _AttachmentMessageState extends State<AttachmentMessage> {
  bool isFileDownloading = false;
  double persontage = 0;

  String getExtentionOfFile() {
    return widget.url.toString().split(".").last;
  }

  String getFileName() {
    return widget.url.toString().split("/").last;
  }

  Future<void> downloadFile() async {

    try {
      if (widget.url.startsWith('http')) {
        // Download file from URL using Dio
        String? downloadPath = await getDownloadPath();
        await Dio().download(
          widget.url,
          "${downloadPath!}/${getFileName()}",
          onReceiveProgress: (int count, int total) async {
            persontage = (count) / total;

            if (persontage == 1) {
              HelperUtils.showSnackBarMessage(
                  context,
                  "fileSavedIn".translate(context),
                  type: MessageType.success
              );

              await OpenFilex.open("$downloadPath/${getFileName()}");
            }
            setState(() {});
          },
        );
      } else {
        // If the URL is not a HTTP URL, assume it's a local file path
        // Copy the file to the download directory
        String? downloadPath = await getDownloadPath();
        final fileName = getFileName();
        File(widget.url).copy("$downloadPath/$fileName");

        HelperUtils.showSnackBarMessage(
            context,
            "fileSavedIn".translate(context),
            type: MessageType.success
        );

        await OpenFilex.open("$downloadPath/$fileName");
      }
    } catch (e) {
      HelperUtils.showSnackBarMessage(
          context,
          "errorFileSave".translate(context),
          type: MessageType.success
      );
    }
  }


/*  Future<void> downloadFile() async {
    print("widget url***${widget.url}");
    try {
      String? downloadPath = await getDownloadPath();
      await Dio().download(
        widget.url,
        "${downloadPath!}/${getFileName()}",
        onReceiveProgress: (int count, int total) async {
          persontage = (count) / total;

          if (persontage == 1) {
            HelperUtils.showSnackBarMessage(
                context, "fileSavedIn".translate(context),
                type: MessageType.success);

            await OpenFilex.open("$downloadPath/${getFileName()}");
          }
          setState(() {});
        },
      );
    } catch (e) {

      HelperUtils.showSnackBarMessage(
          context, "errorFileSave".translate(context),
          type: MessageType.success);
    }
  }*/

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      if (kDebugMode) {
        HelperUtils.showSnackBarMessage(
            context, "fileNotSaved".translate(context),
            type: MessageType.success);
      }
    }
    return directory?.path;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            await downloadFile();
          },
          child: Container(
            height: 50,
            width: 50,
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(
                color: context.color.secondaryColor.withOpacity(0.064),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: context.color.borderColor, width: 1.5)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (persontage != 0 && persontage != 1) ...[
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 1.7,
                        color: context.color.territoryColor,
                        value: persontage,
                      ),
                      const Icon(Icons.close)
                    ],
                  ),
                ] else ...[
                  Text(getExtentionOfFile().toString().toUpperCase()),
                  Icon(
                    Icons.download,
                    size: 14,
                    color: context.color.territoryColor,
                  )
                ]
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Container(
            height: 50,
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(getFileName().toString()).setMaxLines(
                lines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
