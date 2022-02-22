import 'package:anonaddy/shared_components/bottom_sheet_header.dart';
import 'package:anonaddy/shared_components/constants/addymanager_string.dart';
import 'package:anonaddy/shared_components/constants/app_colors.dart';
import 'package:anonaddy/shared_components/platform_aware_widgets/platform_button.dart';
import 'package:anonaddy/shared_components/platform_aware_widgets/platform_input_field.dart';
import 'package:flutter/material.dart';

class UpdateDescriptionWidget extends StatelessWidget {
  const UpdateDescriptionWidget({
    Key? key,
    required this.description,
    required this.descriptionFormKey,
    required this.inputOnChanged,
    required this.updateDescription,
    required this.removeDescription,
  }) : super(key: key);

  final String? description;
  final GlobalKey descriptionFormKey;
  final Function(String)? inputOnChanged;
  final Function() updateDescription;
  final Function() removeDescription;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHeader(
              headerLabel: AddyManagerString.updateDescriptionTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(AddyManagerString.updateDescriptionString),
                SizedBox(height: size.height * 0.02),
                Form(
                  key: descriptionFormKey,
                  child: PlatformInputField(
                    placeholder: description ?? 'No description',
                    onChanged: inputOnChanged,
                    onFieldSubmitted: (toggle) => updateDescription(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: PlatformButton(
                        color: Colors.redAccent,
                        child: const Text(
                          AddyManagerString.removeDescriptionTitle,
                          style: TextStyle(color: Colors.black),
                        ),
                        onPress: removeDescription,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: PlatformButton(
                        color: AppColors.accentColor,
                        child: const Text(
                          AddyManagerString.updateDescriptionTitle,
                          style: TextStyle(color: Colors.black),
                        ),
                        onPress: updateDescription,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
