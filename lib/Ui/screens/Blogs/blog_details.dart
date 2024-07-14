import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../data/model/blog_model.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

class BlogDetails extends StatelessWidget {
  final BlogModel blog;

  const BlogDetails({super.key, required this.blog});

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map;
    return BlurredRouter(
      builder: (context) {
        return BlogDetails(
          blog: arguments['model'],
        );
      },
    );
  }

  String stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String strippedString = htmlString.replaceAll(exp, '');
    return strippedString;
  }

  @override
  Widget build(BuildContext context) {
    print("blog description***${blog.description}");
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: "blogs".translate(context)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(
            20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(
                  10,
                ),
                child: SizedBox(
                  width: context.screenWidth,
                  height: 170.rh(
                    context,
                  ),
                  child: UiUtils.getImage(
                    blog.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 15.rh(context),
              ),
              Text(blog.createdAt.toString().formatDate())
                  .size(context.font.smaller)
                  .color(context.color.textColorDark.withOpacity(0.5)),
              const SizedBox(
                height: 12,
              ),
              Text(
                (blog.title ?? "").firstUpperCase(),
              )
                  .size(
                    context.font.large,
                  )
                  .color(
                    context.color.textColorDark,
                  ),
              const SizedBox(
                height: 14,
              ),
              Html(data: blog.description ?? "")
              //Text(stripHtmlTags(blog.description ?? "").trim()).color(context.color.textColorDark.withOpacity(0.5))
              /* Html(
                data: blog.description ?? "",
                shrinkWrap: true,
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
