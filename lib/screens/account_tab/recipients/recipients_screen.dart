import 'package:anonaddy/models/alias/alias.dart';
import 'package:anonaddy/models/recipient/recipient.dart';
import 'package:anonaddy/shared_components/alias_created_at_widget.dart';
import 'package:anonaddy/shared_components/bottom_sheet_header.dart';
import 'package:anonaddy/shared_components/constants/material_constants.dart';
import 'package:anonaddy/shared_components/constants/official_anonaddy_strings.dart';
import 'package:anonaddy/shared_components/constants/ui_strings.dart';
import 'package:anonaddy/shared_components/list_tiles/alias_detail_list_tile.dart';
import 'package:anonaddy/shared_components/list_tiles/alias_list_tile.dart';
import 'package:anonaddy/shared_components/lottie_widget.dart';
import 'package:anonaddy/shared_components/pie_chart/alias_screen_pie_chart.dart';
import 'package:anonaddy/shared_components/platform_aware_widgets/dialogs/platform_alert_dialog.dart';
import 'package:anonaddy/shared_components/platform_aware_widgets/platform_aware.dart';
import 'package:anonaddy/shared_components/platform_aware_widgets/platform_loading_indicator.dart';
import 'package:anonaddy/shared_components/platform_aware_widgets/platform_switch.dart';
import 'package:anonaddy/state_management/recipient/recipient_screen_notifier.dart';
import 'package:anonaddy/state_management/recipient/recipient_screen_state.dart';
import 'package:anonaddy/utilities/form_validator.dart';
import 'package:anonaddy/utilities/niche_method.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class RecipientsScreen extends StatefulWidget {
  const RecipientsScreen({required this.recipient});
  final Recipient recipient;

  static const routeName = 'recipientDetailedScreen';

  @override
  State<RecipientsScreen> createState() => _RecipientsScreenState();
}

class _RecipientsScreenState extends State<RecipientsScreen> {
  int calculateTotal(List<int> list) {
    if (list.isEmpty) {
      return 0;
    } else {
      final total = list.reduce((value, element) => value + element);
      return total;
    }
  }

  @override
  void initState() {
    super.initState();
    context
        .read(recipientScreenStateNotifier.notifier)
        .fetchRecipient(widget.recipient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(context),
      body: Consumer(
        builder: (context, watch, _) {
          final recipientScreenState = watch(recipientScreenStateNotifier);

          switch (recipientScreenState.status) {
            case RecipientScreenStatus.loading:
              return Center(child: PlatformLoadingIndicator());

            case RecipientScreenStatus.loaded:
              return buildListView(context, recipientScreenState);

            case RecipientScreenStatus.failed:
              final error = recipientScreenState.errorMessage!;
              return LottieWidget(
                lottie: 'assets/lottie/errorCone.json',
                label: error,
              );
          }
        },
      ),
    );
  }

