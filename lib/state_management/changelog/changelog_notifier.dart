import 'package:anonaddy/global_providers.dart';
import 'package:anonaddy/screens/home_screen_components/changelog_widget.dart';
import 'package:anonaddy/services/changelog_service/changelog_service.dart';
import 'package:anonaddy/shared_components/constants/material_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final changelogStateNotifier = StateNotifierProvider((ref) {
  return ChangelogNotifier(changelogService: ref.read(changelogService));
});

class ChangelogNotifier extends StateNotifier {
  ChangelogNotifier({required this.changelogService}) : super(null) {
    /// Check if app has updated
    changelogService.checkIfAppUpdated();
  }

  final ChangelogService changelogService;

  /// Show [ChangelogWidget] if app has been updated
  Future<void> showChangelogWidget(BuildContext context) async {
    final isUpdated = await changelogService.isAppUpdated();
    if (isUpdated) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(kBottomSheetBorderRadius)),
        ),
        builder: (context) => const ChangelogWidget(),
      );
    }
  }

  Future<void> markChangelogRead() async {
    await changelogService.markChangelogRead();
  }
}
