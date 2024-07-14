import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/Ui/screens/Widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../../../Utils/ui_utils.dart';

class PdfViewer extends StatefulWidget {
  final String url;

  const PdfViewer({Key? key, required this.url}) : super(key: key);

  @override
  _PDFViewerState createState() => _PDFViewerState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => PdfViewer(
        url: arguments?['url'],
        // from: arguments?['from'],
      ),
    );
  }
}

class _PDFViewerState extends State<PdfViewer> {
  late File Pfile;
  bool isLoading = false;

  Future<void> loadNetwork() async {
    setState(() {
      isLoading = true;
    });
    var url = widget.url;

    try {
      Response response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));
      final bytes = response.data;
      final filename =
          path.basename(url); // Use path.basename instead of basename
      final dir = await getApplicationDocumentsDirectory();
      var file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        Pfile = file;
      });


      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    loadNetwork();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiUtils.buildAppBar(
        context,
        backgroundColor: context.color.secondaryDetailsColor,
        showBackButton: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              child: Center(
                child: PDFView(
                  filePath: Pfile.path,
                ),
              ),
            ),
    );
  }
}

/*bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    print("widget.url***${widget.url}");
    return Scaffold(
      body: Stack(
        children: [
          PDFView(
            filePath: widget.url,
            onRender: (pages) {
              setState(() {
                _isLoading = false;
              });
            },
            onViewCreated: (controller) {
              setState(() {});
            },
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 20,
            left: 20,
            child: InkWell(
              child: Icon(Icons.arrow_back),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}*/
