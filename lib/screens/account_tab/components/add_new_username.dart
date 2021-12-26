import 'package:anonaddy/shared_components/bottom_sheet_header.dart';
import 'package:anonaddy/shared_components/constants/material_constants.dart';
import 'package:anonaddy/shared_components/constants/official_anonaddy_strings.dart';
import 'package:anonaddy/state_management/usernames/usernames_screen_notifier.dart';
import 'package:anonaddy/utilities/form_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewUsername extends StatefulWidget {
  @override
  State<AddNewUsername> createState() => _AddNewUsernameState();
}

class _AddNewUsernameState extends State<AddNewUsername> {
  final _textEditController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _textEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Future<void> createUsername() async {
      if (_formKey.currentState!.validate()) {
        await context
            .read(usernamesScreenStateNotifier.notifier)
            .createNewUsername(_textEditController.text.trim());
        Navigator.pop(context);
      }
    }

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHeader(headerLabel: 'Add New Username'),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 10),
            child: Column(
              children: [
                Text(kAddNewUsernameString),
                SizedBox(height: size.height * 0.02),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    autofocus: true,
                    controller: _textEditController,
                    validator: (input) =>
                        FormValidator.validateUsernameInput(input!),
                    onFieldSubmitted: (toggle) => createUsername(),
                    decoration: kTextFormFieldDecoration.copyWith(
                      hintText: 'johndoe',
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                ElevatedButton(
                  style: ElevatedButton.styleFrom().copyWith(
                    minimumSize: MaterialStateProperty.all(Size(200, 50)),
                  ),
                  child: Text('Add Username'),
                  onPressed: () => createUsername(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}