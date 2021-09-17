import 'package:anonaddy/models/alias/alias_model.dart';
import 'package:anonaddy/screens/alias_tab/alias_detailed_screen.dart';
import 'package:anonaddy/services/data_storage/search_history_storage.dart';
import 'package:anonaddy/shared_components/constants/ui_strings.dart';
import 'package:anonaddy/shared_components/custom_page_route.dart';
import 'package:anonaddy/shared_components/list_tiles/alias_list_tile.dart';
import 'package:anonaddy/shared_components/lottie_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../global_providers.dart';

class SearchService extends SearchDelegate {
  SearchService(this.searchAliasList);
  List<Alias> searchAliasList;

  void _searchAliases(List<Alias> resultsList) {
    searchAliasList.forEach((element) {
      final filterByEmail =
          element.email.toLowerCase().contains(query.toLowerCase());

      if (element.description == null) {
        if (filterByEmail) {
          resultsList.add(element);
        }
      } else {
        final filterByDescription =
            element.description!.toLowerCase().contains(query.toLowerCase());

        if (filterByEmail || filterByDescription) {
          resultsList.add(element);
        }
      }
    });
  }

  Widget _buildResult(List<Alias> resultsList) {
    if (query.isEmpty)
      return Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 20),
        child: Text(kSearchAliasByEmailOrDesc),
      );
    else if (resultsList.isEmpty)
      return LottieWidget(
        lottie: 'assets/lottie/empty.json',
        lottieHeight: 150,
      );
    else
      return ListView.builder(
        itemCount: resultsList.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: IgnorePointer(
              child: AliasListTile(aliasData: resultsList[index]),
            ),
            onTap: () {
              SearchHistoryStorage.getAliasBoxes().add(resultsList[index]);
              Navigator.push(context,
                  CustomPageRoute(AliasDetailScreen(resultsList[index])));
            },
          );
        },
      );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query.isEmpty
          ? Container()
          : IconButton(icon: Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final resultsList = <Alias>[];

    _searchAliases(resultsList);
    return _buildResult(resultsList);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final resultsList = <Alias>[];

    _searchAliases(resultsList);
    return _buildResult(resultsList);
  }
}
