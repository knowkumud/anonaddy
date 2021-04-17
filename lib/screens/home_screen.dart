import 'package:anonaddy/screens/search_tab/search_tab.dart';
import 'package:anonaddy/screens/settings_screen/settings_screen.dart';
import 'package:anonaddy/services/connectivity/connectivity_service.dart';
import 'package:anonaddy/shared_components/constants/material_constants.dart';
import 'package:anonaddy/shared_components/custom_page_route.dart';
import 'package:anonaddy/shared_components/no_internet_alert.dart';
import 'package:anonaddy/state_management/providers/class_providers.dart';
import 'package:anonaddy/state_management/providers/global_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'account_tab/account_tab.dart';
import 'alias_tab/alias_tab.dart';
import 'alias_tab/create_new_alias.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  void _selectedTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void checkIfAppUpdated() {
    context.read(changelogServiceProvider).isAppUpdated().then((value) {
      print(value.toString() * 100);
      if (value) buildUpdateNews(context);
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfAppUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer(
      builder: (_, watch, __) {
        final connectivityAsyncValue = watch(connectivityStreamProvider);
        bool isOffline = false;

        connectivityAsyncValue.whenData((data) {
          if (data == ConnectionStatus.offline) {
            isOffline = true;
          } else {
            isOffline = false;
          }
        });
        return Scaffold(
          appBar: buildAppBar(context, isOffline),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              AccountTab(),
              AliasTab(),
              SearchTab(),
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isOffline ? NoInternetAlert() : Container(),
              BottomNavigationBar(
                onTap: _selectedTab,
                currentIndex: _selectedIndex,
                selectedItemColor: isDark ? kAccentColor : kBlueNavyColor,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                    label: 'Account',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.alternate_email_sharp),
                    label: 'Aliases',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    label: 'Search',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildAppBar(BuildContext context, bool isOffline) {
    return AppBar(
      elevation: 0,
      title: Text('AddyManager', style: TextStyle(color: Colors.white)),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.add_circle_outline_outlined),
        onPressed: isOffline
            ? () => Fluttertoast.showToast(
                  msg: 'Can not create alias while offline',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.grey[600],
                )
            : () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 0, bottom: 20),
                      child: CreateNewAlias(),
                    );
                  },
                );
              },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () =>
              Navigator.push(context, CustomPageRoute(SettingsScreen())),
        ),
      ],
    );
  }

  Future buildUpdateNews(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return Container(
          height: size.height * 0.5,
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What\'s new?',
                style: Theme.of(context).textTheme.headline6,
              ),
              Consumer(
                builder: (_, watch, __) {
                  final appInfo = watch(packageInfoProvider);
                  return appInfo.when(
                    data: (data) => Text('Version: ${data.version}'),
                    loading: () => CircularProgressIndicator(),
                    error: (error, stackTrace) => Text(error.toString()),
                  );
                },
              ),
              Divider(height: size.height * 0.05),
              //todo automate changelog fetching
              Text('1. Added this widget'),
              SizedBox(height: size.height * 0.01),
              Text('2. Lots of under the hood improvements'),
              SizedBox(height: size.height * 0.01),
              Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(),
                  child: Text('Continue to AddyManager'),
                  onPressed: () {
                    context.read(changelogServiceProvider).markAppUpdated();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
