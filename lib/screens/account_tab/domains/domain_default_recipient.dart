import 'package:anonaddy/models/domain/domain_model.dart';
import 'package:anonaddy/models/recipient/recipient.dart';
import 'package:anonaddy/shared_components/bottom_sheet_header.dart';
import 'package:anonaddy/shared_components/constants/material_constants.dart';
import 'package:anonaddy/shared_components/constants/official_anonaddy_strings.dart';
import 'package:anonaddy/shared_components/constants/ui_strings.dart';
import 'package:anonaddy/state_management/domains/domains_screen_notifier.dart';
import 'package:anonaddy/state_management/recipient/recipient_tab_notifier.dart';
import 'package:anonaddy/state_management/recipient/recipient_tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DomainDefaultRecipient extends StatefulWidget {
  const DomainDefaultRecipient(this.domain);

  final Domain domain;

  @override
  _DomainDefaultRecipientState createState() => _DomainDefaultRecipientState();
}

class _DomainDefaultRecipientState extends State<DomainDefaultRecipient> {
  final _verifiedRecipients = <Recipient>[];
  Recipient? selectedRecipient;

  late double initialChildSize;
  late double maxChildSize;

  void _toggleRecipient(Recipient verifiedRecipient) {
    if (selectedRecipient == null) {
      selectedRecipient = verifiedRecipient;
    } else {
      if (verifiedRecipient.email == selectedRecipient!.email) {
        selectedRecipient = null;
      } else {
        selectedRecipient = verifiedRecipient;
      }
    }
  }

  bool _isDefaultRecipient(Recipient verifiedRecipient) {
    if (selectedRecipient == null) {
      return false;
    } else {
      if (verifiedRecipient.email == selectedRecipient!.email) {
        return true;
      }
      return false;
    }
  }

  void _setVerifiedRecipients() {
    final recipientTabState = context.read(recipientTabStateNotifier);
    if (recipientTabState.status == RecipientTabStatus.loaded) {
      final allRecipients = recipientTabState.recipients!;
      for (Recipient recipient in allRecipients) {
        if (recipient.emailVerifiedAt != null) {
          _verifiedRecipients.add(recipient);
        }
      }
    }
  }

  void _setDefaultRecipient() {
    final defaultRecipient = widget.domain.defaultRecipient;
    for (Recipient verifiedRecipient in _verifiedRecipients) {
      if (defaultRecipient == null) {
        selectedRecipient = null;
      } else {
        if (defaultRecipient.email == verifiedRecipient.email) {
          selectedRecipient = verifiedRecipient;
        }
      }
    }
  }

  void _setScrollSheetSizes() {
    setState(() {
      if (_verifiedRecipients.length <= 3) {
        initialChildSize = 0.5;
        maxChildSize = 0.6;
      } else if (_verifiedRecipients.length > 3 &&
          _verifiedRecipients.length <= 6) {
        initialChildSize = 0.55;
        maxChildSize = 0.7;
      } else {
        initialChildSize = 0.7;
        maxChildSize = 0.9;
      }
    });
  }

  Future<void> updateDefaultRecipient() async {
    await context
        .read(domainsScreenStateNotifier.notifier)
        .updateDomainDefaultRecipients(
          widget.domain.id,
          selectedRecipient == null ? '' : selectedRecipient!.id,
        );
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _setVerifiedRecipients();
    _setDefaultRecipient();
    _setScrollSheetSizes();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialChildSize,
      minChildSize: initialChildSize,
      maxChildSize: maxChildSize,
      builder: (context, controller) {
        return Stack(
          children: [
            ListView(
              controller: controller,
              children: [
                Column(
                  children: [
                    BottomSheetHeader(headerLabel: 'Update Default Recipient'),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          Text(kUpdateDomainDefaultRecipient),
                          SizedBox(height: size.height * 0.01),
                          Consumer(
                            builder: (_, watch, __) {
                              final isLoading =
                                  watch(domainsScreenStateNotifier)
                                      .updateRecipientLoading!;
                              return isLoading
                                  ? LinearProgressIndicator(color: kAccentColor)
                                  : Divider(height: 0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                if (_verifiedRecipients.isEmpty)
                  Center(
                    child: Text(
                      'No recipients found',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _verifiedRecipients.length,
                    itemBuilder: (context, index) {
                      final verifiedRecipient = _verifiedRecipients[index];
                      return ListTile(
                        selected: _isDefaultRecipient(verifiedRecipient),
                        selectedTileColor: kAccentColor,
                        horizontalTitleGap: 0,
                        title: Text(
                          verifiedRecipient.email,
                          style: TextStyle(
                            color: _isDefaultRecipient(verifiedRecipient)
                                ? Colors.black
                                : Theme.of(context).textTheme.bodyText1!.color,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _toggleRecipient(verifiedRecipient);
                          });
                        },
                      );
                    },
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(height: 0),
                      SizedBox(height: size.height * 0.01),
                      Text(kUpdateAliasRecipientNote),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.1),
              ],
            ),
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                child: Text('Update Default Recipients'),
                onPressed: () => updateDefaultRecipient(),
              ),
            ),
          ],
        );
      },
    );
  }
}