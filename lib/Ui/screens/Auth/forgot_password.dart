import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../Utils/helper_utils.dart';
import '../../../Utils/ui_utils.dart';
import '../../../app/routes.dart';
import '../Home/home_screen.dart';
import '../Widgets/AnimatedRoutes/blur_page_route.dart';
import '../Widgets/custom_text_form_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static BlurredRouter route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const ForgotPasswordScreen(),
    );
  }

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: sidePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: FittedBox(
                  fit: BoxFit.none,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.main,
                        arguments: {
                          "from": "login",
                          "isSkipped": true,
                        },
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: context.color.forthColor.withOpacity(0.102),
                    elevation: 0,
                    height: 28,
                    minWidth: 64,
                    child: Text("skip".translate(context))
                        .color(context.color.forthColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 66,
              ),
              Text("forgotPassword".translate(context))
                  .size(context.font.extraLarge),
              const SizedBox(
                height: 20,
              ),
              Text("forgotHeadingTxt".translate(context))
                  .size(context.font.large),
              const SizedBox(
                height: 8,
              ),
              Text("forgotSubHeadingTxt".translate(context))
                  .size(context.font.small)
                  .color(context.color.textLightColor),
              const SizedBox(
                height: 24,
              ),
              CustomTextFormField(
                  controller: _emailController,
                  keyboard: TextInputType.emailAddress,
                  hintText: "emailAddress".translate(context),
                  validator: CustomTextFieldValidator.email),
              const SizedBox(
                height: 25,
              ),
              UiUtils.buildButton(
                context,
                onPressed: () async {
                  FocusScope.of(context).unfocus(); //dismiss keyboard

                  Future.delayed(const Duration(seconds: 1)).then((_) async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await _auth
                            .sendPasswordResetEmail(
                                email: _emailController.text)
                            .then((value) {
                          HelperUtils.showSnackBarMessage(context,
                              "resetPasswordSuccess".translate(context),
                              type: MessageType.success);
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.login, (route) => false);
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          HelperUtils.showSnackBarMessage(
                              context, "userNotFound".translate(context),
                              type: MessageType.error);
                        } else {
                          HelperUtils.showSnackBarMessage(context, e.toString(),
                              type: MessageType.error);
                        }
                      }
                    }
                  });
                },
                buttonTitle: "submitBtnLbl".translate(context),
                radius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
