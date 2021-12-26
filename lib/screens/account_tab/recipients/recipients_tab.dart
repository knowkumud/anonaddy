import 'package:anonaddy/shared_components/list_tiles/recipient_list_tile.dart';
import 'package:anonaddy/shared_components/lottie_widget.dart';
import 'package:anonaddy/shared_components/shimmer_effects/recipients_shimmer_loading.dart';
import 'package:anonaddy/state_management/recipient/recipient_tab_notifier.dart';
import 'package:anonaddy/state_management/recipient/recipient_tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipientsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final recipientTabState = watch(recipientTabStateNotifier);

    final size = MediaQuery.of(context).size;

    switch (recipientTabState.status) {
      case RecipientTabStatus.loading:
        return RecipientsShimmerLoading();

      case RecipientTabStatus.loaded:
        final recipientList = recipientTabState.recipients!;
        if (recipientList.isEmpty)
          return Center(
            child: Text('No recipients found',
                style: Theme.of(context).textTheme.bodyText1),
          );
        else
          return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: size.height * 0.004),
            itemCount: recipientList.length,
            itemBuilder: (context, index) {
              return RecipientListTile(recipient: recipientList[index]);
            },
          );

      case RecipientTabStatus.failed:
        final error = recipientTabState.errorMessage;
        return LottieWidget(
          showLoading: true,
          lottie: 'assets/lottie/errorCone.json',
          lottieHeight: size.height * 0.1,
          label: error.toString(),
        );
    }
  }
}