import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_number_field/src/formatter/country_formatter.dart';
import 'package:phone_number_field/src/formatter/mask_input_formatter.dart';
import 'package:phone_number_field/src/model/country.dart';

import '../mixin/country_mixin.dart';

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    this.onCountrySelected,
    this.initialCountry,
    this.label,
    this.borderColor,
    this.focusColor,
  });

  /// Called when the user selects a country.
  final ValueChanged<Country?>? onCountrySelected;
  final Country? initialCountry;

  /// The label displayed above the text field.
  final String? label;

  ///This color is used to colorize the border when the text field is focused. defaults to [Theme.of(context).colorScheme.primary]
  final Color? focusColor;

  ///This color is used to colorize the border when the text field is not focused. defaults to [Theme.of(context).inputDecorationTheme.border?.borderSide.color]
  final Color? borderColor;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> with CountryMixin {
  late FocusNode _codeFocusNode;
  late FocusNode _numberFocusNode;

  late TextEditingController _codeController;
  late TextEditingController _numberController;

  final ValueNotifier<Country?> _selectedCountry = ValueNotifier(null);

  final ValueNotifier<bool> _isFocused = ValueNotifier(false);

  void _onCountrySelectListener() {
    widget.onCountrySelected?.call(_selectedCountry.value);
  }

  void _focusListener() {
    _isFocused.value = _codeFocusNode.hasFocus || _numberFocusNode.hasFocus;
  }

  @override
  void initState() {
    _codeFocusNode = FocusNode()
      ..requestFocus()
      ..addListener(_focusListener);
    _numberFocusNode = FocusNode()..addListener(_focusListener);
    _codeController = TextEditingController();
    _numberController = TextEditingController();
    getCountries();
    _selectedCountry.addListener(_onCountrySelectListener);
    if (widget.initialCountry != null) {
      _selectedCountry.value = widget.initialCountry;
    }
    super.initState();
  }

  @override
  void dispose() {
    _codeFocusNode
      ..removeListener(_focusListener)
      ..dispose();
    _numberFocusNode
      ..removeListener(_focusListener)
      ..dispose();
    _codeController.dispose();
    _numberController.dispose();
    _selectedCountry.removeListener(_onCountrySelectListener);
    _selectedCountry.dispose();
    _isFocused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, ctc) {
        var maxWidth = ctc.maxWidth;
        return ValueListenableBuilder(
          valueListenable: _isFocused,
          builder: (_, value, _) {
            return CustomPaint(
              painter: _PhoneNumberFieldBorderPainter(
                label: widget.label,
                color: value
                    ? (widget.focusColor ?? Theme.of(context).colorScheme.primary)
                    : (widget.borderColor ??
                          Theme.of(context).inputDecorationTheme.border?.borderSide.color),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      focusNode: _codeFocusNode,
                      decoration: _InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text('+'),
                        ),
                        suffixIcon: CustomPaint(
                          painter: _VerticalDividerPainter(),
                          child: Text(''),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        _selectedCountry.value = findCountryCode(value);

                        if (value.length >= 2 && _selectedCountry.value != null) {
                          _codeController.text = _selectedCountry.value!.code;

                          FocusScope.of(context).requestFocus(_numberFocusNode);
                          return;
                        }

                        if (value.length >= 4) {
                          _selectedCountry.value ??= findCountryStartWith(value);
                          if (_selectedCountry.value != null) {
                            _codeController.text = _selectedCountry.value!.code;
                            _numberController.text = value.replaceFirst(
                              _selectedCountry.value!.code,
                              '',
                            );
                            widget.onCountrySelected?.call(_selectedCountry.value!);
                          }
                          FocusScope.of(context).requestFocus(_numberFocusNode);
                        }
                      },
                      inputFormatters: [CountryFormatter(maxLength: 4)],
                    ),
                  ),
                  KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (value) {
                      if (value.logicalKey == LogicalKeyboardKey.backspace &&
                          _numberController.text.isEmpty) {
                        FocusScope.of(context).requestFocus(_codeFocusNode);
                      }
                    },
                    child: SizedBox(
                      width: maxWidth * .75,
                      child: ValueListenableBuilder(
                        valueListenable: _selectedCountry,
                        builder: (context, value, child) => TextFormField(
                          controller: _numberController,
                          focusNode: _numberFocusNode,
                          keyboardType: TextInputType.phone,
                          decoration: _InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 16),
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              FocusScope.of(context).requestFocus(_codeFocusNode);
                            }
                          },
                          inputFormatters: [
                            CountryFormatter(),
                            if (value != null && value.format != null && value.format!.isNotEmpty)
                              MaskTextInputFormatter(
                                mask: value.format,
                                filter: {'X': RegExp(r'[0-9]')},
                                initialText: _numberController.text,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PhoneNumberFieldBorderPainter extends CustomPainter {
  final Color? color;
  final String? label;
  final double radius;
  final bool isLabelInside;

  _PhoneNumberFieldBorderPainter({
    this.label,
    this.color,
    this.radius = 8,
    this.isLabelInside = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;

    final textSpan = TextSpan(
      text: label,
      style: TextStyle(color: color, fontSize: 12),
    );

    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();

    final labelOffset = isLabelInside
        ? Offset(14, rect.height / 3 - textPainter.height)
        : Offset(14, -textPainter.height / 2);
    final labelWidth = textPainter.width;

    final borderPaint = Paint()
      ..color = color ?? Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();

    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;

    path.moveTo(left + radius, top);
    path.lineTo(isLabelInside || label == null ? rect.center.dx : labelOffset.dx, top);

    path.moveTo(labelOffset.dx + labelWidth + 4, top);
    path.lineTo(right - radius, top);

    path.arcToPoint(Offset(right, top + radius), radius: Radius.circular(radius));
    path.lineTo(right, bottom - radius);
    path.arcToPoint(Offset(right - radius, bottom), radius: Radius.circular(radius));

    path.lineTo(left + radius, bottom);
    path.arcToPoint(Offset(left, bottom - radius), radius: Radius.circular(radius));

    path.lineTo(left, top + radius);
    path.arcToPoint(Offset(left + radius, top), radius: Radius.circular(radius));

    canvas.drawPath(path, borderPaint);

    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InputDecoration extends InputDecoration {
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffix;
  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const _InputDecoration({
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.contentPadding,
    this.suffix,
  }) : super(
         border: InputBorder.none,
         focusedBorder: InputBorder.none,
         enabledBorder: InputBorder.none,
         errorBorder: InputBorder.none,
         disabledBorder: InputBorder.none,
         contentPadding: contentPadding,
         suffix: suffix,
         prefix: prefix,
         prefixIcon: prefixIcon,
         suffixIcon: suffixIcon,
         enabled: true,
         prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
         suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
       );
}

class _VerticalDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(rect.bottomCenter, rect.topCenter, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
