import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Labeled numeric input row used across all calculator screens.
///
/// Previously `class Continar` in lib/view/wedget/CustomContinar.dart.
/// Renamed to NumberInputField — a more descriptive name.
class NumberInputField extends StatelessWidget {
  NumberInputField({
    super.key,
    required this.title,
    required this.hintText,
    this.onChanged,
  });

  final String title;
  final String hintText;
  final ValueChanged<String>? onChanged;

  static double emailRegex = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: TextFormField(
                    style: const TextStyle(color: AppColors.textWhite),
                    keyboardType: TextInputType.number,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: AppColors.inputBorder, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: AppColors.inputBorder, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      border: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.black, width: 2),
                      ),
                      hintText: hintText,
                      hintStyle:
                          const TextStyle(color: AppColors.textWhite),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لا يمكن أن يكون الحقل فارغًا';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
