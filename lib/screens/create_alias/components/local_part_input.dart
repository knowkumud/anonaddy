import 'package:anonaddy/notifiers/create_alias/create_alias_notifier.dart';
import 'package:anonaddy/screens/create_alias/components/create_alias_card.dart';
import 'package:anonaddy/services/theme/theme.dart';
import 'package:anonaddy/shared_components/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalPartInput extends ConsumerWidget {
  const LocalPartInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateAliasCard(
      header: 'Local Part',
      subHeader: '',
      showIcon: false,
      child: TextFormField(
        onChanged: (input) =>
            ref.read(createAliasStateNotifier.notifier).setLocalPart(input),
        textInputAction: TextInputAction.next,
        decoration: AppTheme.kTextFormFieldDecoration.copyWith(
          hintText: AppStrings.localPartFieldHint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