  Widget buildListView(
      BuildContext context, RecipientScreenState recipientScreenState) {
    final recipient = recipientScreenState.recipient!;

    final recipientProvider =
        context.read(recipientScreenStateNotifier.notifier);
    final size = MediaQuery.of(context).size;

    final List<int> forwardedList = [];
    final List<int> blockedList = [];
    final List<int> repliedList = [];
    final List<int> sentList = [];

    if (recipient.aliases != null) {
      for (Alias alias in recipient.aliases!) {
        forwardedList.add(alias.emailsForwarded);
        blockedList.add(alias.emailsBlocked);
        repliedList.add(alias.emailsReplied);
        sentList.add(alias.emailsSent);
      }
    }

    Future<void> toggleEncryption() async {
      return recipient.shouldEncrypt
          ? await recipientProvider.disableEncryption(recipient)
          : await recipientProvider.enableEncryption(recipient);
    }

    return ListView(
      children: [
        if (recipient.aliases == null || recipient.emailVerifiedAt == null)
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 40),
            child: SvgPicture.asset(
              'assets/images/envelope.svg',
              height: size.height * 0.22,
            ),
          )
        else
          AliasScreenPieChart(
            emailsForwarded: calculateTotal(forwardedList),
            emailsBlocked: calculateTotal(blockedList),
            emailsReplied: calculateTotal(repliedList),
            emailsSent: calculateTotal(sentList),
          ),
        Divider(height: size.height * 0.03),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.height * 0.01),
          child: Text('Actions', style: Theme.of(context).textTheme.headline6),
        ),
        AliasDetailListTile(
          leadingIconData: Icons.email_outlined,
          title: recipient.email,
          subtitle: 'Recipient Email',
          trailing: IconButton(icon: Icon(Icons.copy), onPressed: () {}),
          trailingIconOnPress: () => NicheMethod.copyOnTap(recipient.email),
        ),
        AliasDetailListTile(
          leadingIconData: Icons.fingerprint_outlined,
          title: recipient.fingerprint == null
              ? 'No fingerprint found'
              : '${recipient.fingerprint}',
          subtitle: 'GPG Key Fingerprint',
          trailing: recipient.fingerprint == null
              ? IconButton(
                  icon: Icon(Icons.add_circle_outline_outlined),
                  onPressed: () {})
              : IconButton(
                  icon: Icon(Icons.delete_outline_outlined, color: Colors.red),
                  onPressed: () {}),
          trailingIconOnPress: recipient.fingerprint == null
              ? () => buildAddPGPKeyDialog(context, recipient)
              : () => buildRemovePGPKeyDialog(context, recipient),
        ),
        AliasDetailListTile(
          leadingIconData:
              recipient.shouldEncrypt ? Icons.lock : Icons.lock_open,
          leadingIconColor: recipient.shouldEncrypt ? Colors.green : null,
          title: '${recipient.shouldEncrypt ? 'Encrypted' : 'Not Encrypted'}',
          subtitle: 'Encryption',
          trailing: recipient.fingerprint == null
              ? Container()
              : buildSwitch(recipientScreenState),
          trailingIconOnPress:
              recipient.fingerprint == null ? null : () => toggleEncryption(),
        ),
        recipient.emailVerifiedAt == null
            ? AliasDetailListTile(
                leadingIconData: Icons.verified_outlined,
                title: recipient.emailVerifiedAt == null ? 'No' : 'Yes',
                subtitle: 'Is Email Verified?',
                trailing:
                    TextButton(child: Text('Verify now!'), onPressed: () {}),
                trailingIconOnPress: () =>
                    recipientProvider.verifyEmail(recipient),
              )
            : Container(),
        if (recipient.aliases == null)
          Container()
        else if (recipient.emailVerifiedAt == null)
          buildUnverifiedEmailWarning(size)
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: size.height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.height * 0.01),
                child: Text('Aliases',
                    style: Theme.of(context).textTheme.headline6),
              ),
              SizedBox(height: size.height * 0.01),
              if (recipient.aliases!.isEmpty)
                Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.height * 0.01),
                    child: Text('No aliases found'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: recipient.aliases!.length,
                  itemBuilder: (context, index) {
                    return AliasListTile(
                      aliasData: recipient.aliases![index],
                    );
                  },
                ),
            ],
          ),
        Divider(height: size.height * 0.03),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AliasCreatedAtWidget(
              label: 'Created:',
              dateTime: recipient.createdAt,
            ),
            AliasCreatedAtWidget(
              label: 'Updated:',
              dateTime: recipient.updatedAt,
            ),
          ],
        ),
        SizedBox(height: size.height * 0.03),
      ],
    );
  }

  Row buildSwitch(RecipientScreenState recipientScreenState) {
    return Row(
      children: [
        recipientScreenState.isEncryptionToggleLoading!
            ? PlatformLoadingIndicator(size: 20)
            : Container(),
        PlatformSwitch(
          value: recipientScreenState.recipient!.shouldEncrypt,
          onChanged: (toggle) {},
        ),
      ],
    );
  }

  Container buildUnverifiedEmailWarning(Size size) {
    return Container(
      height: size.height * 0.05,
      width: double.infinity,
      color: Colors.amber,
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: Colors.black),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              kUnverifiedRecipientNote,
              style: TextStyle(color: Colors.black),
            ),
          ),
          Container(),
        ],
      ),
    );
  }

  void buildRemovePGPKeyDialog(BuildContext context, Recipient recipient) {
    PlatformAware.platformDialog(
      context: context,
      child: PlatformAlertDialog(
        title: 'Remove Public Key',
        content: kRemoveRecipientPublicKeyConfirmation,
        method: () async {
          await context
              .read(recipientScreenStateNotifier.notifier)
              .removePublicGPGKey(recipient);

          /// Dismisses this dialog
          Navigator.pop(context);
        },
      ),
    );
  }

  Future buildAddPGPKeyDialog(BuildContext context, Recipient recipient) {
    final formKey = GlobalKey<FormState>();

    String keyData = '';

    Future<void> addPublicKey() async {
      if (formKey.currentState!.validate()) {
        await context
            .read(recipientScreenStateNotifier.notifier)
            .addPublicGPGKey(recipient, keyData);
        Navigator.pop(context);
      }
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(kBottomSheetBorderRadius)),
      ),
      builder: (context) {
        final size = MediaQuery.of(context).size;

        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BottomSheetHeader(headerLabel: 'Add GPG Key'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Text(kAddPublicKeyNote),
                    SizedBox(height: size.height * 0.015),
                    Form(
                      key: formKey,
                      child: TextFormField(
                        autofocus: true,
                        validator: (input) =>
                            FormValidator.validatePGPKeyField(input!),
                        minLines: 4,
                        maxLines: 5,
                        textInputAction: TextInputAction.done,
                        onChanged: (input) => keyData = input,
                        onFieldSubmitted: (submit) => addPublicKey(),
                        decoration: kTextFormFieldDecoration.copyWith(
                          contentPadding: EdgeInsets.all(5),
                          hintText: kPublicKeyFieldHint,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      child: Text('Add Key'),
                      onPressed: () => addPublicKey(),
                    ),
                    SizedBox(height: size.height * 0.015),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar buildAppBar(BuildContext context) {
    void showDialog() {
      PlatformAware.platformDialog(
        context: context,
        child: PlatformAlertDialog(
          title: 'Delete Recipient',
          content: kDeleteRecipientConfirmation,
          method: () async {
            await context
                .read(recipientScreenStateNotifier.notifier)
                .removeRecipient(widget.recipient);

            /// Dismisses this dialog
            Navigator.pop(context);

            /// Dismisses [RecipientScreen] after recipient deletion
            Navigator.pop(context);
          },
        ),
      );
    }

    return AppBar(
      title: Text('Recipient', style: TextStyle(color: Colors.white)),
      leading: IconButton(
        icon: Icon(
          PlatformAware.isIOS() ? CupertinoIcons.back : Icons.arrow_back,
        ),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        PopupMenuButton(
          itemBuilder: (BuildContext context) {
            return ['Delete Recipient'].map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
          onSelected: (String choice) => showDialog(),
        ),
      ],
    );
  }
}