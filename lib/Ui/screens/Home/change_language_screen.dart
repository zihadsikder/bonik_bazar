import 'package:eClassify/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:eClassify/data/cubits/system/fetch_language_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/data/model/system_settings_model.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/hive_utils.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/cubits/category/fetch_category_cubit.dart';

class LanguagesListScreen extends StatelessWidget {
  const LanguagesListScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) => const LanguagesListScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final systemSettingsCubit = context.watch<FetchSystemSettingsCubit>();
    final setting = systemSettingsCubit.getSetting(SystemSetting.language) as List?;

    if (setting == null || setting.isEmpty) {
      return Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true, title: "chooseLanguage".translate(context)),
        body: Center(child: Text("No languages available.")),
      );
    }

    final language = context.watch<LanguageCubit>().state;

    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: "chooseLanguage".translate(context)),
      body: BlocListener<FetchLanguageCubit, FetchLanguageState>(
        listener: (context, state) {
          if (state is FetchLanguageInProgress) {
            Widgets.showLoader(context);
          }
          if (state is FetchLanguageSuccess) {
            Widgets.hideLoder(context);

            final map = state.toMap();
            final data = map['file_name'];
            map['data'] = data;
            map.remove('file_name');

            HiveUtils.storeLanguage(map);
            context.read<LanguageCubit>().emit(LanguageLoader(map));
            context.read<FetchCategoryCubit>().fetchCategories();
          }
          if (state is FetchLanguageFailure) {
            Widgets.hideLoder(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to load language. Please try again.")),
            );
          }
        },
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: setting.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemBuilder: (context, index) {
            final isSelected = (language as LanguageLoader).language['code'] ==
                setting[index]['code'];

            final color = isSelected
                ? context.color.territoryColor
                : context.color.textLightColor.withOpacity(0.03);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  onTap: () {
                    final languageCode = setting[index]['code'];
                    if (languageCode != null) {
                      context.read<FetchLanguageCubit>().getLanguage(languageCode);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Language code is missing!")),
                      );
                    }
                  },
                  leading: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: UiUtils.imageType(
                        setting[index]['image'],
                        fit: BoxFit.cover,
                        width: 42,
                        height: 42,
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(setting[index]['name'])
                          .color(isSelected
                          ? context.color.buttonColor
                          : context.color.textColorDark)
                          .bold(),
                      Text(setting[index]['name_in_english'])
                          .color(isSelected
                          ? context.color.buttonColor.withOpacity(0.7)
                          : context.color.textColorDark.withOpacity(0.6))
                          .size(context.font.small),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
