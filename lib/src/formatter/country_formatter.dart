import 'package:flutter/services.dart';

class CountryFormatter extends TextInputFormatter {
  final int? maxLength;

  const CountryFormatter({this.maxLength});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    bool isHasLetter = newValue.text.contains(RegExp(r'[!-\-:-ÿ]'));
    if (isHasLetter) return oldValue;
    if (maxLength != null && newValue.text.length > maxLength!) {
      return oldValue;
    }

    return newValue;
  }
}
