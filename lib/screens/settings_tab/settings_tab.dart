import 'package:animations/animations.dart';
import 'package:anonaddy/models/recipient/recipient_model.dart';
import 'package:anonaddy/screens/login_screen/token_login_screen.dart';
import 'package:anonaddy/services/theme/theme_service.dart';
import 'package:anonaddy/state_management/providers.dart';
import 'package:anonaddy/utilities/confirmation_dialog.dart';
import 'package:anonaddy/utilities/target_platform.dart';
import 'package:anonaddy/widgets/loading_indicator.dart';
import 'package:anonaddy/widgets/lottie_widget.dart';
import 'package:anonaddy/widgets/recipient_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

final recipientDataStream =
    StreamProvider.autoDispose<RecipientModel>((ref) async* {
  while (true) {
    await Future.delayed(Duration(seconds: 10));
    yield* Stream.fromFuture(
        ref.read(recipientServiceProvider).getAllRecipient());
  }
});

class SettingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final size = MediaQuery.of(context).size;
    final isIOS = TargetedPlatform().isIOS();
    final recipientData = watch(recipientDataStream);

    return Padding(
      padding: EdgeInsets.all(size.height * 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // todo implement feedback mechanism.
          // todo Give dev email to receive feedback and suggestions
          // todo encourage users to get into beta program

          recipientData.when(
            loading: () => LoadingIndicator(),
            data: (data) {
              final recipientList = data.recipientDataList;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipients',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: recipientList.length,
                    itemBuilder: (context, index) {
                      return RecipientListTile(
                        recipientDataModel: recipientList[index],
                      );
                    },
                  ),
                ],
              );
            },
            error: (error, stackTrace) {
              return LottieWidget(
                showLoading: true,
                lottie: 'assets/lottie/errorCone.json',
                label: '$error',
              );
            },
          ),
          Divider(height: 0),
          ExpansionTile(
            childrenPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            leading: Icon(isIOS ? CupertinoIcons.settings : Icons.settings),
            title: Text('App Settings'),
            children: [
              ListTile(
                leading: Text(
                  'Dark Theme',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                trailing: Switch.adaptive(
                  value: context.read(themeServiceProvider).isDarkTheme,
                  onChanged: (toggle) =>
                      context.read(themeServiceProvider).toggleTheme(),
                ),
              ),
              ListTile(
                leading: Text(
                  'About App',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onTap: () => aboutAppDialog(context),
              ),
              SizedBox(height: size.height * 0.01),
              ListTile(
                tileColor: Colors.red,
                title: Center(
                  child: Text(
                    'Log Out',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                onTap: () => buildLogoutDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future buildLogoutDialog(BuildContext context) {
    final logout = context.read(loginStateManagerProvider).logout;
    final confirmationDialog = ConfirmationDialog();

    return showModal(
      context: context,
      builder: (context) {
        signOut() {
          logout(context).then((value) {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return TokenLoginScreen();
                },
              ),
            );
          });
        }

        return TargetedPlatform().isIOS()
            ? confirmationDialog.iOSAlertDialog(
                context, kSignOutAlertDialog, signOut, 'Sign out')
            : confirmationDialog.androidAlertDialog(
                context, kSignOutAlertDialog, signOut, 'Sign out');
      },
    );
  }

  aboutAppDialog(BuildContext context) async {
    final confirmationDialog = ConfirmationDialog();

    launchUrl() async {
      await launch(kGithubRepoURL).catchError((error, stackTrace) {
        throw Fluttertoast.showToast(
          msg: error.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
        );
      });
      Navigator.pop(context);
    }

    showModal(
      context: context,
      builder: (context) {
        return TargetedPlatform().isIOS()
            ? confirmationDialog.iOSAlertDialog(context, kAboutAppText,
                launchUrl, 'About App', 'Visit Github', 'Cancel')
            : confirmationDialog.androidAlertDialog(context, kAboutAppText,
                launchUrl, 'About App', 'Visit Github', 'Cancel');
      },
    );
  }
}
