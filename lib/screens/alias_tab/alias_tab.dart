import 'package:anonaddy/screens/alias_tab/components/alias_animated_list.dart';
import 'package:anonaddy/screens/alias_tab/components/alias_shimmer_loading.dart';
import 'package:anonaddy/screens/alias_tab/components/alias_tab_pie_chart.dart';
import 'package:anonaddy/screens/alias_tab/components/empty_list_alias_tab.dart';
import 'package:anonaddy/shared_components/constants/app_colors.dart';
import 'package:anonaddy/shared_components/constants/lottie_images.dart';
import 'package:anonaddy/shared_components/list_tiles/alias_list_tile.dart';
import 'package:anonaddy/shared_components/lottie_widget.dart';
import 'package:anonaddy/shared_components/platform_aware_widgets/platform_scroll_bar.dart';
import 'package:anonaddy/state_management/alias_state/alias_tab_notifier.dart';
import 'package:anonaddy/state_management/alias_state/alias_tab_state.dart';
import 'package:anonaddy/state_management/alias_state/fab_visibility_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AliasTab extends ConsumerStatefulWidget {
  const AliasTab({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _AlisTabState();
}

class _AlisTabState extends ConsumerState<AliasTab> {
  @override
  void initState() {
    super.initState();

    /// Initially, get data from disk (secure device storage) and assign it
    ref.read(aliasTabStateNotifier.notifier).loadOfflineState();

    /// Fetch the latest Aliases data from server
    ref.read(aliasTabStateNotifier.notifier).fetchAliases();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: const Key('aliasTabScaffold'),

      /// [DefaultTabController] is required when using [TabBar]s without
      /// a custom [TabController]
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          key: const Key('aliasTabScrollView'),
          controller:
              ref.read(fabVisibilityStateNotifier.notifier).aliasController,
          headerSliverBuilder: (_, __) {
            return [
              SliverAppBar(
                key: const Key('aliasTabAppBar'),
                expandedHeight: size.height * 0.25,
                elevation: 0,
                floating: true,
                pinned: true,
                flexibleSpace: const FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: AliasTabPieChart(key: Key('aliasTabPieChart')),
                ),
                bottom: const TabBar(
                  key: Key('aliasTabTabBar'),
                  indicatorColor: AppColors.accentColor,
                  tabs: [
                    Tab(
                      key: Key('aliasTabAvailableAliasesTab'),
                      child: Text('Available Aliases'),
                    ),
                    Tab(
                      key: Key('aliasTabDeletedAliasesTab'),
                      child: Text('Deleted Aliases'),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: Consumer(
            builder: (_, ref, __) {
              final aliasTabState = ref.watch(aliasTabStateNotifier);

              switch (aliasTabState.status) {

                /// When AliasTab is fetching data (loading)
                case AliasTabStatus.loading:
                  return const TabBarView(
                    key: Key('aliasTabTabBarView'),
                    children: [
                      AliasShimmerLoading(),
                      AliasShimmerLoading(),
                    ],
                  );

                /// When AliasTab has loaded and has data to display
                case AliasTabStatus.loaded:
                  final availableAliasList = aliasTabState.availableAliasList;
                  final deletedAliasList = aliasTabState.deletedAliasList;

                  return TabBarView(
                    children: [
                      /// Available aliases list
                      RefreshIndicator(
                        color: AppColors.accentColor,
                        displacement: 20,
                        onRefresh: () async {
                          await ref
                              .read(aliasTabStateNotifier.notifier)
                              .refreshAliases();
                        },
                        child: availableAliasList.isEmpty
                            ? const EmptyListAliasTabWidget()
                            : PlatformScrollbar(
                                child: AliasAnimatedList(
                                  listKey: aliasTabState.availableListKey,
                                  itemCount: availableAliasList.length,
                                  itemBuilder: (context, index) {
                                    return AliasListTile(
                                      aliasData: availableAliasList[index],
                                    );
                                  },
                                ),
                              ),
                      ),

                      /// Deleted aliases list
                      RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(aliasTabStateNotifier.notifier)
                              .refreshAliases();
                        },
                        child: deletedAliasList.isEmpty
                            ? const EmptyListAliasTabWidget()
                            : PlatformScrollbar(
                                child: ListView.builder(
                                  itemCount: deletedAliasList.length,
                                  itemBuilder: (context, index) {
                                    return AliasListTile(
                                      aliasData: deletedAliasList[index],
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  );

                /// When AliasTab has failed and has an error message
                case AliasTabStatus.failed:
                  final error = aliasTabState.errorMessage!;
                  return TabBarView(
                    children: [
                      LottieWidget(
                        lottie: LottieImages.errorCone,
                        label: error.toString(),
                        lottieHeight: size.height * 0.2,
                      ),
                      LottieWidget(
                        lottie: LottieImages.errorCone,
                        label: error.toString(),
                        lottieHeight: size.height * 0.2,
                      ),
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
