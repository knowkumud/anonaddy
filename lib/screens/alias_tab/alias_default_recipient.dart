import 'package:anonaddy/models/alias/alias_data_model.dart';
import 'package:anonaddy/models/recipient/recipient_data_model.dart';
import 'package:anonaddy/screens/more_tab/more_tab.dart';
import 'package:anonaddy/state_management/alias_state_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants.dart';

class AliasDefaultRecipientScreen extends StatefulWidget {
  const AliasDefaultRecipientScreen(this.aliasDataModel);

  final AliasDataModel aliasDataModel;

  @override
  _AliasDefaultRecipientScreenState createState() =>
      _AliasDefaultRecipientScreenState();
}

class _AliasDefaultRecipientScreenState
    extends State<AliasDefaultRecipientScreen> {
  final _verifiedRecipients = <RecipientDataModel>[];
  final _defaultRecipients = <RecipientDataModel>[];
  final _selectedRecipientsID = <String>[];

  void _toggleRecipient(RecipientDataModel verifiedRecipient) {
    if (_defaultRecipients.contains(verifiedRecipient)) {
      _defaultRecipients
          .removeWhere((element) => element.email == verifiedRecipient.email);
      _selectedRecipientsID
          .removeWhere((element) => element == verifiedRecipient.id);
    } else {
      _defaultRecipients.add(verifiedRecipient);
      _selectedRecipientsID.add(verifiedRecipient.id);
    }
  }

  bool _isDefaultRecipient(RecipientDataModel verifiedRecipient) {
    for (RecipientDataModel defaultRecipient in _defaultRecipients) {
      if (defaultRecipient.email == verifiedRecipient.email) {
        return true;
      }
    }
    return false;
  }

  void _setVerifiedRecipients() {
    final allRecipients = context.read(recipientStreamProvider).data.value;
    for (RecipientDataModel recipient in allRecipients.recipientDataList) {
      if (recipient.emailVerifiedAt != null) {
        _verifiedRecipients.add(recipient);
      }
    }
  }

  void _setDefaultRecipients() {
    final aliasDefaultRecipients = widget.aliasDataModel.recipients;
    for (RecipientDataModel verifiedRecipient in _verifiedRecipients) {
      for (RecipientDataModel recipient in aliasDefaultRecipients) {
        if (recipient.email == verifiedRecipient.email) {
          _defaultRecipients.add(recipient);
          _selectedRecipientsID.add(recipient.id);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _setVerifiedRecipients();
    _setDefaultRecipients();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Divider(
          thickness: 3,
          indent: size.width * 0.4,
          endIndent: size.width * 0.4,
        ),
        SizedBox(height: size.height * 0.01),
        Text(
          ' Update Alias Recipients',
          style: Theme.of(context).textTheme.headline6,
        ),
        Divider(thickness: 1),
        SizedBox(height: size.height * 0.01),
        Text(kUpdateAliasRecipients),
        SizedBox(height: size.height * 0.01),
        if (_verifiedRecipients.isEmpty)
          Padding(
            padding: EdgeInsets.all(20),
            child: Text('No recipients found',
                style: Theme.of(context).textTheme.headline6),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            itemCount: _verifiedRecipients.length,
            itemBuilder: (context, index) {
              final verifiedRecipient = _verifiedRecipients[index];

              return Padding(
                padding: EdgeInsets.all(2),
                child: ListTile(
                  selected: _isDefaultRecipient(verifiedRecipient),
                  selectedTileColor: kBlueNavyColor,
                  horizontalTitleGap: 0,
                  title: Text(verifiedRecipient.email),
                  onTap: () {
                    setState(() {
                      _toggleRecipient(verifiedRecipient);
                    });
                  },
                ),
              );
            },
          ),
        SizedBox(height: size.height * 0.02),
        RaisedButton(
          child: Text('Update Recipients'),
          onPressed: () => context
              .read(aliasStateManagerProvider)
              .updateAliasDefaultRecipient(
                context,
                widget.aliasDataModel.aliasID,
                _selectedRecipientsID,
              ),
        ),
      ],
    );
  }
}
