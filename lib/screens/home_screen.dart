import 'package:anonaddy/constants.dart';
import 'package:anonaddy/provider/api_data_manager.dart';
import 'package:anonaddy/screens/profile_screen.dart';
import 'package:anonaddy/screens/settings_screen.dart';
import 'package:anonaddy/widgets/account_card.dart';
import 'package:anonaddy/widgets/alias_card.dart';
import 'package:anonaddy/widgets/alias_list_tile.dart';
import 'package:anonaddy/widgets/create_alias_dialog.dart';
import 'package:anonaddy/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Future future;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final apiDataManager = Provider.of<APIDataManager>(context, listen: false);

    Future<void> _refreshData() async {
      return await apiDataManager.fetchData();
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kBackgroundColor,
        appBar: buildAppBar(),
        floatingActionButton: buildFloatingActionButton(),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder(
            future: _refreshData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Consumer<APIDataManager>(
                  builder: (_, __, ___) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Column(
                        children: [
                          AccountCard(
                            username: apiDataManager.username,
                            id: apiDataManager.id,
                            subscription: apiDataManager.subscription,
                            bandwidth: apiDataManager.bandwidth,
                            bandwidthLimit: apiDataManager.bandwidthLimit,
                          ),
                          AliasCard(
                            aliasCount: apiDataManager.aliasCount,
                            aliasLimit: apiDataManager.aliasLimit,
                            child: Container(
                              height: size.height * 0.6,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                itemCount: apiDataManager.aliasList.length,
                                itemBuilder: (context, index) {
                                  return AliasListTile(
                                    email:
                                        apiDataManager.aliasList[index].email,
                                    emailDescription: apiDataManager
                                        .aliasList[index].emailDescription,
                                    switchOnPress: (toggle) {},
                                    switchValue: apiDataManager
                                        .aliasList[index].isAliasActive,
                                    listTileOnPress: () {},
                                    editOnPress: () {},
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return LoadingWidget();
              }
            },
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: kAppBarColor,
      // title: Image.asset('assets/images/logo-dark.svg'),
      leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileScreen()));
          }),
      actions: [
        IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            }),
      ],
    );
  }

  FloatingActionButton buildFloatingActionButton() {
    String textFieldInput;
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return CreateAliasDialog(
                format: 'UUID',
                domain: 'anonaddy.me',
                textFieldOnChanged: (input) {
                  textFieldInput = input;
                },
                buttonOnPress: () {
                  APIDataManager().createNewAlias(description: textFieldInput);
                  Navigator.pop(context);
                },
              );
            });
      },
    );
  }
}
